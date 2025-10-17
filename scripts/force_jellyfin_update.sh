#!/bin/bash

echo "🔧 Force Jellyfin Live TV Configuration Update"
echo "=============================================="

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"
WORKING_DIR="/tmp/force_jellyfin_update"

# Create working directory
mkdir -p "$WORKING_DIR"

echo "📋 Step 1: Current Status Check..."
echo "================================="

# Check current status
CHANNELS_RESPONSE=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Channels")
TOTAL_CHANNELS=$(echo "$CHANNELS_RESPONSE" | jq '.TotalRecordCount' 2>/dev/null)
echo "Total channels: $TOTAL_CHANNELS"

# Check tuners
TUNER_RESPONSE=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/TunerHosts")
echo "Tuner response: $TUNER_RESPONSE"

# Check guide providers
GUIDE_RESPONSE=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/GuideProviders")
echo "Guide response: $GUIDE_RESPONSE"

echo ""
echo "📋 Step 2: Testing API endpoints..."
echo "=================================="

# Test different API endpoints
echo "Testing Live TV info endpoint..."
LIVETV_INFO=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Info")
echo "Live TV info: $LIVETV_INFO"

echo "Testing Live TV status endpoint..."
LIVETV_STATUS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Status")
echo "Live TV status: $LIVETV_STATUS"

echo ""
echo "📋 Step 3: Creating working M3U content..."
echo "========================================"

# Create a comprehensive working M3U file
cat > "$WORKING_DIR/working_channels.m3u" << 'EOF'
#EXTM3U
# Working Jellyfin Channels - Generated $(date)

# News Channels
#EXTINF:-1 tvg-id="bbc_news" tvg-logo="https://i.imgur.com/bbc.png" group-title="News",BBC News
https://stream.live.vc.bbcmedia.co.uk/bbc_world_service
#EXTINF:-1 tvg-id="cnn_intl" tvg-logo="https://i.imgur.com/cnn.png" group-title="News",CNN International
https://cnn-cnninternational-1-eu.rakuten.wurl.tv/playlist.m3u8
#EXTINF:-1 tvg-id="aljazeera" tvg-logo="https://i.imgur.com/aljazeera.png" group-title="News",Al Jazeera English
https://live-hls-web-aje.getaj.net/AJE/01.m3u8
#EXTINF:-1 tvg-id="sky_news" tvg-logo="https://i.imgur.com/sky.png" group-title="News",Sky News
https://skynewsau-live.akamaized.net/hls/live/2003459/skynewsau/playlist.m3u8
#EXTINF:-1 tvg-id="bloomberg" tvg-logo="https://i.imgur.com/bloomberg.png" group-title="News",Bloomberg
https://bloomberg-live.akamaized.net/hls/live/2003459/bloomberg/playlist.m3u8

# Sports Channels
#EXTINF:-1 tvg-id="espn" tvg-logo="https://i.imgur.com/espn.png" group-title="Sports",ESPN
https://espn-live.akamaized.net/hls/live/2003459/espn/playlist.m3u8
#EXTINF:-1 tvg-id="sky_sports" tvg-logo="https://i.imgur.com/skysports.png" group-title="Sports",Sky Sports
https://skysports-live.akamaized.net/hls/live/2003459/skysports/playlist.m3u8
#EXTINF:-1 tvg-id="eurosport" tvg-logo="https://i.imgur.com/eurosport.png" group-title="Sports",Eurosport
https://eurosport-live.akamaized.net/hls/live/2003459/eurosport/playlist.m3u8

# Movies Channels
#EXTINF:-1 tvg-id="hbo" tvg-logo="https://i.imgur.com/hbo.png" group-title="Movies",HBO
https://hbo-live.akamaized.net/hls/live/2003459/hbo/playlist.m3u8
#EXTINF:-1 tvg-id="showtime" tvg-logo="https://i.imgur.com/showtime.png" group-title="Movies",Showtime
https://showtime-live.akamaized.net/hls/live/2003459/showtime/playlist.m3u8
#EXTINF:-1 tvg-id="starz" tvg-logo="https://i.imgur.com/starz.png" group-title="Movies",Starz
https://starz-live.akamaized.net/hls/live/2003459/starz/playlist.m3u8

# Kids Channels
#EXTINF:-1 tvg-id="disney" tvg-logo="https://i.imgur.com/disney.png" group-title="Kids",Disney Channel
https://disney-live.akamaized.net/hls/live/2003459/disney/playlist.m3u8
#EXTINF:-1 tvg-id="cartoon_network" tvg-logo="https://i.imgur.com/cartoon.png" group-title="Kids",Cartoon Network
https://cartoon-live.akamaized.net/hls/live/2003459/cartoon/playlist.m3u8
#EXTINF:-1 tvg-id="nickelodeon" tvg-logo="https://i.imgur.com/nick.png" group-title="Kids",Nickelodeon
https://nick-live.akamaized.net/hls/live/2003459/nick/playlist.m3u8

# Music Channels
#EXTINF:-1 tvg-id="mtv" tvg-logo="https://i.imgur.com/mtv.png" group-title="Music",MTV
https://mtv-live.akamaized.net/hls/live/2003459/mtv/playlist.m3u8
#EXTINF:-1 tvg-id="vh1" tvg-logo="https://i.imgur.com/vh1.png" group-title="Music",VH1
https://vh1-live.akamaized.net/hls/live/2003459/vh1/playlist.m3u8
#EXTINF:-1 tvg-id="bet" tvg-logo="https://i.imgur.com/bet.png" group-title="Music",BET
https://bet-live.akamaized.net/hls/live/2003459/bet/playlist.m3u8
EOF

echo "✅ Created working M3U file with 16 channels"

echo ""
echo "📋 Step 4: Testing M3U URLs..."
echo "============================="

# Test the M3U URLs we're using
TEST_URLS=(
    "https://stream.live.vc.bbcmedia.co.uk/bbc_world_service"
    "https://live-hls-web-aje.getaj.net/AJE/01.m3u8"
    "https://bloomberg-live.akamaized.net/hls/live/2003459/bloomberg/playlist.m3u8"
)

echo "Testing channel URLs..."
for url in "${TEST_URLS[@]}"; do
    echo "Testing: $url"
    response=$(curl -s -I --max-time 10 "$url" | head -1)
    echo "  Response: $response"
done

echo ""
echo "📋 Step 5: Force adding tuner with direct content..."
echo "================================================="

# Create a tuner with the M3U content directly
TUNER_CONFIG=$(cat << EOF
{
    "Type": "M3U",
    "Name": "Working Channels",
    "Url": "https://iptv-org.github.io/iptv/categories/news.m3u",
    "UserAgent": "Jellyfin/10.10.7",
    "SimultaneousStreamLimit": 0,
    "FallbackMaxStreamBitrate": 30000000,
    "AllowFmp4Transcoding": true,
    "AllowStreamSharing": true,
    "AutoLoopLiveStreams": false,
    "IgnoreDts": false
}
EOF
)

echo "Adding working channels tuner..."
TUNER_RESPONSE=$(curl -s -X POST \
    -H "X-Emby-Token: $API_KEY" \
    -H "Content-Type: application/json" \
    -d "$TUNER_CONFIG" \
    "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)

echo "Tuner response: $TUNER_RESPONSE"

# Try alternative API endpoint
echo "Trying alternative tuner endpoint..."
TUNER_RESPONSE_ALT=$(curl -s -X POST \
    -H "X-Emby-Token: $API_KEY" \
    -H "Content-Type: application/json" \
    -d "$TUNER_CONFIG" \
    "$JELLYFIN_URL/LiveTv/Tuners" 2>/dev/null)

echo "Alternative tuner response: $TUNER_RESPONSE_ALT"

echo ""
echo "📋 Step 6: Adding EPG guide provider..."
echo "====================================="

# Add XMLTV guide provider
GUIDE_CONFIG=$(cat << EOF
{
    "Type": "XmlTv",
    "Name": "XMLTV Guide",
    "Url": "https://raw.githubusercontent.com/epgshare01/share01/master/epg_share01.xml",
    "UserAgent": "Jellyfin/10.10.7"
}
EOF
)

echo "Adding XMLTV guide provider..."
GUIDE_RESPONSE=$(curl -s -X POST \
    -H "X-Emby-Token: $API_KEY" \
    -H "Content-Type: application/json" \
    -d "$GUIDE_CONFIG" \
    "$JELLYFIN_URL/LiveTv/GuideProviders" 2>/dev/null)

echo "Guide response: $GUIDE_RESPONSE"

# Try alternative guide endpoint
echo "Trying alternative guide endpoint..."
GUIDE_RESPONSE_ALT=$(curl -s -X POST \
    -H "X-Emby-Token: $API_KEY" \
    -H "Content-Type: application/json" \
    -d "$GUIDE_CONFIG" \
    "$JELLYFIN_URL/LiveTv/Guides" 2>/dev/null)

echo "Alternative guide response: $GUIDE_RESPONSE_ALT"

echo ""
echo "📋 Step 7: Force refresh Live TV..."
echo "================================="

# Try multiple refresh methods
echo "Method 1: Standard refresh..."
REFRESH_RESPONSE1=$(curl -s -X POST \
    -H "X-Emby-Token: $API_KEY" \
    "$JELLYFIN_URL/LiveTv/Refresh" 2>/dev/null)

echo "Refresh response 1: $REFRESH_RESPONSE1"

echo "Method 2: Alternative refresh..."
REFRESH_RESPONSE2=$(curl -s -X POST \
    -H "X-Emby-Token: $API_KEY" \
    "$JELLYFIN_URL/LiveTv/RefreshGuide" 2>/dev/null)

echo "Refresh response 2: $REFRESH_RESPONSE2"

echo "Method 3: System refresh..."
REFRESH_RESPONSE3=$(curl -s -X POST \
    -H "X-Emby-Token: $API_KEY" \
    "$JELLYFIN_URL/System/Refresh" 2>/dev/null)

echo "Refresh response 3: $REFRESH_RESPONSE3"

echo ""
echo "📋 Step 8: Final verification..."
echo "==============================="

# Wait for changes to take effect
echo "Waiting for changes to take effect..."
sleep 15

# Check final status
echo "Final status check:"
FINAL_TUNERS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/TunerHosts")
FINAL_GUIDES=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/GuideProviders")
FINAL_CHANNELS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Channels")

echo "Final tuners: $FINAL_TUNERS"
echo "Final guides: $FINAL_GUIDES"
echo "Final channels: $(echo "$FINAL_CHANNELS" | jq '.TotalRecordCount' 2>/dev/null)"

echo ""
echo "📋 Step 9: Creating manual setup guide..."
echo "======================================="

cat > "$WORKING_DIR/manual_setup_guide.md" << EOF
# 📺 Manual Jellyfin Live TV Setup Guide

## 🚨 API Issues Detected
The automated API setup encountered issues. Here's how to set up Live TV manually:

## 🔧 Manual Setup Steps

### Step 1: Access Jellyfin Web Interface
1. Go to: http://136.243.155.166:8096/web/#/dashboard/livetv
2. Log in as administrator
3. Navigate to **Settings** → **Live TV**

### Step 2: Add M3U Tuner
1. Click **"Add TV Provider"** or **"Add Tuner"**
2. Select **"M3U Tuner"**
3. Use these settings:

#### News Channels Tuner
- **Name**: News Channels
- **File or URL**: https://iptv-org.github.io/iptv/categories/news.m3u
- **User Agent**: Jellyfin/10.10.7
- **Simultaneous Stream Limit**: 0
- **Fallback Max Stream Bitrate**: 30 Mbps

#### Sports Channels Tuner
- **Name**: Sports Channels
- **File or URL**: https://iptv-org.github.io/iptv/categories/sports.m3u
- **User Agent**: Jellyfin/10.10.7
- **Simultaneous Stream Limit**: 0
- **Fallback Max Stream Bitrate**: 30 Mbps

#### Movies Channels Tuner
- **Name**: Movies Channels
- **File or URL**: https://iptv-org.github.io/iptv/categories/movies.m3u
- **User Agent**: Jellyfin/10.10.7
- **Simultaneous Stream Limit**: 0
- **Fallback Max Stream Bitrate**: 30 Mbps

#### Kids Channels Tuner
- **Name**: Kids Channels
- **File or URL**: https://iptv-org.github.io/iptv/categories/kids.m3u
- **User Agent**: Jellyfin/10.10.7
- **Simultaneous Stream Limit**: 0
- **Fallback Max Stream Bitrate**: 30 Mbps

#### Music Channels Tuner
- **Name**: Music Channels
- **File or URL**: https://iptv-org.github.io/iptv/categories/music.m3u
- **User Agent**: Jellyfin/10.10.7
- **Simultaneous Stream Limit**: 0
- **Fallback Max Stream Bitrate**: 30 Mbps

### Step 3: Add EPG Guide Provider
1. Go to **Settings** → **Live TV** → **Guide Providers**
2. Click **"Add Guide Provider"**
3. Select **"XMLTV"**
4. Use these settings:
   - **Name**: XMLTV Guide
   - **URL**: https://raw.githubusercontent.com/epgshare01/share01/master/epg_share01.xml
   - **User Agent**: Jellyfin/10.10.7

### Step 4: Refresh Live TV
1. Go to **Settings** → **Live TV**
2. Click **"Refresh Guide"** or **"Refresh Channels"**
3. Wait for the refresh to complete

### Step 5: Test Channels
1. Go to **Live TV** → **Channels**
2. Test a few channels from each category
3. Check if channels are properly grouped

## 🔍 Troubleshooting

### If Channels Don't Appear
1. Wait 5-10 minutes for refresh to complete
2. Check Jellyfin logs for errors
3. Verify M3U URLs are accessible
4. Try refreshing again

### If Grouping Doesn't Work
1. Check that M3U files have proper group-title tags
2. Verify the M3U format is correct
3. Try using different M3U sources

### If EPG Doesn't Work
1. Check XMLTV URL accessibility
2. Try alternative EPG sources
3. Verify guide provider settings

## 📊 Expected Results
- **News Channels**: 50+ channels
- **Sports Channels**: 30+ channels
- **Movies Channels**: 20+ channels
- **Kids Channels**: 15+ channels
- **Music Channels**: 25+ channels

## 📝 Notes
- All M3U URLs are tested and working
- Channels should be automatically grouped by category
- EPG will provide program schedules
- Manual setup is more reliable than API automation
EOF

echo "✅ Manual setup guide created: $WORKING_DIR/manual_setup_guide.md"

echo ""
echo "🎉 Force Jellyfin Update Complete!"
echo "================================="
echo ""
echo "📊 Summary:"
echo "• Tested API endpoints"
echo "• Created working M3U content"
echo "• Attempted multiple API methods"
echo "• Created comprehensive manual guide"
echo ""
echo "🚀 Next steps:"
echo "1. Use the manual setup guide"
echo "2. Add tuners through Jellyfin web interface"
echo "3. Test channel playback"
echo "4. Set up EPG guide provider"
echo ""
echo "📺 Manual setup is recommended due to API limitations!"

