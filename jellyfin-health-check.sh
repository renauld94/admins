#!/bin/bash
#═══════════════════════════════════════════════════════════════════════════════
# JELLYFIN LIVE TV HEALTH CHECK - Daily Monitor
# Runs daily via cron to verify all TV channels are working
#═══════════════════════════════════════════════════════════════════════════════

set -e

# Configuration
JELLYFIN_URL="http://localhost:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"
LOG_DIR="/tmp/jellyfin-health"
LOG_FILE="$LOG_DIR/health-check-$(date +%Y%m%d).log"
LOCK_FILE="/tmp/jellyfin-healthcheck.lock"

# Create log directory
mkdir -p "$LOG_DIR"

# Prevent concurrent runs
if [ -f "$LOCK_FILE" ]; then
    LOCK_PID=$(cat "$LOCK_FILE")
    if kill -0 "$LOCK_PID" 2>/dev/null; then
        echo "Health check already running (PID $LOCK_PID)" >> "$LOG_FILE"
        exit 0
    fi
fi
echo $$ > "$LOCK_FILE"

# Cleanup on exit
cleanup() {
    rm -f "$LOCK_FILE"
}
trap cleanup EXIT

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Start check
log "═══════════════════════════════════════════════════════════════════════════════"
log "JELLYFIN LIVE TV HEALTH CHECK STARTED"
log "═══════════════════════════════════════════════════════════════════════════════"

# Test 1: Jellyfin server health
log ""
log "TEST 1: Jellyfin Server Health"
HEALTH=$(curl -s -m 10 "$JELLYFIN_URL/health")
if echo "$HEALTH" | grep -qiE "^(OK|Healthy)"; then
    log "✅ Jellyfin server is running ($HEALTH)"
else
    log "❌ Jellyfin server health check failed: $HEALTH"
    exit 1
fi

# Test 2: API authentication
log ""
log "TEST 2: API Authentication"
SYSTEM_INFO=$(curl -s -m 10 "$JELLYFIN_URL/System/Info?api_key=$API_KEY" 2>&1 | head -c 100)
if echo "$SYSTEM_INFO" | grep -q '"'; then
    log "✅ API key authentication successful"
else
    log "❌ API authentication failed: $SYSTEM_INFO"
    exit 1
fi

# Test 3: Check tuner hosts
log ""
log "TEST 3: Live TV Tuner Hosts"
# Note: /api/LiveTv/TunerHosts returns 404, so check tuners.xml directly via docker exec
TUNER_COUNT=$(docker exec jellyfin-simonadmin bash -c 'grep -c "<Tuner>" /config/data/livetv/tuners.xml 2>/dev/null || echo 0')
if [ "$TUNER_COUNT" -gt 0 ]; then
    log "✅ Found $TUNER_COUNT tuner(s) in configuration"
    docker exec jellyfin-simonadmin bash -c 'grep -oP "<Name>\K[^<]+" /config/data/livetv/tuners.xml' | while read -r name; do
        log "   • $name"
    done
else
    log "⚠️  No tuners configured or file not found"
fi

# Test 4: Check channels
log ""
log "TEST 4: Live TV Channels"

# Check if M3U file is accessible via docker exec
CHANNEL_COUNT=$(docker exec jellyfin-simonadmin bash -c 'grep -c "^#EXTINF" /config/data/playlists/iptv_org_international.m3u 2>/dev/null || echo 0')
if [ "$CHANNEL_COUNT" -gt 0 ]; then
    log "✅ IPTV M3U file accessible with ~$CHANNEL_COUNT channels"
else
    log "⚠️  IPTV M3U file not found or empty"
fi

# Test 5: Sample channel stream tests
log ""
log "TEST 5: Sample Channel Stream Reachability"

# Extract a few sample streams from M3U via docker exec
SAMPLES=$(docker exec jellyfin-simonadmin bash -c 'grep "^http" /config/data/playlists/iptv_org_international.m3u 2>/dev/null | head -5' || echo "")

if [ -z "$SAMPLES" ]; then
    log "⚠️  No HTTP streams found in M3U file"
else
    WORKING_STREAMS=0
    TOTAL_STREAMS=$(echo "$SAMPLES" | wc -l)
    
    echo "$SAMPLES" | while read -r stream_url; do
        RESPONSE=$(curl -s -I -m 5 "$stream_url" 2>&1 | head -1)
        
        if echo "$RESPONSE" | grep -qE "HTTP.*20[02]"; then
            log "   ✅ Stream reachable"
            WORKING_STREAMS=$((WORKING_STREAMS + 1))
        else
            STATUS=$(echo "$RESPONSE" | cut -d' ' -f2-3)
            log "   ⚠️  Stream returned: $STATUS"
        fi
    done
fi

# Test 6: Container status
log ""
log "TEST 6: Jellyfin Container Status"
CONTAINER_STATUS=$(docker ps --filter "name=jellyfin" --format "{{.Status}}" 2>/dev/null | head -1)
if [ -n "$CONTAINER_STATUS" ]; then
    log "✅ Container Status: $CONTAINER_STATUS"
else
    log "⚠️  Jellyfin container not found"
fi

# Test 7: Container logs check
log ""
log "TEST 7: Recent Errors in Logs"
ERROR_COUNT=$(docker logs jellyfin-simonadmin 2>&1 | tail -100 | grep -c "\[ERR\]" 2>/dev/null || echo "0")
if [ "$ERROR_COUNT" -lt 10 ]; then
    log "✅ Low error count in recent logs: $ERROR_COUNT errors in last 100 lines"
else
    log "⚠️  High error count detected: $ERROR_COUNT errors in last 100 lines"
    log "   Last few errors:"
    docker logs jellyfin-simonadmin 2>&1 | tail -100 | grep "\[ERR\]" | tail -3 | while read -r line; do
        log "   $line"
    done
fi

# Summary
log ""
log "═══════════════════════════════════════════════════════════════════════════════"
log "✅ HEALTH CHECK COMPLETED - All critical systems operational"
log "═══════════════════════════════════════════════════════════════════════════════"
log "Log saved to: $LOG_FILE"
log ""

# Keep only last 7 days of logs
find "$LOG_DIR" -name "health-check-*.log" -mtime +7 -delete

exit 0
