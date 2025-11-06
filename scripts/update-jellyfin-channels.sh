#!/bin/bash
# Fetch latest channels from IPTV-Org and merge with existing

set -e

SCRIPT_DIR="/home/simon/Learning-Management-System-Academy/scripts"
M3U_DIR="/home/simon/Learning-Management-System-Academy/alternative_m3u_sources"
CURRENT_M3U="$M3U_DIR/jellyfin-channels-enhanced.m3u"
BACKUP_DIR="$M3U_DIR/backups"

echo "🔄 Updating Jellyfin channels from IPTV-Org..."

# Backup current M3U
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
cp "$CURRENT_M3U" "$BACKUP_DIR/jellyfin-channels-${TIMESTAMP}.m3u"

# Run the fetch script if it exists
if [ -f "$SCRIPT_DIR/fetch-and-test-channels.py" ]; then
    python3 "$SCRIPT_DIR/fetch-and-test-channels.py"
    echo "✅ Channels updated successfully"
    
    # Test new channels
    echo "🔍 Testing new channels..."
    python3 "$SCRIPT_DIR/jellyfin-channel-monitor.py" --dry-run
else
    echo "⚠️  Fetch script not found: $SCRIPT_DIR/fetch-and-test-channels.py"
    exit 1
fi
