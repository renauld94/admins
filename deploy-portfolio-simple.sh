#!/bin/bash

# Simple SSH Deployment for Portfolio to CT150
# Uses the correct SSH configuration from ssh_config_corrected

set -e

# Configuration - Updated based on ssh_config_corrected
PACKAGE_FILE="portfolio-ct150-deployment-20251015_001358.tar.gz"
PROXY_HOST="136.243.155.166"
PROXY_PORT="22"  # CT150 uses standard port 22
PROXY_USER="root"
TARGET_HOST="10.0.0.150"  # CT150 server
TARGET_USER="root"
TARGET_PATH="/var/www/html/simondatalab"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_epic() {
    echo -e "${PURPLE}[EPIC]${NC} $1"
}

echo "🚀 Simple Portfolio Deployment to CT150"
echo "======================================="
echo "📦 Package: $PACKAGE_FILE"
echo "🌐 Target: https://simondatalab.de/"
echo "📡 Proxy: $PROXY_USER@$PROXY_HOST:$PROXY_PORT"
echo "🖥️  Server: CT150 - $TARGET_USER@$TARGET_HOST"
echo ""

# Check if package exists
if [ ! -f "$PACKAGE_FILE" ]; then
    print_error "Package file $PACKAGE_FILE not found!"
    print_status "Available packages:"
    ls -la *.tar.gz 2>/dev/null || echo "No .tar.gz files found"
    exit 1
fi

# Test connection with correct SSH parameters
print_status "Testing SSH connection..."
if ssh -o ConnectTimeout=10 -o BatchMode=yes -p $PROXY_PORT $PROXY_USER@$PROXY_HOST "echo 'Proxy connection successful'" 2>/dev/null; then
    print_success "✅ Proxy connection established!"
    
    # Test the target connection through proxy
    if ssh -o ConnectTimeout=10 -o BatchMode=yes -J $PROXY_USER@$PROXY_HOST:$PROXY_PORT $TARGET_USER@$TARGET_HOST "echo 'Target connection successful'" 2>/dev/null; then
        print_success "✅ Target connection established!"
    else
        print_error "❌ Target connection failed through proxy"
        print_status "Manual deployment instructions:"
        echo ""
        echo "1. Copy package to a location accessible to your CT150 server"
        echo "2. On the CT150 server, run:"
        echo "   cd /tmp"
        echo "   # Upload $PACKAGE_FILE here"
        echo "   tar -xzf $PACKAGE_FILE"
        echo "   sudo cp -r portfolio-ct150-deployment-*/* /var/www/html/simondatalab/"
        echo "   sudo chown -R www-data:www-data /var/www/html/simondatalab"
        echo "   sudo chmod -R 755 /var/www/html/simondatalab"
        exit 1
    fi
else
    print_error "❌ Proxy connection failed"
    print_status "Trying alternative connection methods..."
    
    # Try standard port 22
    if ssh -o ConnectTimeout=10 -o BatchMode=yes $PROXY_USER@$PROXY_HOST "echo 'Standard SSH connection successful'" 2>/dev/null; then
        print_success "✅ Connected via standard SSH!"
        PROXY_PORT="22"
    else
        print_error "❌ All connection attempts failed"
        print_status "Manual deployment package is ready at: $(pwd)/$PACKAGE_FILE"
        print_status "Size: $(du -sh $PACKAGE_FILE | cut -f1)"
        echo ""
        echo "📋 Manual Deployment Steps:"
        echo "1. Transfer $PACKAGE_FILE to your CT150 server"
        echo "2. Extract: tar -xzf $PACKAGE_FILE"
        echo "3. Deploy: sudo cp -r portfolio-ct150-deployment-*/* /var/www/html/simondatalab/"
        echo "4. Permissions: sudo chown -R www-data:www-data /var/www/html/simondatalab"
        echo "5. Test: https://simondatalab.de/"
        exit 1
    fi
fi

# Deploy the package
print_epic "🌌 Deploying Epic Neural Cosmos Portfolio..."

# Upload package to target server
print_status "Uploading package..."
scp -P $PROXY_PORT -o ProxyJump=$PROXY_USER@$PROXY_HOST:$PROXY_PORT $PACKAGE_FILE $TARGET_USER@$TARGET_HOST:/tmp/

# Extract and deploy on target server
print_status "Extracting and deploying on target server..."
ssh -J $PROXY_USER@$PROXY_HOST:$PROXY_PORT $TARGET_USER@$TARGET_HOST "
    cd /tmp
    
    # Create backup if directory exists
    if [ -d '$TARGET_PATH' ]; then
        sudo cp -r '$TARGET_PATH' '$TARGET_PATH.backup.\$(date +%Y%m%d_%H%M%S)'
        echo 'Backup created'
    fi
    
    # Extract package
    tar -xzf $PACKAGE_FILE
    EXTRACTED_DIR=\$(ls -1d portfolio-ct150-deployment-* | head -1)
    
    # Ensure target directory exists
    sudo mkdir -p $TARGET_PATH
    
    # Copy files
    sudo cp -r \"\$EXTRACTED_DIR\"/* $TARGET_PATH/
    
    # Set permissions
    sudo chown -R www-data:www-data $TARGET_PATH
    sudo chmod -R 755 $TARGET_PATH
    sudo chmod 644 $TARGET_PATH/.htaccess
    
    # Cleanup
    rm -rf \$EXTRACTED_DIR $PACKAGE_FILE
    
    echo 'Deployment completed successfully!'
"

# Test deployment
print_status "Testing deployment..."
ssh -J $PROXY_USER@$PROXY_HOST:$PROXY_PORT $TARGET_USER@$TARGET_HOST "
    echo '🧪 Testing Portfolio Deployment...'
    echo '================================='
    echo 'Target path: $TARGET_PATH'
    echo ''
    echo 'Files deployed:'
    sudo ls -la $TARGET_PATH/
    echo ''
    echo 'File sizes:'
    sudo du -sh $TARGET_PATH/*
    echo ''
    echo 'Permissions check:'
    sudo ls -la $TARGET_PATH/index.html
    sudo ls -la $TARGET_PATH/epic-neural-cosmos-demo.html
    echo ''
    echo 'Apache status:'
    if sudo systemctl is-active --quiet apache2; then
        echo '✅ Apache2 is running'
    else
        echo '⚠️ Apache2 is not running'
    fi
"

print_success "🎉 Portfolio deployment completed successfully!"
echo ""
print_epic "🌌 Epic Neural Cosmos Portfolio is now live!"
echo ""
print_status "🌐 Access URLs:"
echo "   🏠 Main Portfolio: https://simondatalab.de/"
echo "   🌌 Epic Demo: https://simondatalab.de/epic-neural-cosmos-demo.html"
echo "   📚 Moodle Course: https://moodle.simondatalab.de/course/view.php?id=2"
echo ""
print_success "Your enhanced portfolio with Epic Neural Cosmos visualization is ready! 🚀✨"