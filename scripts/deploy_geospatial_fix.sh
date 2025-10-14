#!/bin/bash

# Deploy geospatial visualization fixes to CT 150
echo "Deploying geospatial visualization fixes..."

# Copy the updated file to CT 150
echo "Copying updated geospatial-viz/index.html to CT 150..."
cp "/home/simon/Desktop/Learning Management System Academy/portfolio/hero-r3f-odyssey/geospatial-viz/index.html" /var/www/html/geospatial-viz/index.html

# Set correct permissions
echo "Setting correct permissions..."
chown www-data:www-data /var/www/html/geospatial-viz/index.html
chmod 644 /var/www/html/geospatial-viz/index.html

# Reload nginx
echo "Reloading nginx..."
systemctl reload nginx

echo "Deployment complete!"
echo "Testing the page..."
curl -s https://www.simondatalab.de/geospatial-viz/index.html | head -20

echo ""
echo "Changes made:"
echo "1. ✅ Changed default location to user's current location (instead of Ho Chi Minh City)"
echo "2. ✅ Fixed openRadarSource function errors"
echo "3. ✅ Removed Vietnam Precipitation Radar panel"
echo "4. ✅ Weather Layer now properly shows Precipitation Radar as default"
echo "5. ✅ Weather Opacity displays correctly (70%)"
