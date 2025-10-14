#!/bin/bash

# Jellyfin API-based TV Channels Setup
# This script uses Jellyfin API to add TV channels

set -e

echo "🔌 Jellyfin API TV Channels Setup"
echo "=================================="

JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY=""
USERNAME="simonadmin"

# Function to get API key
get_api_key() {
    echo "🔑 Getting Jellyfin API key..."
    
    # Login to get API key
    LOGIN_RESPONSE=$(curl -s -X POST "$JELLYFIN_URL/Users/authenticatebyname" \
        -H "Content-Type: application/json" \
        -d "{\"Username\":\"$USERNAME\",\"Pw\":\"\"}")
    
    if [ $? -eq 0 ]; then
        API_KEY=$(echo "$LOGIN_RESPONSE" | grep -o '"AccessToken":"[^"]*"' | cut -d'"' -f4)
        echo "✅ API key obtained: ${API_KEY:0:10}..."
    else
        echo "❌ Failed to get API key"
        exit 1
    fi
}

# Function to add M3U tuner
add_m3u_tuner() {
    echo "📺 Adding M3U tuner..."
    
    curl -X POST "$JELLYFIN_URL/LiveTv/Tuners" \
        -H "Content-Type: application/json" \
        -H "X-Emby-Token: $API_KEY" \
        -d '{
            "Type": "M3U",
            "Name": "Samsung TV Plus",
            "Url": "https://rb.gy/soxjxl"
        }'
    
    echo "✅ M3U tuner added"
}

# Function to add EPG
add_epg() {
    echo "📋 Adding EPG..."
    
    curl -X POST "$JELLYFIN_URL/LiveTv/GuideProviders" \
        -H "Content-Type: application/json" \
        -H "X-Emby-Token: $API_KEY" \
        -d '{
            "Type": "XMLTV",
            "Name": "Samsung TV Plus EPG",
            "Url": "https://rb.gy/csudmm"
        }'
    
    echo "✅ EPG added"
}

# Function to refresh guide data
refresh_guide() {
    echo "🔄 Refreshing guide data..."
    
    curl -X POST "$JELLYFIN_URL/LiveTv/Guide/Refresh" \
        -H "X-Emby-Token: $API_KEY"
    
    echo "✅ Guide data refresh initiated"
}

# Main execution
main() {
    get_api_key
    add_m3u_tuner
    add_epg
    refresh_guide
    
    echo ""
    echo "🎉 TV channels setup complete via API!"
    echo "🌐 Access Jellyfin at: $JELLYFIN_URL/web/"
}

main "$@"
