# 🔧 MANUAL PORTFOLIO REDIRECT FIX COMMANDS

## 🚨 **CRITICAL ISSUE IDENTIFIED**
Your portfolio `www.simondatalab.de` is redirecting to Moodle because:
- **Moodle is installed in `/var/www/html`** (web root) instead of a subdirectory
- **Moodle config** has `wwwroot = 'http://localhost:8081'` causing redirects
- **Apache** is serving Moodle for all requests to the root domain

## 🎯 **SOLUTION**
Move Moodle to `/var/www/html/moodle` and deploy portfolio to `/var/www/html`

---

## 📋 **STEP-BY-STEP FIX COMMANDS**

### **Step 1: Backup Current State**
```bash
# Create backup
sudo cp -r /var/www/html /var/www/html.backup-$(date +%Y%m%d-%H%M%S)
```

### **Step 2: Move Moodle to Subdirectory**
```bash
# Create moodle subdirectory
sudo mkdir -p /var/www/html/moodle

# Move all Moodle files to subdirectory
cd /var/www/html
sudo find . -maxdepth 1 -not -name "." -not -name ".." -not -name "moodle" -exec mv {} moodle/ \;
```

### **Step 3: Update Moodle Configuration**
```bash
# Update Moodle wwwroot to correct URL
sudo sed -i "s|wwwroot.*=.*'http://localhost:8081'|wwwroot = 'https://moodle.simondatalab.de/moodle';|g" /var/www/html/moodle/config.php

# Update dirroot path
sudo sed -i "s|dirroot.*=.*__DIR__|dirroot = '/var/www/html/moodle';|g" /var/www/html/moodle/config.php
```

### **Step 4: Create Portfolio Content**
```bash
# Create portfolio index.html
sudo tee /var/www/html/index.html > /dev/null << 'EOF'
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
EOF
```

### **Step 5: Update Apache Configuration**
```bash
# Update default virtual host for portfolio
sudo tee /etc/apache2/sites-available/000-default.conf > /dev/null << 'EOF'
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
EOF
```

### **Step 6: Restart Apache**
```bash
# Reload Apache configuration
sudo systemctl reload apache2
```

### **Step 7: Test the Fix**
```bash
# Test local connection
curl -I http://localhost/

# Test external connection
curl -I https://www.simondatalab.de/
```

---

## ✅ **EXPECTED RESULTS**

After running these commands:

- **✅ www.simondatalab.de** → Shows portfolio (not Moodle redirect)
- **✅ moodle.simondatalab.de** → Shows Moodle LMS
- **✅ All other services** → Work correctly without Moodle redirects

---

## 🔄 **NEXT STEPS**

1. **Run the commands above** in order
2. **Test https://www.simondatalab.de/** in your browser
3. **Test https://moodle.simondatalab.de/moodle/** in your browser
4. **Purge Cloudflare cache** if needed
5. **Test all other services** to ensure they work correctly

---

## 🆘 **IF SOMETHING GOES WRONG**

```bash
# Restore from backup
sudo rm -rf /var/www/html
sudo mv /var/www/html.backup-* /var/www/html
sudo systemctl reload apache2
```

---

**🎯 This fix will resolve the redirect issue and properly separate your portfolio from Moodle!**
