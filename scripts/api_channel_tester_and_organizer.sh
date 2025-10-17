#!/bin/bash

echo "🔍 Jellyfin API Channel Tester and Organizer"
echo "============================================"

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"
WORKING_DIR="/tmp/jellyfin_channels"
LOG_FILE="$WORKING_DIR/channel_test_results.log"

# Create working directory
mkdir -p "$WORKING_DIR"

echo "📋 Step 1: Getting all channels from Jellyfin API..."
echo "=================================================="

# Get all channels
CHANNELS_RESPONSE=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Channels")
echo "Total channels found: $(echo "$CHANNELS_RESPONSE" | jq '.TotalRecordCount' 2>/dev/null || echo "Unknown")"

# Extract channel data
echo "$CHANNELS_RESPONSE" | jq -r '.Items[] | "\(.Id)|\(.Name)|\(.Number)|\(.ImageUrl // "no-logo")"' > "$WORKING_DIR/all_channels.txt"

echo "📋 Step 2: Creating channel categories..."
echo "======================================"

# Create category directories
mkdir -p "$WORKING_DIR/categories"
mkdir -p "$WORKING_DIR/playlists"

# Define categories and their keywords
cat > "$WORKING_DIR/categories.json" << 'EOF'
{
  "news": {
    "keywords": ["news", "cnn", "bbc", "sky news", "al jazeera", "bloomberg", "france 24", "dw", "rt", "cgtn", "nhk", "arirang", "trt", "euronews", "fox news", "msnbc", "abc news", "cbs news", "nbc news"],
    "description": "News and Information Channels"
  },
  "sports": {
    "keywords": ["sport", "espn", "sky sports", "eurosport", "bt sport", "fox sports", "bein", "nfl", "nba", "premier league", "champions league", "fifa", "olympics", "tennis", "golf", "boxing", "mma", "ufc"],
    "description": "Sports and Athletic Events"
  },
  "movies": {
    "keywords": ["movie", "hbo", "showtime", "starz", "cinemax", "tcm", "amc", "fx", "comedy central", "discovery", "national geographic", "history", "a&e", "lifetime", "hallmark", "syfy", "tnt", "tbs"],
    "description": "Movies and Entertainment"
  },
  "kids": {
    "keywords": ["kids", "children", "cartoon", "disney", "nickelodeon", "cartoon network", "pbs kids", "disney junior", "disney xd", "nick jr", "boomerang", "youtube kids"],
    "description": "Children's Programming"
  },
  "music": {
    "keywords": ["music", "mtv", "vh1", "bet", "cmt", "fuse", "vh1 classic", "mtv hits", "mtv2", "music video", "concert", "live music"],
    "description": "Music and Music Videos"
  },
  "documentary": {
    "keywords": ["documentary", "discovery", "national geographic", "history", "science", "nature", "pbs", "bbc", "investigation", "travel", "animal", "planet"],
    "description": "Documentary and Educational"
  },
  "international": {
    "keywords": ["international", "foreign", "spanish", "french", "german", "italian", "portuguese", "arabic", "chinese", "japanese", "korean", "russian", "hindi", "turkish"],
    "description": "International and Foreign Language"
  },
  "local": {
    "keywords": ["local", "regional", "city", "state", "county", "community", "public access", "government"],
    "description": "Local and Regional Channels"
  }
}
EOF

echo "✅ Created 8 categories: News, Sports, Movies, Kids, Music, Documentary, International, Local"

echo ""
echo "📋 Step 3: Testing channels and categorizing..."
echo "=============================================="

# Initialize counters
TOTAL_CHANNELS=0
TESTED_CHANNELS=0
WORKING_CHANNELS=0
BROKEN_CHANNELS=0

# Initialize category counters
declare -A CATEGORY_COUNTS
for category in news sports movies kids music documentary international local; do
    CATEGORY_COUNTS[$category]=0
done

# Create M3U files for each category
for category in news sports movies kids music documentary international local; do
    echo "#EXTM3U" > "$WORKING_DIR/playlists/${category}_channels.m3u"
    echo "# ${category^} Channels - $(date)" >> "$WORKING_DIR/playlists/${category}_channels.m3u"
done

# Create working channels file
echo "#EXTM3U" > "$WORKING_DIR/playlists/working_channels.m3u"
echo "# Working Channels - $(date)" >> "$WORKING_DIR/playlists/working_channels.m3u"

# Create broken channels file
echo "#EXTM3U" > "$WORKING_DIR/playlists/broken_channels.m3u"
echo "# Broken Channels - $(date)" >> "$WORKING_DIR/playlists/broken_channels.m3u"

echo "Starting channel testing process..."
echo "This may take a while for 13,000+ channels..."

# Read channels and test them
while IFS='|' read -r channel_id channel_name channel_number channel_logo; do
    TOTAL_CHANNELS=$((TOTAL_CHANNELS + 1))
    
    # Progress indicator
    if [ $((TOTAL_CHANNELS % 100)) -eq 0 ]; then
        echo "Processed $TOTAL_CHANNELS channels..."
    fi
    
    # Skip if we've tested enough (limit to first 1000 for now)
    if [ $TOTAL_CHANNELS -gt 1000 ]; then
        echo "Stopping at 1000 channels for initial testing..."
        break
    fi
    
    # Test channel by trying to get channel info
    CHANNEL_INFO=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Channels/$channel_id")
    
    if [ $? -eq 0 ] && [ -n "$CHANNEL_INFO" ]; then
        # Channel exists, test if it's playable
        CHANNEL_URL=$(echo "$CHANNEL_INFO" | jq -r '.Path // empty' 2>/dev/null)
        
        if [ -n "$CHANNEL_URL" ]; then
            # Test if URL is accessible
            HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$CHANNEL_URL" 2>/dev/null)
            
            if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "302" ] || [ "$HTTP_STATUS" = "301" ]; then
                WORKING_CHANNELS=$((WORKING_CHANNELS + 1))
                TESTED_CHANNELS=$((TESTED_CHANNELS + 1))
                
                # Categorize channel
                CATEGORY=""
                CHANNEL_NAME_LOWER=$(echo "$channel_name" | tr '[:upper:]' '[:lower:]')
                
                # Check each category
                for category in news sports movies kids music documentary international local; do
                    keywords=$(jq -r ".$category.keywords[]" "$WORKING_DIR/categories.json" 2>/dev/null)
                    for keyword in $keywords; do
                        if echo "$CHANNEL_NAME_LOWER" | grep -q "$keyword"; then
                            CATEGORY="$category"
                            break 2
                        fi
                    done
                done
                
                # If no category found, try to determine from channel name patterns
                if [ -z "$CATEGORY" ]; then
                    if echo "$CHANNEL_NAME_LOWER" | grep -q -E "(news|cnn|bbc|sky)"; then
                        CATEGORY="news"
                    elif echo "$CHANNEL_NAME_LOWER" | grep -q -E "(sport|espn|football|soccer)"; then
                        CATEGORY="sports"
                    elif echo "$CHANNEL_NAME_LOWER" | grep -q -E "(movie|cinema|film|hbo)"; then
                        CATEGORY="movies"
                    elif echo "$CHANNEL_NAME_LOWER" | grep -q -E "(kids|children|cartoon|disney)"; then
                        CATEGORY="kids"
                    elif echo "$CHANNEL_NAME_LOWER" | grep -q -E "(music|mtv|vh1|concert)"; then
                        CATEGORY="music"
                    elif echo "$CHANNEL_NAME_LOWER" | grep -q -E "(docu|discovery|national|history)"; then
                        CATEGORY="documentary"
                    elif echo "$CHANNEL_NAME_LOWER" | grep -q -E "(international|foreign|spanish|french|german)"; then
                        CATEGORY="international"
                    else
                        CATEGORY="local"
                    fi
                fi
                
                # Add to appropriate category
                if [ -n "$CATEGORY" ]; then
                    CATEGORY_COUNTS[$CATEGORY]=$((${CATEGORY_COUNTS[$CATEGORY]} + 1))
                    echo "#EXTINF:-1 tvg-id=\"$channel_id\" tvg-logo=\"$channel_logo\" group-title=\"${CATEGORY^}\",$channel_name" >> "$WORKING_DIR/playlists/${CATEGORY}_channels.m3u"
                    echo "$CHANNEL_URL" >> "$WORKING_DIR/playlists/${CATEGORY}_channels.m3u"
                fi
                
                # Add to working channels
                echo "#EXTINF:-1 tvg-id=\"$channel_id\" tvg-logo=\"$channel_logo\" group-title=\"Working\",$channel_name" >> "$WORKING_DIR/playlists/working_channels.m3u"
                echo "$CHANNEL_URL" >> "$WORKING_DIR/playlists/working_channels.m3u"
                
                echo "✅ $channel_name -> $CATEGORY" >> "$LOG_FILE"
            else
                BROKEN_CHANNELS=$((BROKEN_CHANNELS + 1))
                TESTED_CHANNELS=$((TESTED_CHANNELS + 1))
                echo "❌ $channel_name -> BROKEN (HTTP $HTTP_STATUS)" >> "$LOG_FILE"
                echo "#EXTINF:-1 tvg-id=\"$channel_id\" tvg-logo=\"$channel_logo\" group-title=\"Broken\",$channel_name" >> "$WORKING_DIR/playlists/broken_channels.m3u"
                echo "$CHANNEL_URL" >> "$WORKING_DIR/playlists/broken_channels.m3u"
            fi
        else
            BROKEN_CHANNELS=$((BROKEN_CHANNELS + 1))
            TESTED_CHANNELS=$((TESTED_CHANNELS + 1))
            echo "❌ $channel_name -> NO URL" >> "$LOG_FILE"
        fi
    else
        BROKEN_CHANNELS=$((BROKEN_CHANNELS + 1))
        TESTED_CHANNELS=$((TESTED_CHANNELS + 1))
        echo "❌ $channel_name -> API ERROR" >> "$LOG_FILE"
    fi
    
    # Small delay to avoid overwhelming the server
    sleep 0.1
    
done < "$WORKING_DIR/all_channels.txt"

echo ""
echo "📊 Testing Results Summary:"
echo "=========================="
echo "Total channels processed: $TOTAL_CHANNELS"
echo "Channels tested: $TESTED_CHANNELS"
echo "Working channels: $WORKING_CHANNELS"
echo "Broken channels: $BROKEN_CHANNELS"
echo ""

echo "📋 Category Breakdown:"
echo "====================="
for category in news sports movies kids music documentary international local; do
    count=${CATEGORY_COUNTS[$category]}
    echo "$category: $count channels"
done

echo ""
echo "📁 Generated Playlists:"
echo "======================"
ls -la "$WORKING_DIR/playlists/"

echo ""
echo "📋 Step 4: Creating comprehensive report..."
echo "========================================="

cat > "$WORKING_DIR/channel_organization_report.md" << EOF
# 📺 Jellyfin Channel Organization Report

## 📊 Testing Summary
- **Total Channels Processed**: $TOTAL_CHANNELS
- **Channels Tested**: $TESTED_CHANNELS
- **Working Channels**: $WORKING_CHANNELS
- **Broken Channels**: $BROKEN_CHANNELS
- **Success Rate**: $(( (WORKING_CHANNELS * 100) / TESTED_CHANNELS ))%

## 🏷️ Category Breakdown
EOF

for category in news sports movies kids music documentary international local; do
    count=${CATEGORY_COUNTS[$category]}
    percentage=$(( (count * 100) / WORKING_CHANNELS ))
    echo "- **${category^}**: $count channels ($percentage%)" >> "$WORKING_DIR/channel_organization_report.md"
done

cat >> "$WORKING_DIR/channel_organization_report.md" << EOF

## 📁 Generated Playlists
- \`working_channels.m3u\` - All working channels
- \`broken_channels.m3u\` - Non-working channels
- \`news_channels.m3u\` - News and information channels
- \`sports_channels.m3u\` - Sports and athletic events
- \`movies_channels.m3u\` - Movies and entertainment
- \`kids_channels.m3u\` - Children's programming
- \`music_channels.m3u\` - Music and music videos
- \`documentary_channels.m3u\` - Documentary and educational
- \`international_channels.m3u\` - International and foreign language
- \`local_channels.m3u\` - Local and regional channels

## 🚀 Next Steps
1. Review the generated playlists
2. Upload working playlists to Jellyfin
3. Remove broken channels from main tuner
4. Set up EPG for better channel information
5. Create user favorites and parental controls

## 📝 Notes
- Testing limited to first 1000 channels for performance
- Channels tested for HTTP accessibility
- Categories assigned based on channel name keywords
- All playlists are in M3U format and ready for Jellyfin
EOF

echo "✅ Report created: $WORKING_DIR/channel_organization_report.md"

echo ""
echo "📋 Step 5: Uploading organized playlists to Jellyfin..."
echo "====================================================="

# Upload playlists to VM
echo "Uploading playlists to VM..."
scp -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -P 2222 "$WORKING_DIR/playlists/"*.m3u simonadmin@136.243.155.166:/tmp/

echo "Copying playlists to Jellyfin container..."
ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'docker cp /tmp/*_channels.m3u jellyfin-simonadmin:/config/'"

echo ""
echo "🎉 Channel Testing and Organization Complete!"
echo "============================================="
echo ""
echo "📊 Results:"
echo "• Tested $TESTED_CHANNELS channels"
echo "• Found $WORKING_CHANNELS working channels"
echo "• Categorized into 8 different playlists"
echo "• Generated comprehensive report"
echo ""
echo "📁 Files created:"
echo "• $WORKING_DIR/channel_organization_report.md"
echo "• $WORKING_DIR/playlists/*.m3u"
echo "• $LOG_FILE"
echo ""
echo "🚀 Next steps:"
echo "1. Review the generated playlists"
echo "2. Add organized playlists as new tuners in Jellyfin"
echo "3. Remove broken channels from main tuner"
echo "4. Set up EPG for better channel information"
echo ""
echo "📺 Your channels are now organized and ready for use!"

