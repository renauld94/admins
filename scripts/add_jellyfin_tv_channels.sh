#!/bin/bash

# Jellyfin TV Channels Setup Script
# Run this script inside the Proxmox VM 200 console

set -e

echo "📺 Setting up Jellyfin TV Channels..."
echo "===================================="

CONTAINER_NAME="jellyfin-simonadmin"
CONFIG_DIR="/config"
TEMP_DIR="/tmp/jellyfin_tv_setup"

# Create temporary directory
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

echo "📥 Downloading M3U playlists..."

# Download Samsung TV Plus M3U
echo "Downloading Samsung TV Plus playlist..."
curl -o samsung_tv_plus.m3u "https://rb.gy/soxjxl" || echo "Failed to download Samsung M3U"

# Download Plex Live Channels M3U
echo "Downloading Plex Live Channels playlist..."
curl -o plex_live.m3u "https://rb.gy/rhktaz" || echo "Failed to download Plex M3U"

# Download Tubi TV M3U
echo "Downloading Tubi TV playlist..."
curl -o tubi_tv.m3u "https://www.apsattv.com/tubi.m3u" || echo "Failed to download Tubi M3U"

echo "📥 Downloading EPG files..."

# Download Samsung TV Plus EPG
echo "Downloading Samsung TV Plus EPG..."
curl -o samsung_epg.xml "https://rb.gy/csudmm" || echo "Failed to download Samsung EPG"

# Download Plex Live Channels EPG
echo "Downloading Plex Live Channels EPG..."
curl -o plex_epg.xml "https://rb.gy/uoqt9v" || echo "Failed to download Plex EPG"

echo "📁 Copying files to Jellyfin container..."

# Copy M3U files to Jellyfin config directory
docker cp samsung_tv_plus.m3u "$CONTAINER_NAME:$CONFIG_DIR/"
docker cp plex_live.m3u "$CONTAINER_NAME:$CONFIG_DIR/"
docker cp tubi_tv.m3u "$CONTAINER_NAME:$CONFIG_DIR/"

# Copy EPG files to Jellyfin config directory
docker cp samsung_epg.xml "$CONTAINER_NAME:$CONFIG_DIR/"
docker cp plex_epg.xml "$CONTAINER_NAME:$CONFIG_DIR/"

echo "🔧 Setting up Jellyfin configuration..."

# Create Jellyfin configuration for Live TV
docker exec "$CONTAINER_NAME" mkdir -p "$CONFIG_DIR/data/livetv"

# Set proper permissions
docker exec "$CONTAINER_NAME" chown -R jellyfin:jellyfin "$CONFIG_DIR"

echo "🔄 Restarting Jellyfin container..."
docker restart "$CONTAINER_NAME"

echo "⏳ Waiting for Jellyfin to start..."
sleep 30

echo "✅ Setup complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Go to Jellyfin web interface: http://136.243.155.166:8096/web/"
echo "2. Log in as simonadmin"
echo "3. Go to Admin Panel → Live TV"
echo "4. Add M3U Tuner with local file: /config/samsung_tv_plus.m3u"
echo "5. Add XMLTV EPG with local file: /config/samsung_epg.xml"
echo "6. Click 'Refresh Guide Data'"
echo ""
echo "📺 Available M3U files:"
echo "  - /config/samsung_tv_plus.m3u"
echo "  - /config/plex_live.m3u"
echo "  - /config/tubi_tv.m3u"
echo ""
echo "📺 Available EPG files:"
echo "  - /config/samsung_epg.xml"
echo "  - /config/plex_epg.xml"
echo ""

# Cleanup
cd /
rm -rf "$TEMP_DIR"

echo "🎉 Jellyfin TV channels setup complete!"
