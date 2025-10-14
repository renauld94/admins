#!/bin/bash

# CLOUDFLARE CACHE PURGE VIA API
# Purges Cloudflare cache for neural GeoServer visualization

echo "🌌 PURGING CLOUDFLARE CACHE VIA API"
echo "===================================="
echo ""

# Check if Cloudflare API credentials are available
if [ -z "$CLOUDFLARE_API_TOKEN" ] && [ -z "$CLOUDFLARE_EMAIL" ] && [ -z "$CLOUDFLARE_API_KEY" ]; then
    echo "❌ Cloudflare API credentials not found!"
    echo ""
    echo "Please set one of the following:"
    echo "  Option 1: CLOUDFLARE_API_TOKEN (recommended)"
    echo "  Option 2: CLOUDFLARE_EMAIL + CLOUDFLARE_API_KEY"
    echo ""
    echo "Example:"
    echo "  export CLOUDFLARE_API_TOKEN='your-api-token'"
    echo "  export CLOUDFLARE_EMAIL='your-email@example.com'"
    echo "  export CLOUDFLARE_API_KEY='your-global-api-key'"
    echo ""
    echo "You can get these from:"
    echo "  https://dash.cloudflare.com/profile/api-tokens"
    echo ""
    echo "For API Token (recommended):"
    echo "  1. Go to https://dash.cloudflare.com/profile/api-tokens"
    echo "  2. Click 'Create Token'"
    echo "  3. Use 'Custom token' template"
    echo "  4. Set permissions: Zone:Zone:Read, Zone:Cache Purge:Edit"
    echo "  5. Set zone resources: Include:simondatalab.de"
    echo "  6. Copy the token and run: export CLOUDFLARE_API_TOKEN='your-token'"
    echo ""
    echo "For Global API Key:"
    echo "  1. Go to https://dash.cloudflare.com/profile/api-tokens"
    echo "  2. Click 'View' next to 'Global API Key'"
    echo "  3. Copy the key and run: export CLOUDFLARE_API_KEY='your-key'"
    echo "  4. Also set: export CLOUDFLARE_EMAIL='your-email@example.com'"
    echo ""
    exit 1
fi

# Set domain
DOMAIN="simondatalab.de"
ZONE_ID=""

echo "🔍 Getting Zone ID for domain: $DOMAIN"

# Get Zone ID
if [ ! -z "$CLOUDFLARE_API_TOKEN" ]; then
    # Using API Token (recommended)
    echo "Using API Token authentication..."
    ZONE_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json")
else
    # Using Email + API Key
    echo "Using Email + API Key authentication..."
    ZONE_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" \
        -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
        -H "X-Auth-Key: $CLOUDFLARE_API_KEY" \
        -H "Content-Type: application/json")
fi

# Extract Zone ID
ZONE_ID=$(echo "$ZONE_RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$ZONE_ID" ]; then
    echo "❌ Failed to get Zone ID for domain: $DOMAIN"
    echo "Response: $ZONE_RESPONSE"
    echo ""
    echo "Please check:"
    echo "  1. Your API credentials are correct"
    echo "  2. You have access to the domain: $DOMAIN"
    echo "  3. Your API token has Zone:Zone:Read permission"
    exit 1
fi

echo "✅ Zone ID found: $ZONE_ID"
echo ""

# URLs to purge
URLS=(
    "https://www.simondatalab.de/"
    "https://www.simondatalab.de/index.html"
    "https://www.simondatalab.de/neural-geoserver-viz.js"
    "https://www.simondatalab.de/neural-geoserver-performance.js"
    "https://www.simondatalab.de/neural-geoserver-styles.css"
    "https://www.simondatalab.de/hero-r3f-odyssey/index.html"
    "https://www.simondatalab.de/hero-r3f-odyssey/neural-geoserver-viz.js"
    "https://www.simondatalab.de/hero-r3f-odyssey/neural-geoserver-performance.js"
    "https://www.simondatalab.de/hero-r3f-odyssey/neural-geoserver-styles.css"
)

echo "🚀 Purging cache for ${#URLS[@]} URLs..."

# Create JSON payload for URLs
JSON_PAYLOAD='{"files":['
for i in "${!URLS[@]}"; do
    JSON_PAYLOAD+="\"${URLS[$i]}\""
    if [ $i -lt $((${#URLS[@]} - 1)) ]; then
        JSON_PAYLOAD+=","
    fi
done
JSON_PAYLOAD+=']}'

echo "📋 URLs to purge:"
for url in "${URLS[@]}"; do
    echo "  - $url"
done
echo ""

# Purge cache
echo "🔄 Sending purge request..."

if [ ! -z "$CLOUDFLARE_API_TOKEN" ]; then
    # Using API Token (recommended)
    PURGE_RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$JSON_PAYLOAD")
else
    # Using Email + API Key
    PURGE_RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
        -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
        -H "X-Auth-Key: $CLOUDFLARE_API_KEY" \
        -H "Content-Type: application/json" \
        -d "$JSON_PAYLOAD")
fi

# Check if purge was successful
if echo "$PURGE_RESPONSE" | grep -q '"success":true'; then
    echo "✅ Cache purge successful!"
    echo ""
    echo "⏳ Waiting 60 seconds for cache to propagate globally..."
    sleep 60
    echo ""
    
    echo "🧪 TESTING DEPLOYMENT..."
    echo "========================"
    
    # Test main page
    echo "1. Testing main page:"
    MAIN_PAGE_TEST=$(curl -s https://www.simondatalab.de/ | grep -i "initializing.*neural.*geoserver")
    if [ ! -z "$MAIN_PAGE_TEST" ]; then
        echo "   ✅ Main page shows neural GeoServer content"
        echo "   Content: $MAIN_PAGE_TEST"
    else
        echo "   ⚠️  Main page still shows old content (cache may need more time)"
        echo "   Current content: $(curl -s https://www.simondatalab.de/ | grep -i "initializing" | head -1)"
    fi
    
    # Test hero page
    echo ""
    echo "2. Testing hero-r3f-odyssey page:"
    HERO_PAGE_TEST=$(curl -s https://www.simondatalab.de/hero-r3f-odyssey/index.html | grep -i "initializing.*neural.*geoserver")
    if [ ! -z "$HERO_PAGE_TEST" ]; then
        echo "   ✅ Hero page shows neural GeoServer content"
        echo "   Content: $HERO_PAGE_TEST"
    else
        echo "   ⚠️  Hero page still shows old content (cache may need more time)"
        echo "   Current content: $(curl -s https://www.simondatalab.de/hero-r3f-odyssey/index.html | grep -i "initializing" | head -1)"
    fi
    
    # Test neural GeoServer files
    echo ""
    echo "3. Testing neural GeoServer files:"
    
    for url in "https://www.simondatalab.de/neural-geoserver-viz.js" \
               "https://www.simondatalab.de/neural-geoserver-performance.js" \
               "https://www.simondatalab.de/neural-geoserver-styles.css"; do
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$url")
        CONTENT_LENGTH=$(curl -s -I "$url" | grep -i "content-length" | cut -d' ' -f2 | tr -d '\r')
        if [ "$HTTP_STATUS" = "200" ]; then
            echo "   ✅ $(basename $url): HTTP 200 (${CONTENT_LENGTH} bytes)"
        else
            echo "   ❌ $(basename $url): HTTP $HTTP_STATUS"
        fi
    done
    
    echo ""
    echo "4. Testing hero-r3f-odyssey files:"
    
    for url in "https://www.simondatalab.de/hero-r3f-odyssey/neural-geoserver-viz.js" \
               "https://www.simondatalab.de/hero-r3f-odyssey/neural-geoserver-performance.js" \
               "https://www.simondatalab.de/hero-r3f-odyssey/neural-geoserver-styles.css"; do
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$url")
        CONTENT_LENGTH=$(curl -s -I "$url" | grep -i "content-length" | cut -d' ' -f2 | tr -d '\r')
        if [ "$HTTP_STATUS" = "200" ]; then
            echo "   ✅ $(basename $url): HTTP 200 (${CONTENT_LENGTH} bytes)"
        else
            echo "   ❌ $(basename $url): HTTP $HTTP_STATUS"
        fi
    done
    
    echo ""
    echo "🎉 CACHE PURGE COMPLETE!"
    echo "========================"
    echo ""
    echo "🌐 Test URLs:"
    echo "  Main page: https://www.simondatalab.de/"
    echo "  Hero page: https://www.simondatalab.de/hero-r3f-odyssey/index.html"
    echo ""
    echo "Expected result:"
    echo "  - Page shows 'Initializing Neural GeoServer...'"
    echo "  - Neural GeoServer visualization loads with real-time GeoServer integration"
    echo "  - Neural clusters, synaptic connections, Earth backdrop, Proxmox satellites"
    echo "  - GPU-accelerated 3D visualization with 10K+ particles"
    
else
    echo "❌ Cache purge failed!"
    echo "Response: $PURGE_RESPONSE"
    echo ""
    echo "Please check:"
    echo "  1. Your API credentials are correct"
    echo "  2. You have Zone:Cache Purge:Edit permission"
    echo "  3. Your API token has access to the domain: $DOMAIN"
    exit 1
fi
