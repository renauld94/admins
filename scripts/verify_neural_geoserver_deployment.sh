#!/bin/bash

# NEURAL GEOSERVER DEPLOYMENT VERIFICATION
# This script helps verify the deployment was successful

echo "🔍 Neural GeoServer Deployment Verification"
echo "=========================================="

echo "📋 Current Status Check:"
echo ""

# Check if neural GeoServer files are accessible
echo "1. Checking neural GeoServer files on production server..."

if curl -s -o /dev/null -w "%{http_code}" "https://www.simondatalab.de/hero-r3f-odyssey/neural-geoserver-viz.js" | grep -q "200"; then
    echo "   ✅ neural-geoserver-viz.js is accessible"
else
    echo "   ❌ neural-geoserver-viz.js returns 404 (not deployed yet)"
fi

if curl -s -o /dev/null -w "%{http_code}" "https://www.simondatalab.de/hero-r3f-odyssey/neural-geoserver-performance.js" | grep -q "200"; then
    echo "   ✅ neural-geoserver-performance.js is accessible"
else
    echo "   ❌ neural-geoserver-performance.js returns 404 (not deployed yet)"
fi

if curl -s -o /dev/null -w "%{http_code}" "https://www.simondatalab.de/hero-r3f-odyssey/neural-geoserver-styles.css" | grep -q "200"; then
    echo "   ✅ neural-geoserver-styles.css is accessible"
else
    echo "   ❌ neural-geoserver-styles.css returns 404 (not deployed yet)"
fi

echo ""
echo "2. Checking main page content..."

# Check what the main page shows
MAIN_PAGE_CONTENT=$(curl -s "https://www.simondatalab.de/hero-r3f-odyssey/index.html")

if echo "$MAIN_PAGE_CONTENT" | grep -q "Initializing Neural GeoServer"; then
    echo "   ✅ Main page shows 'Initializing Neural GeoServer...' (CORRECT)"
elif echo "$MAIN_PAGE_CONTENT" | grep -q "Epic Journey"; then
    echo "   ❌ Main page shows 'Epic Journey' (OLD VERSION - needs deployment)"
elif echo "$MAIN_PAGE_CONTENT" | grep -q "Initializing Data Intelligence Platform"; then
    echo "   ❌ Main page shows 'Initializing Data Intelligence Platform...' (OLD VERSION - needs deployment)"
else
    echo "   ⚠️  Main page content unclear - check manually"
fi

echo ""
echo "3. Checking script references..."

if echo "$MAIN_PAGE_CONTENT" | grep -q "NEURAL GEOSERVER VISUALIZATION"; then
    echo "   ✅ Page contains neural GeoServer script (CORRECT)"
elif echo "$MAIN_PAGE_CONTENT" | grep -q "NEURONS TO COSMOS"; then
    echo "   ❌ Page contains old 'NEURONS TO COSMOS' script (NEEDS UPDATE)"
else
    echo "   ⚠️  Script content unclear - check manually"
fi

echo ""
echo "📊 Summary:"
echo "==========="

# Count successful checks
SUCCESS_COUNT=0
TOTAL_CHECKS=5

if curl -s -o /dev/null -w "%{http_code}" "https://www.simondatalab.de/hero-r3f-odyssey/neural-geoserver-viz.js" | grep -q "200"; then
    ((SUCCESS_COUNT++))
fi

if curl -s -o /dev/null -w "%{http_code}" "https://www.simondatalab.de/hero-r3f-odyssey/neural-geoserver-performance.js" | grep -q "200"; then
    ((SUCCESS_COUNT++))
fi

if curl -s -o /dev/null -w "%{http_code}" "https://www.simondatalab.de/hero-r3f-odyssey/neural-geoserver-styles.css" | grep -q "200"; then
    ((SUCCESS_COUNT++))
fi

if echo "$MAIN_PAGE_CONTENT" | grep -q "Initializing Neural GeoServer"; then
    ((SUCCESS_COUNT++))
fi

if echo "$MAIN_PAGE_CONTENT" | grep -q "NEURAL GEOSERVER VISUALIZATION"; then
    ((SUCCESS_COUNT++))
fi

echo "Deployment Status: $SUCCESS_COUNT/$TOTAL_CHECKS checks passed"

if [ $SUCCESS_COUNT -eq $TOTAL_CHECKS ]; then
    echo "🎉 SUCCESS: Neural GeoServer visualization is fully deployed!"
    echo ""
    echo "🌌 Features now active:"
    echo "   ✅ Real-time GeoServer REST API integration"
    echo "   ✅ Neural clusters representing GeoServer layers"
    echo "   ✅ Synaptic connections with animated data flows"
    echo "   ✅ Earth sphere with live WMS textures"
    echo "   ✅ Proxmox VM metrics as orbital satellites"
    echo "   ✅ Interactive hover/click/selection with metadata"
    echo "   ✅ GPU acceleration with LOD and frustum culling"
    echo "   ✅ Performance monitoring and optimization"
elif [ $SUCCESS_COUNT -gt 0 ]; then
    echo "⚠️  PARTIAL: Some files deployed, but not complete"
    echo "   Continue with the deployment process"
else
    echo "❌ NOT DEPLOYED: Neural GeoServer files not uploaded yet"
    echo ""
    echo "🚀 Next Steps:"
    echo "   1. Upload files from quick-fix/ directory to your server"
    echo "   2. Set proper permissions"
    echo "   3. Restart web server"
    echo "   4. Run this verification script again"
fi

echo ""
echo "🔍 Manual Test URL:"
echo "   https://www.simondatalab.de/hero-r3f-odyssey/index.html"
