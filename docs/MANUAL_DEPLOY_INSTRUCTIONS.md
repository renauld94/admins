# MANUAL DEPLOYMENT INSTRUCTIONS FOR CT 150
# Run these commands directly on CT 150 (portfolio-web)

echo "🚀 Deploying geospatial visualization fixes..."

# 1. Backup current file
cp /var/www/html/geospatial-viz/index.html /var/www/html/geospatial-viz/index.html.backup.$(date +%Y%m%d_%H%M%S)

# 2. Copy the fixed file (you'll need to transfer this file to CT 150 first)
# Option A: If you have the file on CT 150 already:
# cp /path/to/geospatial-viz-fixed-final.html /var/www/html/geospatial-viz/index.html

# Option B: If you need to transfer from local machine:
# scp /tmp/geospatial-viz-fixed-final.html root@10.0.0.150:/tmp/
# Then: cp /tmp/geospatial-viz-fixed-final.html /var/www/html/geospatial-viz/index.html

# 3. Set permissions
chown www-data:www-data /var/www/html/geospatial-viz/index.html
chmod 644 /var/www/html/geospatial-viz/index.html

# 4. Reload nginx
systemctl reload nginx

# 5. Test
echo "Testing deployment..."
curl -s https://www.simondatalab.de/geospatial-viz/index.html | grep -c "Vietnam Precipitation Radar"
echo "Should show 0 (panel removed)"

curl -s https://www.simondatalab.de/geospatial-viz/index.html | grep -c "addPrecipitationLayer"
echo "Should show 2 (radar functionality added)"

echo "✅ Deployment complete!"
echo "🌐 Visit: https://www.simondatalab.de/geospatial-viz/index.html"
