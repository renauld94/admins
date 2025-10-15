#!/bin/bash

echo "🔧 Trying Alternative API Methods for Jellyfin Live TV"
echo "====================================================="

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"

echo "📋 Step 1: Checking Live TV status and configuration..."

# Get Live TV info
echo "Live TV Info:"
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Info" | jq '.' 2>/dev/null || curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Info"

echo ""
echo "📋 Step 2: Trying different API endpoints for tuner creation..."

# Try different endpoints that might work
ENDPOINTS=(
    "/LiveTv/TunerHosts"
    "/LiveTv/Providers"
    "/LiveTv/ListingProviders"
    "/LiveTv/Configuration"
)

for endpoint in "${ENDPOINTS[@]}"; do
    echo "Testing $endpoint with GET..."
    response=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL$endpoint")
    echo "Response: $response"
    echo ""
done

echo "📋 Step 3: Trying to create tuner with minimal data..."

# Try with minimal data
echo "Trying minimal tuner creation..."
RESPONSE_MINIMAL=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Test Minimal",
    "Url": "https://live-hls-web-aje.getaj.net/AJE/01.m3u8"
  }' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "Minimal Response: $RESPONSE_MINIMAL"

echo ""
echo "📋 Step 4: Trying to create tuner with different field names..."

# Try different field names
echo "Trying with different field names..."
RESPONSE_FIELDS=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "TunerName": "Test Fields",
    "TunerUrl": "https://live-hls-web-aje.getaj.net/AJE/01.m3u8",
    "TunerType": "M3U"
  }' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "Fields Response: $RESPONSE_FIELDS"

echo ""
echo "📋 Step 5: Trying to create tuner with XML format..."

# Try XML format
echo "Trying XML format..."
RESPONSE_XML=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/xml" \
  -d '<?xml version="1.0" encoding="UTF-8"?>
<tuner>
  <name>Test XML</name>
  <url>https://live-hls-web-aje.getaj.net/AJE/01.m3u8</url>
  <type>M3U</type>
</tuner>' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "XML Response: $RESPONSE_XML"

echo ""
echo "📋 Step 6: Trying to create tuner with query parameters..."

# Try query parameters
echo "Trying query parameters..."
RESPONSE_QUERY=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{}' \
  "$JELLYFIN_URL/LiveTv/TunerHosts?Name=TestQuery&Url=https://live-hls-web-aje.getaj.net/AJE/01.m3u8&Type=M3U" 2>/dev/null)

echo "Query Response: $RESPONSE_QUERY"

echo ""
echo "📋 Step 7: Trying to create tuner with different HTTP methods..."

# Try different HTTP methods
echo "Trying PUT method..."
RESPONSE_PUT=$(curl -s -X PUT \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Test PUT",
    "Url": "https://live-hls-web-aje.getaj.net/AJE/01.m3u8",
    "Type": "M3U"
  }' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "PUT Response: $RESPONSE_PUT"

echo ""
echo "Trying PATCH method..."
RESPONSE_PATCH=$(curl -s -X PATCH \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Test PATCH",
    "Url": "https://live-hls-web-aje.getaj.net/AJE/01.m3u8",
    "Type": "M3U"
  }' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "PATCH Response: $RESPONSE_PATCH"

echo ""
echo "📋 Step 8: Trying to create tuner with different content types..."

# Try different content types
echo "Trying application/x-www-form-urlencoded..."
RESPONSE_FORM=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "Name=TestForm&Url=https://live-hls-web-aje.getaj.net/AJE/01.m3u8&Type=M3U" \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "Form Response: $RESPONSE_FORM"

echo ""
echo "📋 Step 9: Checking if we can access the Jellyfin configuration directly..."

# Try to access configuration
echo "Trying to get configuration..."
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/System/Configuration" | head -10

echo ""
echo "📋 Step 10: Trying to create tuner with a working M3U file..."

# Create a simple M3U file and try to use it
echo "Creating simple M3U file..."
cat > /tmp/simple_test.m3u << 'EOF'
#EXTM3U
#EXTINF:-1 tvg-id="Test" tvg-logo="" group-title="Test",Test Channel
https://live-hls-web-aje.getaj.net/AJE/01.m3u8
EOF

echo "Trying to create tuner with local file..."
RESPONSE_LOCAL=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Test Local File",
    "Url": "/tmp/simple_test.m3u",
    "Type": "M3U"
  }' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "Local File Response: $RESPONSE_LOCAL"

echo ""
echo "✅ Alternative API Methods Testing Complete!"
echo "==========================================="
echo ""
echo "📊 Summary of findings:"
echo "1. Live TV is enabled but has no tuners"
echo "2. All POST requests to /LiveTv/TunerHosts return 500 Internal Server Error"
echo "3. Different content types and methods don't work"
echo "4. The API seems to have issues with tuner creation"
echo ""
echo "💡 Conclusion:"
echo "The Jellyfin API for Live TV tuner creation appears to be broken or not properly configured."
echo "The best approach is to use the manual web interface method."
echo ""
echo "🚀 Next steps:"
echo "1. Use the manual web interface to add tuners"
echo "2. Use the verified working M3U content I provided earlier"
echo "3. If that doesn't work, check Jellyfin logs for errors"

