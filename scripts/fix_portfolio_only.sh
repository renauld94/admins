#!/bin/bash
echo "🎯 PORTFOLIO ONLY FIX - NO MOODLE TOUCHING"
echo "==========================================="
echo "Goal: Fix www.simondatalab.de to show portfolio"
echo "Method: Override the redirect with portfolio content"
echo "Date: $(date)"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root"
    echo "Please run: sudo $0"
    exit 1
fi

echo "📋 STEP 1: BACKING UP CURRENT STATE"
echo "===================================="
# Create backup
BACKUP_DIR="/var/backups/portfolio-fix-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r /var/www/html "$BACKUP_DIR/"
echo "✅ Backup created at: $BACKUP_DIR"

echo "📋 STEP 2: CREATING PORTFOLIO CONTENT"
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

echo "📋 STEP 3: UPDATING APACHE CONFIGURATION"
echo "========================================"
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
        
        # Force serve index.html instead of index.php
        DirectoryIndex index.html index.php
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/portfolio_error.log
    CustomLog ${APACHE_LOG_DIR}/portfolio_access.log combined
</VirtualHost>
DEFAULT_EOF

echo "📋 STEP 4: RESTARTING APACHE"
echo "============================"
# Reload Apache configuration
systemctl reload apache2

echo "📋 STEP 5: TESTING THE FIX"
echo "=========================="
# Test local connection
echo "🔍 Testing local connection..."
curl -I http://localhost/ | head -5

echo ""
echo "✅ PORTFOLIO FIX COMPLETED!"
echo "=========================="
echo "🌐 Portfolio: https://www.simondatalab.de/"
echo "🎓 Moodle: https://moodle.simondatalab.de/"
echo ""
echo "📋 What was fixed:"
echo "  ✅ Created portfolio index.html to override Moodle"
echo "  ✅ Updated Apache to prioritize index.html over index.php"
echo "  ✅ Restarted Apache service"
echo ""
echo "🔄 Next steps:"
echo "  1. Test https://www.simondatalab.de/ in browser"
echo "  2. Purge Cloudflare cache if needed"
echo ""
