#!/bin/bash

# QUICK NEURAL GEOSERVER DEPLOYMENT FIX
# This script creates a minimal deployment package to fix the visualization immediately

set -e

echo "🚀 Quick Neural GeoServer Deployment Fix"
echo "======================================="

# Configuration
SOURCE_DIR="/home/simon/Desktop/Learning Management System Academy/deploy-package"
QUICK_DEPLOY_DIR="/home/simon/Desktop/Learning Management System Academy/quick-fix"

echo "📋 Issue Identified:"
echo "  ❌ Production server running old 'NEURONS TO COSMOS' script"
echo "  ✅ Local version has correct 'NEURAL GEOSERVER' script"
echo ""

# Create quick fix directory
mkdir -p "$QUICK_DEPLOY_DIR"

echo "📦 Creating minimal deployment package..."

# Copy only the essential files
cp "$SOURCE_DIR/index.html" "$QUICK_DEPLOY_DIR/"
cp "$SOURCE_DIR/neural-geoserver-viz.js" "$QUICK_DEPLOY_DIR/"
cp "$SOURCE_DIR/neural-geoserver-performance.js" "$QUICK_DEPLOY_DIR/"
cp "$SOURCE_DIR/neural-geoserver-styles.css" "$QUICK_DEPLOY_DIR/"

echo "✅ Minimal deployment package created!"
echo ""

echo "📁 Files in quick-fix directory:"
ls -la "$QUICK_DEPLOY_DIR"

echo ""
echo "🚀 URGENT DEPLOYMENT STEPS:"
echo ""
echo "1. Access your server console/KVM"
echo "2. Navigate to: /var/www/html/hero-r3f-odyssey/"
echo "3. Upload these 4 files from $QUICK_DEPLOY_DIR:"
echo "   - index.html (CRITICAL - this fixes the visualization)"
echo "   - neural-geoserver-viz.js"
echo "   - neural-geoserver-performance.js"
echo "   - neural-geoserver-styles.css"
echo ""
echo "4. Set permissions:"
echo "   chown -R www-data:www-data /var/www/html/hero-r3f-odyssey/"
echo "   chmod -R 755 /var/www/html/hero-r3f-odyssey/"
echo ""
echo "5. Restart web server:"
echo "   systemctl reload nginx"
echo ""
echo "✅ Expected Result:"
echo "   The page will show 'Initializing Neural GeoServer...' instead of"
echo "   '🌌 Epic Journey - Neural Data Visualization'"
echo ""
echo "🔍 Test URL after deployment:"
echo "   https://www.simondatalab.de/hero-r3f-odyssey/index.html"
echo ""
echo "📊 File Sizes:"
echo "   - index.html: $(du -h $QUICK_DEPLOY_DIR/index.html | cut -f1)"
echo "   - neural-geoserver-viz.js: $(du -h $QUICK_DEPLOY_DIR/neural-geoserver-viz.js | cut -f1)"
echo "   - neural-geoserver-performance.js: $(du -h $QUICK_DEPLOY_DIR/neural-geoserver-performance.js | cut -f1)"
echo "   - neural-geoserver-styles.css: $(du -h $QUICK_DEPLOY_DIR/neural-geoserver-styles.css | cut -f1)"
