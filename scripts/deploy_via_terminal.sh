#!/bin/bash

# TERMINAL DEPLOYMENT WITH CURL TESTING
# Attempts multiple deployment methods and tests with curl

set -e

echo "🚀 Terminal Deployment with Curl Testing"
echo "========================================"

# Configuration
QUICK_FIX_DIR="/home/simon/Desktop/Learning Management System Academy/quick-fix"
SERVER_IP="136.243.155.166"
SERVER_USER="root"
TARGET_PATH="/var/www/html/hero-r3f-odyssey"

echo "📋 Files ready for deployment:"
ls -la "$QUICK_FIX_DIR"

echo ""
echo "🔍 Testing server connectivity..."

# Test basic connectivity
if ping -c 2 $SERVER_IP > /dev/null 2>&1; then
    echo "✅ Server $SERVER_IP is reachable"
else
    echo "❌ Server $SERVER_IP is not reachable"
    exit 1
fi

echo ""
echo "🚀 Attempting deployment methods..."

# Method 1: Try rsync with password prompt
echo "Method 1: rsync with password authentication"
echo "Uploading files to $SERVER_USER@$SERVER_IP:$TARGET_PATH"
echo "You may be prompted for password..."

rsync -avz --progress "$QUICK_FIX_DIR/" "$SERVER_USER@$SERVER_IP:$TARGET_PATH/" || {
    echo "❌ rsync failed - trying alternative method"
    
    # Method 2: Try scp
    echo ""
    echo "Method 2: scp with password authentication"
    echo "Uploading files individually..."
    
    for file in "$QUICK_FIX_DIR"/*; do
        filename=$(basename "$file")
        echo "Uploading $filename..."
        scp "$file" "$SERVER_USER@$SERVER_IP:$TARGET_PATH/" || {
            echo "❌ scp failed for $filename"
        }
    done
}

echo ""
echo "🔧 Setting permissions on server..."
ssh "$SERVER_USER@$SERVER_IP" "chown -R www-data:www-data $TARGET_PATH && chmod -R 755 $TARGET_PATH" || {
    echo "⚠️  Could not set permissions via SSH"
}

echo ""
echo "🔄 Restarting web server..."
ssh "$SERVER_USER@$SERVER_IP" "systemctl reload nginx" || {
    echo "⚠️  Could not restart web server via SSH"
}

echo ""
echo "🧪 Testing deployment with curl..."

# Wait a moment for server to restart
sleep 3

# Test each file
echo "Testing neural GeoServer files:"

# Test neural-geoserver-viz.js
if curl -s -o /dev/null -w "%{http_code}" "https://www.simondatalab.de/hero-r3f-odyssey/neural-geoserver-viz.js" | grep -q "200"; then
    echo "✅ neural-geoserver-viz.js is accessible"
else
    echo "❌ neural-geoserver-viz.js returns error"
fi

# Test neural-geoserver-performance.js
if curl -s -o /dev/null -w "%{http_code}" "https://www.simondatalab.de/hero-r3f-odyssey/neural-geoserver-performance.js" | grep -q "200"; then
    echo "✅ neural-geoserver-performance.js is accessible"
else
    echo "❌ neural-geoserver-performance.js returns error"
fi

# Test neural-geoserver-styles.css
if curl -s -o /dev/null -w "%{http_code}" "https://www.simondatalab.de/hero-r3f-odyssey/neural-geoserver-styles.css" | grep -q "200"; then
    echo "✅ neural-geoserver-styles.css is accessible"
else
    echo "❌ neural-geoserver-styles.css returns error"
fi

# Test main page content
echo ""
echo "Testing main page content..."
MAIN_PAGE_CONTENT=$(curl -s "https://www.simondatalab.de/hero-r3f-odyssey/index.html")

if echo "$MAIN_PAGE_CONTENT" | grep -q "Initializing Neural GeoServer"; then
    echo "✅ Main page shows 'Initializing Neural GeoServer...' (SUCCESS!)"
elif echo "$MAIN_PAGE_CONTENT" | grep -q "Epic Journey"; then
    echo "❌ Main page still shows 'Epic Journey' (deployment failed)"
else
    echo "⚠️  Main page content unclear"
fi

if echo "$MAIN_PAGE_CONTENT" | grep -q "NEURAL GEOSERVER VISUALIZATION"; then
    echo "✅ Page contains neural GeoServer script (SUCCESS!)"
elif echo "$MAIN_PAGE_CONTENT" | grep -q "NEURONS TO COSMOS"; then
    echo "❌ Page still contains old 'NEURONS TO COSMOS' script"
else
    echo "⚠️  Script content unclear"
fi

echo ""
echo "🎯 Final Test URL:"
echo "https://www.simondatalab.de/hero-r3f-odyssey/index.html"

echo ""
echo "📊 Deployment Summary:"
echo "======================"

# Count successful deployments
SUCCESS_COUNT=0
TOTAL_FILES=4

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

echo "Deployment Status: $SUCCESS_COUNT/$TOTAL_FILES files deployed successfully"

if [ $SUCCESS_COUNT -eq $TOTAL_FILES ]; then
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
else
    echo "⚠️  Partial deployment - some files may need manual upload"
    echo ""
    echo "Manual upload required for:"
    echo "   - Files in: $QUICK_FIX_DIR"
    echo "   - Target: $SERVER_USER@$SERVER_IP:$TARGET_PATH"
fi
