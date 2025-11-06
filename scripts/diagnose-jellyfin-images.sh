#!/bin/bash
# Diagnose Jellyfin Image Loading Issues
# Checks for common causes of 500 errors on image requests

set -e

echo "================================================"
echo "  Jellyfin Image Issue Diagnostic"
echo "================================================"
echo ""

# Jellyfin server details
JELLYFIN_HOST="10.0.0.103"
JELLYFIN_PORT="8096"
JELLYFIN_URL="http://${JELLYFIN_HOST}:${JELLYFIN_PORT}"

echo "🔍 Testing Jellyfin server: $JELLYFIN_URL"
echo ""

# Test 1: Check if Jellyfin is responding
echo "Test 1: Server Connectivity"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${JELLYFIN_URL}/web/index.html" || echo "000")

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Server is responding (HTTP $HTTP_CODE)"
else
    echo "❌ Server connection failed (HTTP $HTTP_CODE)"
    echo "   Trying external IP..."
    JELLYFIN_HOST="136.243.155.166"
    JELLYFIN_URL="http://${JELLYFIN_HOST}:${JELLYFIN_PORT}"
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "${JELLYFIN_URL}/web/index.html" || echo "000")
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ External server responding (HTTP $HTTP_CODE)"
    else
        echo "❌ Cannot connect to Jellyfin server"
        exit 1
    fi
fi
echo ""

# Test 2: Check a failing image URL
echo "Test 2: Image Request Analysis"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
FAILING_IMAGE="${JELLYFIN_URL}/Items/477c89a15bc2fbfc58c5f278ae334870/Images/Primary?fillHeight=330&fillWidth=330&quality=96&tag=543b6ca4c9f21c87d81daf7a932499c0"

echo "Testing URL: ${FAILING_IMAGE:0:80}..."
RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" "$FAILING_IMAGE" 2>&1)
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE:")

echo "Response: HTTP $HTTP_CODE"
if [ "$HTTP_CODE" = "500" ]; then
    echo "❌ Internal Server Error"
    echo "Error message: $BODY"
else
    echo "✅ Image request successful"
fi
echo ""

# Test 3: Check Jellyfin process
echo "Test 3: Jellyfin Process Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if pgrep -f jellyfin > /dev/null; then
    echo "✅ Jellyfin process running locally"
    ps aux | grep jellyfin | grep -v grep | head -1
else
    echo "⚠️  Jellyfin not running on this machine (likely on VM200)"
fi
echo ""

# Test 4: Check for SSH access to VM
echo "Test 4: Remote VM Access"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if timeout 5 ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no root@10.0.0.103 "echo 'Connected'" 2>/dev/null; then
    echo "✅ SSH access to VM200 (10.0.0.103) available"
    echo ""
    echo "Fetching Jellyfin logs from remote server..."
    ssh root@10.0.0.103 "tail -50 /var/log/jellyfin/jellyfin.log 2>/dev/null || journalctl -u jellyfin -n 50 --no-pager 2>/dev/null || echo 'Log location unknown'" | grep -E "(Error|error|Exception|exception|Image)" | tail -15 || echo "No recent errors in logs"
else
    echo "⚠️  Cannot SSH to VM200 (10.0.0.103)"
    echo "   Image errors may be in logs on that server"
fi
echo ""

# Test 5: Check common causes
echo "Test 5: Common Issue Analysis"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Possible causes of image 500 errors:"
echo ""
echo "1. 🔧 METADATA MISSING"
echo "   - Channels don't have proper tvg-logo URLs"
echo "   - Jellyfin can't fetch/generate thumbnails"
echo "   Fix: Update M3U with valid logo URLs"
echo ""
echo "2. 🖼️  IMAGE CACHE CORRUPTION"
echo "   - Jellyfin's image cache is corrupted"
echo "   Fix: Clear cache directory on server"
echo "   Location: /var/lib/jellyfin/data/cache/"
echo ""
echo "3. 💾 STORAGE PERMISSIONS"
echo "   - Jellyfin can't write to cache directory"
echo "   Fix: Check permissions on /var/lib/jellyfin/"
echo ""
echo "4. 🌐 EXTERNAL IMAGE FETCH FAILED"
echo "   - Logo URLs in M3U are dead/inaccessible"
echo "   Fix: Validate logo URLs in channel list"
echo ""
echo "5. 🔌 PLUGIN ISSUE"
echo "   - Image provider plugin error"
echo "   Fix: Check Dashboard → Plugins for errors"
echo ""

# Test 6: Analyze M3U for logo URLs
echo "Test 6: M3U Logo URL Analysis"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
M3U_FILE="/home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-channels-enhanced.m3u"

if [ -f "$M3U_FILE" ]; then
    TOTAL_CHANNELS=$(grep -c "^#EXTINF:" "$M3U_FILE" || echo "0")
    WITH_LOGO=$(grep "tvg-logo=" "$M3U_FILE" | wc -l || echo "0")
    WITHOUT_LOGO=$((TOTAL_CHANNELS - WITH_LOGO))
    
    echo "Total channels: $TOTAL_CHANNELS"
    echo "Channels with tvg-logo: $WITH_LOGO"
    echo "Channels without tvg-logo: $WITHOUT_LOGO"
    
    if [ $WITHOUT_LOGO -gt 0 ]; then
        echo ""
        echo "⚠️  $WITHOUT_LOGO channels missing logo metadata"
        echo "   This is likely why images show 500 errors"
    else
        echo "✅ All channels have logo metadata"
    fi
    
    # Test a few logo URLs
    echo ""
    echo "Testing 5 random logo URLs..."
    grep "tvg-logo=" "$M3U_FILE" | head -5 | while read -r line; do
        LOGO_URL=$(echo "$line" | grep -oP 'tvg-logo="\K[^"]+' || echo "")
        if [ -n "$LOGO_URL" ]; then
            HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$LOGO_URL" 2>/dev/null || echo "000")
            if [ "$HTTP_CODE" = "200" ]; then
                echo "   ✅ $HTTP_CODE - ${LOGO_URL:0:60}..."
            else
                echo "   ❌ $HTTP_CODE - ${LOGO_URL:0:60}..."
            fi
        fi
    done
else
    echo "❌ M3U file not found: $M3U_FILE"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Recommended Actions:"
echo ""
echo "If SSH to VM200 works:"
echo "  ssh root@10.0.0.103"
echo "  tail -100 /var/log/jellyfin/jellyfin.log | grep -i error"
echo "  ls -la /var/lib/jellyfin/data/cache/"
echo "  rm -rf /var/lib/jellyfin/data/cache/* (to clear cache)"
echo ""
echo "To fix missing logos:"
echo "  1. Check M3U file has tvg-logo= attributes"
echo "  2. Verify logo URLs are accessible"
echo "  3. Update Jellyfin channel metadata"
echo ""
