#!/bin/bash

echo "🔍 VERIFICATION SCRIPT - Run this on CT 150"
echo "=========================================="

echo "Current live file status:"
echo "Vietnam Precipitation Radar occurrences: $(curl -s https://www.simondatalab.de/geospatial-viz/index.html | grep -c "Vietnam Precipitation Radar")"
echo "Radar functionality occurrences: $(curl -s https://www.simondatalab.de/geospatial-viz/index.html | grep -c "addPrecipitationLayer")"

echo ""
echo "Expected results after correct deployment:"
echo "Vietnam Precipitation Radar: 0 (should be removed)"
echo "Radar functionality: 2 (should be added)"

echo ""
echo "If the numbers don't match, run these commands on CT 150:"
echo "1. cp /tmp/geospatial-viz-fixed-final.html /var/www/html/geospatial-viz/index.html"
echo "2. chown www-data:www-data /var/www/html/geospatial-viz/index.html"
echo "3. chmod 644 /var/www/html/geospatial-viz/index.html"
echo "4. systemctl reload nginx"
echo "5. Run this script again to verify"
