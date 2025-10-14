#!/bin/bash

# Docker-based Jellyfin TV Channels Setup
# Run this script inside the Proxmox VM 200 console

set -e

echo "🐳 Docker-based Jellyfin TV Setup"
echo "================================="

CONTAINER_NAME="jellyfin-simonadmin"
CONFIG_DIR="/config"

echo "📥 Downloading TV channel files..."

# Download M3U playlists
docker exec "$CONTAINER_NAME" wget -O "$CONFIG_DIR/samsung_tv.m3u" "https://rb.gy/soxjxl" || echo "Failed to download Samsung M3U"
docker exec "$CONTAINER_NAME" wget -O "$CONFIG_DIR/plex_tv.m3u" "https://rb.gy/rhktaz" || echo "Failed to download Plex M3U"
docker exec "$CONTAINER_NAME" wget -O "$CONFIG_DIR/tubi_tv.m3u" "https://www.apsattv.com/tubi.m3u" || echo "Failed to download Tubi M3U"

# Download EPG files
docker exec "$CONTAINER_NAME" wget -O "$CONFIG_DIR/samsung_epg.xml" "https://rb.gy/csudmm" || echo "Failed to download Samsung EPG"
docker exec "$CONTAINER_NAME" wget -O "$CONFIG_DIR/plex_epg.xml" "https://rb.gy/uoqt9v" || echo "Failed to download Plex EPG"

echo "🔧 Setting up Jellyfin configuration..."

# Create Live TV directory
docker exec "$CONTAINER_NAME" mkdir -p "$CONFIG_DIR/data/livetv"

# Set permissions
docker exec "$CONTAINER_NAME" chown -R jellyfin:jellyfin "$CONFIG_DIR"

echo "🔄 Restarting Jellyfin..."
docker restart "$CONTAINER_NAME"

echo "⏳ Waiting for restart..."
sleep 30

echo "✅ Setup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Go to: http://136.243.155.166:8096/web/"
echo "2. Log in as simonadmin"
echo "3. Admin Panel → Live TV"
echo "4. Add M3U Tuner with file: /config/samsung_tv.m3u"
echo "5. Add XMLTV EPG with file: /config/samsung_epg.xml"
echo ""
