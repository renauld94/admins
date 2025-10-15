#!/bin/bash

echo "🧪 Testing Jellyfin API Execution - Finding Working Method"
echo "========================================================"

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"

echo "📋 Step 1: Testing Jellyfin API connectivity..."
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/System/Info" | jq -r '.ServerName, .Version' 2>/dev/null || echo "Jellyfin is accessible"

echo ""
echo "📋 Step 2: Testing all possible Live TV API endpoints..."

# Test all possible Live TV endpoints
ENDPOINTS=(
    "/LiveTv"
    "/LiveTv/Tuners"
    "/LiveTv/TunerHosts"
    "/LiveTv/Configuration"
    "/LiveTv/Info"
    "/LiveTv/Recordings"
    "/LiveTv/Channels"
    "/LiveTv/Programs"
    "/LiveTv/Guide"
    "/LiveTv/Providers"
    "/LiveTv/ListingProviders"
    "/LiveTv/SeriesTimers"
    "/LiveTv/Timers"
)

for endpoint in "${ENDPOINTS[@]}"; do
    echo "Testing $endpoint..."
    response=$(curl -s -w "%{http_code}" -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL$endpoint" -o /dev/null)
    echo "  HTTP Status: $response"
done

echo ""
echo "📋 Step 3: Testing tuner creation with different JSON formats..."

# Test different JSON formats for tuner creation
echo "Method 1: Basic M3U tuner..."
RESPONSE1=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Test M3U Tuner",
    "Type": "M3U",
    "Url": "https://live-hls-web-aje.getaj.net/AJE/01.m3u8",
    "Enable": true
  }' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "Response: $RESPONSE1"

echo ""
echo "Method 2: Alternative JSON format..."
RESPONSE2=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "TunerType": "M3U",
    "Name": "Test M3U Tuner 2",
    "Url": "https://live-hls-web-aje.getaj.net/AJE/01.m3u8",
    "Enable": true
  }' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "Response: $RESPONSE2"

echo ""
echo "Method 3: Minimal JSON format..."
RESPONSE3=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Test M3U Tuner 3",
    "Url": "https://live-hls-web-aje.getaj.net/AJE/01.m3u8"
  }' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "Response: $RESPONSE3"

echo ""
echo "Method 4: Using /LiveTv/Tuners endpoint..."
RESPONSE4=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Test M3U Tuner 4",
    "Type": "M3U",
    "Url": "https://live-hls-web-aje.getaj.net/AJE/01.m3u8",
    "Enable": true
  }' \
  "$JELLYFIN_URL/LiveTv/Tuners" 2>/dev/null)

echo "Response: $RESPONSE4"

echo ""
echo "📋 Step 4: Testing with different HTTP methods..."

# Test different HTTP methods
echo "Testing PUT method..."
RESPONSE_PUT=$(curl -s -X PUT \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Test M3U Tuner PUT",
    "Type": "M3U",
    "Url": "https://live-hls-web-aje.getaj.net/AJE/01.m3u8",
    "Enable": true
  }' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "PUT Response: $RESPONSE_PUT"

echo ""
echo "Testing PATCH method..."
RESPONSE_PATCH=$(curl -s -X PATCH \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Test M3U Tuner PATCH",
    "Type": "M3U",
    "Url": "https://live-hls-web-aje.getaj.net/AJE/01.m3u8",
    "Enable": true
  }' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "PATCH Response: $RESPONSE_PATCH"

echo ""
echo "📋 Step 5: Testing with verbose output to see detailed errors..."

# Test with verbose output
echo "Testing with verbose curl..."
curl -v -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Verbose Test",
    "Type": "M3U",
    "Url": "https://live-hls-web-aje.getaj.net/AJE/01.m3u8",
    "Enable": true
  }' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>&1 | head -30

echo ""
echo "📋 Step 6: Testing with different content types..."

# Test different content types
echo "Testing with application/x-www-form-urlencoded..."
RESPONSE_FORM=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "Name=TestForm&Type=M3U&Url=https://live-hls-web-aje.getaj.net/AJE/01.m3u8&Enable=true" \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "Form Response: $RESPONSE_FORM"

echo ""
echo "Testing with text/plain..."
RESPONSE_TEXT=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: text/plain" \
  -d "Name=TestText&Type=M3U&Url=https://live-hls-web-aje.getaj.net/AJE/01.m3u8&Enable=true" \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "Text Response: $RESPONSE_TEXT"

echo ""
echo "📋 Step 7: Testing with different M3U URLs..."

# Test different M3U URLs
M3U_URLS=(
    "https://live-hls-web-aje.getaj.net/AJE/01.m3u8"
    "https://bloomberg-live.akamaized.net/hls/live/2003459/bloomberg/playlist.m3u8"
    "https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8"
    "https://iptv-org.github.io/iptv/index.m3u"
)

for url in "${M3U_URLS[@]}"; do
    echo "Testing with URL: $url"
    response=$(curl -s -X POST \
      -H "X-Emby-Token: $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"Name\": \"Test with $(basename $url)\",
        \"Type\": \"M3U\",
        \"Url\": \"$url\",
        \"Enable\": true
      }" \
      "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)
    
    echo "  Response: $response"
done

echo ""
echo "📋 Step 8: Testing GET requests to see existing tuners..."

# Test GET requests
echo "Getting existing tuners..."
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/TunerHosts" | head -5

echo ""
echo "Getting Live TV configuration..."
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Configuration" | head -5

echo ""
echo "✅ API Testing Complete!"
echo "======================="
echo ""
echo "📊 Summary:"
echo "1. Tested all Live TV endpoints"
echo "2. Tested different JSON formats"
echo "3. Tested different HTTP methods"
echo "4. Tested different content types"
echo "5. Tested different M3U URLs"
echo "6. Tested GET requests for existing data"
echo ""
echo "💡 Next steps:"
echo "1. Check which methods return success responses"
echo "2. Use the working method for actual tuner creation"
echo "3. If API doesn't work, use manual web interface"

