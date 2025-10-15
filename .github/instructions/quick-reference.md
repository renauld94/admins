# 🔑 Quick Reference - Infrastructure Cheat Sheet

**Last Updated:** October 15, 2025

---

## 🚀 Quick Access

### SSH Access
```bash
ssh -p 2222 root@136.243.155.166
```

### Container 150 (Portfolio)
```bash
pct exec 150 -- bash
# or
ssh -p 2222 root@136.243.155.166 "pct exec 150 -- bash"
```

### VM 9001 (Moodle) - Console Only
```bash
ssh -p 2222 root@136.243.155.166 "qm console 9001"
```

---

## 📍 IP Addresses

| Service | External | Internal |
|---------|----------|----------|
| Proxmox Host | 136.243.155.166 | 10.0.0.1 |
| Portfolio (CT 150) | - | 10.0.0.150 |
| Moodle (VM 9001) | - | 10.0.0.104 |
| Jellyfin (CT 103) | - | 10.0.0.103 |

---

## 🔐 SSL Certificate Path

**⚠️ IMPORTANT:** All services use the SAME certificate path!

```bash
/etc/letsencrypt/live/ollama.simondatalab.de/fullchain.pem
/etc/letsencrypt/live/ollama.simondatalab.de/privkey.pem
```

**Why "ollama" path?**
- It's just a directory name (certbot's naming convention)
- The certificate covers ALL 8 domains (see SANs)
- Path could be renamed but it doesn't matter

**Certificate covers:**
- simondatalab.de
- www.simondatalab.de
- moodle.simondatalab.de
- grafana.simondatalab.de
- ollama.simondatalab.de
- mlflow.simondatalab.de
- booklore.simondatalab.de
- geoneuralviz.simondatalab.de

---

## ⚙️ Nginx Management

### Test Configuration
```bash
nginx -t
```

### Reload (No Downtime)
```bash
systemctl reload nginx
```

### Restart (Full Restart)
```bash
systemctl restart nginx
```

### View Active Configs
```bash
ls -la /etc/nginx/sites-enabled/
```

### Edit Moodle Config
```bash
nano /etc/nginx/sites-enabled/moodle.simondatalab.de.conf
```

---

## 🔥 IPTables Quick Commands

### View NAT Rules
```bash
iptables -t nat -L -n -v --line-numbers
```

### Save Current Rules
```bash
iptables-save > /etc/iptables/rules.v4
```

### Restore Rules
```bash
iptables-restore < /etc/iptables/rules.v4
```

### Delete Rule by Number
```bash
# Get line number first
iptables -t nat -L POSTROUTING -n --line-numbers

# Delete (example: line 10)
iptables -t nat -D POSTROUTING 10
```

---

## 📜 Certificate Management

### Check Certificate Expiry
```bash
certbot certificates
```

### Test Renewal
```bash
certbot renew --dry-run
```

### Force Renewal
```bash
certbot renew --force-renewal
```

### View Certificate SANs
```bash
openssl x509 -in /etc/letsencrypt/live/ollama.simondatalab.de/fullchain.pem -noout -text | grep -A 10 "Subject Alternative Name"
```

---

## 🐳 Container & VM Management

### Container 150 (Portfolio)
```bash
pct start 150      # Start
pct stop 150       # Stop
pct status 150     # Status
pct console 150    # Console access
pct exec 150 -- bash  # Execute command
```

### VM 9001 (Moodle)
```bash
qm start 9001      # Start
qm stop 9001       # Stop
qm status 9001     # Status
qm console 9001    # Console access
```

---

## 🌐 DNS Records (Cloudflare)

**Zone ID:** `8721a7620b0d4b0d29e926fda5525d23`  
**All point to:** `136.243.155.166`  
**Mode:** DNS-only (not proxied)  
**TTL:** 120 seconds

---

## 📂 Important File Locations

### Nginx Configs
```
/etc/nginx/sites-enabled/simondatalab-https.conf        (Portfolio)
/etc/nginx/sites-enabled/moodle.simondatalab.de.conf   (Moodle)
/etc/nginx/sites-enabled/000-auth-redirect.conf         (HTTP handler)
```

### SSL Certificates
```
/etc/letsencrypt/live/ollama.simondatalab.de/
/etc/letsencrypt/renewal/ollama.simondatalab.de.conf
/root/.secrets/cloudflare.ini
```

### Moodle Custom Assets
```
/var/www/moodle-assets/epic-course-theme.css
/var/www/moodle-assets/epic-course-interactive.js
```

### Portfolio Files (in Container 150)
```
/var/www/html/index.html
/var/www/html/styles.css
/var/www/html/neural-geoserver-styles.css
```

---

## 🔍 Troubleshooting Commands

### Test SSL Certificate
```bash
echo | openssl s_client -connect moodle.simondatalab.de:443 -servername moodle.simondatalab.de 2>/dev/null | grep -E "subject|issuer|Verify"
```

### Test Service Accessibility
```bash
curl -I https://www.simondatalab.de/
curl -I https://moodle.simondatalab.de/
curl -I https://moodle.simondatalab.de/epic-course-theme.css
```

### Check Internal Connectivity
```bash
curl -I http://10.0.0.150
curl -I http://10.0.0.104:9001
```

### View Nginx Error Logs
```bash
tail -100 /var/log/nginx/error.log
tail -f /var/log/nginx/access.log
```

### Check Open Ports
```bash
ss -tlnp
netstat -tlnp
```

---

## 🔄 Update Workflow

### Update Moodle Theme Files
```bash
# 1. Edit locally
cd /home/simon/Learning-Management-System-Academy/learning-platform/
nano epic-course-theme.css

# 2. Upload to server
scp -P 2222 epic-course-theme.css root@136.243.155.166:/var/www/moodle-assets/

# 3. No nginx reload needed (static files)
# Just clear browser cache
```

### Update Portfolio
```bash
# 1. Edit locally
nano /home/simon/Learning-Management-System-Academy/portfolio-deployment-enhanced/index.html

# 2. Upload to Container 150
scp -P 2222 index.html root@136.243.155.166:/tmp/
ssh -p 2222 root@136.243.155.166 "pct exec 150 -- bash -c 'cp /tmp/index.html /var/www/html/'"
```

### Update Nginx Config
```bash
# 1. Backup current config
ssh -p 2222 root@136.243.155.166 'cp /etc/nginx/sites-enabled/moodle.simondatalab.de.conf /etc/nginx/sites-enabled/moodle.simondatalab.de.conf.backup-$(date +%Y%m%d-%H%M%S)'

# 2. Edit config
ssh -p 2222 root@136.243.155.166 'nano /etc/nginx/sites-enabled/moodle.simondatalab.de.conf'

# 3. Test and reload
ssh -p 2222 root@136.243.155.166 'nginx -t && systemctl reload nginx'
```

---

## ⚡ Emergency Recovery

### Restore Previous Nginx Config
```bash
# List backups
ssh -p 2222 root@136.243.155.166 'ls -lt /etc/nginx/sites-enabled/*.backup-*'

# Restore (example)
ssh -p 2222 root@136.243.155.166 'cp /etc/nginx/sites-enabled/moodle.simondatalab.de.conf.backup-20251015-022822 /etc/nginx/sites-enabled/moodle.simondatalab.de.conf && nginx -t && systemctl reload nginx'
```

### Restore IPTables
```bash
ssh -p 2222 root@136.243.155.166 'iptables-restore < /etc/iptables/rules.v4'
```

### Restart Container/VM
```bash
# Container 150
ssh -p 2222 root@136.243.155.166 'pct restart 150'

# VM 9001
ssh -p 2222 root@136.243.155.166 'qm restart 9001'
```

---

## 📊 Health Check Script

```bash
#!/bin/bash
# Save as: health-check.sh

echo "=== SSL Certificates ==="
ssh -p 2222 root@136.243.155.166 'certbot certificates | grep -E "Certificate Name|Expiry Date"'

echo -e "\n=== Nginx Status ==="
ssh -p 2222 root@136.243.155.166 'systemctl status nginx | grep -E "Active|loaded"'

echo -e "\n=== Container 150 Status ==="
ssh -p 2222 root@136.243.155.166 'pct status 150'

echo -e "\n=== VM 9001 Status ==="
ssh -p 2222 root@136.243.155.166 'qm status 9001'

echo -e "\n=== Test HTTPS ==="
curl -sI https://www.simondatalab.de/ | grep -E "HTTP|Server"
curl -sI https://moodle.simondatalab.de/ | grep -E "HTTP|Server"

echo -e "\n=== Disk Space ==="
ssh -p 2222 root@136.243.155.166 'df -h | grep -E "Filesystem|vmbr0|/$"'

echo -e "\n✅ Health check complete!"
```

---

## 📞 Common Issues & Solutions

### Issue: 404 on CSS/JS Files
**Solution:**
```bash
# Check files exist
ssh -p 2222 root@136.243.155.166 'ls -lh /var/www/moodle-assets/'

# Check nginx config
ssh -p 2222 root@136.243.155.166 'nginx -t'

# Reload nginx
ssh -p 2222 root@136.243.155.166 'systemctl reload nginx'
```

### Issue: SSL Certificate Error
**Solution:**
```bash
# Check certificate validity
ssh -p 2222 root@136.243.155.166 'certbot certificates'

# Renew if needed
ssh -p 2222 root@136.243.155.166 'certbot renew --force-renewal'

# Reload nginx
ssh -p 2222 root@136.243.155.166 'systemctl reload nginx'
```

### Issue: Service Not Accessible
**Solution:**
```bash
# Check if container/VM is running
ssh -p 2222 root@136.243.155.166 'pct status 150'
ssh -p 2222 root@136.243.155.166 'qm status 9001'

# Check nginx is running
ssh -p 2222 root@136.243.155.166 'systemctl status nginx'

# Check iptables rules
ssh -p 2222 root@136.243.155.166 'iptables -t nat -L -n -v'
```

---

**For detailed documentation, see:**
- `infrastructure-configuration.md` (full details)
- `MOODLE_THEME_DEPLOYMENT.md` (theme info)
- `DEPLOYMENT_STATUS.md` (deployment history)
