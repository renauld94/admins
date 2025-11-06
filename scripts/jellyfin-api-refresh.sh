#!/bin/bash
# Jellyfin API Operations Script
# Uses API key to refresh metadata and clear image cache

set -e

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"

echo "╔══════════════════════════════════════════════════════════════════════════╗"
echo "║                                                                          ║"
echo "║   🎬 Jellyfin API Operations                                            ║"
echo "║   ══════════════════════════════                                        ║"
echo "║                                                                          ║"
echo "╚══════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Target Server: $JELLYFIN_URL"
echo "API Key: ${API_KEY:0:8}...${API_KEY:24:8}"
echo ""

# Function to make API calls
api_call() {
    local method="$1"
    local endpoint="$2"
    local description="$3"
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📡 $description"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
        -X "$method" \
        -H "X-MediaBrowser-Token: $API_KEY" \
        -H "Content-Type: application/json" \
        "${JELLYFIN_URL}${endpoint}" 2>&1)
    
    HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
    BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE:")
    
    echo "HTTP Status: $HTTP_CODE"
    
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "204" ]; then
        echo "✅ Success!"
        if [ -n "$BODY" ]; then
            echo "$BODY" | python3 -m json.tool 2>/dev/null || echo "$BODY"
        fi
    else
        echo "❌ Failed"
        echo "Response: $BODY"
        return 1
    fi
    echo ""
}

# Test 1: Verify API Key
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔑 Test 1: Verify API Key"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
    -H "X-MediaBrowser-Token: $API_KEY" \
    "${JELLYFIN_URL}/System/Info" 2>&1)

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE:")

echo "HTTP Status: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ API Key is valid!"
    echo ""
    
    # Extract useful info
    SERVER_NAME=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('ServerName', 'Unknown'))" 2>/dev/null || echo "Unknown")
    VERSION=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('Version', 'Unknown'))" 2>/dev/null || echo "Unknown")
    OS=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('OperatingSystem', 'Unknown'))" 2>/dev/null || echo "Unknown")
    
    echo "Server Name: $SERVER_NAME"
    echo "Version: $VERSION"
    echo "OS: $OS"
    echo ""
else
    echo "❌ API Key validation failed!"
    echo "Response: $BODY"
    exit 1
fi

# Test 2: Get Live TV Tuner Info
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📺 Test 2: Get Live TV Tuner Info"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
    -H "X-MediaBrowser-Token: $API_KEY" \
    "${JELLYFIN_URL}/LiveTv/TunerHosts" 2>&1)

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE:")

echo "HTTP Status: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Tuner info retrieved!"
    echo ""
    
    # Extract tuner details
    TUNER_COUNT=$(echo "$BODY" | python3 -c "import sys, json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo "0")
    echo "Tuners configured: $TUNER_COUNT"
    
    if [ "$TUNER_COUNT" -gt 0 ]; then
        echo ""
        echo "Tuner Details:"
        echo "$BODY" | python3 -c "
import sys, json
tuners = json.load(sys.stdin)
for i, tuner in enumerate(tuners):
    print(f\"  Tuner {i+1}:\")
    print(f\"    Type: {tuner.get('Type', 'Unknown')}\")
    print(f\"    URL: {tuner.get('Url', 'N/A')}\")
    print(f\"    Channel Count: {tuner.get('ChannelCount', 0)}\")
    print(f\"    Status: {tuner.get('Status', 'Unknown')}\")
" 2>/dev/null || echo "$BODY" | head -20
    fi
    echo ""
else
    echo "⚠️  Could not retrieve tuner info"
    echo "Response: $BODY"
    echo ""
fi

# Test 3: Get Channel Count
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📡 Test 3: Get Live TV Channel Count"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
    -H "X-MediaBrowser-Token: $API_KEY" \
    "${JELLYFIN_URL}/LiveTv/Channels?limit=1" 2>&1)

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE:")

echo "HTTP Status: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Channel info retrieved!"
    echo ""
    
    TOTAL_CHANNELS=$(echo "$BODY" | python3 -c "import sys, json; print(json.load(sys.stdin).get('TotalRecordCount', 0))" 2>/dev/null || echo "0")
    echo "Total Live TV Channels in Jellyfin: $TOTAL_CHANNELS"
    echo ""
else
    echo "⚠️  Could not retrieve channel count"
    echo ""
fi

# Operation 1: Refresh Live TV Guide Data
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 Operation 1: Refresh Live TV Guide Data"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

read -p "Do you want to refresh Live TV guide data? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Refreshing guide data..."
    
    RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
        -X POST \
        -H "X-MediaBrowser-Token: $API_KEY" \
        "${JELLYFIN_URL}/LiveTv/GuideData/Refresh" 2>&1)
    
    HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
    
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "204" ]; then
        echo "✅ Guide data refresh started!"
        echo "   This may take 2-5 minutes to complete."
    else
        echo "❌ Failed to refresh guide data"
        echo "Response: $(echo "$RESPONSE" | grep -v "HTTP_CODE:")"
    fi
else
    echo "⏭️  Skipped"
fi
echo ""

# Operation 2: Refresh Library
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 Operation 2: Refresh Library (Metadata)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

read -p "Do you want to refresh all library metadata? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Refreshing library metadata..."
    
    RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
        -X POST \
        -H "X-MediaBrowser-Token: $API_KEY" \
        "${JELLYFIN_URL}/Library/Refresh" 2>&1)
    
    HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
    
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "204" ]; then
        echo "✅ Library metadata refresh started!"
        echo "   This will scan all libraries and update metadata."
    else
        echo "❌ Failed to refresh library"
        echo "Response: $(echo "$RESPONSE" | grep -v "HTTP_CODE:")"
    fi
else
    echo "⏭️  Skipped"
fi
echo ""

# Operation 3: Get Scheduled Tasks
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚙️  Operation 3: Check Scheduled Tasks"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
    -H "X-MediaBrowser-Token: $API_KEY" \
    "${JELLYFIN_URL}/ScheduledTasks" 2>&1)

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE:")

echo "HTTP Status: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Tasks retrieved!"
    echo ""
    echo "Relevant tasks:"
    
    echo "$BODY" | python3 -c "
import sys, json
tasks = json.load(sys.stdin)
relevant = ['Refresh Guide', 'Clean Cache', 'Clear', 'Image']
for task in tasks:
    name = task.get('Name', '')
    if any(keyword in name for keyword in relevant):
        state = task.get('State', 'Unknown')
        last_run = task.get('LastExecutionResult', {}).get('EndTimeUtc', 'Never')
        print(f\"  • {name}\")
        print(f\"    State: {state}\")
        print(f\"    Last Run: {last_run}\")
        print(f\"    Task ID: {task.get('Key', 'N/A')}\")
        print()
" 2>/dev/null || echo "Could not parse tasks"
    echo ""
else
    echo "⚠️  Could not retrieve scheduled tasks"
    echo ""
fi

# Operation 4: Trigger Cache Cleanup
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧹 Operation 4: Clear Image Cache"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

read -p "Do you want to clear the image cache? (y/n): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Clearing image cache..."
    
    # Try different endpoints for cache clearing
    RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
        -X POST \
        -H "X-MediaBrowser-Token: $API_KEY" \
        "${JELLYFIN_URL}/System/Tasks/Running/ClearCache" 2>&1)
    
    HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
    
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "204" ]; then
        echo "✅ Cache clear task started!"
    else
        # Try alternative endpoint
        echo "⚠️  First attempt failed, trying scheduled task trigger..."
        
        RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
            -X POST \
            -H "X-MediaBrowser-Token: $API_KEY" \
            "${JELLYFIN_URL}/ScheduledTasks/Running/ClearCacheDirectory" 2>&1)
        
        HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
        
        if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "204" ]; then
            echo "✅ Cache clear scheduled task triggered!"
        else
            echo "❌ Failed to clear cache via API"
            echo "   Manual clearing required on server"
            echo "   SSH: docker exec jellyfin rm -rf /config/data/cache/images/*"
        fi
    fi
else
    echo "⏭️  Skipped"
fi
echo ""

# Operation 5: Test Image Endpoint
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🖼️  Operation 5: Test Channel Image Loading"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo "Getting first channel to test image..."

RESPONSE=$(curl -s -w "\nHTTP_CODE:%{http_code}" \
    -H "X-MediaBrowser-Token: $API_KEY" \
    "${JELLYFIN_URL}/LiveTv/Channels?limit=3" 2>&1)

HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | grep -v "HTTP_CODE:")

if [ "$HTTP_CODE" = "200" ]; then
    echo ""
    echo "Testing image URLs for first 3 channels:"
    
    echo "$BODY" | python3 << 'PYEOF'
import sys, json
data = json.load(sys.stdin)
items = data.get('Items', [])
for i, item in enumerate(items[:3]):
    name = item.get('Name', 'Unknown')
    item_id = item.get('Id', '')
    has_primary = item.get('ImageTags', {}).get('Primary')
    
    print(f"\n  Channel {i+1}: {name}")
    print(f"    ID: {item_id}")
    print(f"    Has Primary Image: {bool(has_primary)}")
    
    if has_primary:
        print(f"    Image URL: /Items/{item_id}/Images/Primary")
PYEOF

    echo ""
    echo "Testing actual image endpoint..."
    
    FIRST_CHANNEL_ID=$(echo "$BODY" | python3 -c "import sys, json; items = json.load(sys.stdin).get('Items', []); print(items[0]['Id'] if items else '')" 2>/dev/null)
    
    if [ -n "$FIRST_CHANNEL_ID" ]; then
        IMAGE_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" \
            -H "X-MediaBrowser-Token: $API_KEY" \
            "${JELLYFIN_URL}/Items/${FIRST_CHANNEL_ID}/Images/Primary?fillHeight=330&fillWidth=330&quality=96")
        
        echo "Image endpoint test: HTTP $IMAGE_RESPONSE"
        
        if [ "$IMAGE_RESPONSE" = "200" ]; then
            echo "✅ Images are loading correctly!"
        elif [ "$IMAGE_RESPONSE" = "404" ]; then
            echo "⚠️  Image not found (channel may not have logo)"
        elif [ "$IMAGE_RESPONSE" = "500" ]; then
            echo "❌ Server error loading image (cache issue likely)"
        else
            echo "⚠️  Unexpected response: $IMAGE_RESPONSE"
        fi
    fi
else
    echo "❌ Could not retrieve channels for testing"
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Operations completed. Check above for any errors."
echo ""
echo "Next steps:"
echo "  1. Wait 2-5 minutes for tasks to complete"
echo "  2. Open Jellyfin: https://jellyfin.simondatalab.de"
echo "  3. Test Live TV → Channels (check for images)"
echo "  4. Press F12 and check console for 500 errors"
echo ""
echo "If images still fail:"
echo "  • SSH to VM200: ssh root@10.0.0.103"
echo "  • Check logs: docker logs jellyfin -n 100 | grep -i error"
echo "  • Manual cache clear: docker exec jellyfin rm -rf /config/data/cache/images/*"
echo "  • Restart: docker restart jellyfin"
echo ""
