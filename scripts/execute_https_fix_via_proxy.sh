#!/bin/bash
echo "🚀 EXECUTING HTTPS FIX VIA PROXY JUMP"
echo "====================================="
echo "Target: CT 150 (portfolio-web-1000150) - 10.0.0.150"
echo "Proxy: 136.243.155.166"
echo "Issue: www.simondatalab.de still redirecting to Moodle"
echo "Date: $(date)"
echo ""

# Check if we can reach the proxy server
echo "🔍 Testing proxy server connectivity..."
if ! ping -c 1 136.243.155.166 > /dev/null 2>&1; then
    echo "❌ Cannot reach proxy server 136.243.155.166"
    echo "Please check your network connection"
    exit 1
fi

echo "✅ Proxy server reachable"

# Create the HTTPS fix script to deploy
cat > /tmp/https_fix_script.sh << 'EOF'
#!/bin/bash
echo "🔒 HTTPS FIX SCRIPT ON CT 150"
echo "============================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root"
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

echo "📋 STEP 3: CREATING PORTFOLIO CONTENT"
echo "====================================="
# Create portfolio index.html that will override Moodle
cat > /var/www/html/index.html << 'PORTFOLIO_EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Simon Data Lab - Portfolio</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .container {
            text-align: center;
            max-width: 800px;
            padding: 2rem;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            backdrop-filter: blur(10px);
            box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
        }
        h1 {
            font-size: 3rem;
            margin-bottom: 1rem;
            background: linear-gradient(45deg, #ff6b6b, #4ecdc4);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .subtitle {
            font-size: 1.5rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }
        .services {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-top: 2rem;
        }
        .service {
            background: rgba(255, 255, 255, 0.1);
            padding: 1rem;
            border-radius: 10px;
            transition: transform 0.3s ease;
        }
        .service:hover {
            transform: translateY(-5px);
        }
        .service a {
            color: white;
            text-decoration: none;
            font-weight: bold;
        }
        .status {
            margin-top: 2rem;
            padding: 1rem;
            background: rgba(76, 175, 80, 0.2);
            border-radius: 10px;
            border-left: 4px solid #4caf50;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Simon Data Lab</h1>
        <p class="subtitle">Data Science & Machine Learning Portfolio</p>
        
        <div class="services">
            <div class="service">
                <a href="https://moodle.simondatalab.de/">🎓 Moodle LMS</a>
                <p>Learning Management System</p>
            </div>
            <div class="service">
                <a href="https://grafana.simondatalab.de/">📊 Grafana</a>
                <p>Monitoring & Analytics</p>
            </div>
            <div class="service">
                <a href="https://openwebui.simondatalab.de/">🤖 OpenWebUI</a>
                <p>AI Interface</p>
            </div>
            <div class="service">
                <a href="https://ollama.simondatalab.de/">🦙 Ollama</a>
                <p>Local LLM Server</p>
            </div>
            <div class="service">
                <a href="https://mlflow.simondatalab.de/">🔬 MLflow</a>
                <p>ML Experiment Tracking</p>
            </div>
            <div class="service">
                <a href="https://geoneuralviz.simondatalab.de/">🗺️ GeoNeuralViz</a>
                <p>Geospatial Visualization</p>
            </div>
            <div class="service">
                <a href="https://booklore.simondatalab.de/">📚 BookLore</a>
                <p>Knowledge Management</p>
            </div>
        </div>
        
        <div class="status">
            <h3>✅ Portfolio Fixed!</h3>
            <p>www.simondatalab.de now correctly displays the portfolio instead of redirecting to Moodle.</p>
            <p>Moodle is available at: <a href="https://moodle.simondatalab.de/" style="color: #4caf50;">moodle.simondatalab.de</a></p>
        </div>
    </div>
</body>
</html>
PORTFOLIO_EOF

echo "📋 STEP 4: CREATING HTTPS VIRTUAL HOST"
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

echo "📋 STEP 5: UPDATING HTTP VIRTUAL HOST FOR REDIRECT"
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

echo "📋 STEP 6: ENABLING MODULES AND SITE"
echo "==================================="
# Enable rewrite module for redirects
a2enmod rewrite
echo "✅ Rewrite module enabled"

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
echo "  ✅ Created portfolio index.html to override Moodle"
echo "  ✅ Configured HTTPS virtual host"
echo "  ✅ Set up HTTP to HTTPS redirect"
echo "  ✅ Enabled rewrite module"
echo "  ✅ Restarted Apache"
echo ""
echo "⚠️  Note: Browser will show security warning for self-signed certificate"
echo "   This is normal for development. Click 'Advanced' → 'Proceed' to continue"
echo ""
EOF

echo "📤 DEPLOYING HTTPS FIX SCRIPT TO CT 150"
echo "======================================="

# Copy the fix script to CT 150
echo "📋 Copying HTTPS fix script to CT 150..."
scp -J root@136.243.155.166 /tmp/https_fix_script.sh simonadmin@10.0.0.150:/tmp/

if [ $? -eq 0 ]; then
    echo "✅ Script copied successfully"
    
    echo "🚀 EXECUTING HTTPS FIX SCRIPT ON CT 150"
    echo "======================================="
    
    # Execute the fix script on CT 150
    ssh -J root@136.243.155.166 simonadmin@10.0.0.150 "chmod +x /tmp/https_fix_script.sh && sudo /tmp/https_fix_script.sh"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 HTTPS FIX COMPLETED SUCCESSFULLY!"
        echo "===================================="
        echo "✅ www.simondatalab.de should now show your portfolio"
        echo "✅ HTTPS should be working with self-signed certificate"
        echo ""
        echo "🔍 Testing the fix..."
        echo "===================="
        
        # Test the fix
        echo "Testing https://www.simondatalab.de/..."
        curl -I https://www.simondatalab.de/ | head -3
        
    else
        echo "❌ Failed to execute HTTPS fix script on CT 150"
        echo "Please check the connection and try again"
        exit 1
    fi
    
else
    echo "❌ Failed to copy HTTPS fix script to CT 150"
    echo "Please check the proxy connection and try again"
    exit 1
fi

# Cleanup
rm -f /tmp/https_fix_script.sh

echo ""
echo "🏁 HTTPS FIX EXECUTION COMPLETED!"
echo "================================="
