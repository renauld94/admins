#!/bin/bash
echo "🚀 EXECUTING PORTFOLIO REDIRECT FIX VIA PROXY JUMP"
echo "=================================================="
echo "Target: CT 150 (portfolio-web-1000150) - 10.0.0.150"
echo "Proxy: 136.243.155.166"
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

# Create the fix script to deploy
cat > /tmp/portfolio_fix_script.sh << 'EOF'
#!/bin/bash
echo "🔧 PORTFOLIO REDIRECT FIX ON CT 150"
echo "==================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root"
    exit 1
fi

echo "📋 STEP 1: BACKING UP CURRENT STATE"
echo "===================================="
# Create backup directory
BACKUP_DIR="/var/backups/moodle-move-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup current Moodle installation
echo "📦 Backing up Moodle installation..."
cp -r /var/www/html "$BACKUP_DIR/"

echo "📋 STEP 2: MOVING MOODLE TO SUBDIRECTORY"
echo "========================================"
# Create moodle subdirectory
mkdir -p /var/www/html/moodle

# Move all Moodle files except . and .. to subdirectory
echo "📁 Moving Moodle files to /var/www/html/moodle/"
cd /var/www/html
find . -maxdepth 1 -not -name "." -not -name ".." -not -name "moodle" -exec mv {} moodle/ \;

echo "📋 STEP 3: UPDATING MOODLE CONFIGURATION"
echo "========================================"
# Update Moodle config.php
echo "🔧 Updating Moodle wwwroot configuration..."
sed -i "s|wwwroot.*=.*'http://localhost:8081'|wwwroot = 'https://moodle.simondatalab.de/moodle';|g" /var/www/html/moodle/config.php

# Update dirroot in config.php
sed -i "s|dirroot.*=.*__DIR__|dirroot = '/var/www/html/moodle';|g" /var/www/html/moodle/config.php

echo "📋 STEP 4: CREATING PORTFOLIO CONTENT"
echo "====================================="
# Create portfolio index.html
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
                <a href="https://moodle.simondatalab.de/moodle/">🎓 Moodle LMS</a>
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
            <p>Moodle is now available at: <a href="https://moodle.simondatalab.de/moodle/" style="color: #4caf50;">moodle.simondatalab.de/moodle</a></p>
        </div>
    </div>
</body>
</html>
PORTFOLIO_EOF

echo "📋 STEP 5: UPDATING APACHE CONFIGURATION"
echo "========================================"
# Update Apache virtual host for moodle.simondatalab.de
cat > /etc/apache2/sites-available/moodle.simondatalab.de.conf << 'APACHE_EOF'
# Apache vhost for Moodle (HTTP)
<VirtualHost *:80>
    ServerName moodle.simondatalab.de

    # Preserve the original Host header for Moodle reverseproxy mode
    ProxyPreserveHost On

    # Proxy to Bitnami/Moodle container on localhost:8086
    ProxyPass        / http://127.0.0.1:8086/
    ProxyPassReverse / http://127.0.0.1:8086/
    ProxyPassReverse / http://136.243.155.166:8086/

    # Optional: ensure Location headers and Set-Cookie domains rewrite correctly
    RequestHeader set X-Forwarded-Proto "http"
    RequestHeader set X-Forwarded-Host "moodle.simondatalab.de"

    # Hardening and helpful headers
    Header always set X-Content-Type-Options nosniff
    Header always set X-Frame-Options SAMEORIGIN

    # Logs
    ErrorLog  /var/log/apache2/moodle.simondatalab.de.error.log
    CustomLog /var/log/apache2/moodle.simondatalab.de.access.log combined
</VirtualHost>
APACHE_EOF

# Update default virtual host to serve portfolio
cat > /etc/apache2/sites-available/000-default.conf << 'DEFAULT_EOF'
<VirtualHost *:80>
    ServerName www.simondatalab.de
    ServerAlias simondatalab.de
    DocumentRoot /var/www/html
    
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/portfolio_error.log
    CustomLog ${APACHE_LOG_DIR}/portfolio_access.log combined
</VirtualHost>
DEFAULT_EOF

echo "📋 STEP 6: RESTARTING APACHE"
echo "============================"
# Reload Apache configuration
systemctl reload apache2

echo "📋 STEP 7: TESTING THE FIX"
echo "=========================="
# Test local connection
echo "🔍 Testing local connection..."
curl -I http://localhost/ | head -5

echo ""
echo "✅ PORTFOLIO REDIRECT FIX COMPLETED!"
echo "===================================="
echo "🌐 Portfolio: https://www.simondatalab.de/"
echo "🎓 Moodle: https://moodle.simondatalab.de/moodle/"
echo ""
echo "📋 What was fixed:"
echo "  ✅ Moved Moodle from /var/www/html to /var/www/html/moodle"
echo "  ✅ Deployed portfolio content to /var/www/html"
echo "  ✅ Updated Moodle config to use correct wwwroot"
echo "  ✅ Updated Apache virtual hosts"
echo "  ✅ Restarted Apache service"
echo ""
echo "🔄 Next steps:"
echo "  1. Test https://www.simondatalab.de/ in browser"
echo "  2. Test https://moodle.simondatalab.de/moodle/ in browser"
echo "  3. Purge Cloudflare cache if needed"
echo ""
EOF

echo "📤 DEPLOYING FIX SCRIPT TO CT 150"
echo "================================="

# Copy the fix script to CT 150
echo "📋 Copying portfolio fix script to CT 150..."
scp -J root@136.243.155.166 /tmp/portfolio_fix_script.sh simonadmin@10.0.0.150:/tmp/

if [ $? -eq 0 ]; then
    echo "✅ Script copied successfully"
    
    echo "🚀 EXECUTING FIX SCRIPT ON CT 150"
    echo "=================================="
    
    # Execute the fix script on CT 150
    ssh -J root@136.243.155.166 simonadmin@10.0.0.150 "chmod +x /tmp/portfolio_fix_script.sh && sudo /tmp/portfolio_fix_script.sh"
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "🎉 PORTFOLIO REDIRECT FIX COMPLETED SUCCESSFULLY!"
        echo "================================================="
        echo "✅ www.simondatalab.de should now show your portfolio"
        echo "✅ moodle.simondatalab.de should show Moodle LMS"
        echo ""
        echo "🔍 Testing the fix..."
        echo "===================="
        
        # Test the fix
        echo "Testing www.simondatalab.de..."
        curl -I https://www.simondatalab.de/ | head -3
        
        echo ""
        echo "Testing moodle.simondatalab.de..."
        curl -I https://moodle.simondatalab.de/ | head -3
        
    else
        echo "❌ Failed to execute fix script on CT 150"
        echo "Please check the connection and try again"
        exit 1
    fi
    
else
    echo "❌ Failed to copy fix script to CT 150"
    echo "Please check the proxy connection and try again"
    exit 1
fi

# Cleanup
rm -f /tmp/portfolio_fix_script.sh

echo ""
echo "🏁 PORTFOLIO REDIRECT FIX EXECUTION COMPLETED!"
echo "=============================================="
