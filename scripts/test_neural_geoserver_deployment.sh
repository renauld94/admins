#!/bin/bash

# NEURAL GEOSERVER DEPLOYMENT TEST
# Tests the deployment after Cloudflare cache purge

echo "🧪 NEURAL GEOSERVER DEPLOYMENT TEST"
echo "===================================="
echo ""

echo "⏳ Testing deployment status..."
echo ""

# Test main page
echo "1. Testing main page content:"
MAIN_PAGE_CONTENT=$(curl -s https://www.simondatalab.de/ | grep -i "initializing")
if echo "$MAIN_PAGE_CONTENT" | grep -q "neural.*geoserver"; then
    echo "   ✅ Main page shows neural GeoServer content"
    echo "   Content: $MAIN_PAGE_CONTENT"
else
    echo "   ⚠️  Main page shows old content"
    echo "   Content: $MAIN_PAGE_CONTENT"
fi

echo ""

# Test neural GeoServer files
echo "2. Testing neural GeoServer files:"
echo ""

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

# Test hero-r3f-odyssey files
echo "3. Testing hero-r3f-odyssey files:"
echo ""

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

# Test hero page
echo "4. Testing hero-r3f-odyssey page:"
HERO_PAGE_CONTENT=$(curl -s https://www.simondatalab.de/hero-r3f-odyssey/index.html | grep -i "initializing")
if echo "$HERO_PAGE_CONTENT" | grep -q "neural.*geoserver"; then
    echo "   ✅ Hero page shows neural GeoServer content"
    echo "   Content: $HERO_PAGE_CONTENT"
else
    echo "   ⚠️  Hero page shows old content"
    echo "   Content: $HERO_PAGE_CONTENT"
fi

echo ""

# Summary
echo "📊 DEPLOYMENT SUMMARY:"
echo "======================"

# Count successful tests
SUCCESS_COUNT=0
TOTAL_TESTS=7

# Check main page
if echo "$MAIN_PAGE_CONTENT" | grep -q "neural.*geoserver"; then
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
fi

# Check files
for url in "https://www.simondatalab.de/neural-geoserver-viz.js" \
           "https://www.simondatalab.de/neural-geoserver-performance.js" \
           "https://www.simondatalab.de/neural-geoserver-styles.css" \
           "https://www.simondatalab.de/hero-r3f-odyssey/neural-geoserver-viz.js" \
           "https://www.simondatalab.de/hero-r3f-odyssey/neural-geoserver-performance.js" \
           "https://www.simondatalab.de/hero-r3f-odyssey/neural-geoserver-styles.css"; do
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    if [ "$HTTP_STATUS" = "200" ]; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    fi
done

# Check hero page
if echo "$HERO_PAGE_CONTENT" | grep -q "neural.*geoserver"; then
    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
fi

echo "Tests passed: $SUCCESS_COUNT/$TOTAL_TESTS"

if [ $SUCCESS_COUNT -eq $TOTAL_TESTS ]; then
    echo ""
    echo "🎉 SUCCESS! Neural GeoServer visualization is fully deployed!"
    echo ""
    echo "🌐 Live URLs:"
    echo "  Main page: https://www.simondatalab.de/"
    echo "  Hero page: https://www.simondatalab.de/hero-r3f-odyssey/index.html"
    echo ""
    echo "Expected features:"
    echo "  ✅ Real-time GeoServer REST API integration"
    echo "  ✅ Neural clusters representing GeoServer layers"
    echo "  ✅ Synaptic connections with animated data flows"
    echo "  ✅ Earth sphere with live WMS textures"
    echo "  ✅ Proxmox VM metrics as orbital satellites"
    echo "  ✅ Interactive hover/click/selection with metadata"
    echo "  ✅ GPU acceleration with LOD and frustum culling"
    echo "  ✅ Performance monitoring and optimization"
elif [ $SUCCESS_COUNT -gt 0 ]; then
    echo ""
    echo "⚠️  PARTIAL SUCCESS: Some files are accessible but cache purge may be incomplete"
    echo "   Wait 1-2 minutes and run this test again"
else
    echo ""
    echo "❌ CACHE PURGE NEEDED: All files still returning 404"
    echo ""
    echo "Please purge Cloudflare cache:"
    echo "1. Go to https://dash.cloudflare.com/"
    echo "2. Select your domain: simondatalab.de"
    echo "3. Go to Caching > Configuration"
    echo "4. Click 'Purge Everything'"
    echo "5. Wait 1-2 minutes"
    echo "6. Run this test again"
fi

echo ""
echo "🔄 To run this test again: ./test_neural_geoserver_deployment.sh"
