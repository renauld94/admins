#!/bin/bash

# Add organized M3U tuners to Jellyfin via API
API_KEY="f870ddf763334cfba15fb45b091b10a8"
SERVER="http://136.243.155.166:8096"

echo "📡 Adding Organized Channel Tuners to Jellyfin"
echo "=============================================="
echo ""

# Array of tuners to add
declare -A TUNERS=(
    ["US Channels"]="/config/data/playlists/clean/US_channels.m3u"
    ["UK Channels"]="/config/data/playlists/clean/UK_channels.m3u"
    ["Canadian Channels"]="/config/data/playlists/clean/CA_channels.m3u"
    ["German Channels"]="/config/data/playlists/clean/DE_channels.m3u"
    ["French Channels"]="/config/data/playlists/clean/FR_channels.m3u"
)

echo "🔍 Step 1: Checking existing tuners..."
echo ""

# Get existing tuners
EXISTING=$(curl -s "${SERVER}/LiveTv/TunerHosts?api_key=${API_KEY}")

if [ -n "$EXISTING" ]; then
    echo "Existing tuners found. Listing..."
    echo "$EXISTING" | jq -r '.[] | "  - \(.FriendlyName // "Unknown"): \(.Url)"' 2>/dev/null || echo "  (Unable to parse)"
    echo ""
fi

echo "➕ Step 2: Adding new organized tuners..."
echo ""

# Add each tuner
for name in "${!TUNERS[@]}"; do
    path="${TUNERS[$name]}"
    
    echo "Adding: $name"
    echo "   Path: $path"
    
    # Create tuner via API
    RESPONSE=$(curl -s -X POST "${SERVER}/LiveTv/TunerHosts" \
        -H "Content-Type: application/json" \
        -H "X-Emby-Token: ${API_KEY}" \
        -d "{
            \"Type\": \"m3u\",
            \"Url\": \"${path}\",
            \"FriendlyName\": \"${name}\",
            \"ImportFavoritesOnly\": false,
            \"AllowHWTranscoding\": true,
            \"EnableStreamLooping\": false,
            \"Source\": \"Schedule\",
            \"TunerCount\": 1,
            \"UserAgent\": \"\"
        }" 2>&1)
    
    # Check if successful
    if echo "$RESPONSE" | jq -e '.Id' >/dev/null 2>&1; then
        TUNER_ID=$(echo "$RESPONSE" | jq -r '.Id')
        echo "   ✅ Added successfully (ID: $TUNER_ID)"
    else
        echo "   ⚠️  Response: $RESPONSE"
    fi
    
    echo ""
done

echo "🔄 Step 3: Refreshing Jellyfin guide data..."
curl -s -X POST "${SERVER}/LiveTv/GuideData/Refresh?api_key=${API_KEY}" >/dev/null 2>&1
echo "   ✅ Guide refresh triggered"
echo ""

echo "📊 Step 4: Verifying channel count..."
sleep 3  # Wait for Jellyfin to process

TOTAL=$(curl -s "${SERVER}/LiveTv/Channels?api_key=${API_KEY}&userId=0efdd3b94bcc4b77a52343bf70d948b0&Limit=1" | jq -r '.TotalRecordCount' 2>/dev/null || echo "0")
echo "   📺 Total channels now in Jellyfin: $TOTAL"
echo ""

if [ "$TOTAL" -gt 11337 ]; then
    echo "⚠️  NOTE: Old tuner might still be active (total > 11,337)"
    echo "   To remove old tuners, use the Jellyfin web UI:"
    echo "   Dashboard → Live TV → Tuner Devices → Delete old tuners"
    echo ""
fi

echo "=============================================="
echo "✅ Tuner Addition Complete!"
echo "=============================================="
echo ""
echo "📺 Check your channels at:"
echo "   ${SERVER}/web/#/livetv.html"
echo ""
echo "💡 If you see duplicate channels, remove old tuners via:"
echo "   Dashboard → Live TV → Tuner Devices"
