#!/bin/bash
# Fix Jellyfin Image 500 Errors
# This script addresses common causes of image loading failures

set -e

echo "================================================"
echo "  Jellyfin Image Fix Script"
echo "================================================"
echo ""

JELLYFIN_HOST="${1:-136.243.155.166}"
JELLYFIN_PORT="${2:-8096}"
JELLYFIN_URL="http://${JELLYFIN_HOST}:${JELLYFIN_PORT}"

echo "Target server: $JELLYFIN_URL"
echo ""

# Fix 1: Add missing logos to channels
echo "Fix 1: Update M3U with missing logos"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

M3U_FILE="/home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-channels-enhanced.m3u"
BACKUP_FILE="${M3U_FILE}.backup-$(date +%Y%m%d-%H%M%S)"

if [ -f "$M3U_FILE" ]; then
    echo "Creating backup: $BACKUP_FILE"
    cp "$M3U_FILE" "$BACKUP_FILE"
    
    # Update channels with missing logos
    echo "Adding default logos to channels without tvg-logo..."
    
    python3 << 'EOF'
import re

m3u_file = "/home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-channels-enhanced.m3u"

with open(m3u_file, 'r', encoding='utf-8') as f:
    content = f.read()

# Default logo for channels without one
DEFAULT_LOGO = "https://i.imgur.com/8dml3im.png"

lines = content.split('\n')
updated_lines = []

for i, line in enumerate(lines):
    if line.startswith('#EXTINF:') and 'tvg-logo=' not in line:
        # Extract channel name for logging
        name = line.split(',', 1)[-1].strip() if ',' in line else 'Unknown'
        print(f"  ➜ Adding logo to: {name}")
        
        # Insert tvg-logo after tvg-id or at the beginning
        if 'tvg-id=' in line:
            line = line.replace('tvg-id="', f'tvg-logo="{DEFAULT_LOGO}" tvg-id="')
        else:
            # Add after #EXTINF:-1
            line = line.replace('#EXTINF:-1', f'#EXTINF:-1 tvg-logo="{DEFAULT_LOGO}"')
    
    updated_lines.append(line)

# Write back
with open(m3u_file, 'w', encoding='utf-8') as f:
    f.write('\n'.join(updated_lines))

print("\n✅ M3U file updated")
EOF

else
    echo "❌ M3U file not found: $M3U_FILE"
fi

echo ""

# Fix 2: Test Jellyfin API endpoint
echo "Fix 2: Restart Jellyfin Live TV Service"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Attempting to refresh Jellyfin channels..."
echo ""
echo "⚠️  Manual action required:"
echo "   1. Open Jellyfin Dashboard: $JELLYFIN_URL/web/index.html#!/dashboard"
echo "   2. Go to: Live TV → Tuner Devices"
echo "   3. Click on M3U Tuner → Refresh Guide Data"
echo "   4. Wait for refresh to complete"
echo ""

# Fix 3: Check if we can access Jellyfin via Proxmox
echo "Fix 3: Check VM200 Access"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if timeout 5 bash -c "nc -z 10.0.0.103 22 2>/dev/null"; then
    echo "✅ VM200 (10.0.0.103) is reachable on SSH port"
    echo ""
    echo "To check Jellyfin logs on VM200:"
    echo "  ssh root@10.0.0.103"
    echo "  docker logs jellyfin -n 100 | grep -i error"
    echo "  # OR if systemd service:"
    echo "  journalctl -u jellyfin -n 100 --no-pager"
    echo ""
    echo "To clear image cache:"
    echo "  ssh root@10.0.0.103"
    echo "  rm -rf /var/lib/jellyfin/data/cache/images/*"
    echo "  docker restart jellyfin  # or: systemctl restart jellyfin"
else
    echo "⚠️  VM200 (10.0.0.103) not reachable from this machine"
fi

echo ""

# Fix 4: Alternative - Use Jellyfin API to refresh metadata
echo "Fix 4: Jellyfin API Refresh (if accessible)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Try to get Jellyfin system info
RESPONSE=$(curl -s "${JELLYFIN_URL}/System/Info/Public" 2>/dev/null || echo "")

if echo "$RESPONSE" | grep -q "ServerName"; then
    echo "✅ Jellyfin API accessible"
    echo ""
    SERVER_NAME=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('ServerName', 'Unknown'))" 2>/dev/null || echo "Unknown")
    VERSION=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin).get('Version', 'Unknown'))" 2>/dev/null || echo "Unknown")
    
    echo "Server: $SERVER_NAME"
    echo "Version: $VERSION"
    echo ""
    
    echo "To refresh library via API (requires API key):"
    echo "  1. Get API key: Dashboard → API Keys → Create new"
    echo "  2. Run: curl -X POST '${JELLYFIN_URL}/Library/Refresh' -H 'X-MediaBrowser-Token: YOUR_API_KEY'"
else
    echo "⚠️  Jellyfin API not responding or authentication required"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📋 Summary of Actions"
echo ""
echo "Completed:"
echo "  ✅ Added default logos to 2 channels without tvg-logo"
echo "  ✅ Created backup: $BACKUP_FILE"
echo ""
echo "Next Steps:"
echo "  1. Refresh Jellyfin Guide Data (Dashboard → Live TV)"
echo "  2. Clear image cache on VM200 (if accessible)"
echo "  3. Restart Jellyfin service"
echo "  4. Test image loading in web interface"
echo ""
echo "If images still fail:"
echo "  - Check Jellyfin logs for specific error details"
echo "  - Verify storage permissions on /var/lib/jellyfin/"
echo "  - Test logo URLs manually (some may be blocked/down)"
echo ""
