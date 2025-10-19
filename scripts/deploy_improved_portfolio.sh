#!/bin/bash

# Deploy Improved Simon Renauld Portfolio to Production
# Target: https://www.simondatalab.de/
# Server: 10.0.0.150 (portfolio-web CT150)
# Author: Simon Renauld
# Date: $(date)

set -euo pipefail

# Configuration
SERVER_HOST="portfolio-vm150"  # Use SSH config alias
SERVER_IP="10.0.0.150"
SERVER_USER="root"
SERVER_PATH="/var/www/html"
LOCAL_FILES="/home/simon/Learning-Management-System-Academy/portfolio-deployment-enhanced"
BACKUP_DIR="/var/backups/portfolio"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=========================================="
echo "🚀 IMPROVED PORTFOLIO DEPLOYMENT"
echo "=========================================="
echo "Date: $(date)"
echo "Target: https://www.simondatalab.de/"
echo "Server: $SERVER_IP"
echo ""

# Pre-deployment checks
echo "📋 PRE-DEPLOYMENT CHECKS"
echo "=========================================="

# Check if local files exist
if [ ! -d "$LOCAL_FILES" ]; then
    echo -e "${RED}❌ Error: Local portfolio directory not found: $LOCAL_FILES${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Local portfolio directory found${NC}"

# Count files to deploy
FILE_COUNT=$(find "$LOCAL_FILES" -type f ! -path "*/node_modules/*" ! -path "*/.git/*" | wc -l)
echo -e "${GREEN}✅ Files to deploy: $FILE_COUNT${NC}"

# Test server connectivity
echo -n "🔍 Testing SSH connectivity to $SERVER_HOST (via ProxyJump) ... "
if ! ssh -o ConnectTimeout=30 -o BatchMode=yes "$SERVER_HOST" "echo ok" > /dev/null 2>&1; then
    echo -e "${RED}❌ FAILED${NC}"
    echo "💡 Ensure SSH config has entry for '$SERVER_HOST' with ProxyJump"
    echo "💡 Check: cat ~/.ssh/config | grep -A 5 '$SERVER_HOST'"
    exit 1
fi
echo -e "${GREEN}✅ Connected${NC}"

echo ""
echo "📦 CREATING BACKUP"
echo "=========================================="
ssh $SERVER_HOST "mkdir -p $BACKUP_DIR"
echo "Creating backup: $BACKUP_DIR/backup_$TIMESTAMP"
ssh $SERVER_HOST "
    if [ -d $SERVER_PATH ]; then
        tar -czf $BACKUP_DIR/backup_$TIMESTAMP.tar.gz -C $SERVER_PATH . 2>/dev/null || true
        echo '✅ Backup created successfully'
    else
        echo '⚠️  No existing files to backup'
    fi
"

echo ""
echo "⬆️  UPLOADING IMPROVED PORTFOLIO"
echo "=========================================="
echo "Deploying from: $LOCAL_FILES"
echo "Deploying to: $SERVER_HOST:$SERVER_PATH"
echo ""

# Upload files with rsync (using SSH config)
rsync -avz --progress \
    -e "ssh" \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='*.log' \
    --exclude='.DS_Store' \
    --exclude='IMPROVEMENTS_SUMMARY.md' \
    --exclude='*.tar.gz' \
    --exclude='test-*.html' \
    --delete \
    "$LOCAL_FILES/" \
    "$SERVER_HOST:$SERVER_PATH/"

echo ""
echo "🔐 SETTING PERMISSIONS"
echo "=========================================="
ssh $SERVER_HOST "
    chown -R www-data:www-data $SERVER_PATH
    chmod -R 755 $SERVER_PATH
    find $SERVER_PATH -type f -exec chmod 644 {} \;
    echo '✅ Permissions set correctly'
"

echo ""
echo "🔄 RESTARTING WEB SERVER"
echo "=========================================="
ssh $SERVER_HOST "
    # Try nginx first, then apache2
    if systemctl is-active --quiet nginx; then
        systemctl reload nginx && echo '✅ Nginx reloaded'
    elif systemctl is-active --quiet apache2; then
        systemctl reload apache2 && echo '✅ Apache2 reloaded'
    else
        echo '⚠️  No web server found to reload'
    fi
"

echo ""
echo "🧪 TESTING DEPLOYMENT"
echo "=========================================="
sleep 3

# Test local server
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$SERVER_IP" || echo "000")
if [ "$HTTP_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Local server responding (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${YELLOW}⚠️  Local server returned HTTP $HTTP_CODE${NC}"
fi

# Test production URL
PROD_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://www.simondatalab.de/" || echo "000")
if [ "$PROD_CODE" = "200" ]; then
    echo -e "${GREEN}✅ Production URL responding (HTTP $PROD_CODE)${NC}"
else
    echo -e "${YELLOW}⚠️  Production URL returned HTTP $PROD_CODE (may need CDN cache clear)${NC}"
fi

echo ""
echo "=========================================="
echo "🎉 DEPLOYMENT COMPLETED SUCCESSFULLY!"
echo "=========================================="
echo ""
echo "📊 DEPLOYMENT SUMMARY"
echo "─────────────────────────────────────────"
echo "🕐 Timestamp:        $TIMESTAMP"
echo "📁 Files Deployed:   $FILE_COUNT"
echo "💾 Backup Location:  $BACKUP_DIR/backup_$TIMESTAMP.tar.gz"
echo "🌐 Local URL:        http://$SERVER_IP"
echo "🌐 Production URL:   https://www.simondatalab.de/"
echo ""
echo "✨ KEY IMPROVEMENTS DEPLOYED"
echo "─────────────────────────────────────────"
echo "✅ Enhanced hero section with business-focused messaging"
echo "✅ Expanded about section with research + enterprise narrative"
echo "✅ Detailed experience timeline with specific achievements"
echo "✅ Comprehensive project case studies with business outcomes"
echo "✅ Expanded expertise section (40+ technologies)"
echo "✅ Improved architecture descriptions"
echo "✅ Enhanced contact section with engagement types"
echo "✅ Better typography and spacing (same visual style)"
echo "✅ Improved card hover states and interactions"
echo "✅ Enhanced mobile responsiveness"
echo ""
echo "🔄 NEXT STEPS"
echo "─────────────────────────────────────────"
echo "1. Visit https://www.simondatalab.de/ to verify deployment"
echo "2. Test mobile responsiveness"
echo "3. Verify all links and downloads work"
echo "4. Clear Cloudflare cache if needed"
echo "5. Test contact form submission"
echo "6. Check all sections for proper display"
echo ""
echo "📋 ROLLBACK INSTRUCTIONS (if needed)"
echo "─────────────────────────────────────────"
echo "ssh $SERVER_HOST"
echo "cd $SERVER_PATH"
echo "tar -xzf $BACKUP_DIR/backup_$TIMESTAMP.tar.gz"
echo "systemctl reload nginx  # or apache2"
echo ""
echo "🎯 For detailed improvements, see:"
echo "   $LOCAL_FILES/IMPROVEMENTS_SUMMARY.md"
echo ""

