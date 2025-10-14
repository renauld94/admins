#!/bin/bash

# NEURAL GEOSERVER MANUAL DEPLOYMENT
# Creates deployment package for manual upload to production server

set -e

echo "🌌 Creating Neural GeoServer Deployment Package..."

# Configuration
SOURCE_DIR="/home/simon/Desktop/Learning Management System Academy/portfolio/hero-r3f-odyssey"
DEPLOY_DIR="/home/simon/Desktop/Learning Management System Academy/deploy-package"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create deployment directory
mkdir -p "$DEPLOY_DIR"

echo "📦 Creating deployment package..."

# Copy neural GeoServer files
echo "  Copying neural GeoServer files..."
cp "$SOURCE_DIR/neural-geoserver-viz.js" "$DEPLOY_DIR/"
cp "$SOURCE_DIR/neural-geoserver-performance.js" "$DEPLOY_DIR/"
cp "$SOURCE_DIR/neural-geoserver-styles.css" "$DEPLOY_DIR/"
cp "$SOURCE_DIR/neural-geoserver-r3f.jsx" "$DEPLOY_DIR/"
cp "$SOURCE_DIR/index.html" "$DEPLOY_DIR/"

# Copy essential supporting files
echo "  Copying supporting files..."
cp "$SOURCE_DIR/styles.css" "$DEPLOY_DIR/"
cp "$SOURCE_DIR/globe-fab.css" "$DEPLOY_DIR/"
cp "$SOURCE_DIR/app.js" "$DEPLOY_DIR/"

# Create deployment instructions
cat > "$DEPLOY_DIR/DEPLOYMENT_INSTRUCTIONS.md" << 'EOF'
# Neural GeoServer Deployment Instructions

## Files to Upload
Upload these files to your web server's `/var/www/html/hero-r3f-odyssey/` directory:

### Core Neural GeoServer Files
- `neural-geoserver-viz.js` - Main visualization class
- `neural-geoserver-performance.js` - Performance optimizer
- `neural-geoserver-styles.css` - Styling and animations
- `neural-geoserver-r3f.jsx` - React Three Fiber components
- `index.html` - Updated HTML with neural GeoServer integration

### Supporting Files
- `styles.css` - Main stylesheet
- `globe-fab.css` - Globe button styles
- `app.js` - Main application script

## Deployment Steps

### Option 1: Direct File Upload
1. Access your server via console/KVM
2. Copy files to `/var/www/html/hero-r3f-odyssey/`
3. Set permissions: `chown -R www-data:www-data /var/www/html/hero-r3f-odyssey/`
4. Set permissions: `chmod -R 755 /var/www/html/hero-r3f-odyssey/`
5. Restart web server: `systemctl reload nginx`

### Option 2: Using rsync (if SSH is available)
```bash
rsync -avz --progress neural-geoserver-* root@136.243.155.166:/var/www/html/hero-r3f-odyssey/
rsync -avz --progress index.html styles.css globe-fab.css app.js root@136.243.155.166:/var/www/html/hero-r3f-odyssey/
```

### Option 3: Using scp (if SSH is available)
```bash
scp neural-geoserver-* root@136.243.155.166:/var/www/html/hero-r3f-odyssey/
scp index.html styles.css globe-fab.css app.js root@136.243.155.166:/var/www/html/hero-r3f-odyssey/
```

## Verification
After deployment, test the following URLs:
- https://www.simondatalab.de/hero-r3f-odyssey/index.html
- https://www.simondatalab.de/hero-r3f-odyssey/neural-geoserver-viz.js

## Features Deployed
✅ Real-time GeoServer REST API integration
✅ Neural clusters representing GeoServer layers
✅ Synaptic connections with animated data flows
✅ Earth sphere with live WMS textures
✅ Proxmox VM metrics as orbital satellites
✅ Interactive hover/click/selection with metadata
✅ GPU acceleration with LOD and frustum culling
✅ Performance monitoring and optimization

## Troubleshooting
- Check browser console for JavaScript errors
- Verify file permissions (755 for directories, 644 for files)
- Ensure web server is running and accessible
- Check GeoServer API endpoints are properly configured
EOF

# Create tar archive for easy transfer
echo "📦 Creating tar archive..."
cd "$DEPLOY_DIR"
tar -czf "../neural-geoserver-deployment-${TIMESTAMP}.tar.gz" *

echo ""
echo "✅ Neural GeoServer deployment package created!"
echo ""
echo "📁 Package location: $DEPLOY_DIR"
echo "📦 Archive: /home/simon/Desktop/Learning Management System Academy/neural-geoserver-deployment-${TIMESTAMP}.tar.gz"
echo ""
echo "📋 Files ready for deployment:"
ls -la "$DEPLOY_DIR"
echo ""
echo "🚀 Next Steps:"
echo "1. Upload files to your web server"
echo "2. Set proper permissions"
echo "3. Restart web server"
echo "4. Test the neural GeoServer visualization"
echo ""
echo "📖 See DEPLOYMENT_INSTRUCTIONS.md for detailed steps"
