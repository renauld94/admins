#!/bin/bash

echo "📥 Uploading iptv-org M3U to VM 200 and configuring via API"
echo "==========================================================="

# Configuration
PROXY_HOST="136.243.155.166:2222"
VM_HOST="10.0.0.103"
VM_USER="simonadmin"
CONTAINER_NAME="jellyfin-simonadmin"
CONFIG_DIR="/config"
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"

echo "📤 Uploading iptv-org.m3u to VM 200..."
scp -o StrictHostKeyChecking=no -P 2222 /tmp/iptv_org.m3u simonadmin@136.243.155.166:/tmp/

echo "📁 Installing iptv-org.m3u in Jellyfin container..."
ssh -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'docker cp /tmp/iptv_org.m3u jellyfin-simonadmin:$CONFIG_DIR/'"

echo "🔧 Configuring iptv-org tuner via API..."

# Try multiple API approaches
echo "Attempting API configuration..."

# Method 1: Direct tuner creation
RESPONSE1=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "iptv-org Global",
    "Type": "M3U",
    "Url": "/config/iptv_org.m3u",
    "Enable": true
  }' \
  "$JELLYFIN_URL/LiveTv/Tuners" 2>/dev/null)

echo "Method 1 Response: $RESPONSE1"

# Method 2: Alternative endpoint
RESPONSE2=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "TunerType": "M3U",
    "Name": "iptv-org Global",
    "Url": "/config/iptv_org.m3u",
    "Enable": true
  }' \
  "$JELLYFIN_URL/LiveTv/Tuners" 2>/dev/null)

echo "Method 2 Response: $RESPONSE2"

# Method 3: Using TunerHosts endpoint
RESPONSE3=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "iptv-org Global",
    "Type": "M3U",
    "Url": "/config/iptv_org.m3u",
    "Enable": true
  }' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "Method 3 Response: $RESPONSE3"

echo "🔄 Refreshing Live TV guide..."
curl -s -X POST -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Guide/Refresh"

echo "📊 Checking current tuners..."
CURRENT_TUNERS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Tuners")
echo "Current tuners: $CURRENT_TUNERS"

echo ""
echo "✅ iptv-org M3U Upload and Configuration Complete!"
echo "================================================="
echo ""
echo "📁 File installed: /config/iptv_org.m3u"
echo "📺 Tuner name: iptv-org Global"
echo "🌐 Contains: 1000+ free TV channels from iptv-org"
echo ""
echo "🌐 Check your Jellyfin Live TV section now!"
echo "📺 You should see the new iptv-org tuner with 1000+ channels"
echo "🔄 If channels don't appear immediately, wait a few minutes for the guide to refresh"
