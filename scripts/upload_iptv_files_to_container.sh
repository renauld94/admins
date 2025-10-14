#!/bin/bash

echo "📥 Uploading iptv-org M3U files to Jellyfin Docker container"
echo "============================================================"

# Configuration
PROXY_HOST="136.243.155.166:2222"
VM_HOST="10.0.0.103"
VM_USER="simonadmin"
CONTAINER_NAME="jellyfin-simonadmin"

echo "📤 Uploading M3U files to VM 200..."
scp -o StrictHostKeyChecking=no -P 2222 /tmp/iptv_global.m3u simonadmin@136.243.155.166:/tmp/
scp -o StrictHostKeyChecking=no -P 2222 /tmp/iptv_us.m3u simonadmin@136.243.155.166:/tmp/
scp -o StrictHostKeyChecking=no -P 2222 /tmp/iptv_news.m3u simonadmin@136.243.155.166:/tmp/
scp -o StrictHostKeyChecking=no -P 2222 /tmp/iptv_sports.m3u simonadmin@136.243.155.166:/tmp/
scp -o StrictHostKeyChecking=no -P 2222 /tmp/iptv_movies.m3u simonadmin@136.243.155.166:/tmp/

echo "📁 Installing M3U files in Jellyfin container..."
ssh -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'docker cp /tmp/iptv_global.m3u jellyfin-simonadmin:/config/ && docker cp /tmp/iptv_us.m3u jellyfin-simonadmin:/config/ && docker cp /tmp/iptv_news.m3u jellyfin-simonadmin:/config/ && docker cp /tmp/iptv_sports.m3u jellyfin-simonadmin:/config/ && docker cp /tmp/iptv_movies.m3u jellyfin-simonadmin:/config/'"

echo "✅ M3U files uploaded to Jellyfin container!"
echo "============================================="
echo ""
echo "📁 Files now available in /config/:"
echo "  - /config/iptv_global.m3u"
echo "  - /config/iptv_us.m3u"
echo "  - /config/iptv_news.m3u"
echo "  - /config/iptv_sports.m3u"
echo "  - /config/iptv_movies.m3u"
echo ""
echo "🌐 Now you can use these paths in Jellyfin Live TV setup!"
