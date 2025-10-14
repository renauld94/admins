#!/bin/bash

# MANUAL NEURAL GEOSERVER DEPLOYMENT HELPER
# This script prepares files for manual upload to your production server

set -e

echo "🌌 Neural GeoServer Manual Deployment Helper"
echo "============================================="

# Configuration
DEPLOY_DIR="/home/simon/Desktop/Learning Management System Academy/deploy-package"
TARGET_SERVER="136.243.155.166"
TARGET_PATH="/var/www/html/hero-r3f-odyssey"

echo ""
echo "📋 Current Status:"
echo "  ✅ Neural GeoServer files created locally"
echo "  ❌ Files not deployed to production server"
echo "  ❌ Website still showing old content"
echo ""

echo "📦 Files ready for deployment:"
ls -la "$DEPLOY_DIR" | grep -E "(neural-geoserver|index\.html|styles\.css|app\.js|globe-fab\.css)"

echo ""
echo "🚀 Manual Deployment Options:"
echo ""
echo "OPTION 1: Direct Server Access (Recommended)"
echo "1. Access your server console/KVM"
echo "2. Navigate to: $TARGET_PATH"
echo "3. Upload these files from $DEPLOY_DIR:"
echo "   - neural-geoserver-viz.js"
echo "   - neural-geoserver-performance.js"
echo "   - neural-geoserver-styles.css"
echo "   - neural-geoserver-r3f.jsx"
echo "   - index.html"
echo "   - styles.css"
echo "   - globe-fab.css"
echo "   - app.js"
echo "4. Set permissions: chown -R www-data:www-data $TARGET_PATH"
echo "5. Set permissions: chmod -R 755 $TARGET_PATH"
echo "6. Restart web server: systemctl reload nginx"
echo ""

echo "OPTION 2: Using File Manager"
echo "1. Open your server's file manager"
echo "2. Navigate to $TARGET_PATH"
echo "3. Upload files from $DEPLOY_DIR"
echo "4. Set proper permissions"
echo ""

echo "OPTION 3: Using Web-based File Upload"
echo "1. Access your server's web-based file manager"
echo "2. Navigate to $TARGET_PATH"
echo "3. Upload the files"
echo ""

echo "🔍 Verification Steps:"
echo "After deployment, test these URLs:"
echo "  - https://www.simondatalab.de/hero-r3f-odyssey/index.html"
echo "  - https://www.simondatalab.de/hero-r3f-odyssey/neural-geoserver-viz.js"
echo ""

echo "✅ Expected Result:"
echo "The page should show 'Initializing Neural GeoServer...' instead of"
echo "'Initializing Data Intelligence Platform...'"
echo ""

echo "🌌 Neural GeoServer Features After Deployment:"
echo "  ✅ Real-time GeoServer REST API integration"
echo "  ✅ Neural clusters representing GeoServer layers"
echo "  ✅ Synaptic connections with animated data flows"
echo "  ✅ Earth sphere with live WMS textures"
echo "  ✅ Proxmox VM metrics as orbital satellites"
echo "  ✅ Interactive hover/click/selection with metadata"
echo "  ✅ GPU acceleration with LOD and frustum culling"
echo "  ✅ Performance monitoring and optimization"
echo ""

echo "📁 Files are ready in: $DEPLOY_DIR"
echo "📖 See DEPLOYMENT_INSTRUCTIONS.md for detailed steps"
