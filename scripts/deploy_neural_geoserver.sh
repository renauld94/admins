#!/bin/bash

# NEURAL GEOSERVER DEPLOYMENT SCRIPT
# Deploys the updated neural GeoServer visualization to simondatalab.de

set -e

echo "🌌 Deploying Neural GeoServer Visualization to simondatalab.de..."

# Configuration
LOCAL_DIR="/home/simon/Desktop/Learning Management System Academy/portfolio/hero-r3f-odyssey"
REMOTE_HOST="136.243.155.166"
REMOTE_USER="root"
REMOTE_PATH="/var/www/html"
BACKUP_DIR="/var/www/html/backups/$(date +%Y%m%d_%H%M%S)"

# Files to deploy
FILES=(
    "neural-geoserver-viz.js"
    "neural-geoserver-r3f.jsx"
    "neural-geoserver-styles.css"
    "neural-geoserver-performance.js"
    "index.html"
)

echo "📁 Creating backup of current files..."
ssh ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p ${BACKUP_DIR}"

for file in "${FILES[@]}"; do
    if ssh ${REMOTE_USER}@${REMOTE_HOST} "test -f ${REMOTE_PATH}/${file}"; then
        echo "  Backing up ${file}..."
        ssh ${REMOTE_USER}@${REMOTE_HOST} "cp ${REMOTE_PATH}/${file} ${BACKUP_DIR}/"
    fi
done

echo "🚀 Deploying new files..."

# Deploy each file
for file in "${FILES[@]}"; do
    if [ -f "${LOCAL_DIR}/${file}" ]; then
        echo "  Deploying ${file}..."
        scp "${LOCAL_DIR}/${file}" ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/
        
        # Set proper permissions
        ssh ${REMOTE_USER}@${REMOTE_HOST} "chmod 644 ${REMOTE_PATH}/${file}"
        ssh ${REMOTE_USER}@${REMOTE_HOST} "chown www-data:www-data ${REMOTE_PATH}/${file}"
    else
        echo "  ⚠️  Warning: ${file} not found locally"
    fi
done

echo "🔄 Restarting web services..."
ssh ${REMOTE_USER}@${REMOTE_HOST} "systemctl reload nginx"

echo "🧹 Clearing caches..."
ssh ${REMOTE_USER}@${REMOTE_HOST} "rm -rf /var/cache/nginx/*"

echo "✅ Deployment completed successfully!"
echo ""
echo "📊 Deployment Summary:"
echo "  - Files deployed: ${#FILES[@]}"
echo "  - Backup location: ${BACKUP_DIR}"
echo "  - Target URL: https://www.simondatalab.de/"
echo ""
echo "🌌 Neural GeoServer Visualization Features:"
echo "  - Real-time GeoServer REST API integration"
echo "  - Neural clusters representing GeoServer layers"
echo "  - Synaptic connections with animated data flows"
echo "  - Earth sphere with live WMS textures"
echo "  - Proxmox VM metrics as orbital satellites"
echo "  - Interactive hover/click/selection with metadata"
echo "  - GPU acceleration with LOD and frustum culling"
echo "  - Performance monitoring and optimization"
echo ""
echo "🎯 Next Steps:"
echo "  1. Test the visualization at https://www.simondatalab.de/"
echo "  2. Monitor performance metrics in browser console"
echo "  3. Verify GeoServer API connectivity"
echo "  4. Check Proxmox metrics integration"
echo ""
echo "🔧 Troubleshooting:"
echo "  - Check browser console for errors"
echo "  - Verify GeoServer REST endpoints are accessible"
echo "  - Monitor server logs: ssh ${REMOTE_USER}@${REMOTE_HOST} 'tail -f /var/log/nginx/error.log'"
echo "  - Restore from backup if needed: scp ${REMOTE_USER}@${REMOTE_HOST}:${BACKUP_DIR}/* ${LOCAL_DIR}/"
