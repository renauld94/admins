#!/bin/bash

echo "🧪 Testing Jellyfin API with curl - Bypassing Cloudflare"
echo "======================================================="

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"

echo "📋 Step 1: Testing Jellyfin API connectivity..."
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/System/Info" | head -3
if [ $? -eq 0 ]; then
    echo "✅ Jellyfin API is accessible"
else
    echo "❌ Jellyfin API is not accessible"
    exit 1
fi

echo ""
echo "📋 Step 2: Testing different M3U URLs..."

# Test different M3U URLs
URLS=(
    "https://iptv-org.github.io/iptv/index.m3u"
    "https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8"
    "https://iptv-org.github.io/iptv/index.m3u8"
    "https://raw.githubusercontent.com/iptv-org/iptv/master/streams/us.m3u"
    "https://iptv-org.github.io/iptv/countries/us.m3u"
)

for url in "${URLS[@]}"; do
    echo "Testing URL: $url"
    response=$(curl -s -I "$url" 2>&1 | head -1)
    echo "  Response: $response"
    
    # Test if we can get content
    content=$(curl -s "$url" | head -1)
    if [[ "$content" == "#EXTM3U" ]]; then
        echo "  ✅ Content accessible and valid M3U format"
    else
        echo "  ❌ Content not accessible or invalid format"
    fi
    echo ""
done

echo "📋 Step 3: Testing Jellyfin Live TV API endpoints..."

# Test different Live TV endpoints
echo "Testing /LiveTv/Tuners endpoint..."
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Tuners" | head -3

echo ""
echo "Testing /LiveTv/TunerHosts endpoint..."
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/TunerHosts" | head -3

echo ""
echo "Testing /LiveTv/Configuration endpoint..."
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Configuration" | head -3

echo ""
echo "📋 Step 4: Testing tuner creation with different methods..."

# Method 1: Test with working channels M3U
echo "Method 1: Creating tuner with working channels..."
WORKING_M3U='#EXTM3U
#EXTINF:-1 tvg-id="BBCNews" tvg-logo="https://i.imgur.com/bbc.png" group-title="News",BBC News
https://stream.live.vc.bbcmedia.co.uk/bbc_world_service
#EXTINF:-1 tvg-id="CNN" tvg-logo="https://i.imgur.com/cnn.png" group-title="News",CNN International
https://cnn-cnninternational-1-eu.rakuten.wurl.tv/playlist.m3u8'

# Create a temporary M3U file
echo "$WORKING_M3U" > /tmp/test_channels.m3u

# Try to create tuner with local file
echo "Trying with local file path..."
RESPONSE1=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Test Channels",
    "Type": "M3U",
    "Url": "/tmp/test_channels.m3u",
    "Enable": true
  }' \
  "$JELLYFIN_URL/LiveTv/Tuners" 2>/dev/null)

echo "Response: $RESPONSE1"

# Method 2: Test with direct URL
echo ""
echo "Method 2: Creating tuner with direct URL..."
RESPONSE2=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Test Direct URL",
    "Type": "M3U",
    "Url": "https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8",
    "Enable": true
  }' \
  "$JELLYFIN_URL/LiveTv/Tuners" 2>/dev/null)

echo "Response: $RESPONSE2"

# Method 3: Test with TunerHosts endpoint
echo ""
echo "Method 3: Using TunerHosts endpoint..."
RESPONSE3=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Test TunerHosts",
    "Type": "M3U",
    "Url": "https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8",
    "Enable": true
  }' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "Response: $RESPONSE3"

# Method 4: Test with different JSON format
echo ""
echo "Method 4: Using alternative JSON format..."
RESPONSE4=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "TunerType": "M3U",
    "Name": "Test Alternative",
    "Url": "https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8",
    "Enable": true
  }' \
  "$JELLYFIN_URL/LiveTv/Tuners" 2>/dev/null)

echo "Response: $RESPONSE4"

echo ""
echo "📋 Step 5: Testing with verbose curl to see detailed responses..."

# Test with verbose output
echo "Testing with verbose curl..."
curl -v -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Verbose Test",
    "Type": "M3U",
    "Url": "https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8",
    "Enable": true
  }' \
  "$JELLYFIN_URL/LiveTv/Tuners" 2>&1 | head -20

echo ""
echo "📋 Step 6: Testing different User-Agent headers..."

# Test with different User-Agent headers
USER_AGENTS=(
    "Jellyfin/10.10.7"
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    "VLC/3.0.0 LibVLC/3.0.0"
    "curl/7.68.0"
)

for ua in "${USER_AGENTS[@]}"; do
    echo "Testing with User-Agent: $ua"
    response=$(curl -s -A "$ua" "https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8" | head -1)
    if [[ "$response" == "#EXTM3U" ]]; then
        echo "  ✅ Works with User-Agent: $ua"
    else
        echo "  ❌ Doesn't work with User-Agent: $ua"
    fi
done

echo ""
echo "📋 Step 7: Testing M3U URL accessibility from Jellyfin server..."

# Test if Jellyfin can access the URLs
echo "Testing URL accessibility from Jellyfin server..."
ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "curl -s -I 'https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8' | head -3"

echo ""
echo "✅ API Testing Complete!"
echo "======================="
echo ""
echo "📊 Summary of findings:"
echo "1. Check which URLs are accessible"
echo "2. Check which API endpoints work"
echo "3. Check which JSON formats work"
echo "4. Check which User-Agent headers work"
echo ""
echo "💡 Next steps:"
echo "1. Use the working URL/format combination"
echo "2. If API doesn't work, use manual web interface"
echo "3. If URLs are blocked, use alternative sources"

