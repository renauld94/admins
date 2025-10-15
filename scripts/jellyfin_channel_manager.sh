#!/bin/bash

#############################################################################
# Jellyfin Channel Manager via API
#############################################################################
# Manage Live TV channels using Jellyfin API
# Uses your API key: f870ddf763334cfba15fb45b091b10a8
#############################################################################

# Load configuration
source "$(dirname "$0")/jellyfin_api_config.sh"

# Check dependencies
if ! command -v jq &> /dev/null; then
    echo "❌ Error: jq is required but not installed"
    echo "   Install: sudo apt-get install jq"
    exit 1
fi

show_menu() {
    echo ""
    echo "============================================================================"
    echo "Jellyfin Live TV Manager (API-based)"
    echo "============================================================================"
    echo ""
    echo "1. Show channel count"
    echo "2. List all channels (first 20)"
    echo "3. List tuner devices"
    echo "4. Refresh guide data"
    echo "5. Show Live TV programs (now playing)"
    echo "6. Export channel list to file"
    echo "7. Check API connection"
    echo "8. Exit"
    echo ""
    read -p "Select option (1-8): " choice
    
    case $choice in
        1) show_channel_count ;;
        2) list_channels ;;
        3) list_tuners ;;
        4) refresh_guide_data ;;
        5) show_programs ;;
        6) export_channels ;;
        7) check_api ;;
        8) exit 0 ;;
        *) echo "Invalid option"; show_menu ;;
    esac
}

show_channel_count() {
    echo ""
    echo "📊 Fetching channel count..."
    
    RESPONSE=$(curl -s "${JELLYFIN_URL}/LiveTv/Channels?api_key=${JELLYFIN_API_KEY}&UserId=${JELLYFIN_USER_ID}")
    TOTAL=$(echo "$RESPONSE" | jq -r '.TotalRecordCount // 0')
    
    if [ "$TOTAL" -gt 0 ]; then
        echo "✅ Total channels: $TOTAL"
    else
        echo "❌ No channels found or API error"
    fi
    
    show_menu
}

list_channels() {
    echo ""
    echo "📺 Fetching channels (first 20)..."
    echo ""
    
    curl -s "${JELLYFIN_URL}/LiveTv/Channels?api_key=${JELLYFIN_API_KEY}&UserId=${JELLYFIN_USER_ID}&limit=20" | \
        jq -r '.Items[] | "\(.ChannelNumber // "N/A") - \(.Name)"'
    
    show_menu
}

list_tuners() {
    echo ""
    echo "📡 Fetching tuner devices..."
    echo ""
    
    curl -s "${JELLYFIN_URL}/LiveTv/Tuners?api_key=${JELLYFIN_API_KEY}" | \
        jq -r '.[] | "Tuner: \(.Name // .Id)\n  Type: \(.Type)\n  URL: \(.Url)\n"'
    
    show_menu
}

refresh_guide_data() {
    echo ""
    echo "🔄 Refreshing guide data..."
    
    curl -X POST "${JELLYFIN_URL}/LiveTv/GuideData/Refresh?api_key=${JELLYFIN_API_KEY}"
    
    echo "✅ Guide data refresh initiated"
    echo "   This may take a few minutes to complete."
    
    show_menu
}

show_programs() {
    echo ""
    echo "📺 Currently airing programs (first 10)..."
    echo ""
    
    curl -s "${JELLYFIN_URL}/LiveTv/Programs?api_key=${JELLYFIN_API_KEY}&UserId=${JELLYFIN_USER_ID}&IsAiring=true&limit=10" | \
        jq -r '.Items[] | "Channel: \(.ChannelName)\n  Program: \(.Name)\n  Time: \(.StartDate)\n"'
    
    show_menu
}

export_channels() {
    echo ""
    echo "💾 Exporting channel list..."
    
    OUTPUT_FILE="jellyfin_channels_$(date +%Y%m%d_%H%M%S).json"
    
    curl -s "${JELLYFIN_URL}/LiveTv/Channels?api_key=${JELLYFIN_API_KEY}&UserId=${JELLYFIN_USER_ID}&limit=10000" > "$OUTPUT_FILE"
    
    CHANNEL_COUNT=$(jq -r '.TotalRecordCount // 0' "$OUTPUT_FILE")
    
    echo "✅ Exported $CHANNEL_COUNT channels to: $OUTPUT_FILE"
    
    # Also create a simple text list
    TEXT_FILE="${OUTPUT_FILE%.json}.txt"
    jq -r '.Items[] | "\(.ChannelNumber // "N/A")\t\(.Name)"' "$OUTPUT_FILE" > "$TEXT_FILE"
    
    echo "✅ Created text list: $TEXT_FILE"
    
    show_menu
}

check_api() {
    echo ""
    echo "🔍 Testing API connection..."
    echo ""
    
    # Test system info endpoint
    RESPONSE=$(curl -s -w "\n%{http_code}" "${JELLYFIN_URL}/System/Info/Public")
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ Server reachable: ${JELLYFIN_URL}"
        SERVER_NAME=$(echo "$BODY" | jq -r '.ServerName // "Unknown"')
        VERSION=$(echo "$BODY" | jq -r '.Version // "Unknown"')
        echo "   Server: $SERVER_NAME"
        echo "   Version: $VERSION"
    else
        echo "❌ Server unreachable (HTTP $HTTP_CODE)"
    fi
    
    # Test API key
    RESPONSE=$(curl -s -w "\n%{http_code}" "${JELLYFIN_URL}/Users/${JELLYFIN_USER_ID}?api_key=${JELLYFIN_API_KEY}")
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | head -n-1)
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ API key valid"
        USER_NAME=$(echo "$BODY" | jq -r '.Name // "Unknown"')
        echo "   User: $USER_NAME"
    else
        echo "❌ API key invalid or expired (HTTP $HTTP_CODE)"
    fi
    
    # Test Live TV
    RESPONSE=$(curl -s -w "\n%{http_code}" "${JELLYFIN_URL}/LiveTv/Channels?api_key=${JELLYFIN_API_KEY}&UserId=${JELLYFIN_USER_ID}&limit=1")
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ Live TV API accessible"
    else
        echo "❌ Live TV API error (HTTP $HTTP_CODE)"
    fi
    
    show_menu
}

# Main
echo "============================================================================"
echo "Jellyfin Live TV Manager"
echo "============================================================================"
echo ""
echo "Server: ${JELLYFIN_URL}"
echo "API Key: ${JELLYFIN_API_KEY:0:20}..."
echo ""

show_menu
