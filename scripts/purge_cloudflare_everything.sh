#!/bin/bash

# CLOUDFLARE CACHE PURGE VIA API - PURGE EVERYTHING
# Purges all Cloudflare cache for neural GeoServer visualization

echo "🌌 PURGING CLOUDFLARE CACHE VIA API (PURGE EVERYTHING)"
echo "====================================================="
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
    echo "For now, I'll show you how to do it manually:"
    echo "1. Go to https://dash.cloudflare.com/"
    echo "2. Select your domain: simondatalab.de"
    echo "3. Go to Caching > Configuration"
    echo "4. Click 'Purge Everything'"
    echo "5. Wait 1-2 minutes"
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
    ZONE_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json")
else
    # Using Email + API Key
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
    exit 1
fi

echo "✅ Zone ID found: $ZONE_ID"
echo ""

# Purge everything
echo "🚀 Purging ALL cache for domain: $DOMAIN"
echo "This will purge all cached content, not just specific URLs."
echo ""

# Purge everything
if [ ! -z "$CLOUDFLARE_API_TOKEN" ]; then
    # Using API Token (recommended)
    PURGE_RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
        -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
        -H "Content-Type: application/json" \
        -d '{"purge_everything":true}')
else
    # Using Email + API Key
    PURGE_RESPONSE=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
        -H "X-Auth-Email: $CLOUDFLARE_EMAIL" \
        -H "X-Auth-Key: $CLOUDFLARE_API_KEY" \
        -H "Content-Type: application/json" \
        -d '{"purge_everything":true}')
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
    
    # Test neural GeoServer files
    echo ""
    echo "2. Testing neural GeoServer files:"
    
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
    echo "3. Testing hero-r3f-odyssey files:"
    
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
    exit 1
fi
