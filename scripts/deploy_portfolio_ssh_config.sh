#!/bin/bash

# Simplified Portfolio Deployment using SSH Config ProxyJump
# This script assumes you have SSH config set up for ProxyJump

set -e

TARGET_HOST="ct150"  # This should be defined in ~/.ssh/config
TARGET_PATH="/var/www/html"
LOCAL_FILES="/home/simon/Desktop/Learning Management System Academy/portfolio/hero-r3f-odyssey"

echo "🚀 Starting portfolio deployment using SSH config ProxyJump..."
echo "📁 Local files: $LOCAL_FILES"
echo "🌐 Target: $TARGET_HOST:$TARGET_PATH"

# Check if local files exist
if [ ! -d "$LOCAL_FILES" ]; then
    echo "❌ Error: Local portfolio directory not found: $LOCAL_FILES"
    exit 1
fi

# Test SSH connection
echo "🔍 Testing SSH connection to $TARGET_HOST..."
if ! ssh -o ConnectTimeout=10 $TARGET_HOST "echo 'Connection successful'" > /dev/null 2>&1; then
    echo "❌ Error: Cannot connect to $TARGET_HOST"
    echo "💡 Please check:"
    echo "   - SSH config file (~/.ssh/config) is set up correctly"
    echo "   - ProxyJump configuration is working"
    echo "   - SSH keys are properly configured"
    echo ""
    echo "📋 Add this to your ~/.ssh/config:"
    echo "Host proxmox"
    echo "    HostName 136.243.155.166"
    echo "    User root"
    echo "    Port 22"
    echo ""
    echo "Host ct150"
    echo "    HostName 10.0.0.150"
    echo "    User root"
    echo "    Port 22"
    echo "    ProxyJump proxmox"
    exit 1
fi
echo "✅ SSH connection successful"

# Create backup on target server
echo "📦 Creating backup on target server..."
ssh $TARGET_HOST "mkdir -p /var/backups/portfolio && cp -r $TARGET_PATH/* /var/backups/portfolio/$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || true"

# Upload files to target server
echo "⬆️ Uploading portfolio files to target server..."
rsync -avz --progress --delete \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='*.log' \
    --exclude='.DS_Store' \
    "$LOCAL_FILES/" \
    "$TARGET_HOST:$TARGET_PATH/"

# Set proper permissions
echo "🔐 Setting proper permissions..."
ssh $TARGET_HOST "chown -R www-data:www-data $TARGET_PATH && chmod -R 755 $TARGET_PATH"

# Restart web server
echo "🔄 Restarting web services..."
ssh $TARGET_HOST "systemctl reload nginx || systemctl restart apache2 || true"

# Test deployment
echo "🧪 Testing deployment..."
sleep 2
if curl -s -o /dev/null -w "%{http_code}" "http://10.0.0.150" | grep -q "200"; then
    echo "✅ Deployment successful! Portfolio is responding."
    echo "🌐 Portfolio URL: http://10.0.0.150"
    echo "🌐 Public URL: https://www.simondatalab.de/"
else
    echo "⚠️ Warning: Portfolio may not be responding properly. Check server logs."
fi

echo ""
echo "🎉 Portfolio deployment completed!"
echo "📊 Summary:"
echo "   - Target: $TARGET_HOST"
echo "   - Files uploaded: $(find $LOCAL_FILES -type f | wc -l) files"
echo "   - Portfolio URL: http://10.0.0.150"
echo "   - Public URL: https://www.simondatalab.de/"
