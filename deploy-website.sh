#!/bin/bash

# Simon DataLab Website Deployment Script
# This script deploys the portfolio website and configures Apache

set -e

echo "🚀 Starting Simon DataLab website deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root (use sudo)"
    exit 1
fi

# Set variables
PROJECT_DIR="/home/simon/Desktop/Learning Management System Academy"
WEB_ROOT="/var/www/html/simondatalab"
APACHE_CONFIG="/etc/apache2/sites-available/simondatalab.de.conf"

print_status "Creating web directory..."
mkdir -p "$WEB_ROOT"

print_status "Copying website files..."
cp -r "$PROJECT_DIR/portfolio/"* "$WEB_ROOT/"

print_status "Setting proper permissions..."
chown -R www-data:www-data "$WEB_ROOT"
chmod -R 755 "$WEB_ROOT"

print_status "Installing Apache configuration..."
cp "$PROJECT_DIR/simondatalab.de.conf" "$APACHE_CONFIG"

print_status "Enabling required Apache modules..."
a2enmod rewrite headers expires deflate

print_status "Enabling the site..."
a2ensite simondatalab.de

print_status "Disabling default site (if exists)..."
a2dissite 000-default 2>/dev/null || true

print_status "Testing Apache configuration..."
apache2ctl configtest

if [ $? -eq 0 ]; then
    print_status "Apache configuration is valid!"
    
    print_status "Reloading Apache..."
    systemctl reload apache2
    
    print_status "Checking Apache status..."
    systemctl status apache2 --no-pager -l
    
    print_status "✅ Deployment completed successfully!"
    echo ""
    print_status "Your website should now be accessible at:"
    echo "  - http://simondatalab.de"
    echo "  - http://www.simondatalab.de"
    echo ""
    print_status "To test locally:"
    echo "  curl -I http://localhost"
    echo ""
    print_warning "Note: HTTPS will need SSL certificate configuration"
    print_warning "Cloudflare should now be able to connect to your origin server"
    
else
    print_error "Apache configuration test failed!"
    print_error "Please check the configuration and try again"
    exit 1
fi
