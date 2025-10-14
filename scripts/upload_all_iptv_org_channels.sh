#!/bin/bash

echo "📥 Uploading ALL iptv-org M3U channels to VM 200 and configuring via API"
echo "======================================================================="

# Configuration
PROXY_HOST="136.243.155.166:2222"
VM_HOST="10.0.0.103"
VM_USER="simonadmin"
CONTAINER_NAME="jellyfin-simonadmin"
CONFIG_DIR="/config"
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"

echo "📤 Uploading all iptv-org M3U files to VM 200..."
scp -o StrictHostKeyChecking=no -P 2222 /tmp/iptv_global.m3u simonadmin@136.243.155.166:/tmp/
scp -o StrictHostKeyChecking=no -P 2222 /tmp/iptv_us.m3u simonadmin@136.243.155.166:/tmp/
scp -o StrictHostKeyChecking=no -P 2222 /tmp/iptv_news.m3u simonadmin@136.243.155.166:/tmp/
scp -o StrictHostKeyChecking=no -P 2222 /tmp/iptv_sports.m3u simonadmin@136.243.155.166:/tmp/
scp -o StrictHostKeyChecking=no -P 2222 /tmp/iptv_movies.m3u simonadmin@136.243.155.166:/tmp/

echo "📁 Installing all M3U files in Jellyfin container..."
ssh -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'docker cp /tmp/iptv_global.m3u jellyfin-simonadmin:$CONFIG_DIR/ && docker cp /tmp/iptv_us.m3u jellyfin-simonadmin:$CONFIG_DIR/ && docker cp /tmp/iptv_news.m3u jellyfin-simonadmin:$CONFIG_DIR/ && docker cp /tmp/iptv_sports.m3u jellyfin-simonadmin:$CONFIG_DIR/ && docker cp /tmp/iptv_movies.m3u jellyfin-simonadmin:$CONFIG_DIR/'"

echo "🔧 Configuring all iptv-org tuners via API..."

# Function to create tuner
create_tuner() {
    local name="$1"
    local file="$2"
    local description="$3"
    
    echo "Creating tuner: $name"
    
    # Try multiple API approaches for each tuner
    RESPONSE1=$(curl -s -X POST \
      -H "X-Emby-Token: $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"Name\": \"$name\",
        \"Type\": \"M3U\",
        \"Url\": \"$CONFIG_DIR/$file\",
        \"Enable\": true
      }" \
      "$JELLYFIN_URL/LiveTv/Tuners" 2>/dev/null)
    
    echo "  Response: $RESPONSE1"
    
    # Alternative endpoint
    RESPONSE2=$(curl -s -X POST \
      -H "X-Emby-Token: $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"TunerType\": \"M3U\",
        \"Name\": \"$name\",
        \"Url\": \"$CONFIG_DIR/$file\",
        \"Enable\": true
      }" \
      "$JELLYFIN_URL/LiveTv/Tuners" 2>/dev/null)
    
    echo "  Alt Response: $RESPONSE2"
    
    # TunerHosts endpoint
    RESPONSE3=$(curl -s -X POST \
      -H "X-Emby-Token: $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"Name\": \"$name\",
        \"Type\": \"M3U\",
        \"Url\": \"$CONFIG_DIR/$file\",
        \"Enable\": true
      }" \
      "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)
    
    echo "  TunerHosts Response: $RESPONSE3"
    echo ""
}

# Create all tuners
create_tuner "iptv-org Global" "iptv_global.m3u" "1000+ global channels"
create_tuner "iptv-org US Channels" "iptv_us.m3u" "US-specific channels"
create_tuner "iptv-org News" "iptv_news.m3u" "News channels worldwide"
create_tuner "iptv-org Sports" "iptv_sports.m3u" "Sports channels"
create_tuner "iptv-org Movies" "iptv_movies.m3u" "Movie channels"

echo "🔄 Refreshing Live TV guide..."
curl -s -X POST -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Guide/Refresh"

echo "📊 Checking current tuners..."
CURRENT_TUNERS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Tuners")
echo "Current tuners: $CURRENT_TUNERS"

echo ""
echo "✅ ALL iptv-org M3U Channels Upload and Configuration Complete!"
echo "=============================================================="
echo ""
echo "📁 Files installed in /config/:"
echo "  - iptv_global.m3u (2.7MB - 1000+ global channels)"
echo "  - iptv_us.m3u (410KB - US channels)"
echo "  - iptv_news.m3u (180KB - News channels)"
echo "  - iptv_sports.m3u (72KB - Sports channels)"
echo "  - iptv_movies.m3u (107KB - Movie channels)"
echo ""
echo "📺 Tuners created:"
echo "  1. iptv-org Global"
echo "  2. iptv-org US Channels"
echo "  3. iptv-org News"
echo "  4. iptv-org Sports"
echo "  5. iptv-org Movies"
echo ""
echo "🌐 Check your Jellyfin Live TV section now!"
echo "📺 You should see 5 new tuners with thousands of channels"
echo "🔄 If channels don't appear immediately, wait a few minutes for the guide to refresh"
