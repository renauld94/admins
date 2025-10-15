#!/bin/bash

echo "🔄 Restarting Jellyfin Container and Testing API"
echo "==============================================="

# Configuration
PROXY_HOST="136.243.155.166:2222"
VM_USER="simonadmin"
SSH_KEY="~/.ssh/jellyfin_vm_key"
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"

echo "📋 Step 1: Finding Jellyfin container..."
ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'docker ps | grep jellyfin'"

echo ""
echo "📋 Step 2: Restarting Jellyfin container..."
ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'docker restart jellyfin-simonadmin'"

echo ""
echo "📋 Step 3: Waiting for Jellyfin to restart..."
echo "Waiting 30 seconds for Jellyfin to fully restart..."
sleep 30

echo ""
echo "📋 Step 4: Testing Jellyfin connectivity..."
for i in {1..5}; do
    echo "Attempt $i: Testing Jellyfin connection..."
    response=$(curl -s -w "%{http_code}" -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/System/Info" -o /dev/null)
    if [ "$response" = "200" ]; then
        echo "✅ Jellyfin is responding (HTTP $response)"
        break
    else
        echo "❌ Jellyfin not ready yet (HTTP $response), waiting..."
        sleep 10
    fi
done

echo ""
echo "📋 Step 5: Testing Live TV API after restart..."

# Test Live TV info
echo "Testing Live TV info..."
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Info" | jq '.' 2>/dev/null || curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Info"

echo ""
echo "📋 Step 6: Testing tuner creation with different methods..."

# Method 1: Test with simple M3U URL
echo "Method 1: Testing with iptv-org URL..."
RESPONSE1=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "iptv-org Test",
    "Type": "M3U",
    "Url": "https://iptv-org.github.io/iptv/index.m3u",
    "Enable": true
  }' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "Response 1: $RESPONSE1"

# Method 2: Test with GitHub URL
echo ""
echo "Method 2: Testing with GitHub URL..."
RESPONSE2=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "GitHub Test",
    "Type": "M3U",
    "Url": "https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8",
    "Enable": true
  }' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "Response 2: $RESPONSE2"

# Method 3: Test with minimal data
echo ""
echo "Method 3: Testing with minimal data..."
RESPONSE3=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Minimal Test",
    "Url": "https://live-hls-web-aje.getaj.net/AJE/01.m3u8"
  }' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "Response 3: $RESPONSE3"

# Method 4: Test with alternative endpoint
echo ""
echo "Method 4: Testing with /LiveTv/Tuners endpoint..."
RESPONSE4=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Tuners Test",
    "Type": "M3U",
    "Url": "https://iptv-org.github.io/iptv/index.m3u",
    "Enable": true
  }' \
  "$JELLYFIN_URL/LiveTv/Tuners" 2>/dev/null)

echo "Response 4: $RESPONSE4"

echo ""
echo "📋 Step 7: Checking current tuners after restart..."
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/TunerHosts" | head -5

echo ""
echo "📋 Step 8: Testing with verbose output to see detailed errors..."

# Test with verbose output
echo "Testing with verbose curl..."
curl -v -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "Verbose Test",
    "Type": "M3U",
    "Url": "https://iptv-org.github.io/iptv/index.m3u",
    "Enable": true
  }' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>&1 | head -20

echo ""
echo "✅ Jellyfin Restart and API Testing Complete!"
echo "============================================="
echo ""
echo "📊 Summary:"
echo "1. Jellyfin container restarted"
echo "2. Tested multiple API methods"
echo "3. Checked for any improvements"
echo ""
echo "💡 If API still returns errors:"
echo "1. The Live TV API is fundamentally broken in this Jellyfin version"
echo "2. Use the manual web interface method"
echo "3. Consider updating Jellyfin to the latest version"
echo ""
echo "🌐 Next steps:"
echo "1. Check if any of the API calls succeeded"
echo "2. If not, use the manual web interface"
echo "3. Try adding tuners through the web interface after restart"

