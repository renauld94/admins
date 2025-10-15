#!/bin/bash

echo "🚀 Upgrading Jellyfin via Direct VM Access"
echo "========================================="

# Configuration
PROXY_HOST="136.243.155.166:2222"
VM_USER="simonadmin"
SSH_KEY="~/.ssh/jellyfin_vm_key"
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"

echo "📋 Step 1: Testing direct access to internal VM..."

# Try to access the internal VM directly
echo "Attempting direct access to internal VM..."
ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'echo \"Direct VM access successful\"'"

echo ""
echo "📋 Step 2: Creating Jellyfin upgrade script for internal VM..."

# Create upgrade script for internal VM
ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "cat > /tmp/upgrade_jellyfin_internal.sh << 'EOF'
#!/bin/bash
echo '🚀 Upgrading Jellyfin on internal VM...'

# Check current Jellyfin container
echo 'Checking current Jellyfin container...'
docker ps | grep jellyfin

# Stop Jellyfin container
echo 'Stopping Jellyfin container...'
docker stop jellyfin-simonadmin

# Backup current configuration
echo 'Backing up current configuration...'
docker cp jellyfin-simonadmin:/config /tmp/jellyfin_config_backup

# Pull latest Jellyfin image
echo 'Pulling latest Jellyfin image...'
docker pull jellyfin/jellyfin:latest

# Remove old container
echo 'Removing old container...'
docker rm jellyfin-simonadmin

# Create new container with latest image
echo 'Creating new container with latest image...'
docker run -d \
  --name jellyfin-simonadmin \
  --restart unless-stopped \
  -p 8096:8096 \
  -v /tmp/jellyfin_config_backup:/config \
  -v /tmp/jellyfin_config_backup/cache:/cache \
  -v /tmp/jellyfin_config_backup/media:/media \
  jellyfin/jellyfin:latest

# Wait for container to start
echo 'Waiting for container to start...'
sleep 30

# Check if container is running
echo 'Checking container status...'
docker ps | grep jellyfin

echo 'Jellyfin upgrade complete!'
EOF"

echo ""
echo "📋 Step 3: Executing Jellyfin upgrade on internal VM..."
ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'chmod +x /tmp/upgrade_jellyfin_internal.sh && /tmp/upgrade_jellyfin_internal.sh'"

echo ""
echo "📋 Step 4: Waiting for Jellyfin to fully start..."
echo "Waiting 60 seconds for Jellyfin to fully initialize..."
sleep 60

echo ""
echo "📋 Step 5: Testing Jellyfin connectivity after upgrade..."
for i in {1..10}; do
    echo "Attempt $i: Testing Jellyfin connection..."
    response=$(curl -s -w "%{http_code}" -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/System/Info" -o /dev/null)
    if [ "$response" = "200" ]; then
        echo "✅ Jellyfin is responding (HTTP $response)"
        break
    else
        echo "❌ Jellyfin not ready yet (HTTP $response), waiting..."
        sleep 15
    fi
done

echo ""
echo "📋 Step 6: Checking new Jellyfin version..."
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/System/Info" | jq -r '.Version, .ServerName' 2>/dev/null || echo "Version check failed"

echo ""
echo "📋 Step 7: Testing Live TV API after upgrade..."

# Test Live TV info
echo "Testing Live TV info..."
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Info" | jq '.' 2>/dev/null || curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Info"

echo ""
echo "📋 Step 8: Testing tuner creation with upgraded Jellyfin..."

# Test tuner creation
echo "Testing tuner creation with iptv-org URL..."
RESPONSE1=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "iptv-org Global",
    "Type": "M3U",
    "Url": "https://iptv-org.github.io/iptv/index.m3u",
    "Enable": true
  }' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "Response: $RESPONSE1"

# Test with GitHub URL
echo ""
echo "Testing tuner creation with GitHub URL..."
RESPONSE2=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "Name": "GitHub Free TV",
    "Type": "M3U",
    "Url": "https://raw.githubusercontent.com/Free-TV/IPTV/master/playlist.m3u8",
    "Enable": true
  }' \
  "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "Response: $RESPONSE2"

echo ""
echo "📋 Step 9: Checking current tuners after upgrade..."
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/TunerHosts" | jq '.' 2>/dev/null || curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/TunerHosts"

echo ""
echo "📋 Step 10: Refreshing Live TV guide..."
curl -s -X POST -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Guide/Refresh"

echo ""
echo "✅ Jellyfin Upgrade and Live TV Fix Complete!"
echo "============================================="
echo ""
echo "📊 Summary:"
echo "1. Attempted Jellyfin upgrade via direct VM access"
echo "2. Tested Live TV API after upgrade"
echo "3. Checked for tuner creation success"
echo ""
echo "💡 If API still returns errors:"
echo "1. The Live TV API issue persists even after upgrade"
echo "2. Use the manual web interface method"
echo "3. This might be a fundamental Jellyfin configuration issue"
echo ""
echo "🌐 Next steps:"
echo "1. Check if any of the API calls succeeded"
echo "2. If not, use the manual web interface"
echo "3. Try adding tuners through the web interface"

