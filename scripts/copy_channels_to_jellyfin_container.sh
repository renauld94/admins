#!/bin/bash

echo "📁 Copying Enhanced Channels to Jellyfin Container"
echo "================================================="

# Configuration
PROXY_HOST="136.243.155.166:2222"
VM_HOST="10.0.0.103"
VM_USER="simonadmin"
CONTAINER_NAME="jellyfin-simonadmin"
CONFIG_DIR="/config"

ENHANCED_DIR="/home/simon/Learning-Management-System-Academy/enhanced_channels"

echo "📤 Uploading enhanced channel files to VM..."

# Upload all M3U files to VM
for file in "$ENHANCED_DIR"/*.m3u*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "Uploading $filename..."
        scp -o StrictHostKeyChecking=no -P 2222 "$file" simonadmin@136.243.155.166:/tmp/
    fi
done

echo "📁 Copying files to Jellyfin container..."

# Copy all files to Jellyfin container
for file in "$ENHANCED_DIR"/*.m3u*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "Installing $filename in Jellyfin container..."
        ssh -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'docker cp /tmp/$filename jellyfin-simonadmin:$CONFIG_DIR/'"
    fi
done

echo "🔄 Restarting Jellyfin to load new files..."
ssh -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'docker restart jellyfin-simonadmin'"

echo "⏳ Waiting for Jellyfin to restart..."
sleep 30

echo "✅ Enhanced channels copied to Jellyfin container!"
echo ""
echo "📺 Now you can use these paths in Jellyfin:"
echo "• /config/free_tv_github.m3u8"
echo "• /config/iptv_org.m3u"
echo "• /config/iptv_us.m3u"
echo "• /config/iptv_uk.m3u"
echo "• /config/iptv_ca.m3u"
echo "• /config/iptv_news.m3u"
echo "• /config/iptv_sports.m3u"
echo "• /config/iptv_movies.m3u"
echo "• /config/iptv_music.m3u"
echo "• /config/curated_free_channels.m3u"
echo "• /config/samsung_tv_plus_enhanced.m3u"
echo "• /config/pluto_tv.m3u"
echo ""
echo "🌐 Go back to Jellyfin and try adding the tuners again!"
