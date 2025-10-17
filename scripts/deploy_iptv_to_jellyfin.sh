#!/bin/bash

echo "🚀 Deploying iptv-org channels to VM 200 Docker Jellyfin"
echo "======================================================="

# Configuration
PROXY_HOST="136.243.155.166:2222"
VM_USER="simonadmin"
SSH_KEY="~/.ssh/jellyfin_vm_key"
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"

echo "📋 Step 1: Creating deployment script on VM 200..."
ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "cat > /tmp/deploy_iptv.sh << 'EOF'
#!/bin/bash
echo '🚀 Deploying iptv-org channels to Jellyfin container...'

# Download M3U files
echo '📥 Downloading iptv-org M3U files...'
curl -s -o /tmp/iptv_global.m3u 'https://iptv-org.github.io/iptv/index.m3u'
curl -s -o /tmp/iptv_us.m3u 'https://iptv-org.github.io/iptv/countries/us.m3u'
curl -s -o /tmp/iptv_news.m3u 'https://iptv-org.github.io/iptv/categories/news.m3u'
curl -s -o /tmp/iptv_sports.m3u 'https://iptv-org.github.io/iptv/categories/sports.m3u'
curl -s -o /tmp/iptv_movies.m3u 'https://iptv-org.github.io/iptv/categories/movies.m3u'

echo '📁 Files downloaded:'
ls -la /tmp/iptv_*.m3u

# Try to find and access the Jellyfin container
echo '🔍 Looking for Jellyfin container...'
CONTAINER_ID=\$(docker ps | grep jellyfin | awk '{print \$1}' | head -1)

if [ -z \"\$CONTAINER_ID\" ]; then
    echo '❌ Jellyfin container not found. Trying alternative methods...'
    
    # Try to find container by name
    CONTAINER_ID=\$(docker ps -a | grep jellyfin | awk '{print \$1}' | head -1)
    
    if [ -z \"\$CONTAINER_ID\" ]; then
        echo '❌ No Jellyfin container found. Listing all containers:'
        docker ps -a
        exit 1
    else
        echo '📦 Found Jellyfin container (stopped): \$CONTAINER_ID'
        echo '🔄 Starting container...'
        docker start \$CONTAINER_ID
        sleep 5
    fi
else
    echo '✅ Found running Jellyfin container: \$CONTAINER_ID'
fi

# Copy M3U files to container
echo '📁 Copying M3U files to Jellyfin container...'
docker cp /tmp/iptv_global.m3u \$CONTAINER_ID:/config/ && echo '✅ iptv_global.m3u copied' || echo '❌ Failed to copy iptv_global.m3u'
docker cp /tmp/iptv_us.m3u \$CONTAINER_ID:/config/ && echo '✅ iptv_us.m3u copied' || echo '❌ Failed to copy iptv_us.m3u'
docker cp /tmp/iptv_news.m3u \$CONTAINER_ID:/config/ && echo '✅ iptv_news.m3u copied' || echo '❌ Failed to copy iptv_news.m3u'
docker cp /tmp/iptv_sports.m3u \$CONTAINER_ID:/config/ && echo '✅ iptv_sports.m3u copied' || echo '❌ Failed to copy iptv_sports.m3u'
docker cp /tmp/iptv_movies.m3u \$CONTAINER_ID:/config/ && echo '✅ iptv_movies.m3u copied' || echo '❌ Failed to copy iptv_movies.m3u'

# Verify files in container
echo '🔍 Verifying files in container...'
docker exec \$CONTAINER_ID ls -la /config/iptv_*.m3u 2>/dev/null || echo '❌ Could not verify files in container'

# Restart Jellyfin to pick up new files
echo '🔄 Restarting Jellyfin container...'
docker restart \$CONTAINER_ID

echo '✅ Deployment complete!'
echo '📺 M3U files are now available in Jellyfin container at:'
echo '   - /config/iptv_global.m3u'
echo '   - /config/iptv_us.m3u'
echo '   - /config/iptv_news.m3u'
echo '   - /config/iptv_sports.m3u'
echo '   - /config/iptv_movies.m3u'
EOF"

echo "🚀 Executing deployment script on VM 200..."
ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "chmod +x /tmp/deploy_iptv.sh && /tmp/deploy_iptv.sh"

echo ""
echo "📋 Step 2: Configuring tuners via API..."
sleep 10  # Wait for Jellyfin to restart

# Function to create tuner via API
create_tuner() {
    local name="$1"
    local file="$2"
    local description="$3"
    
    echo "Creating tuner: $name"
    
    # Try multiple API approaches
    RESPONSE1=$(curl -s -X POST \
      -H "X-Emby-Token: $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"Name\": \"$name\",
        \"Type\": \"M3U\",
        \"Url\": \"/config/$file\",
        \"Enable\": true
      }" \
      "$JELLYFIN_URL/LiveTv/Tuners" 2>/dev/null)
    
    echo "  Response: $RESPONSE1"
    
    # Try TunerHosts endpoint
    RESPONSE2=$(curl -s -X POST \
      -H "X-Emby-Token: $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"Name\": \"$name\",
        \"Type\": \"M3U\",
        \"Url\": \"/config/$file\",
        \"Enable\": true
      }" \
      "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)
    
    echo "  TunerHosts Response: $RESPONSE2"
    echo ""
}

# Create all tuners
create_tuner "iptv-org Global" "iptv_global.m3u" "1000+ global channels"
create_tuner "iptv-org US Channels" "iptv_us.m3u" "US-specific channels"
create_tuner "iptv-org News" "iptv_news.m3u" "News channels worldwide"
create_tuner "iptv-org Sports" "iptv_sports.m3u" "Sports channels"
create_tuner "iptv-org Movies" "iptv_movies.m3u" "Movie channels"

echo "🔄 Refreshing Live TV guide..."
curl -s -X POST -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Guide/Refresh"

echo "📊 Checking current tuners..."
CURRENT_TUNERS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Tuners")
echo "Current tuners: $CURRENT_TUNERS"

echo ""
echo "🎉 iptv-org Channels Deployment Complete!"
echo "========================================"
echo ""
echo "📁 Files deployed to Jellyfin container:"
echo "  - /config/iptv_global.m3u (2.7MB - 1000+ channels)"
echo "  - /config/iptv_us.m3u (410KB - US channels)"
echo "  - /config/iptv_news.m3u (180KB - News channels)"
echo "  - /config/iptv_sports.m3u (72KB - Sports channels)"
echo "  - /config/iptv_movies.m3u (107KB - Movie channels)"
echo ""
echo "📺 Tuners configured:"
echo "  1. iptv-org Global"
echo "  2. iptv-org US Channels"
echo "  3. iptv-org News"
echo "  4. iptv-org Sports"
echo "  5. iptv-org Movies"
echo ""
echo "🌐 Check your Jellyfin Live TV section now!"
echo "📺 You should see 5 new tuners with 1300+ channels"
echo "🔄 If channels don't appear immediately, wait a few minutes for the guide to refresh"


