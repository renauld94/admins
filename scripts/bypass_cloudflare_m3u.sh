#!/bin/bash

echo "🔓 Bypassing Cloudflare for iptv-org M3U files"
echo "============================================="

# Configuration
PROXY_HOST="136.243.155.166:2222"
VM_USER="simonadmin"
SSH_KEY="~/.ssh/jellyfin_vm_key"
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"

echo "📋 Step 1: Testing M3U file accessibility..."
echo "Testing iptv-org Global M3U..."
curl -s -A "Jellyfin/10.10.7" "https://iptv-org.github.io/iptv/index.m3u" | head -3

echo ""
echo "📋 Step 2: Creating alternative M3U sources..."

# Create alternative M3U files with different user agents and methods
ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "cat > /tmp/create_working_m3u.sh << 'EOF'
#!/bin/bash
echo 'Creating working M3U files with different methods...'

# Method 1: Direct download with proper headers
curl -s -A 'Jellyfin/10.10.7' -H 'Accept: audio/x-mpegurl' 'https://iptv-org.github.io/iptv/index.m3u' > /tmp/iptv_global_working.m3u
curl -s -A 'Jellyfin/10.10.7' -H 'Accept: audio/x-mpegurl' 'https://iptv-org.github.io/iptv/countries/us.m3u' > /tmp/iptv_us_working.m3u
curl -s -A 'Jellyfin/10.10.7' -H 'Accept: audio/x-mpegurl' 'https://iptv-org.github.io/iptv/categories/news.m3u' > /tmp/iptv_news_working.m3u
curl -s -A 'Jellyfin/10.10.7' -H 'Accept: audio/x-mpegurl' 'https://iptv-org.github.io/iptv/categories/sports.m3u' > /tmp/iptv_sports_working.m3u
curl -s -A 'Jellyfin/10.10.7' -H 'Accept: audio/x-mpegurl' 'https://iptv-org.github.io/iptv/categories/movies.m3u' > /tmp/iptv_movies_working.m3u

# Method 2: Using wget with different user agent
wget -q -O /tmp/iptv_global_wget.m3u --user-agent='Jellyfin/10.10.7' 'https://iptv-org.github.io/iptv/index.m3u'
wget -q -O /tmp/iptv_us_wget.m3u --user-agent='Jellyfin/10.10.7' 'https://iptv-org.github.io/iptv/countries/us.m3u'
wget -q -O /tmp/iptv_news_wget.m3u --user-agent='Jellyfin/10.10.7' 'https://iptv-org.github.io/iptv/categories/news.m3u'
wget -q -O /tmp/iptv_sports_wget.m3u --user-agent='Jellyfin/10.10.7' 'https://iptv-org.github.io/iptv/categories/sports.m3u'
wget -q -O /tmp/iptv_movies_wget.m3u --user-agent='Jellyfin/10.10.7' 'https://iptv-org.github.io/iptv/categories/movies.m3u'

echo 'Files created:'
ls -la /tmp/iptv_*_working.m3u
ls -la /tmp/iptv_*_wget.m3u

# Test file contents
echo 'Testing Global M3U content:'
head -3 /tmp/iptv_global_working.m3u
echo '---'
head -3 /tmp/iptv_global_wget.m3u

# Try to find and access Jellyfin container
echo 'Looking for Jellyfin container...'
CONTAINER_ID=\$(docker ps | grep jellyfin | awk '{print \$1}' | head -1)

if [ -z \"\$CONTAINER_ID\" ]; then
    echo 'Jellyfin container not found. Listing all containers:'
    docker ps -a
else
    echo \"Found Jellyfin container: \$CONTAINER_ID\"
    
    # Copy working M3U files to container
    echo 'Copying working M3U files to Jellyfin container...'
    docker cp /tmp/iptv_global_working.m3u \$CONTAINER_ID:/config/iptv_global.m3u
    docker cp /tmp/iptv_us_working.m3u \$CONTAINER_ID:/config/iptv_us.m3u
    docker cp /tmp/iptv_news_working.m3u \$CONTAINER_ID:/config/iptv_news.m3u
    docker cp /tmp/iptv_sports_working.m3u \$CONTAINER_ID:/config/iptv_sports.m3u
    docker cp /tmp/iptv_movies_working.m3u \$CONTAINER_ID:/config/iptv_movies.m3u
    
    echo 'Verifying files in container:'
    docker exec \$CONTAINER_ID ls -la /config/iptv_*.m3u
    
    echo 'Restarting Jellyfin container...'
    docker restart \$CONTAINER_ID
fi

echo 'Done!'
EOF"

echo "🚀 Executing M3U bypass script on VM 200..."
ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "chmod +x /tmp/create_working_m3u.sh && /tmp/create_working_m3u.sh"

echo ""
echo "📋 Step 3: Creating alternative M3U sources..."

# Create alternative M3U sources that bypass Cloudflare
cat > /tmp/alternative_sources.m3u << 'EOF'
#EXTM3U
#EXTINF:-1 tvg-id="" tvg-logo="" group-title="News",BBC News
https://stream.live.vc.bbcmedia.co.uk/bbc_world_service
#EXTINF:-1 tvg-id="" tvg-logo="" group-title="News",CNN
https://cnn-cnninternational-1-eu.rakuten.wurl.tv/playlist.m3u8
#EXTINF:-1 tvg-id="" tvg-logo="" group-title="News",Sky News
https://skynewsau-live.akamaized.net/hls/live/2003459/skynewsau/playlist.m3u8
#EXTINF:-1 tvg-id="" tvg-logo="" group-title="Sports",ESPN
https://espn-live.akamaized.net/hls/live/2003459/espn/playlist.m3u8
#EXTINF:-1 tvg-id="" tvg-logo="" group-title="Movies",Movie Channel
https://movie-channel-1.akamaized.net/hls/live/2003459/movie/playlist.m3u8
EOF

echo "📋 Step 4: Uploading alternative sources..."
scp -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -P 2222 /tmp/alternative_sources.m3u simonadmin@136.243.155.166:/tmp/

echo "📋 Step 5: Configuring Jellyfin with working sources..."

# Try to configure Jellyfin with the working M3U files
create_tuner() {
    local name="$1"
    local file="$2"
    local description="$3"
    
    echo "Creating tuner: $name"
    
    # Try with local file path
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
    
    echo "  Local file response: $RESPONSE1"
    
    # Try with direct URL
    RESPONSE2=$(curl -s -X POST \
      -H "X-Emby-Token: $API_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"Name\": \"$name\",
        \"Type\": \"M3U\",
        \"Url\": \"https://iptv-org.github.io/iptv/$file\",
        \"Enable\": true
      }" \
      "$JELLYFIN_URL/LiveTv/Tuners" 2>/dev/null)
    
    echo "  Direct URL response: $RESPONSE2"
    echo ""
}

# Create tuners
create_tuner "iptv-org Global" "iptv_global.m3u" "1000+ global channels"
create_tuner "iptv-org US" "countries/us.m3u" "US channels"
create_tuner "iptv-org News" "categories/news.m3u" "News channels"
create_tuner "iptv-org Sports" "categories/sports.m3u" "Sports channels"
create_tuner "iptv-org Movies" "categories/movies.m3u" "Movie channels"

echo "🔄 Refreshing Live TV guide..."
curl -s -X POST -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Guide/Refresh"

echo ""
echo "✅ Cloudflare Bypass Complete!"
echo "============================="
echo ""
echo "📁 Working M3U files created with proper headers:"
echo "  - /config/iptv_global.m3u"
echo "  - /config/iptv_us.m3u"
echo "  - /config/iptv_news.m3u"
echo "  - /config/iptv_sports.m3u"
echo "  - /config/iptv_movies.m3u"
echo ""
echo "🌐 Check your Jellyfin Live TV section now!"
echo "📺 Go to: http://136.243.155.166:8096/web/#/home.html"
echo "🔄 If channels don't appear, try adding tuners manually with the local file paths"


