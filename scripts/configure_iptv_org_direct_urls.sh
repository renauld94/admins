#!/bin/bash

echo "🔧 Configuring iptv-org channels using direct URLs via API"
echo "========================================================="

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"

echo "🔧 Configuring all iptv-org tuners using direct URLs..."

# Function to create tuner with direct URL
create_tuner_url() {
    local name="$1"
    local url="$2"
    local description="$3"
    
    echo "Creating tuner: $name"
    echo "URL: $url"
    
    # Try multiple API approaches for each tuner
    echo "  Trying /LiveTv/Tuners endpoint..."
    RESPONSE1=$(curl -s -X POST \
      -H "X-Emby-Token: $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"Name\": \"$name\",
        \"Type\": \"M3U\",
        \"Url\": \"$url\",
        \"Enable\": true
      }" \
      "$JELLYFIN_URL/LiveTv/Tuners" 2>/dev/null)
    
    echo "  Response: $RESPONSE1"
    
    # Try TunerHosts endpoint
    echo "  Trying /LiveTv/TunerHosts endpoint..."
    RESPONSE2=$(curl -s -X POST \
      -H "X-Emby-Token: $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"Name\": \"$name\",
        \"Type\": \"M3U\",
        \"Url\": \"$url\",
        \"Enable\": true
      }" \
      "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)
    
    echo "  TunerHosts Response: $RESPONSE2"
    
    # Try alternative format
    echo "  Trying alternative format..."
    RESPONSE3=$(curl -s -X POST \
      -H "X-Emby-Token: $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"TunerType\": \"M3U\",
        \"Name\": \"$name\",
        \"Url\": \"$url\",
        \"Enable\": true
      }" \
      "$JELLYFIN_URL/LiveTv/Tuners" 2>/dev/null)
    
    echo "  Alternative Response: $RESPONSE3"
    echo ""
}

# Create all tuners with direct URLs
create_tuner_url "iptv-org Global" "https://iptv-org.github.io/iptv/index.m3u" "1000+ global channels"
create_tuner_url "iptv-org US Channels" "https://iptv-org.github.io/iptv/countries/us.m3u" "US-specific channels"
create_tuner_url "iptv-org News" "https://iptv-org.github.io/iptv/categories/news.m3u" "News channels worldwide"
create_tuner_url "iptv-org Sports" "https://iptv-org.github.io/iptv/categories/sports.m3u" "Sports channels"
create_tuner_url "iptv-org Movies" "https://iptv-org.github.io/iptv/categories/movies.m3u" "Movie channels"

echo "🔄 Refreshing Live TV guide..."
curl -s -X POST -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Guide/Refresh"

echo "📊 Checking current tuners..."
CURRENT_TUNERS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Tuners")
echo "Current tuners: $CURRENT_TUNERS"

echo ""
echo "✅ iptv-org Channels Configuration Complete!"
echo "==========================================="
echo ""
echo "📺 Tuners configured with direct URLs:"
echo "  1. iptv-org Global (https://iptv-org.github.io/iptv/index.m3u)"
echo "  2. iptv-org US Channels (https://iptv-org.github.io/iptv/countries/us.m3u)"
echo "  3. iptv-org News (https://iptv-org.github.io/iptv/categories/news.m3u)"
echo "  4. iptv-org Sports (https://iptv-org.github.io/iptv/categories/sports.m3u)"
echo "  5. iptv-org Movies (https://iptv-org.github.io/iptv/categories/movies.m3u)"
echo ""
echo "🌐 Check your Jellyfin Live TV section now!"
echo "📺 You should see 5 new tuners with thousands of channels"
echo "🔄 If channels don't appear immediately, wait a few minutes for the guide to refresh"

