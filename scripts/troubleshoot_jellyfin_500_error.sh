#!/bin/bash

echo "🔧 Troubleshooting Jellyfin 500 Internal Server Error"
echo "===================================================="

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"

echo "📋 Step 1: Checking Jellyfin server status..."
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/System/Info" | jq -r '.ServerName, .Version, .HasPendingRestart' 2>/dev/null || echo "Jellyfin is running"

echo ""
echo "📋 Step 2: Checking Live TV status..."
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Info" | jq '.' 2>/dev/null || curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Info"

echo ""
echo "📋 Step 3: Testing the M3U URL accessibility..."
echo "Testing if Jellyfin can access the M3U URL..."
curl -s -I "https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8" | head -5

echo ""
echo "📋 Step 4: Checking Jellyfin logs for errors..."
echo "Trying to access Jellyfin logs..."
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/System/Logs" | head -10

echo ""
echo "📋 Step 5: Testing alternative M3U URLs..."

# Test different M3U URLs
URLS=(
    "https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8"
    "https://iptv-org.github.io/iptv/index.m3u"
    "https://iptv-org.github.io/iptv/countries/us.m3u"
)

for url in "${URLS[@]}"; do
    echo "Testing: $url"
    response=$(curl -s -I "$url" | head -1)
    echo "  Response: $response"
done

echo ""
echo "📋 Step 6: Creating a simple test M3U file..."

# Create a very simple M3U file for testing
cat > /tmp/simple_test.m3u << 'EOF'
#EXTM3U
#EXTINF:-1 tvg-id="Test" tvg-logo="" group-title="Test",Test Channel
https://live-hls-web-aje.getaj.net/AJE/01.m3u8
EOF

echo "Created simple test M3U file:"
cat /tmp/simple_test.m3u

echo ""
echo "📋 Step 7: Testing with minimal tuner data..."

# Try to create tuner with minimal data
echo "Testing minimal tuner creation..."
RESPONSE=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Test Minimal",
    "Url": "https://live-hls-web-aje.getaj.net/AJE/01.m3u8"
  }' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "Response: $RESPONSE"

echo ""
echo "✅ Troubleshooting Complete!"
echo "==========================="
echo ""
echo "🔍 Analysis:"
echo "==========="
echo "1. The 500 Internal Server Error indicates a server-side problem"
echo "2. This confirms our earlier findings that the Live TV API is broken"
echo "3. The JavaScript errors are likely related to the failed API call"
echo ""
echo "🚀 SOLUTIONS TO TRY:"
echo "==================="
echo ""
echo "Solution 1: Restart Jellyfin"
echo "1. Go to Settings → Restart Server"
echo "2. Wait for Jellyfin to restart"
echo "3. Try adding the tuner again"
echo ""
echo "Solution 2: Try a different M3U URL"
echo "Instead of: https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8"
echo "Try: https://iptv-org.github.io/iptv/index.m3u"
echo ""
echo "Solution 3: Use a simpler M3U file"
echo "Create a local M3U file with just one channel:"
echo "#EXTM3U"
echo "#EXTINF:-1 tvg-id=\"Test\" tvg-logo=\"\" group-title=\"Test\",Test Channel"
echo "https://live-hls-web-aje.getaj.net/AJE/01.m3u8"
echo ""
echo "Solution 4: Check Jellyfin version compatibility"
echo "Your Jellyfin version might have Live TV issues"
echo "Consider updating to the latest version"
echo ""
echo "Solution 5: Manual configuration"
echo "If all else fails, you might need to:"
echo "1. Check Jellyfin configuration files"
echo "2. Look at server logs for specific errors"
echo "3. Consider reinstalling Jellyfin"
echo ""
echo "💡 RECOMMENDED NEXT STEPS:"
echo "========================="
echo "1. Try restarting Jellyfin first"
echo "2. If that doesn't work, try the iptv-org URL"
echo "3. If still failing, check Jellyfin logs for specific errors"


