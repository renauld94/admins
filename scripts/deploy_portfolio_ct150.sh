#!/bin/bash

# Deploy Simon Renauld Portfolio to CT 150 Server
# Server: 10.0.0.150 (portfolio-web)
# Author: Simon Renauld
# Date: $(date)

set -e

SERVER_IP="10.0.0.150"
SERVER_USER="root"
SERVER_PATH="/var/www/html"
LOCAL_FILES="/home/simon/Desktop/Learning Management System Academy/portfolio/hero-r3f-odyssey"

echo "🚀 Starting portfolio deployment to CT 150 server ($SERVER_IP)..."

# Check if local files exist
if [ ! -d "$LOCAL_FILES" ]; then
    echo "❌ Error: Local portfolio directory not found: $LOCAL_FILES"
    exit 1
fi

echo "📁 Local portfolio directory: $LOCAL_FILES"
echo "🌐 Target server: $SERVER_USER@$SERVER_IP:$SERVER_PATH"

# Test server connectivity
echo "🔍 Testing server connectivity..."
if ! ping -c 2 $SERVER_IP > /dev/null 2>&1; then
    echo "❌ Error: Cannot reach server $SERVER_IP"
    echo "💡 Please check:"
    echo "   - Server is running"
    echo "   - Network connectivity"
    echo "   - Firewall settings"
    exit 1
fi

echo "✅ Server is reachable"

# Create backup on server
echo "📦 Creating backup on server..."
ssh -o ConnectTimeout=10 $SERVER_USER@$SERVER_IP "mkdir -p /var/backups/portfolio && cp -r $SERVER_PATH/* /var/backups/portfolio/$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || true"

# Upload files to server
echo "⬆️ Uploading portfolio files to server..."
rsync -avz --progress --delete \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='*.log' \
    --exclude='.DS_Store' \
    "$LOCAL_FILES/" \
    "$SERVER_USER@$SERVER_IP:$SERVER_PATH/"

# Set proper permissions
echo "🔐 Setting proper permissions..."
ssh $SERVER_USER@$SERVER_IP "chown -R www-data:www-data $SERVER_PATH && chmod -R 755 $SERVER_PATH"

# Restart web server
echo "🔄 Restarting web services..."
ssh $SERVER_USER@$SERVER_IP "systemctl reload nginx || systemctl restart apache2 || true"

# Test deployment
echo "🧪 Testing deployment..."
sleep 2
if curl -s -o /dev/null -w "%{http_code}" "http://$SERVER_IP" | grep -q "200"; then
    echo "✅ Deployment successful! Portfolio is responding."
    echo "🌐 Portfolio URL: http://$SERVER_IP"
    echo "🌐 Public URL: https://www.simondatalab.de/"
else
    echo "⚠️ Warning: Portfolio may not be responding properly. Check server logs."
fi

echo ""
echo "🎉 Portfolio deployment to CT 150 completed!"
echo "📊 Summary:"
echo "   - Server: $SERVER_IP"
echo "   - Files uploaded: $(find $LOCAL_FILES -type f | wc -l) files"
echo "   - Backup created: /var/backups/portfolio/$(date +%Y%m%d_%H%M%S)/"
echo "   - Portfolio URL: http://$SERVER_IP"
echo "   - Public URL: https://www.simondatalab.de/"
echo ""
echo "🔍 Key Features Deployed:"
echo "   ✅ Floating Action Button (Globe Infrastructure Link)"
echo "   ✅ Performance Optimized Hero Visualization"
echo "   ✅ Print CSS Optimizations"
echo "   ✅ Mobile-First Responsive Design"
echo "   ✅ GSAP Animations with ScrollTrigger"
echo "   ✅ Three.js R3F Integration"
echo "   ✅ Contact Form Integration"
echo "   ✅ Professional Portfolio Content"
