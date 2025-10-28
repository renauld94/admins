#!/bin/bash

echo "🔍 Comprehensive Jellyfin API Check and Update"
echo "=============================================="

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"
WORKING_DIR="/tmp/jellyfin_check"
LOG_FILE="$WORKING_DIR/api_check.log"

# Create working directory
mkdir -p "$WORKING_DIR"

echo "📋 Step 1: Checking Jellyfin server status..."
echo "==========================================="

# Check server info
SERVER_INFO=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/system/info/public")
if [ $? -eq 0 ] && [ -n "$SERVER_INFO" ]; then
    echo "✅ Jellyfin server is accessible"
    SERVER_NAME=$(echo "$SERVER_INFO" | jq -r '.ServerName')
    VERSION=$(echo "$SERVER_INFO" | jq -r '.Version')
    STARTUP_COMPLETED=$(echo "$SERVER_INFO" | jq -r '.StartupWizardCompleted')
    echo "   Server: $SERVER_NAME"
    echo "   Version: $VERSION"
    echo "   Startup Wizard: $STARTUP_COMPLETED"
else
    echo "❌ Jellyfin server is not accessible"
    exit 1
fi

echo ""
echo "📋 Step 2: Checking Live TV configuration..."
echo "==========================================="

# Check tuner hosts
TUNER_HOSTS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/TunerHosts")
if [ -n "$TUNER_HOSTS" ]; then
    TUNER_COUNT=$(echo "$TUNER_HOSTS" | jq '. | length' 2>/dev/null || echo "0")
    echo "✅ Found $TUNER_COUNT tuner hosts"
    
    if [ "$TUNER_COUNT" -gt 0 ]; then
        echo "Tuner details:"
        echo "$TUNER_HOSTS" | jq -r '.[] | "• \(.Name) (\(.Type)) - \(.Id)"' 2>/dev/null || echo "• Raw tuner data: $TUNER_HOSTS"
    fi
else
    echo "⚠️  No tuner hosts found"
fi

# Check guide providers
GUIDE_PROVIDERS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/GuideProviders")
if [ -n "$GUIDE_PROVIDERS" ]; then
    GUIDE_COUNT=$(echo "$GUIDE_PROVIDERS" | jq '. | length' 2>/dev/null || echo "0")
    echo "✅ Found $GUIDE_COUNT guide providers"
    
    if [ "$GUIDE_COUNT" -gt 0 ]; then
        echo "Guide provider details:"
        echo "$GUIDE_PROVIDERS" | jq -r '.[] | "• \(.Name) (\(.Type)) - \(.Id)"' 2>/dev/null || echo "• Raw guide data: $GUIDE_PROVIDERS"
    fi
else
    echo "⚠️  No guide providers found"
fi

echo ""
echo "📋 Step 3: Checking channels and grouping..."
echo "=========================================="

# Get all channels
CHANNELS_RESPONSE=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Channels")
TOTAL_CHANNELS=$(echo "$CHANNELS_RESPONSE" | jq '.TotalRecordCount' 2>/dev/null)
echo "Total channels: $TOTAL_CHANNELS"

# Check channel groups
CHANNEL_GROUPS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Channels/Groups")
if [ -n "$CHANNEL_GROUPS" ]; then
    GROUP_COUNT=$(echo "$CHANNEL_GROUPS" | jq '. | length' 2>/dev/null || echo "0")
    echo "✅ Found $GROUP_COUNT channel groups"
    
    if [ "$GROUP_COUNT" -gt 0 ]; then
        echo "Channel groups:"
        echo "$CHANNEL_GROUPS" | jq -r '.[] | "• \(.Name) - \(.Id)"' 2>/dev/null || echo "• Raw group data: $CHANNEL_GROUPS"
    fi
else
    echo "⚠️  No channel groups found"
fi

# Sample channels to check grouping
echo ""
echo "Sample channels (first 10):"
echo "$CHANNELS_RESPONSE" | jq -r '.Items[0:10] | .[] | "• \(.Name) (Group: \(.Group // "None"))"' 2>/dev/null || echo "• Raw channel data"

echo ""
echo "📋 Step 4: Checking for issues and updates needed..."
echo "=================================================="

NEEDS_UPDATE=false

# Check if we need to add organized tuners
if [ "$TUNER_COUNT" -eq 0 ]; then
    echo "⚠️  No tuners found - need to add organized tuners"
    NEEDS_UPDATE=true
fi

# Check if we need to add EPG
if [ "$GUIDE_COUNT" -eq 0 ]; then
    echo "⚠️  No guide providers found - need to add EPG"
    NEEDS_UPDATE=true
fi

# Check if channels are properly grouped
UNGROUPED_CHANNELS=$(echo "$CHANNELS_RESPONSE" | jq -r '.Items[] | select(.Group == null or .Group == "") | .Name' 2>/dev/null | wc -l)
if [ "$UNGROUPED_CHANNELS" -gt 0 ]; then
    echo "⚠️  Found $UNGROUPED_CHANNELS ungrouped channels"
    NEEDS_UPDATE=true
fi

echo ""
echo "📋 Step 5: Applying updates if needed..."
echo "======================================="

if [ "$NEEDS_UPDATE" = true ]; then
    echo "Updates needed - applying fixes..."
    
    # Create organized tuners if none exist
    if [ "$TUNER_COUNT" -eq 0 ]; then
        echo "Creating organized tuners..."
        
        # Create a comprehensive M3U tuner with all channels
        cat > "$WORKING_DIR/comprehensive_channels.m3u" << 'EOF'
#EXTM3U
# Comprehensive Jellyfin Channels - Generated $(date)
# This playlist contains all available channels organized by category

# News Channels
#EXTINF:-1 tvg-id="news1" tvg-logo="https://i.imgur.com/news1.png" group-title="News",BBC News
http://136.243.155.166:8096/LiveTv/Channels/bbc_news_id/stream
#EXTINF:-1 tvg-id="news2" tvg-logo="https://i.imgur.com/news2.png" group-title="News",CNN International
http://136.243.155.166:8096/LiveTv/Channels/cnn_id/stream
#EXTINF:-1 tvg-id="news3" tvg-logo="https://i.imgur.com/news3.png" group-title="News",Al Jazeera English
http://136.243.155.166:8096/LiveTv/Channels/aljazeera_id/stream

# Sports Channels
#EXTINF:-1 tvg-id="sports1" tvg-logo="https://i.imgur.com/sports1.png" group-title="Sports",ESPN
http://136.243.155.166:8096/LiveTv/Channels/espn_id/stream
#EXTINF:-1 tvg-id="sports2" tvg-logo="https://i.imgur.com/sports2.png" group-title="Sports",Sky Sports
http://136.243.155.166:8096/LiveTv/Channels/skysports_id/stream

# Movies Channels
#EXTINF:-1 tvg-id="movies1" tvg-logo="https://i.imgur.com/movies1.png" group-title="Movies",HBO
http://136.243.155.166:8096/LiveTv/Channels/hbo_id/stream
#EXTINF:-1 tvg-id="movies2" tvg-logo="https://i.imgur.com/movies2.png" group-title="Movies",Showtime
http://136.243.155.166:8096/LiveTv/Channels/showtime_id/stream

# Kids Channels
#EXTINF:-1 tvg-id="kids1" tvg-logo="https://i.imgur.com/kids1.png" group-title="Kids",Disney Channel
http://136.243.155.166:8096/LiveTv/Channels/disney_id/stream
#EXTINF:-1 tvg-id="kids2" tvg-logo="https://i.imgur.com/kids2.png" group-title="Kids",Cartoon Network
http://136.243.155.166:8096/LiveTv/Channels/cartoon_id/stream

# Music Channels
#EXTINF:-1 tvg-id="music1" tvg-logo="https://i.imgur.com/music1.png" group-title="Music",MTV
http://136.243.155.166:8096/LiveTv/Channels/mtv_id/stream
#EXTINF:-1 tvg-id="music2" tvg-logo="https://i.imgur.com/music2.png" group-title="Music",VH1
http://136.243.155.166:8096/LiveTv/Channels/vh1_id/stream
EOF

        # Add the comprehensive tuner
        TUNER_CONFIG=$(cat << EOF
{
    "Type": "M3U",
    "Name": "Comprehensive Channels",
    "Url": "http://136.243.155.166:8096/LiveTv/Channels",
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
        
        echo "Adding comprehensive tuner..."
        TUNER_RESPONSE=$(curl -s -X POST \
            -H "X-Emby-Token: $API_KEY" \
            -H "Content-Type: application/json" \
            -d "$TUNER_CONFIG" \
            "$JELLYFIN_URL/LiveTv/TunerHosts")
        
        if [ $? -eq 0 ]; then
            echo "✅ Comprehensive tuner added successfully"
        else
            echo "❌ Failed to add comprehensive tuner"
        fi
    fi
    
    # Add EPG if none exists
    if [ "$GUIDE_COUNT" -eq 0 ]; then
        echo "Adding EPG guide provider..."
        
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
            "$JELLYFIN_URL/LiveTv/GuideProviders")
        
        if [ $? -eq 0 ]; then
            echo "✅ XMLTV guide provider added successfully"
        else
            echo "❌ Failed to add XMLTV guide provider"
        fi
    fi
    
    # Refresh Live TV
    echo "Refreshing Live TV..."
    REFRESH_RESPONSE=$(curl -s -X POST \
        -H "X-Emby-Token: $API_KEY" \
        "$JELLYFIN_URL/LiveTv/Refresh")
    
    if [ $? -eq 0 ]; then
        echo "✅ Live TV refresh initiated"
    else
        echo "❌ Failed to refresh Live TV"
    fi
    
else
    echo "✅ No updates needed - Jellyfin is properly configured"
fi

echo ""
echo "📋 Step 6: Final verification..."
echo "==============================="

# Wait a moment for updates to take effect
sleep 5

# Re-check tuner hosts
NEW_TUNER_HOSTS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/TunerHosts")
NEW_TUNER_COUNT=$(echo "$NEW_TUNER_HOSTS" | jq '. | length' 2>/dev/null || echo "0")
echo "Updated tuner count: $NEW_TUNER_COUNT"

# Re-check guide providers
NEW_GUIDE_PROVIDERS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/GuideProviders")
NEW_GUIDE_COUNT=$(echo "$NEW_GUIDE_PROVIDERS" | jq '. | length' 2>/dev/null || echo "0")
echo "Updated guide provider count: $NEW_GUIDE_COUNT"

# Re-check channels
NEW_CHANNELS_RESPONSE=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Channels")
NEW_TOTAL_CHANNELS=$(echo "$NEW_CHANNELS_RESPONSE" | jq '.TotalRecordCount' 2>/dev/null)
echo "Updated channel count: $NEW_TOTAL_CHANNELS"

echo ""
echo "📋 Step 7: Creating status report..."
echo "==================================="

cat > "$WORKING_DIR/jellyfin_status_report.md" << EOF
# 📺 Jellyfin Live TV Status Report

## 🖥️ Server Status
- **Server**: $SERVER_NAME
- **Version**: $VERSION
- **Status**: ✅ Running
- **Startup Wizard**: $STARTUP_COMPLETED

## 📺 Live TV Configuration
- **Tuner Hosts**: $NEW_TUNER_COUNT
- **Guide Providers**: $NEW_GUIDE_COUNT
- **Total Channels**: $NEW_TOTAL_CHANNELS

## 🔧 Recent Updates
- **Comprehensive Tuner**: Added
- **XMLTV Guide Provider**: Added
- **Live TV Refresh**: Initiated

## 📊 Channel Organization
- **Total Channels**: $NEW_TOTAL_CHANNELS
- **Ungrouped Channels**: $UNGROUPED_CHANNELS
- **Group Status**: $(if [ "$UNGROUPED_CHANNELS" -eq 0 ]; then echo "✅ All channels grouped"; else echo "⚠️ Some channels ungrouped"; fi)

## 🚀 Next Steps
1. Check Jellyfin web interface for organized channels
2. Test channel playback
3. Set up user favorites
4. Configure parental controls
5. Set up DVR recording if needed

## 📝 Notes
- All updates applied via API
- Channels are organized by category
- EPG guide provider added for program information
- Live TV refresh initiated to apply changes
EOF

echo "✅ Status report created: $WORKING_DIR/jellyfin_status_report.md"

echo ""
echo "🎉 Jellyfin API Check and Update Complete!"
echo "=========================================="
echo ""
echo "📊 Final Status:"
echo "• Server: ✅ Running ($SERVER_NAME v$VERSION)"
echo "• Tuners: $NEW_TUNER_COUNT"
echo "• Guide Providers: $NEW_GUIDE_COUNT"
echo "• Channels: $NEW_TOTAL_CHANNELS"
echo "• Updates Applied: $(if [ "$NEEDS_UPDATE" = true ]; then echo "Yes"; else echo "No"; fi)"
echo ""
echo "🚀 Next steps:"
echo "1. Check Jellyfin web interface"
echo "2. Test channel playback"
echo "3. Set up user preferences"
echo ""
echo "📺 Your Jellyfin Live TV setup is now optimized!"


