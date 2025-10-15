#!/bin/bash
# Manual Portfolio Deployment for CT150
# Creates a deployment package for manual upload to moodle.simondatalab.de

set -e

# Configuration
PORTFOLIO_SOURCE="/home/simon/Learning-Management-System-Academy/portfolio-deployment-enhanced"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PACKAGE_NAME="portfolio-ct150-deployment-$TIMESTAMP"
PACKAGE_PATH="/home/simon/Learning-Management-System-Academy/$PACKAGE_NAME"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_epic() {
    echo -e "${PURPLE}[EPIC]${NC} $1"
}

echo "📦 Creating Portfolio Deployment Package for CT150"
echo "=================================================="
echo "🎯 Target: simondatalab.de"
echo "📁 Source: $PORTFOLIO_SOURCE"
echo "📦 Package: $PACKAGE_NAME"
echo ""

# Create package directory
print_status "Creating deployment package structure..."
mkdir -p "$PACKAGE_PATH"/{css,js,assets,geospatial-viz}

# Copy core HTML files
print_epic "🌌 Packaging Epic Neural Cosmos Portfolio..."
cp "$PORTFOLIO_SOURCE/index.html" "$PACKAGE_PATH/" || true
cp "$PORTFOLIO_SOURCE/epic-neural-cosmos-demo.html" "$PACKAGE_PATH/" || true

# Copy CSS files
print_status "Packaging stylesheets..."
cp "$PORTFOLIO_SOURCE/styles.css" "$PACKAGE_PATH/css/" || true
[ -f "$PORTFOLIO_SOURCE/globe-fab.css" ] && cp "$PORTFOLIO_SOURCE/globe-fab.css" "$PACKAGE_PATH/css/"
[ -f "$PORTFOLIO_SOURCE/print.css" ] && cp "$PORTFOLIO_SOURCE/print.css" "$PACKAGE_PATH/css/"

# Copy JavaScript files
print_status "Packaging JavaScript libraries and visualizations..."
cp "$PORTFOLIO_SOURCE/three-loader.js" "$PACKAGE_PATH/js/" || true
cp "$PORTFOLIO_SOURCE/epic-neural-cosmos-viz.js" "$PACKAGE_PATH/js/" || true
cp "$PORTFOLIO_SOURCE/app.js" "$PACKAGE_PATH/js/" || true
[ -f "$PORTFOLIO_SOURCE/ai-integration.js" ] && cp "$PORTFOLIO_SOURCE/ai-integration.js" "$PACKAGE_PATH/js/"
[ -f "$PORTFOLIO_SOURCE/hero-performance.js" ] && cp "$PORTFOLIO_SOURCE/hero-performance.js" "$PACKAGE_PATH/js/"
[ -f "$PORTFOLIO_SOURCE/gsap.min.js" ] && cp "$PORTFOLIO_SOURCE/gsap.min.js" "$PACKAGE_PATH/js/"
[ -f "$PORTFOLIO_SOURCE/ScrollTrigger.min.js" ] && cp "$PORTFOLIO_SOURCE/ScrollTrigger.min.js" "$PACKAGE_PATH/js/"
[ -f "$PORTFOLIO_SOURCE/d3.v7.min.js" ] && cp "$PORTFOLIO_SOURCE/d3.v7.min.js" "$PACKAGE_PATH/js/"

# Copy assets if they exist
if [ -d "$PORTFOLIO_SOURCE/assets" ]; then
    print_status "Packaging assets..."
    cp -r "$PORTFOLIO_SOURCE/assets"/* "$PACKAGE_PATH/assets/" || true
fi

# Copy geospatial viz if it exists
if [ -d "$PORTFOLIO_SOURCE/geospatial-viz" ]; then
    print_status "Packaging geospatial visualizations..."
    cp -r "$PORTFOLIO_SOURCE/geospatial-viz"/* "$PACKAGE_PATH/geospatial-viz/" || true
fi

# Copy favicon
[ -f "$PORTFOLIO_SOURCE/favicon.svg" ] && cp "$PORTFOLIO_SOURCE/favicon.svg" "$PACKAGE_PATH/"

# Create .htaccess for Apache optimization
print_status "Creating Apache configuration..."
cat > "$PACKAGE_PATH/.htaccess" << 'EOF'
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
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
    ExpiresByType image/png "access plus 1 month"
    ExpiresByType image/jpg "access plus 1 month"
    ExpiresByType image/jpeg "access plus 1 month"
    ExpiresByType image/gif "access plus 1 month"
    ExpiresByType image/svg+xml "access plus 1 month"
    ExpiresByType font/woff2 "access plus 1 year"
    ExpiresByType font/woff "access plus 1 year"
</IfModule>

# Security Headers
Header always set X-Content-Type-Options nosniff
Header always set X-Frame-Options SAMEORIGIN
Header always set X-XSS-Protection "1; mode=block"
Header always set Referrer-Policy "strict-origin-when-cross-origin"

# CORS for THREE.js and other assets
<IfModule mod_headers.c>
    Header set Access-Control-Allow-Origin "*"
    Header set Access-Control-Allow-Methods "GET, POST, OPTIONS"
    Header set Access-Control-Allow-Headers "Origin, X-Requested-With, Content-Type, Accept"
</IfModule>
EOF

# Create deployment instructions
cat > "$PACKAGE_PATH/DEPLOYMENT_INSTRUCTIONS.md" << EOF
# 📦 Portfolio Deployment Instructions for CT150

## 🧭 Target Server
- **URL**: https://simondatalab.de/
- **Server**: CT150 - simondatalab.de
- **Target Path**: `/var/www/html/simondatalab`

## 🚀 Deployment Steps

### Method 1: Direct Upload (Recommended)
1. Extract this package on the target server
2. Copy all files to `/var/www/html/simondatalab/`
3. Set proper permissions:
   ```bash
   sudo chown -R www-data:www-data /var/www/html/simondatalab
   sudo chmod -R 755 /var/www/html/simondatalab
   sudo chmod 644 /var/www/html/simondatalab/.htaccess
   ```

### Method 2: Using SSH (if configured)
```bash
# Upload package
scp $PACKAGE_NAME.tar.gz user@simondatalab.de:/tmp/

# SSH to server
ssh user@simondatalab.de

# Extract and deploy
cd /tmp
tar -xzf $PACKAGE_NAME.tar.gz
sudo cp -r $PACKAGE_NAME/* /var/www/html/simondatalab/
sudo chown -R www-data:www-data /var/www/html/simondatalab
sudo chmod -R 755 /var/www/html/simondatalab
```

## 📋 What's Included

✅ **Core Files**
- `index.html` - Main portfolio page
- `epic-neural-cosmos-demo.html` - Epic visualization demo

✅ **Stylesheets**
- `css/styles.css` - Main styles
- `css/globe-fab.css` - Globe component styles
- `css/print.css` - Print styles

✅ **JavaScript Libraries**
- `js/three-loader.js` - Custom THREE.js loader
- `js/epic-neural-cosmos-viz.js` - Epic visualization system
- `js/app.js` - Main application logic
- `js/ai-integration.js` - AI integration features
- `js/hero-performance.js` - Performance optimizations
- `js/gsap.min.js` - Animation library
- `js/ScrollTrigger.min.js` - Scroll animations
- `js/d3.v7.min.js` - Data visualization library

✅ **Assets**
- Images, fonts, and other static assets
- Geospatial visualization components
- Favicon and branding assets

✅ **Configuration**
- `.htaccess` - Apache performance and security configuration

## 🧪 Testing

After deployment, verify:
1. **Main Site**: https://simondatalab.de/
2. **Epic Demo**: https://simondatalab.de/epic-neural-cosmos-demo.html
3. **Moodle Course**: https://moodle.simondatalab.de/course/view.php?id=2

EOF

# Create deployment meta
cat > "$PACKAGE_PATH/deployment-info.json" << EOF
{
    "package_name": "$PACKAGE_NAME",
    "created_date": "$(date -Iseconds)",
    "source_path": "$PORTFOLIO_SOURCE",
    "target_server": "simondatalab.de",
    "target_path": "/var/www/html/simondatalab",
    "version": "epic-neural-cosmos-2.0"
}
EOF

# Create the tar.gz package
print_status "Creating compressed package..."
cd "/home/simon/Learning-Management-System-Academy"
tar -czf "$PACKAGE_NAME.tar.gz" "$PACKAGE_NAME" || true

# Cleanup temporary directory
rm -rf "$PACKAGE_PATH" || true

# Show results
print_success "📦 Deployment package created successfully!"
echo ""
print_epic "🌌 Epic Neural Cosmos Portfolio Package Ready!"
echo ""
echo "📄 Package Details:"
echo "   📦 Name: $PACKAGE_NAME.tar.gz"
echo "   📁 Location: /home/simon/Learning-Management-System-Academy/$PACKAGE_NAME.tar.gz"
echo ""
print_success "Ready for deployment to simondatalab.de! 🌟"
