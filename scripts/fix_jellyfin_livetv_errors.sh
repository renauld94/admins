#!/bin/bash

###############################################################################
# Jellyfin LiveTV 500 Error Fix
# Addresses: Primary image 500 errors, PlaybackInfo failures, EPG fetch issues
###############################################################################

set -e

REMOTE_HOST="136.243.155.166"
REMOTE_USER="simonadmin"
PROXMOX_IP="10.0.0.103"
CONTAINER_NAME="jellyfin-simonadmin"

echo "🔧 Jellyfin LiveTV Error Fix"
echo "============================="
echo ""

# Test network connectivity from container
echo "1️⃣ Testing network connectivity from Jellyfin container..."
ssh -p 2222 root@${REMOTE_HOST} \
  "ssh ${REMOTE_USER}@${PROXMOX_IP} 'docker exec ${CONTAINER_NAME} curl -I -m 10 https://raw.githubusercontent.com/iptv-org/iptv/master/streams/us.m3u'" || {
    echo "⚠️  Network connectivity issue detected"
}
echo ""

# Check DNS resolution
echo "2️⃣ Checking DNS resolution..."
ssh -p 2222 root@${REMOTE_HOST} \
  "ssh ${REMOTE_USER}@${PROXMOX_IP} 'docker exec ${CONTAINER_NAME} nslookup raw.githubusercontent.com'" || {
    echo "⚠️  DNS resolution issue detected"
}
echo ""

# Solution 1: Clear Jellyfin cache and restart
echo "3️⃣ Clearing Jellyfin cache..."
ssh -p 2222 root@${REMOTE_HOST} \
  "ssh ${REMOTE_USER}@${PROXMOX_IP} '
    docker exec ${CONTAINER_NAME} rm -rf /cache/images/* 2>/dev/null || true
    docker exec ${CONTAINER_NAME} rm -rf /config/cache/images/* 2>/dev/null || true
    docker exec ${CONTAINER_NAME} rm -rf /config/metadata/livetv/* 2>/dev/null || true
  '"
echo "✅ Cache cleared"
echo ""

# Solution 2: Update DNS settings in container
echo "4️⃣ Updating container DNS settings..."
ssh -p 2222 root@${REMOTE_HOST} \
  "ssh ${REMOTE_USER}@${PROXMOX_IP} '
    docker stop ${CONTAINER_NAME}
    
    # Backup current container config
    docker inspect ${CONTAINER_NAME} > /tmp/jellyfin_inspect_backup.json
    
    # Remove and recreate with updated DNS
    JELLYFIN_CONFIG=\$(docker inspect ${CONTAINER_NAME} --format=\"{{range .Mounts}}{{if eq .Destination \\\"/config\\\"}}{{.Source}}{{end}}{{end}}\")
    JELLYFIN_CACHE=\$(docker inspect ${CONTAINER_NAME} --format=\"{{range .Mounts}}{{if eq .Destination \\\"/cache\\\"}}{{.Source}}{{end}}{{end}}\")
    
    docker rm ${CONTAINER_NAME}
    
    docker run -d \\
      --name ${CONTAINER_NAME} \\
      --restart=unless-stopped \\
      --network=bridge \\
      --dns=8.8.8.8 \\
      --dns=8.8.4.4 \\
      --dns=1.1.1.1 \\
      -p 8096:8096 \\
      -p 1900:1900/udp \\
      -v \${JELLYFIN_CONFIG}:/config \\
      -v \${JELLYFIN_CACHE}:/cache \\
      -e TZ=UTC \\
      jellyfin/jellyfin:latest
    
    # Wait for container to start
    sleep 10
    
    # Verify DNS
    docker exec ${CONTAINER_NAME} cat /etc/resolv.conf
  '"
echo "✅ Container restarted with updated DNS"
echo ""

# Solution 3: Force refresh LiveTV guide
echo "5️⃣ Forcing LiveTV guide refresh..."
echo "   Please do this manually in Jellyfin:"
echo "   - Go to Dashboard → Live TV"
echo "   - Click on TV Guide Data Providers"
echo "   - Click 'Refresh Guide Data'"
echo ""

# Solution 4: Check if we can access images directly
echo "6️⃣ Testing direct image access..."
ssh -p 2222 root@${REMOTE_HOST} \
  "ssh ${REMOTE_USER}@${PROXMOX_IP} '
    docker exec ${CONTAINER_NAME} curl -I -m 10 https://github.com/iptv-org/iptv/raw/master/streams/us.m3u
  '" && echo "✅ Direct access working" || echo "⚠️  Direct access still failing"
echo ""

# Alternative solution: Use local EPG data
echo "7️⃣ Alternative: Switch to local EPG data..."
cat << 'EOF'

If network issues persist, consider these alternatives:

A. Use local M3U playlists (already configured):
   - Your playlists are in: /config/data/playlists/
   - No external EPG data needed
   
B. Configure local XMLTV EPG data:
   - Download EPG data manually and host locally
   - Update guide provider in Jellyfin to use local file
   
C. Disable automatic metadata refresh:
   - Dashboard → Live TV → Guide Providers
   - Disable automatic refresh
   - Manually refresh when needed

D. Use alternative EPG source:
   - https://epg.best/
   - https://www.xmltv.org/
   
EOF

# Check current status
echo "8️⃣ Current Jellyfin status:"
ssh -p 2222 root@${REMOTE_HOST} \
  "ssh ${REMOTE_USER}@${PROXMOX_IP} 'docker ps | grep ${CONTAINER_NAME}'"
echo ""

echo "✅ Fix script completed!"
echo ""
echo "📋 Next Steps:"
echo "   1. Wait 2-3 minutes for Jellyfin to fully start"
echo "   2. Clear your browser cache (Ctrl+Shift+R)"
echo "   3. Navigate to http://136.243.155.166:8096/web/#/livetv.html"
echo "   4. Check browser console for remaining errors"
echo "   5. If images still fail, manually refresh guide data in Dashboard"
echo ""
echo "🔍 To monitor logs:"
echo "   ssh -p 2222 root@${REMOTE_HOST} 'ssh ${REMOTE_USER}@${PROXMOX_IP} \"docker logs -f ${CONTAINER_NAME}\"'"
