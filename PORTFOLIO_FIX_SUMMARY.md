# 🚨 PORTFOLIO REDIRECT FIX - COMPLETE SOLUTION

## ❌ **CURRENT ISSUE CONFIRMED**
Your website [https://www.simondatalab.de/](https://www.simondatalab.de/) is **redirecting to Moodle** instead of showing your portfolio.

**Evidence:**
```
HTTP/2 303 
location: https://moodle.simondatalab.de/
x-redirect-by: Moodle
```

## 🔧 **IMMEDIATE FIX REQUIRED**

### **Step 1: Fix NGINX Configuration on CT 150**

Connect to your CT 150 server and run these commands:

```bash
# Connect to CT 150
ssh -J root@136.243.155.166 simonadmin@10.0.0.150

# Backup current config
sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup

# Create correct configuration
sudo tee /etc/nginx/sites-available/default > /dev/null << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name simondatalab.de www.simondatalab.de;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name simondatalab.de www.simondatalab.de;
    
    ssl_certificate /etc/letsencrypt/live/simondatalab.de/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/simondatalab.de/privkey.pem;
    
    root /var/www/html;
    index index.html index.htm;
    
    location / {
        try_files $uri $uri/ =404;
    }
    
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name moodle.simondatalab.de;
    
    ssl_certificate /etc/letsencrypt/live/simondatalab.de/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/simondatalab.de/privkey.pem;
    
    root /var/www/moodle;
    index index.php;
    
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
    
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }
}
EOF

# Test and reload
sudo nginx -t && sudo systemctl reload nginx
```

### **Step 2: Purge Cloudflare Cache**

After fixing NGINX, purge the Cloudflare cache:

```bash
# Run the automated purge script
bash scripts/cloudflare_purge_api.sh
```

**Or manually via Cloudflare Dashboard:**
1. Go to [https://dash.cloudflare.com/](https://dash.cloudflare.com/)
2. Select domain: `simondatalab.de`
3. Go to **Caching** → **Configuration**
4. Click **"Purge Everything"**

## 📋 **COMPLETE SOLUTION FILES**

I've created these files for you:

1. **`MANUAL_PORTFOLIO_FIX.md`** - Detailed manual fix instructions
2. **`scripts/cloudflare_purge_api.sh`** - Automated Cloudflare cache purge
3. **`scripts/fix_portfolio_redirect.sh`** - Complete fix script (needs to be run on CT 150)

## 🎯 **EXPECTED RESULTS AFTER FIX**

- ✅ **Portfolio**: https://www.simondatalab.de/ → Shows your portfolio
- ✅ **Moodle**: https://moodle.simondatalab.de/ → Shows Moodle LMS  
- ✅ **No redirects** between the two
- ✅ **Both working** with proper SSL certificates

## 🚀 **QUICK EXECUTION**

**Option 1: Manual Fix (Recommended)**
```bash
# 1. Connect to CT 150
ssh -J root@136.243.155.166 simonadmin@10.0.0.150

# 2. Run the fix commands above

# 3. Purge Cloudflare cache
bash scripts/cloudflare_purge_api.sh
```

**Option 2: Automated Fix**
```bash
# Copy fix script to CT 150 and run
scp scripts/fix_portfolio_redirect.sh ct150:/tmp/
ssh ct150 "sudo bash /tmp/fix_portfolio_redirect.sh"

# Purge Cloudflare cache
bash scripts/cloudflare_purge_api.sh
```

## ⚠️ **CRITICAL NOTES**

1. **The redirect is in NGINX configuration** - it's sending all traffic to Moodle
2. **You MUST purge Cloudflare cache** after fixing NGINX
3. **Both domains will work** after the fix (portfolio and Moodle)
4. **Backup is created** before making changes

## 🔍 **VERIFICATION**

After the fix, test:
```bash
# Should show portfolio content (no redirect)
curl -I https://www.simondatalab.de/

# Should show Moodle content
curl -I https://moodle.simondatalab.de/
```

---

**Status**: Ready for execution  
**Priority**: HIGH - Portfolio is not accessible  
**Estimated Time**: 5-10 minutes
