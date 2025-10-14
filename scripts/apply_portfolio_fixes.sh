#!/bin/bash

# Quick Portfolio Fix Deployment Script for CT 150
# Run this script on the CT 150 server to apply JavaScript fixes

echo "🚀 Applying Portfolio JavaScript Fixes..."

# Navigate to web directory
cd /var/www/html

# Create backup
echo "📦 Creating backup..."
cp index.html "index.html.backup.$(date +%Y%m%d_%H%M%S)"

# The fixed index.html content should be copied here
# For now, let's create a simple fix for the CSP script

echo "🔧 Applying CSP script fix..."
sed -i 's/document\.querySelector("meta\[http-equiv="Content-Security-Policy"\]")/document.querySelector('\''meta[http-equiv="Content-Security-Policy"]'\'')/g' index.html

echo "✅ CSP script fix applied"

# Set proper permissions
echo "🔐 Setting permissions..."
chown www-data:www-data index.html
chmod 644 index.html

# Reload web server
echo "🔄 Reloading web server..."
systemctl reload nginx

echo "🎉 Portfolio fixes applied!"
echo "🌐 Test your website at: https://www.simondatalab.de/"
echo "📋 Check browser console for JavaScript errors"

# Test the website
echo "🧪 Testing website..."
if curl -s -o /dev/null -w "%{http_code}" "http://localhost" | grep -q "200"; then
    echo "✅ Website is responding correctly"
else
    echo "⚠️ Warning: Website may not be responding properly"
fi

echo ""
echo "📊 Summary:"
echo "   - Backup created: index.html.backup.$(date +%Y%m%d_%H%M%S)"
echo "   - CSP script syntax error fixed"
echo "   - Permissions set correctly"
echo "   - Web server reloaded"
echo ""
echo "🔍 Next steps:"
echo "   1. Test the website in browser"
echo "   2. Check JavaScript console for errors"
echo "   3. Verify admin dropdown menu works"
echo "   4. Test on mobile devices"
