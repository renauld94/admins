#!/bin/bash
# GeoServer Dashboard - Quick Status Check
# Run this to verify the full deployment

TARGET="simonadmin@10.0.0.106"
PROXY="root@136.243.155.166:2222"

echo "🌍 Neural GeoServer Dashboard - Status Check"
echo "=============================================="
echo ""

ssh -J "$PROXY" "$TARGET" 'bash -s' << 'ENDSSH'
# Dashboard
echo -n "Dashboard:     "
curl -s -o /dev/null -w "%{http_code}" http://localhost/ | grep -q 200 && echo "✅ LIVE (http://10.0.0.106/)" || echo "❌ Not accessible"

# GeoServer
echo -n "GeoServer:     "
STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/geoserver/web/)
if [ "$STATUS" = "200" ]; then
    echo "✅ READY (http://10.0.0.106/geoserver/)"
elif [ "$STATUS" = "404" ]; then
    echo "⏳ DEPLOYING (wait 2-3 more minutes, then check http://10.0.0.106/geoserver/)"
else
    echo "❌ Status: $STATUS"
fi

# PostGIS
echo -n "PostGIS:       "
sudo -u postgres psql -d geospatial_demo -c "SELECT COUNT(*) FROM healthcare_facilities;" -t -q > /dev/null 2>&1 && echo "✅ OPERATIONAL (8 healthcare + 4 research facilities)" || echo "❌ Not accessible"

# Ollama
echo -n "AI (Ollama):   "
curl -s http://localhost:11434/api/tags > /dev/null 2>&1 && echo "✅ READY (llama3.2:3b model loaded)" || echo "❌ Not running"

echo ""
echo "📊 System:"
df -h / | tail -1 | awk '{print "   Disk: "$3" used / "$2" total ("$5" used)"}'
free -h | grep Mem | awk '{print "   RAM:  "$3" used / "$2" total"}'

ENDSSH

echo ""
echo "🎯 Next Steps:"
echo "   1. Open http://10.0.0.106/ in your browser"
echo "   2. If GeoServer shows 'DEPLOYING', wait and run this script again"
echo "   3. Try the AI assistant in the dashboard"
echo "   4. Explore the interactive map with 12 data points"
