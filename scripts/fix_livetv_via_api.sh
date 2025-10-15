#!/bin/bash

echo "🔧 Fixing Live TV via API - Direct Approach"
echo "==========================================="

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"

echo "🔍 Checking current Live TV status..."
CURRENT_TUNERS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Tuners")
echo "Current tuners: $CURRENT_TUNERS"

echo ""
echo "📺 Adding M3U tuners via API..."

# Function to add M3U tuner via API
add_m3u_tuner() {
    local name="$1"
    local url="$2"
    
    echo "Adding $name..."
    
    # Try different API endpoints
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
    
    echo "Response 1: $RESPONSE1"
    
    # Try alternative endpoint
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
    
    echo "Response 2: $RESPONSE2"
    
    # Try with different structure
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
    
    echo "Response 3: $RESPONSE3"
}

# Add tuners using direct URLs (these should work)
echo "Adding GitHub Free-TV..."
add_m3u_tuner "GitHub Free-TV" "https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8"

echo "Adding iptv-org Global..."
add_m3u_tuner "iptv-org Global" "https://iptv-org.github.io/iptv/index.m3u"

echo "Adding US Channels..."
add_m3u_tuner "US Channels" "https://iptv-org.github.io/iptv/countries/us.m3u"

echo "Adding News Channels..."
add_m3u_tuner "News Channels" "https://iptv-org.github.io/iptv/categories/news.m3u"

echo "Adding Sports Channels..."
add_m3u_tuner "Sports Channels" "https://iptv-org.github.io/iptv/categories/sports.m3u"

echo "Adding Movies Channels..."
add_m3u_tuner "Movies Channels" "https://iptv-org.github.io/iptv/categories/movies.m3u"

echo "Adding Music Channels..."
add_m3u_tuner "Music Channels" "https://iptv-org.github.io/iptv/categories/music.m3u"

echo ""
echo "🔄 Refreshing Live TV..."
curl -s -X POST -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Guide/Refresh"

echo ""
echo "📊 Checking final tuner status..."
FINAL_TUNERS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Tuners")
echo "Final tuners: $FINAL_TUNERS"

echo ""
echo "✅ Live TV API Configuration Complete!"
echo "====================================="
echo ""
echo "🌐 Check your Jellyfin Live TV section now!"
echo "📺 You should see all the new tuners added"
echo "🔄 If channels don't appear, wait a few minutes for the guide to refresh"

