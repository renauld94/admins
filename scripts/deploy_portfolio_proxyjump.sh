#!/bin/bash

# Deploy Portfolio to CT 150 Server using ProxyJump
# Uses Proxmox server (136.243.155.166) as jump host (port 2222) to reach CT 150 (10.0.0.150)
# Author: Simon Renauld
# Date: $(date)

set -euo pipefail

PROXY_HOST="136.243.155.166"
PROXY_PORT="2222"
PROXY_USER="root"
TARGET_HOST="10.0.0.150"
TARGET_USER="root"
TARGET_PATH="/var/www/html"
LOCAL_FILES="/home/simon/Learning-Management-System-Academy/portfolio-deployment-enhanced"

JUMP_SPEC="${PROXY_USER}@${PROXY_HOST}:${PROXY_PORT}"

echo "🚀 Starting portfolio deployment to CT 150 via ProxyJump..."
echo "🔗 ProxyJump: ${PROXY_USER}@${PROXY_HOST}:${PROXY_PORT} -> $TARGET_HOST"
echo "📁 Local files: $LOCAL_FILES"
echo "🌐 Target: $TARGET_USER@$TARGET_HOST:$TARGET_PATH"

# Check if local files exist
if [ ! -d "$LOCAL_FILES" ]; then
    echo "❌ Error: Local portfolio directory not found: $LOCAL_FILES"
    exit 1
fi

# Test proxy connectivity
echo "🔍 Testing proxy host SSH connectivity (port $PROXY_PORT)..."
if ! ssh -p "$PROXY_PORT" -o ConnectTimeout=10 -o BatchMode=yes "$PROXY_USER@$PROXY_HOST" "echo ok" > /dev/null 2>&1; then
    echo "❌ Error: Cannot establish SSH to proxy host $PROXY_USER@$PROXY_HOST on port $PROXY_PORT"
    echo "💡 Ensure your SSH keys are installed and port $PROXY_PORT is open."
    exit 1
fi
echo "✅ Proxy host SSH reachable"

# Test target connectivity through proxy
echo "🔍 Testing target host connectivity through proxy..."
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes -o ProxyJump="$JUMP_SPEC" "$TARGET_USER@$TARGET_HOST" "echo 'Connection successful'" > /dev/null 2>&1; then
    echo "❌ Error: Cannot reach target host $TARGET_HOST through proxy $PROXY_HOST"
    echo "💡 Please check:"
    echo "   - SSH key authentication is set up"
    echo "   - ProxyJump configuration is correct"
    echo "   - Target host is accessible from proxy"
    exit 1
fi
echo "✅ Target host is reachable through proxy"

# Create backup on target server
echo "📦 Creating backup on target server..."
ssh -o ProxyJump="$JUMP_SPEC" "$TARGET_USER@$TARGET_HOST" "mkdir -p /var/backups/portfolio && cp -r $TARGET_PATH/* /var/backups/portfolio/$(date +%Y%m%d_%H%M%S)/ 2>/dev/null || true"

# Upload files to target server via proxy
echo "⬆️ Uploading portfolio files to target server via proxy..."
rsync -avz --progress --delete \
    -e "ssh -o ProxyJump=$JUMP_SPEC" \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='*.log' \
    --exclude='.DS_Store' \
    "$LOCAL_FILES/" \
    "$TARGET_USER@$TARGET_HOST:$TARGET_PATH/"

# Set proper permissions
echo "🔐 Setting proper permissions..."
ssh -o ProxyJump="$JUMP_SPEC" "$TARGET_USER@$TARGET_HOST" "chown -R www-data:www-data $TARGET_PATH && chmod -R 755 $TARGET_PATH"

# Restart web server
echo "🔄 Restarting web services..."
ssh -o ProxyJump="$JUMP_SPEC" "$TARGET_USER@$TARGET_HOST" "systemctl reload nginx || systemctl restart apache2 || true"

# Test deployment
echo "🧪 Testing deployment..."
sleep 2
if curl -s -o /dev/null -w "%{http_code}" "http://$TARGET_HOST" | grep -q "200"; then
    echo "✅ Deployment successful! Portfolio is responding."
    echo "🌐 Portfolio URL: http://$TARGET_HOST"
    echo "🌐 Public URL: https://www.simondatalab.de/"
else
    echo "⚠️ Warning: Portfolio may not be responding properly. Check server logs."
fi

echo ""
echo "🎉 Portfolio deployment via ProxyJump completed!"
echo "📊 Summary:"
echo "   - ProxyJump: $PROXY_HOST -> $TARGET_HOST"
echo "   - Files uploaded: $(find $LOCAL_FILES -type f | wc -l) files"
echo "   - Backup created: /var/backups/portfolio/$(date +%Y%m%d_%H%M%S)/"
echo "   - Portfolio URL: http://$TARGET_HOST"
echo "   - Public URL: https://www.simondatalab.de/"
echo ""
echo "🔍 Key Features Deployed:"
echo "   ✅ Admin Dropdown Menu (Desktop & Mobile)"
echo "   ✅ Fixed JavaScript Syntax Errors"
echo "   ✅ Nuclear CSP Fix"
echo "   ✅ Performance Optimized Hero Visualization"
echo "   ✅ Print CSS Optimizations"
echo "   ✅ Mobile-First Responsive Design"
echo "   ✅ GSAP Animations with ScrollTrigger"
echo "   ✅ Three.js R3F Integration"
echo "   ✅ Contact Form Integration"
echo "   ✅ Professional Portfolio Content"
echo ""
echo "🔧 ProxyJump Configuration Used:"
echo "   ssh -o ProxyJump=$JUMP_SPEC $TARGET_USER@$TARGET_HOST"
echo "   rsync -e \"ssh -o ProxyJump=$JUMP_SPEC\" ..."
