#!/bin/bash

# Configure Jellyfin Live TV using API
# This script attempts to configure Live TV tuners and guide providers via API

API_KEY="f870ddf763334cfba15fb45b091b10a8"
JELLYFIN_URL="http://136.243.155.166:8096"

echo "📺 Configuring Jellyfin Live TV via API"
echo "======================================"
echo ""

# Function to make API call
api_call() {
    local method="$1"
    local endpoint="$2"
    local data="$3"
    
    if [ -n "$data" ]; then
        curl -s -X "$method" \
            -H "X-Emby-Token: $API_KEY" \
            -H "Content-Type: application/json" \
            -d "$data" \
            "$JELLYFIN_URL$endpoint"
    else
        curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL$endpoint"
    fi
}

echo "🔧 Current Live TV Status:"
echo "-------------------------"
api_call "GET" "/LiveTv/Info"
echo ""

echo "🔧 Current Tuners:"
echo "-----------------"
api_call "GET" "/LiveTv/Tuners"
echo ""

echo "🔧 Current Guide Providers:"
echo "--------------------------"
api_call "GET" "/LiveTv/GuideProviders"
echo ""

echo "🔧 Attempting to configure tuners..."
echo "-----------------------------------"

# Try different API endpoints for tuners
echo "Trying /LiveTv/Tuners endpoint..."
api_call "POST" "/LiveTv/Tuners" '{"Type":"M3U","Name":"Samsung TV Plus","Url":"/config/samsung_tv_plus.m3u","Enable":true}'
echo ""

echo "Trying /LiveTv/Tuners/Direct endpoint..."
api_call "POST" "/LiveTv/Tuners/Direct" '{"Type":"M3U","Name":"Samsung TV Plus","Url":"/config/samsung_tv_plus.m3u","Enable":true}'
echo ""

echo "Trying /LiveTv/Tuners/Discover endpoint..."
api_call "POST" "/LiveTv/Tuners/Discover" '{"Type":"M3U","Name":"Samsung TV Plus","Url":"/config/samsung_tv_plus.m3u","Enable":true}'
echo ""

echo "🔧 Attempting to configure guide providers..."
echo "--------------------------------------------"

# Try different API endpoints for guide providers
echo "Trying /LiveTv/GuideProviders endpoint..."
api_call "POST" "/LiveTv/GuideProviders" '{"Type":"XMLTV","Name":"US EPG","Url":"/config/epg_us.xml","Enable":true}'
echo ""

echo "Trying /LiveTv/GuideProviders/Direct endpoint..."
api_call "POST" "/LiveTv/GuideProviders/Direct" '{"Type":"XMLTV","Name":"US EPG","Url":"/config/epg_us.xml","Enable":true}'
echo ""

echo "Trying /LiveTv/GuideProviders/Discover endpoint..."
api_call "POST" "/LiveTv/GuideProviders/Discover" '{"Type":"XMLTV","Name":"US EPG","Url":"/config/epg_us.xml","Enable":true}'
echo ""

echo "🔧 Checking if configuration was successful..."
echo "--------------------------------------------"
echo "Tuners after configuration:"
api_call "GET" "/LiveTv/Tuners"
echo ""

echo "Guide Providers after configuration:"
api_call "GET" "/LiveTv/GuideProviders"
echo ""

echo "📋 Summary:"
echo "==========="
echo "If the API calls didn't work, you may need to:"
echo "1. Configure Live TV through the web interface"
echo "2. Check Jellyfin logs for errors"
echo "3. Verify the API endpoints are correct"
echo ""
echo "🌐 Web Interface: $JELLYFIN_URL/web/"
echo "📺 Live TV URL: $JELLYFIN_URL/web/#/livetv.html?collectionType=livetv"
