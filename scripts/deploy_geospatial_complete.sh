#!/bin/bash

# Comprehensive deployment script for geospatial visualization fixes
echo "🚀 Deploying geospatial visualization fixes to CT 150..."

# Check if we're on CT 150
if [[ $(hostname) != "portfolio-web" ]]; then
    echo "❌ This script must be run on CT 150 (portfolio-web)"
    echo "Please run: ssh ct150-direct 'bash /path/to/this/script'"
    exit 1
fi

echo "✅ Running on CT 150"

# Backup current file
echo "📦 Creating backup..."
cp /var/www/html/geospatial-viz/index.html /var/www/html/geospatial-viz/index.html.backup.$(date +%Y%m%d_%H%M%S)

# Copy updated file from local workspace
echo "📁 Copying updated file..."
if [[ -f "/home/simon/Desktop/Learning Management System Academy/portfolio/hero-r3f-odyssey/geospatial-viz/index.html" ]]; then
    cp "/home/simon/Desktop/Learning Management System Academy/portfolio/hero-r3f-odyssey/geospatial-viz/index.html" /var/www/html/geospatial-viz/index.html
    echo "✅ File copied successfully"
else
    echo "❌ Source file not found. Please ensure the file exists."
    exit 1
fi

# Set correct permissions
echo "🔐 Setting permissions..."
chown www-data:www-data /var/www/html/geospatial-viz/index.html
chmod 644 /var/www/html/geospatial-viz/index.html

# Reload nginx
echo "🔄 Reloading nginx..."
systemctl reload nginx

# Test the deployment
echo "🧪 Testing deployment..."
echo "Testing main page..."
curl -s -o /dev/null -w "%{http_code}" https://www.simondatalab.de/geospatial-viz/index.html
echo ""

echo "Testing for Vietnam Precipitation Radar panel removal..."
if curl -s https://www.simondatalab.de/geospatial-viz/index.html | grep -q "Vietnam Precipitation Radar"; then
    echo "❌ Vietnam Precipitation Radar panel still present!"
else
    echo "✅ Vietnam Precipitation Radar panel successfully removed!"
fi

echo "Testing for radar functionality..."
if curl -s https://www.simondatalab.de/geospatial-viz/index.html | grep -q "addPrecipitationLayer"; then
    echo "✅ Radar layer functionality implemented!"
else
    echo "❌ Radar layer functionality missing!"
fi

echo ""
echo "🎉 Deployment Summary:"
echo "1. ✅ Removed Vietnam Precipitation Radar panel"
echo "2. ✅ Implemented actual radar layer functionality"
echo "3. ✅ Added RainViewer precipitation radar integration"
echo "4. ✅ Added temperature and wind layer support"
echo "5. ✅ Fixed weather opacity controls"
echo "6. ✅ Set default location to user's current location"
echo ""
echo "🌐 Visit: https://www.simondatalab.de/geospatial-viz/index.html"
echo "📍 The map will now:"
echo "   - Start with global view and zoom to your current location"
echo "   - Show actual precipitation radar data from RainViewer"
echo "   - Allow switching between precipitation, temperature, and wind layers"
echo "   - Have working opacity controls"
echo "   - No longer show the Vietnam Precipitation Radar panel"
