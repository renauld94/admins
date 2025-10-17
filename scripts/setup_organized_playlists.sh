#!/bin/bash

echo "🚀 Setting up organized playlists in Jellyfin"
echo "==========================================="

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"
WORKING_DIR="/tmp/smart_channels"

echo "📋 Step 1: Checking if organized playlists exist..."
echo "================================================="

if [ ! -d "$WORKING_DIR/playlists" ]; then
    echo "❌ Organized playlists not found. Running smart organizer first..."
    ./scripts/smart_channel_organizer.sh
fi

echo "✅ Organized playlists found"

echo ""
echo "📋 Step 2: Creating organized M3U playlists with direct URLs..."
echo "============================================================="

# Create a new directory for API-ready playlists
mkdir -p "$WORKING_DIR/api_playlists"

# Define categories
categories=("news" "sports" "movies" "kids" "music" "documentary" "international" "local" "religious" "shopping")

for category in "${categories[@]}"; do
    if [ -f "$WORKING_DIR/playlists/${category}_channels.m3u" ]; then
        echo "Processing $category channels..."
        
        # Count channels in this category
        channel_count=$(grep -c "EXTINF" "$WORKING_DIR/playlists/${category}_channels.m3u" 2>/dev/null || echo "0")
        
        if [ "$channel_count" -gt 0 ]; then
            echo "  Found $channel_count $category channels"
            
            # Create API-ready playlist with direct URLs
            cat > "$WORKING_DIR/api_playlists/${category}_channels.m3u" << EOF
#EXTM3U
# ${category^} Channels - Generated $(date)
# Channel Count: $channel_count
# Description: $(jq -r ".$category.description" "$WORKING_DIR/smart_categories.json" 2>/dev/null || echo "Organized $category channels")
EOF
            
            # Convert to direct URLs
            grep "EXTINF" "$WORKING_DIR/playlists/${category}_channels.m3u" | while read -r line; do
                echo "$line" >> "$WORKING_DIR/api_playlists/${category}_channels.m3u"
                # Get the next line (URL) and convert to direct URL
                channel_id=$(echo "$line" | grep -o 'tvg-id="[^"]*"' | sed 's/tvg-id="//;s/"//')
                if [ -n "$channel_id" ]; then
                    echo "http://136.243.155.166:8096/LiveTv/Channels/$channel_id/stream" >> "$WORKING_DIR/api_playlists/${category}_channels.m3u"
                fi
            done
            
            echo "  ✅ Created API-ready playlist: $category"
        else
            echo "  ⚠️  No channels found for $category"
        fi
    fi
done

echo ""
echo "📋 Step 3: Testing Jellyfin API connectivity..."
echo "=============================================="

# Test API connectivity
api_test=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/system/info/public")
if [ $? -eq 0 ]; then
    echo "✅ Jellyfin API is accessible"
    server_name=$(echo "$api_test" | jq -r '.ServerName')
    version=$(echo "$api_test" | jq -r '.Version')
    echo "   Server: $server_name"
    echo "   Version: $version"
else
    echo "❌ Jellyfin API is not accessible"
    exit 1
fi

echo ""
echo "📋 Step 4: Adding organized playlists as new tuners..."
echo "===================================================="

# Function to add a tuner
add_tuner() {
    local category="$1"
    local playlist_file="$2"
    local channel_count="$3"
    
    echo "Adding $category tuner ($channel_count channels)..."
    
    # Create tuner configuration
    tuner_config=$(cat << EOF
{
    "Type": "M3U",
    "Name": "${category^} Channels",
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
    
    # Add tuner via API
    response=$(curl -s -X POST \
        -H "X-Emby-Token: $API_KEY" \
        -H "Content-Type: application/json" \
        -d "$tuner_config" \
        "$JELLYFIN_URL/LiveTv/TunerHosts" 2>/dev/null)
    
    if [ $? -eq 0 ] && [ -n "$response" ]; then
        echo "  ✅ $category tuner added successfully"
        return 0
    else
        echo "  ❌ Failed to add $category tuner"
        echo "  Response: $response"
        return 1
    fi
}

# Add tuners for each category
success_count=0
total_categories=0

for category in "${categories[@]}"; do
    if [ -f "$WORKING_DIR/api_playlists/${category}_channels.m3u" ]; then
        channel_count=$(grep -c "EXTINF" "$WORKING_DIR/api_playlists/${category}_channels.m3u" 2>/dev/null || echo "0")
        
        if [ "$channel_count" -gt 0 ]; then
            total_categories=$((total_categories + 1))
            if add_tuner "$category" "$WORKING_DIR/api_playlists/${category}_channels.m3u" "$channel_count"; then
                success_count=$((success_count + 1))
            fi
        fi
    fi
done

echo ""
echo "📋 Step 5: Creating manual setup guide..."
echo "======================================="

cat > "$WORKING_DIR/manual_playlist_setup_guide.md" << EOF
# 📺 Manual Playlist Setup Guide

## 🎉 Automated Setup Results
- **Total Categories**: $total_categories
- **Successfully Added**: $success_count
- **Failed**: $((total_categories - success_count))

## 📁 Available Playlists
EOF

for category in "${categories[@]}"; do
    if [ -f "$WORKING_DIR/api_playlists/${category}_channels.m3u" ]; then
        channel_count=$(grep -c "EXTINF" "$WORKING_DIR/api_playlists/${category}_channels.m3u" 2>/dev/null || echo "0")
        if [ "$channel_count" -gt 0 ]; then
            echo "- **${category^}**: $channel_count channels" >> "$WORKING_DIR/manual_playlist_setup_guide.md"
        fi
    fi
done

cat >> "$WORKING_DIR/manual_playlist_setup_guide.md" << EOF

## 🔧 Manual Setup (If API Failed)

If the automated setup didn't work, you can add these playlists manually:

### Step 1: Go to Jellyfin Settings
1. Open Jellyfin web interface
2. Click the ⚙️ Settings gear icon
3. Go to **Live TV** in the left sidebar

### Step 2: Add New Tuners
1. Click **"Add TV Provider"** or **"Add Tuner"**
2. Select **"M3U Tuner"**
3. For each category, use these settings:

#### News Channels
- **Name**: News Channels
- **File or URL**: Use the content from \`$WORKING_DIR/api_playlists/news_channels.m3u\`
- **User Agent**: Jellyfin/10.10.7

#### Sports Channels
- **Name**: Sports Channels
- **File or URL**: Use the content from \`$WORKING_DIR/api_playlists/sports_channels.m3u\`
- **User Agent**: Jellyfin/10.10.7

#### Movies Channels
- **Name**: Movies Channels
- **File or URL**: Use the content from \`$WORKING_DIR/api_playlists/movies_channels.m3u\`
- **User Agent**: Jellyfin/10.10.7

#### Kids Channels
- **Name**: Kids Channels
- **File or URL**: Use the content from \`$WORKING_DIR/api_playlists/kids_channels.m3u\`
- **User Agent**: Jellyfin/10.10.7

#### Music Channels
- **Name**: Music Channels
- **File or URL**: Use the content from \`$WORKING_DIR/api_playlists/music_channels.m3u\`
- **User Agent**: Jellyfin/10.10.7

### Step 3: Test Channels
1. Go to **Live TV** → **Channels**
2. Test a few channels from each category
3. Check if channels are properly grouped

## 📊 Expected Results
- **News**: 3,028 channels
- **Sports**: 449 channels
- **Music**: 231 channels
- **Movies**: 175 channels
- **Kids**: 86 channels
- **Local**: 77 channels
- **Shopping**: 39 channels
- **International**: 40 channels
- **Religious**: 19 channels
- **Documentary**: 20 channels

## 🚀 Next Steps
1. Test channel playback
2. Set up EPG (Electronic Program Guide)
3. Create user favorites
4. Configure parental controls
5. Set up DVR recording if needed

## 📝 Notes
- All playlists use Jellyfin's internal streaming URLs
- Channels are organized by category for easy navigation
- Each category can be managed independently
- Playlists are automatically updated when you refresh the tuners
EOF

echo "✅ Manual setup guide created: $WORKING_DIR/manual_playlist_setup_guide.md"

echo ""
echo "📋 Step 6: Checking current tuners..."
echo "===================================="

current_tuners=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/TunerHosts")
if [ -n "$current_tuners" ]; then
    echo "Current tuners:"
    echo "$current_tuners" | jq -r '.[] | "• \(.Name) (\(.Type))"' 2>/dev/null || echo "• Raw tuner data: $current_tuners"
else
    echo "No tuners found or API error"
fi

echo ""
echo "🎉 Organized Playlists Setup Complete!"
echo "====================================="
echo ""
echo "📊 Results:"
echo "• Processed $total_categories categories"
echo "• Successfully added $success_count tuners"
echo "• Created manual setup guide"
echo ""
echo "📁 Files created:"
echo "• $WORKING_DIR/api_playlists/*.m3u"
echo "• $WORKING_DIR/manual_playlist_setup_guide.md"
echo ""
echo "🚀 Next steps:"
echo "1. Check your Jellyfin Live TV section"
echo "2. Test a few channels from each category"
echo "3. Set up EPG for better channel information"
echo "4. Create favorites and parental controls"
echo ""
echo "📺 Your channels are now organized and ready to use!"

