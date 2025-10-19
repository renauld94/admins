# CT 150 Portfolio Website Update Guide

## 🌐 Portfolio Website: [https://www.simondatalab.de/](https://www.simondatalab.de/)

Your CT 150 server hosts your **professional portfolio website**, not the Moodle LMS. This guide will help you update and maintain your portfolio.

## 📋 Current Portfolio Status

Based on the website analysis, your portfolio includes:
- **Professional Learning Platform** with various courses
- **Vietnamese Language Mastery** course
- **Simon Renauld** portfolio content
- **Course offerings**: MLFlow, Clinical Programming, Data Engineering, etc.

## 🚀 Quick Update Commands

### Connect to CT 150 Server
```bash
# Direct connection via proxy jump
ssh -J root@136.243.155.166 simonadmin@10.0.0.150

# Or two-step connection
ssh root@136.243.155.166
ssh simonadmin@10.0.0.150
```

### Run Portfolio Update Script
```bash
# Copy script to CT 150
scp ct150_portfolio_fix.sh ct150:/tmp/

# Connect and run update
ssh ct150
sudo bash /tmp/ct150_portfolio_fix.sh
```

### Purge Cloudflare Cache
```bash
# Run cache purge script
bash purge_cloudflare_cache.sh

# Or manually via Cloudflare dashboard
# https://dash.cloudflare.com/ → Caching → Purge Everything
```

## 🔧 What the Portfolio Update Script Does

### Website File Checks
- ✅ Verifies `/var/www/html/index.html` exists
- ✅ Checks for portfolio-specific content (Simon Renauld)
- ✅ Validates CSS files (`professional-portfolio.css`, `legacy-theme-overrides.css`)
- ✅ Checks JavaScript files (`app.js`, `hero-performance.js`)
- ✅ Verifies assets directory and files
- ✅ Confirms resume PDF is present

### NGINX Configuration
- ✅ Checks NGINX status and configuration
- ✅ Updates Cloudflare IP ranges automatically
- ✅ Configures real IP headers for Cloudflare
- ✅ Reloads NGINX configuration

### SSL & Security
- ✅ Verifies SSL certificates for simondatalab.de
- ✅ Checks certificate expiry dates
- ✅ Reviews firewall and port rules
- ✅ Validates NAT configuration

### Performance & Monitoring
- ✅ Checks system performance metrics
- ✅ Analyzes NGINX access and error logs
- ✅ Monitors disk space and memory usage
- ✅ Verifies website responsiveness

## 🌐 Cloudflare Integration

### Automatic Configuration
The script automatically:
- Downloads latest Cloudflare IP ranges
- Configures NGINX to trust Cloudflare IPs
- Sets up proper real IP headers
- Ensures correct client IP detection

### Cache Management
```bash
# Purge entire cache
curl -X POST "https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/purge_cache" \
     -H "X-Auth-Email: sn.renauld@gmail.com" \
     -H "X-Auth-Key: YOUR_API_KEY" \
     -H "Content-Type: application/json" \
     --data '{"purge_everything":true}'

# Purge specific files
curl -X POST "https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/purge_cache" \
     -H "X-Auth-Email: sn.renauld@gmail.com" \
     -H "X-Auth-Key: YOUR_API_KEY" \
     -H "Content-Type: application/json" \
     --data '{"files":["https://www.simondatalab.de/", "https://www.simondatalab.de/index.html"]}'
```

## 🔍 Troubleshooting Portfolio Issues

### Website Not Loading
```bash
# Check local access
curl -I http://localhost
curl -I https://localhost

# Check external access
curl -I https://www.simondatalab.de/

# Check NGINX status
systemctl status nginx
```

### Wrong Content Displayed
If you see Moodle content instead of your portfolio:
```bash
# Check which index.html is being served
ls -la /var/www/html/index.html
head -20 /var/www/html/index.html

# Check NGINX configuration
cat /etc/nginx/sites-available/default
```

### Missing Assets
```bash
# Check for missing files
ls -la /var/www/html/
ls -la /var/www/html/assets/

# Check file permissions
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/
```

### SSL Certificate Issues
```bash
# Check certificate status
openssl x509 -in /etc/letsencrypt/live/simondatalab.de/fullchain.pem -noout -dates

# Renew if needed
certbot renew --dry-run
```

## 📊 Portfolio Content Structure

Your portfolio should have these key files:
```
/var/www/html/
├── index.html                    # Main portfolio page
├── professional-portfolio.css    # Portfolio styling
├── legacy-theme-overrides.css    # Theme overrides
├── app.js                       # Portfolio JavaScript
├── hero-performance.js          # Performance scripts
├── assets/                      # Images and assets
│   ├── jnj-logo.svg
│   └── additional.scss
└── Simon_Renauld_Data_Engineering_Analytics_Lead.pdf
```

## 🚨 Emergency Procedures

### If Portfolio is Down
```bash
# Quick restart
systemctl restart nginx

# Check logs
tail -f /var/log/nginx/error.log

# Restore from backup
cp -r /var/backups/website-backup-*/ /var/www/html/
```

### If Wrong Content Shows
```bash
# Check NGINX configuration
nginx -t
cat /etc/nginx/sites-available/default

# Restart NGINX
systemctl reload nginx
```

### If SSL Issues
```bash
# Check certificate
openssl x509 -in /etc/letsencrypt/live/simondatalab.de/fullchain.pem -noout -text

# Renew certificate
certbot renew
systemctl reload nginx
```

## 📈 Performance Optimization

### NGINX Optimization
```nginx
# Add to /etc/nginx/nginx.conf
gzip on;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
gzip_min_length 1000;

# Add caching headers
location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### Cloudflare Settings
- Enable **Auto Minify** for CSS, JS, and HTML
- Enable **Brotli Compression**
- Set **Browser Cache TTL** to 1 month
- Enable **Rocket Loader** for JavaScript

## 🔄 Regular Maintenance

### Daily Checks
- [ ] Website loads correctly
- [ ] All assets load properly
- [ ] No errors in logs

### Weekly Checks
- [ ] SSL certificate status
- [ ] Cloudflare cache status
- [ ] System performance metrics

### Monthly Checks
- [ ] Update Cloudflare IP ranges
- [ ] Review security logs
- [ ] Check disk space usage
- [ ] Test backup procedures

## 📞 Support Information

- **Portfolio Website**: [https://www.simondatalab.de/](https://www.simondatalab.de/)
- **Server**: CT 150 (portfolio-web-1000150)
- **Proxmox Node**: pve
- **Admin**: Simon Renauld (sn.renauld@gmail.com)

---

**Last Updated**: $(date)  
**Script Version**: 1.0  
**Status**: Ready for portfolio updates
