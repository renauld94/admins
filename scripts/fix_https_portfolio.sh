#!/bin/bash
echo "🔒 FIXING HTTPS FOR PORTFOLIO"
echo "============================="
echo "Issue: HTTPS not working for www.simondatalab.de"
echo "Solution: Enable SSL and create self-signed certificate"
echo "Date: $(date)"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root"
    echo "Please run: sudo $0"
    exit 1
fi

echo "📋 STEP 1: ENABLING SSL MODULE"
echo "=============================="
# Enable SSL module
a2enmod ssl
echo "✅ SSL module enabled"

echo "📋 STEP 2: CREATING SSL CERTIFICATE"
echo "==================================="
# Create SSL certificate directory
mkdir -p /etc/ssl/private
mkdir -p /etc/ssl/certs

# Generate self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/simondatalab.key \
    -out /etc/ssl/certs/simondatalab.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=simondatalab.de"

echo "✅ SSL certificate created"

echo "📋 STEP 3: CREATING HTTPS VIRTUAL HOST"
echo "======================================"
# Create HTTPS virtual host
cat > /etc/apache2/sites-available/simondatalab-ssl.conf << 'SSL_EOF'
<VirtualHost *:443>
    ServerName www.simondatalab.de
    ServerAlias simondatalab.de
    DocumentRoot /var/www/html
    
    # SSL Configuration
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/simondatalab.crt
    SSLCertificateKeyFile /etc/ssl/private/simondatalab.key
    
    # Security headers
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options DENY
    Header always set X-XSS-Protection "1; mode=block"
    
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
        
        # Force serve index.html instead of index.php
        DirectoryIndex index.html index.php
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/portfolio_ssl_error.log
    CustomLog ${APACHE_LOG_DIR}/portfolio_ssl_access.log combined
</VirtualHost>
SSL_EOF

echo "✅ HTTPS virtual host created"

echo "📋 STEP 4: UPDATING HTTP VIRTUAL HOST FOR REDIRECT"
echo "=================================================="
# Update HTTP virtual host to redirect to HTTPS
cat > /etc/apache2/sites-available/000-default.conf << 'HTTP_EOF'
<VirtualHost *:80>
    ServerName www.simondatalab.de
    ServerAlias simondatalab.de
    
    # Redirect all HTTP traffic to HTTPS
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
    
    ErrorLog ${APACHE_LOG_DIR}/portfolio_redirect_error.log
    CustomLog ${APACHE_LOG_DIR}/portfolio_redirect_access.log combined
</VirtualHost>
HTTP_EOF

echo "✅ HTTP redirect configured"

echo "📋 STEP 5: ENABLING REWRITE MODULE"
echo "=================================="
# Enable rewrite module for redirects
a2enmod rewrite
echo "✅ Rewrite module enabled"

echo "📋 STEP 6: ENABLING SSL SITE"
echo "============================"
# Enable the SSL site
a2ensite simondatalab-ssl
echo "✅ SSL site enabled"

echo "📋 STEP 7: RESTARTING APACHE"
echo "============================"
# Restart Apache to apply all changes
systemctl restart apache2

echo "📋 STEP 8: TESTING HTTPS"
echo "========================"
# Test HTTPS connection
echo "🔍 Testing HTTPS connection..."
curl -k -I https://localhost/ | head -5

echo ""
echo "✅ HTTPS FIX COMPLETED!"
echo "======================="
echo "🌐 Portfolio: https://www.simondatalab.de/"
echo "🔒 HTTPS: Now working with self-signed certificate"
echo ""
echo "📋 What was fixed:"
echo "  ✅ Enabled SSL module"
echo "  ✅ Created self-signed certificate"
echo "  ✅ Configured HTTPS virtual host"
echo "  ✅ Set up HTTP to HTTPS redirect"
echo "  ✅ Enabled rewrite module"
echo "  ✅ Restarted Apache"
echo ""
echo "⚠️  Note: Browser will show security warning for self-signed certificate"
echo "   This is normal for development. Click 'Advanced' → 'Proceed' to continue"
echo ""
echo "🔄 Next steps:"
echo "  1. Test https://www.simondatalab.de/ in browser"
echo "  2. Accept the security warning for self-signed certificate"
echo "  3. For production, get a real SSL certificate from Let's Encrypt"
echo ""
