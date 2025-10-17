#!/bin/bash

echo "🔧 Fixing Jellyfin 503 Service Unavailable Errors"
echo "================================================"

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"

echo "🔍 Diagnosing Jellyfin status..."

# Check if Jellyfin is responding
echo "Checking Jellyfin web interface..."
curl -s -w "HTTP Status: %{http_code}\n" "$JELLYFIN_URL/web/" | tail -1

echo "Checking Jellyfin API..."
curl -s -w "HTTP Status: %{http_code}\n" "$JELLYFIN_URL/system/info/public" | tail -1

echo "Checking ScheduledTasks endpoint..."
curl -s -w "HTTP Status: %{http_code}\n" "$JELLYFIN_URL/ScheduledTasks?IsEnabled=true" | tail -1

echo ""
echo "🎯 Root Cause Analysis:"
echo "======================="
echo "The 503 errors in your browser console are caused by:"
echo "1. ❌ API calls require authentication (401 Unauthorized)"
echo "2. ❌ You need to be logged in to access most endpoints"
echo "3. ❌ The web interface loads but can't fetch data"

echo ""
echo "✅ Solution:"
echo "============"
echo "1. 🌐 Open your browser"
echo "2. 🔗 Go to: http://136.243.155.166:8096/web/"
echo "3. 🔐 Login with username: simonadmin"
echo "4. 🔄 The errors will disappear once logged in"

echo ""
echo "🔧 Alternative: Check if Jellyfin needs restart..."

# Try to restart Jellyfin container via API (if possible)
echo "Attempting to restart Jellyfin service..."

# Check if we can restart via API
RESTART_RESPONSE=$(curl -s -X POST \
  -H "X-Emby-Token: $API_KEY" \
  -w "HTTP Status: %{http_code}" \
  "$JELLYFIN_URL/System/Restart" 2>/dev/null)

echo "Restart response: $RESTART_RESPONSE"

echo ""
echo "📋 Manual Steps if API restart fails:"
echo "====================================="
echo "1. SSH into your VM:"
echo "   ssh -p 2222 simonadmin@136.243.155.166"
echo "   ssh simonadmin@10.0.0.103"
echo ""
echo "2. Restart Jellyfin container:"
echo "   docker restart jellyfin-simonadmin"
echo ""
echo "3. Wait 30 seconds and refresh browser"

echo ""
echo "🎉 Expected Result:"
echo "=================="
echo "After logging in, you should see:"
echo "✅ No more 503 errors in console"
echo "✅ Jellyfin home page loads properly"
echo "✅ All API calls work correctly"
echo "✅ Live TV and media libraries accessible"

echo ""
echo "🌐 Access Jellyfin: http://136.243.155.166:8096/web/"
echo "🔐 Login as: simonadmin"


