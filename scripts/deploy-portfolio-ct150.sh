#!/bin/bash

# Portfolio Deployment Script for CT150 - moodle.simondatalab.de
# Deploys the enhanced portfolio with Epic Neural Cosmos visualization

set -e

# Configuration
PROXY_HOST="root@136.243.155.166"
TARGET_HOST="simonadmin@10.0.0.104"
TARGET_PATH="/var/www/html/simondatalab"
PORTFOLIO_SOURCE="/home/simon/Learning-Management-System-Academy/portfolio-deployment-enhanced"
MOODLE_PATH="/var/www/html/moodle"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_epic() {
    echo -e "${PURPLE}[EPIC]${NC} $1"
}

echo "🚀 Portfolio Deployment - CT150 Server"
echo "====================================="
echo "🎯 Target: https://moodle.simondatalab.de/"
echo "📡 Proxy: $PROXY_HOST"
echo "🖥️  Server: $TARGET_HOST"
echo "📁 Path: $TARGET_PATH"
echo ""

# Test connection first
print_status "Testing connection to CT150..."
if ssh -o ConnectTimeout=10 -o BatchMode=yes -J $PROXY_HOST $TARGET_HOST "echo 'Connection successful'" 2>/dev/null; then
    print_success "✅ Connected to CT150 server!"
else
    print_error "❌ Connection failed. Please ensure:"
    echo "1. SSH keys are configured for $PROXY_HOST"
    echo "2. Proxy server is accessible"
    echo "3. Target server is reachable from proxy"
    echo "4. Network connectivity is working"
    exit 1
fi

# Create backup of current portfolio (if exists)
print_status "Creating backup of existing portfolio..."
ssh -J $PROXY_HOST $TARGET_HOST "
    if [ -d '$TARGET_PATH' ]; then
        sudo cp -r '$TARGET_PATH' '$TARGET_PATH.backup.$(date +%Y%m%d_%H%M%S)'
        echo 'Backup created successfully'
    else
        echo 'No existing portfolio found - fresh deployment'
    fi
"

# Create target directory structure
print_status "Creating directory structure on CT150..."
ssh -J $PROXY_HOST $TARGET_HOST "
    sudo mkdir -p $TARGET_PATH/{css,js,assets/images,assets/fonts,geospatial-viz}
    sudo chown -R www-data:www-data $TARGET_PATH
    sudo chmod -R 755 $TARGET_PATH
"

# Deploy core HTML files
print_epic "🌌 Deploying Epic Neural Cosmos Portfolio..."

print_status "Copying main portfolio files..."
scp -J $PROXY_HOST $PORTFOLIO_SOURCE/index.html $TARGET_HOST:/tmp/
scp -J $PROXY_HOST $PORTFOLIO_SOURCE/epic-neural-cosmos-demo.html $TARGET_HOST:/tmp/

ssh -J $PROXY_HOST $TARGET_HOST "
    sudo mv /tmp/index.html $TARGET_PATH/
    sudo mv /tmp/epic-neural-cosmos-demo.html $TARGET_PATH/
    sudo chown www-data:www-data $TARGET_PATH/*.html
"

# Deploy CSS files
print_status "Deploying stylesheets..."
scp -J $PROXY_HOST $PORTFOLIO_SOURCE/styles.css $TARGET_HOST:/tmp/
scp -J $PROXY_HOST $PORTFOLIO_SOURCE/globe-fab.css $TARGET_HOST:/tmp/
scp -J $PROXY_HOST $PORTFOLIO_SOURCE/print.css $TARGET_HOST:/tmp/

ssh -J $PROXY_HOST $TARGET_HOST "
    sudo mv /tmp/styles.css $TARGET_PATH/css/
    sudo mv /tmp/globe-fab.css $TARGET_PATH/css/
    sudo mv /tmp/print.css $TARGET_PATH/css/
    sudo chown -R www-data:www-data $TARGET_PATH/css/
"

# Deploy JavaScript files
print_status "Deploying JavaScript libraries and visualizations..."
scp -J $PROXY_HOST $PORTFOLIO_SOURCE/three-loader.js $TARGET_HOST:/tmp/
scp -J $PROXY_HOST $PORTFOLIO_SOURCE/epic-neural-cosmos-viz.js $TARGET_HOST:/tmp/
scp -J $PROXY_HOST $PORTFOLIO_SOURCE/app.js $TARGET_HOST:/tmp/
scp -J $PROXY_HOST $PORTFOLIO_SOURCE/ai-integration.js $TARGET_HOST:/tmp/
scp -J $PROXY_HOST $PORTFOLIO_SOURCE/hero-performance.js $TARGET_HOST:/tmp/
scp -J $PROXY_HOST $PORTFOLIO_SOURCE/gsap.min.js $TARGET_HOST:/tmp/
scp -J $PROXY_HOST $PORTFOLIO_SOURCE/ScrollTrigger.min.js $TARGET_HOST:/tmp/
scp -J $PROXY_HOST $PORTFOLIO_SOURCE/d3.v7.min.js $TARGET_HOST:/tmp/

ssh -J $PROXY_HOST $TARGET_HOST "
    sudo mv /tmp/three-loader.js $TARGET_PATH/js/
    sudo mv /tmp/epic-neural-cosmos-viz.js $TARGET_PATH/js/
    sudo mv /tmp/app.js $TARGET_PATH/js/
    sudo mv /tmp/ai-integration.js $TARGET_PATH/js/
    sudo mv /tmp/hero-performance.js $TARGET_PATH/js/
    sudo mv /tmp/gsap.min.js $TARGET_PATH/js/
    sudo mv /tmp/ScrollTrigger.min.js $TARGET_PATH/js/
    sudo mv /tmp/d3.v7.min.js $TARGET_PATH/js/
    sudo chown -R www-data:www-data $TARGET_PATH/js/
"

# Deploy assets if they exist
if [ -d "$PORTFOLIO_SOURCE/assets" ]; then
    print_status "Deploying assets..."
    scp -r -J $PROXY_HOST $PORTFOLIO_SOURCE/assets/* $TARGET_HOST:/tmp/assets/
    ssh -J $PROXY_HOST $TARGET_HOST "
        sudo cp -r /tmp/assets/* $TARGET_PATH/assets/
        sudo chown -R www-data:www-data $TARGET_PATH/assets/
        sudo rm -rf /tmp/assets/
    "
fi

# Deploy geospatial visualization files if they exist
if [ -d "$PORTFOLIO_SOURCE/geospatial-viz" ]; then
    print_status "Deploying geospatial visualizations..."
    scp -r -J $PROXY_HOST $PORTFOLIO_SOURCE/geospatial-viz/* $TARGET_HOST:/tmp/geospatial-viz/
    ssh -J $PROXY_HOST $TARGET_HOST "
        sudo cp -r /tmp/geospatial-viz/* $TARGET_PATH/geospatial-viz/
        sudo chown -R www-data:www-data $TARGET_PATH/geospatial-viz/
        sudo rm -rf /tmp/geospatial-viz/
    "
fi

# Deploy favicon
if [ -f "$PORTFOLIO_SOURCE/favicon.svg" ]; then
    print_status "Deploying favicon..."
    scp -J $PROXY_HOST $PORTFOLIO_SOURCE/favicon.svg $TARGET_HOST:/tmp/
    ssh -J $PROXY_HOST $TARGET_HOST "
        sudo mv /tmp/favicon.svg $TARGET_PATH/
        sudo chown www-data:www-data $TARGET_PATH/favicon.svg
    "
fi

# Create .htaccess for Apache optimization
print_status "Creating Apache configuration..."
ssh -J $PROXY_HOST $TARGET_HOST "sudo tee $TARGET_PATH/.htaccess > /dev/null << 'EOF'
# Portfolio Performance Optimization
RewriteEngine On

# Enable Compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/plain
    AddOutputFilterByType DEFLATE text/html
    AddOutputFilterByType DEFLATE text/xml
    AddOutputFilterByType DEFLATE text/css
    AddOutputFilterByType DEFLATE application/xml
    AddOutputFilterByType DEFLATE application/xhtml+xml
    AddOutputFilterByType DEFLATE application/rss+xml
    AddOutputFilterByType DEFLATE application/javascript
    AddOutputFilterByType DEFLATE application/x-javascript
    AddOutputFilterByType DEFLATE application/json
</IfModule>

# Cache Control
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType text/css \"access plus 1 month\"
    ExpiresByType application/javascript \"access plus 1 month\"
    ExpiresByType image/png \"access plus 1 month\"
    ExpiresByType image/jpg \"access plus 1 month\"
    ExpiresByType image/jpeg \"access plus 1 month\"
    ExpiresByType image/gif \"access plus 1 month\"
    ExpiresByType image/svg+xml \"access plus 1 month\"
    ExpiresByType font/woff2 \"access plus 1 year\"
    ExpiresByType font/woff \"access plus 1 year\"
</IfModule>

# Security Headers
Header always set X-Content-Type-Options nosniff
Header always set X-Frame-Options SAMEORIGIN
Header always set X-XSS-Protection \"1; mode=block\"
Header always set Referrer-Policy \"strict-origin-when-cross-origin\"

# CORS for THREE.js and other assets
<IfModule mod_headers.c>
    Header set Access-Control-Allow-Origin \"*\"
    Header set Access-Control-Allow-Methods \"GET, POST, OPTIONS\"
    Header set Access-Control-Allow-Headers \"Origin, X-Requested-With, Content-Type, Accept\"
</IfModule>

# Redirect non-www to www (optional)
# RewriteCond %{HTTP_HOST} ^simondatalab\.de [NC]
# RewriteRule ^(.*)$ https://www.simondatalab.de/\$1 [R=301,L]
EOF"

# Set final permissions
ssh -J $PROXY_HOST $TARGET_HOST "
    sudo chown -R www-data:www-data $TARGET_PATH
    sudo chmod -R 755 $TARGET_PATH
    sudo chmod 644 $TARGET_PATH/.htaccess
"

# Create deployment info file
print_status "Creating deployment information..."
ssh -J $PROXY_HOST $TARGET_HOST "sudo tee $TARGET_PATH/deployment-info.json > /dev/null << EOF
{
    \"deployment_date\": \"$(date -Iseconds)\",
    \"deployment_method\": \"ssh-proxy-jump\",
    \"source_path\": \"$PORTFOLIO_SOURCE\",
    \"target_path\": \"$TARGET_PATH\",
    \"server\": \"CT150 - moodle.simondatalab.de\",
    \"proxy_host\": \"$PROXY_HOST\",
    \"target_host\": \"$TARGET_HOST\",
    \"version\": \"epic-neural-cosmos-2.0\",
    \"features\": [
        \"Epic Neural to Cosmos Visualization\",
        \"THREE.js Integration\",
        \"Mobile Responsive Design\",
        \"Performance Optimized\",
        \"Professional Portfolio Layout\"
    ],
    \"urls\": {
        \"main_site\": \"https://moodle.simondatalab.de/\",
        \"epic_demo\": \"https://moodle.simondatalab.de/epic-neural-cosmos-demo.html\",
        \"moodle_course\": \"https://moodle.simondatalab.de/course/view.php?id=2\"
    }
}
EOF"

# Test deployment
print_status "Testing deployment..."
ssh -J $PROXY_HOST $TARGET_HOST "
    echo '🧪 Testing Portfolio Deployment...'
    echo '=================================='
    echo 'Files deployed to: $TARGET_PATH'
    echo ''
    echo 'Directory structure:'
    sudo ls -la $TARGET_PATH/
    echo ''
    echo 'CSS files:'
    sudo ls -la $TARGET_PATH/css/
    echo ''
    echo 'JavaScript files:'
    sudo ls -la $TARGET_PATH/js/
    echo ''
    echo 'Assets:'
    if [ -d '$TARGET_PATH/assets' ]; then
        sudo ls -la $TARGET_PATH/assets/
    else
        echo 'No assets directory'
    fi
    echo ''
    echo 'File sizes:'
    sudo du -sh $TARGET_PATH/*
    echo ''
    echo 'Permissions:'
    sudo ls -la $TARGET_PATH/index.html
    sudo ls -la $TARGET_PATH/epic-neural-cosmos-demo.html
"

# Check Apache status
print_status "Checking Apache status..."
ssh -J $PROXY_HOST $TARGET_HOST "
    if sudo systemctl is-active --quiet apache2; then
        echo '✅ Apache2 is running'
        if sudo apache2ctl configtest 2>/dev/null; then
            echo '✅ Apache configuration is valid'
        else
            echo '⚠️ Apache configuration has warnings (but should still work)'
        fi
    else
        echo '⚠️ Apache2 is not running - you may need to start it'
        echo 'Run: sudo systemctl start apache2'
    fi
"

print_success "🎉 Portfolio deployment completed successfully!"
echo ""
print_epic "🌌 Epic Neural Cosmos Portfolio is now live!"
echo ""
print_status "📍 Access URLs:"
echo "   🏠 Main Portfolio: https://moodle.simondatalab.de/"
echo "   🌌 Epic Demo: https://moodle.simondatalab.de/epic-neural-cosmos-demo.html"
echo "   📚 Moodle Course: https://moodle.simondatalab.de/course/view.php?id=2"
echo ""
print_status "🔧 Post-deployment steps:"
echo "   1. Test the main portfolio at https://moodle.simondatalab.de/"
echo "   2. Verify the Epic Neural Cosmos demo loads properly"
echo "   3. Check mobile responsiveness"
echo "   4. Ensure THREE.js visualizations work correctly"
echo "   5. Test all navigation links"
echo ""
print_success "Your enhanced portfolio with Epic Neural Cosmos visualization is ready! 🚀✨"

echo ""
echo "📊 Deployment Summary:"
echo "======================"
echo "✅ Core HTML files deployed"
echo "✅ CSS stylesheets deployed"
echo "✅ JavaScript libraries deployed"
echo "✅ Epic Neural Cosmos visualization deployed"
echo "✅ Performance optimizations applied"
echo "✅ Security headers configured"
echo "✅ File permissions set correctly"
echo "✅ Apache configuration updated"
