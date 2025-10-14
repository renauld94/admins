# 🔧 MANUAL PORTFOLIO REDIRECT FIX

## 🚨 **URGENT: Portfolio Redirect Issue**

Your website [https://www.simondatalab.de/](https://www.simondatalab.de/) is redirecting to Moodle instead of showing your portfolio.

## 📋 **Manual Fix Steps**

### Step 1: Connect to CT 150 Server

```bash
# Method 1: Direct connection via proxy jump
ssh -J root@136.243.155.166 simonadmin@10.0.0.150

# Method 2: Two-step connection
ssh root@136.243.155.166
ssh simonadmin@10.0.0.150

# Method 3: Proxmox Console
# Go to https://136.243.155.166:8006
# Login to Proxmox
# Go to CT 1000150 (portfolio-web)
# Click Console
```

### Step 2: Backup Current Configuration

```bash
# Create backup
sudo mkdir -p /var/backups/nginx-$(date +%Y%m%d_%H%M%S)
sudo cp -r /etc/nginx/ /var/backups/nginx-$(date +%Y%m%d_%H%M%S)/
```

### Step 3: Check Current NGINX Configuration

```bash
# View current configuration
sudo cat /etc/nginx/sites-available/default

# Search for redirect rules
sudo grep -r "moodle.simondatalab.de" /etc/nginx/
```

### Step 4: Fix NGINX Configuration

```bash
# Create the correct NGINX configuration
sudo tee /etc/nginx/sites-available/default > /dev/null << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name simondatalab.de www.simondatalab.de;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name simondatalab.de www.simondatalab.de;
    
    # SSL configuration
    ssl_certificate /etc/letsencrypt/live/simondatalab.de/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/simondatalab.de/privkey.pem;
    
    # SSL settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Root directory
    root /var/www/html;
    index index.html index.htm;
    
    # Main location block
    location / {
        try_files $uri $uri/ =404;
        
        # Cache static assets
        location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
            expires 1y;
            add_header Cache-Control "public, immutable";
            add_header Vary "Accept-Encoding";
        }
        
        # Cache HTML files for shorter period
        location ~* \.html$ {
            expires 1h;
            add_header Cache-Control "public";
        }
    }
    
    # Handle PDF files
    location ~* \.pdf$ {
        expires 1y;
        add_header Cache-Control "public";
        add_header Content-Disposition "inline";
    }
    
    # Security: Deny access to hidden files
    location ~ /\. {
        deny all;
    }
    
    # Security: Deny access to backup files
    location ~ ~$ {
        deny all;
    }
    
    # Logging
    access_log /var/log/nginx/simondatalab_access.log;
    error_log /var/log/nginx/simondatalab_error.log;
}

# Moodle server (separate subdomain)
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name moodle.simondatalab.de;
    
    # SSL configuration
    ssl_certificate /etc/letsencrypt/live/simondatalab.de/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/simondatalab.de/privkey.pem;
    
    # SSL settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Moodle root (adjust path as needed)
    root /var/www/moodle;
    index index.php index.html index.htm;
    
    # PHP handling
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
    
    # Moodle specific configuration
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
    
    # Logging
    access_log /var/log/nginx/moodle_access.log;
    error_log /var/log/nginx/moodle_error.log;
}
EOF
```

### Step 5: Test NGINX Configuration

```bash
# Test configuration
sudo nginx -t

# If successful, reload NGINX
sudo systemctl reload nginx
```

### Step 6: Ensure Portfolio Files Exist

```bash
# Check if portfolio files exist
ls -la /var/www/html/

# If index.html doesn't exist or is wrong, create/copy it
# You may need to copy your portfolio files to /var/www/html/
```

### Step 7: Set Correct Permissions

```bash
# Set correct ownership and permissions
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
```

### Step 8: Test the Fix

```bash
# Test local access
curl -I http://localhost

# Test external access
curl -I https://www.simondatalab.de/

# Check if redirect is gone
curl -s -I https://www.simondatalab.de/ | grep -i "location:" || echo "No redirect found"
```

## 🌐 **Cloudflare Cache Purge (Required After Fix)**

After fixing the NGINX configuration, you MUST purge the Cloudflare cache:

### Option 1: Cloudflare Dashboard
1. Go to [https://dash.cloudflare.com/](https://dash.cloudflare.com/)
2. Select your domain: `simondatalab.de`
3. Go to **Caching** → **Configuration**
4. Click **"Purge Everything"**

### Option 2: Cloudflare API (Automated)
```bash
# Get your Zone ID and API Token from Cloudflare dashboard
ZONE_ID="YOUR_ZONE_ID"
API_TOKEN="YOUR_API_TOKEN"

# Purge everything
curl -X POST "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/purge_cache" \
     -H "Authorization: Bearer $API_TOKEN" \
     -H "Content-Type: application/json" \
     --data '{"purge_everything":true}'
```

## ✅ **Expected Results After Fix**

- **Portfolio**: https://www.simondatalab.de/ → Shows your portfolio
- **Moodle**: https://moodle.simondatalab.de/ → Shows Moodle LMS
- **No redirects** between the two
- **Both working** with proper SSL certificates

## 🚨 **If Something Goes Wrong**

### Restore Previous Configuration
```bash
# Restore from backup
sudo cp -r /var/backups/nginx-*/nginx/* /etc/nginx/
sudo systemctl reload nginx
```

### Check Logs
```bash
# Check NGINX error logs
sudo tail -f /var/log/nginx/error.log

# Check NGINX access logs
sudo tail -f /var/log/nginx/access.log
```

## 📞 **Support**

If you need help with any of these steps, the key points are:
1. **Remove redirect** from NGINX config
2. **Separate domains**: `www.simondatalab.de` for portfolio, `moodle.simondatalab.de` for Moodle
3. **Purge Cloudflare cache** after making changes
4. **Test both domains** to ensure they work correctly

---

**Last Updated**: $(date)  
**Status**: Ready for manual execution
