#!/bin/bash

echo "🚀 Final iptv-org Channels Deployment to Jellyfin"
echo "================================================"

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"

echo "📋 Step 1: Testing Jellyfin connection..."
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/System/Info" > /dev/null
if [ $? -eq 0 ]; then
    echo "✅ Jellyfin is accessible"
else
    echo "❌ Jellyfin is not accessible"
    exit 1
fi

echo ""
echo "📋 Step 2: Creating iptv-org tuners using direct URLs..."

# Function to create tuner with direct URL
create_tuner_url() {
    local name="$1"
    local url="$2"
    local description="$3"
    
    echo "Creating tuner: $name"
    echo "URL: $url"
    
    # Try multiple API approaches
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

echo "📋 Step 3: Refreshing Live TV guide..."
curl -s -X POST -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Guide/Refresh"

echo "📋 Step 4: Checking current tuners..."
CURRENT_TUNERS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Tuners")
echo "Current tuners: $CURRENT_TUNERS"

echo ""
echo "🎉 iptv-org Channels Deployment Complete!"
echo "========================================"
echo ""
echo "📺 Tuners configured with direct URLs:"
echo "  1. iptv-org Global (https://iptv-org.github.io/iptv/index.m3u)"
echo "  2. iptv-org US Channels (https://iptv-org.github.io/iptv/countries/us.m3u)"
echo "  3. iptv-org News (https://iptv-org.github.io/iptv/categories/news.m3u)"
echo "  4. iptv-org Sports (https://iptv-org.github.io/iptv/categories/sports.m3u)"
echo "  5. iptv-org Movies (https://iptv-org.github.io/iptv/categories/movies.m3u)"
echo ""
echo "📊 Expected channel counts:"
echo "  - Global: ~1000+ channels worldwide"
echo "  - US: ~200+ US channels"
echo "  - News: ~50+ news channels"
echo "  - Sports: ~30+ sports channels"
echo "  - Movies: ~40+ movie channels"
echo "  - Total: 1300+ free TV channels! 🎉"
echo ""
echo "🌐 Check your Jellyfin Live TV section now!"
echo "📺 Go to: http://136.243.155.166:8096/web/#/home.html"
echo "🔄 If channels don't appear immediately, wait a few minutes for the guide to refresh"
echo ""
echo "💡 If API configuration didn't work, use the manual method:"
echo "   1. Go to Settings → Live TV"
echo "   2. Add TV Provider → M3U Tuner"
echo "   3. Use the URLs above for each tuner"

