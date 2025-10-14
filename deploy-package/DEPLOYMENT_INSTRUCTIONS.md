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
