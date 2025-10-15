#!/bin/bash

# Remove old tuner and verify new channel count
API_KEY="f870ddf763334cfba15fb45b091b10a8"
SERVER="http://136.243.155.166:8096"

echo "🗑️  Removing Old IPTV Tuner"
echo "=============================================="
echo ""

echo "📋 Step 1: Listing all tuners..."
echo ""

# Get all tuner hosts
TUNERS=$(curl -s "${SERVER}/LiveTv/TunerHosts?api_key=${API_KEY}")

# Display tuners
echo "$TUNERS" | jq -r '.[] | "ID: \(.Id)\n   Name: \(.FriendlyName // "Unknown")\n   URL: \(.Url)\n"' 2>/dev/null

echo ""
echo "🔍 Step 2: Identifying old large tuner..."
echo ""

# Find tuners with "international" or large playlists in the URL
OLD_TUNER_IDS=$(echo "$TUNERS" | jq -r '.[] | select(.Url | contains("iptv_org_international") or contains("iptv_org_countries") or contains("iptv_org_languages")) | .Id' 2>/dev/null)

if [ -n "$OLD_TUNER_IDS" ]; then
    echo "Found old tuner(s) to remove:"
    while IFS= read -r tuner_id; do
        TUNER_INFO=$(echo "$TUNERS" | jq -r ".[] | select(.Id == \"$tuner_id\") | \"   - \(.FriendlyName // .Url)\"" 2>/dev/null)
        echo "$TUNER_INFO (ID: $tuner_id)"
    done <<< "$OLD_TUNER_IDS"
    
    echo ""
    echo "🗑️  Step 3: Removing old tuner(s)..."
    echo ""
    
    while IFS= read -r tuner_id; do
        echo "Deleting tuner: $tuner_id"
        DELETE_RESPONSE=$(curl -s -X DELETE "${SERVER}/LiveTv/TunerHosts?id=${tuner_id}&api_key=${API_KEY}" -w "\nHTTP_CODE:%{http_code}")
        HTTP_CODE=$(echo "$DELETE_RESPONSE" | grep "HTTP_CODE:" | cut -d':' -f2)
        
        if [ "$HTTP_CODE" = "204" ] || [ "$HTTP_CODE" = "200" ]; then
            echo "   ✅ Deleted successfully"
        else
            echo "   ⚠️  Response code: $HTTP_CODE"
        fi
    done <<< "$OLD_TUNER_IDS"
else
    echo "⚠️  No old tuners found with 'iptv_org_international' in the URL"
    echo "   You may need to manually delete old tuners via web UI"
fi

echo ""
echo "🔄 Step 4: Refreshing guide data..."
curl -s -X POST "${SERVER}/LiveTv/GuideData/Refresh?api_key=${API_KEY}" >/dev/null 2>&1
echo "   ✅ Guide refresh triggered"
echo ""

echo "⏳ Waiting 5 seconds for Jellyfin to update..."
sleep 5

echo ""
echo "📊 Step 5: Checking new channel count..."
echo ""

TOTAL=$(curl -s "${SERVER}/LiveTv/Channels?api_key=${API_KEY}&userId=0efdd3b94bcc4b77a52343bf70d948b0&Limit=1" | jq -r '.TotalRecordCount' 2>/dev/null || echo "0")
echo "   📺 Total channels: $TOTAL"

if [ "$TOTAL" -lt 3500 ] && [ "$TOTAL" -gt 2000 ]; then
    echo "   ✅ Perfect! Using organized playlists (~3,000 channels)"
elif [ "$TOTAL" -gt 10000 ]; then
    echo "   ⚠️  Still showing $TOTAL channels - old tuner might still be active"
    echo ""
    echo "   Manual removal required:"
    echo "   1. Go to: ${SERVER}/web/"
    echo "   2. Dashboard → Live TV → Tuner Devices"
    echo "   3. Delete any tuner with 11,000+ channels"
else
    echo "   📊 Channel count: $TOTAL"
fi

echo ""
echo "=============================================="
echo "✅ Cleanup Complete!"
echo "=============================================="
echo ""
echo "📺 View your organized channels:"
echo "   ${SERVER}/web/#/livetv.html"
echo ""
echo "📋 Current tuners:"
curl -s "${SERVER}/LiveTv/TunerHosts?api_key=${API_KEY}" | jq -r '.[] | "   - \(.FriendlyName // "Unknown"): \(.Url | split("/") | last)"' 2>/dev/null
