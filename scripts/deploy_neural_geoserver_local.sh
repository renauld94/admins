#!/bin/bash

# LOCAL NEURAL GEOSERVER DEPLOYMENT SCRIPT
# Copies files to the correct location for local web server

set -e

echo "🌌 Deploying Neural GeoServer Visualization locally..."

# Configuration
SOURCE_DIR="/home/simon/Desktop/Learning Management System Academy/portfolio/hero-r3f-odyssey"
TARGET_DIR="/home/simon/Desktop/Learning Management System Academy/portfolio"
BACKUP_DIR="/home/simon/Desktop/Learning Management System Academy/backups/neural-geoserver-$(date +%Y%m%d_%H%M%S)"

# Files to deploy
FILES=(
    "neural-geoserver-viz.js"
    "neural-geoserver-r3f.jsx"
    "neural-geoserver-styles.css"
    "neural-geoserver-performance.js"
    "index.html"
)

echo "📁 Creating backup directory..."
mkdir -p "${BACKUP_DIR}"

echo "💾 Backing up existing files..."
for file in "${FILES[@]}"; do
    if [ -f "${TARGET_DIR}/${file}" ]; then
        echo "  Backing up ${file}..."
        cp "${TARGET_DIR}/${file}" "${BACKUP_DIR}/"
    fi
done

echo "🚀 Deploying new files..."

# Deploy each file
for file in "${FILES[@]}"; do
    if [ -f "${SOURCE_DIR}/${file}" ]; then
        echo "  Deploying ${file}..."
        cp "${SOURCE_DIR}/${file}" "${TARGET_DIR}/"
        echo "    ✅ ${file} deployed successfully"
    else
        echo "  ⚠️  Warning: ${file} not found in source directory"
    fi
done

echo ""
echo "✅ Local deployment completed successfully!"
echo ""
echo "📊 Deployment Summary:"
echo "  - Files deployed: ${#FILES[@]}"
echo "  - Source: ${SOURCE_DIR}"
echo "  - Target: ${TARGET_DIR}"
echo "  - Backup: ${BACKUP_DIR}"
echo ""
echo "🌌 Neural GeoServer Visualization Features:"
echo "  ✅ Real-time GeoServer REST API integration"
echo "  ✅ Neural clusters representing GeoServer layers"
echo "  ✅ Synaptic connections with animated data flows"
echo "  ✅ Earth sphere with live WMS textures"
echo "  ✅ Proxmox VM metrics as orbital satellites"
echo "  ✅ Interactive hover/click/selection with metadata"
echo "  ✅ GPU acceleration with LOD and frustum culling"
echo "  ✅ Performance monitoring and optimization"
echo ""
echo "🎯 Next Steps:"
echo "  1. Start your local web server"
echo "  2. Open http://localhost:8000/hero-r3f-odyssey/index.html"
echo "  3. Test the neural GeoServer visualization"
echo "  4. Monitor performance metrics in browser console"
echo ""
echo "🔧 Manual Deployment to Production:"
echo "  When ready to deploy to production, you can:"
echo "  1. Use rsync: rsync -avz ${TARGET_DIR}/ user@server:/var/www/html/"
echo "  2. Use scp: scp ${TARGET_DIR}/* user@server:/var/www/html/"
echo "  3. Use git: git add . && git commit -m 'Deploy neural GeoServer viz' && git push"
echo ""
echo "📝 Files Ready for Production:"
for file in "${FILES[@]}"; do
    if [ -f "${TARGET_DIR}/${file}" ]; then
        echo "  ✅ ${file}"
    else
        echo "  ❌ ${file} (missing)"
    fi
done
