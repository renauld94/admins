# SimonDataLab.de HTTPS Fix Summary
**Date:** November 3, 2025  
**Issue:** https://www.simondatalab.de returns 521 error (Web server down)  
**Root Cause:** Origin (CT 10.0.0.150) nginx not listening on port 443

---

## ✅ What's Been Fixed

### 1. NAT/Firewall (pve - Proxmox Host)
- **DNAT Rules Added:** Traffic on public IP 136.243.155.166:80/443 → CT 10.0.0.150:80/443
- **FORWARD Rules:** Allow forwarding to 10.0.0.150 ports 80/443
- **Old Rules Removed:** Previous DNAT to 192.168.100.101 removed
- **Hetzner Firewall:** ✅ Active, allows ports 80/443 (rule #1 "Proxmox")

### 2. Origin CT (10.0.0.150 - portfolio-web-1000150)
- **HTTP (Port 80):** ✅ Working - nginx listening, returns 200 OK
- **HTTPS (Port 443):** ❌ NOT configured - nginx not listening on 443
- **No SSL Certificates:** No Let's Encrypt or other certs present

### 3. Cloudflare
- **Zone ID:** 8721a7620b0d4b0d29e926fda5525d23
- **Domain:** simondatalab.de
- **API Token:** Valid but lacks SSL settings edit permission
- **Current Status:** 
  - HTTP → 301 redirect to HTTPS ✅
  - HTTPS → 521 error (can't connect to origin) ❌

---

## 🔧 Required Actions

### Option A: Cloudflare Flexible SSL (Quickest - RECOMMENDED)
This allows Cloudflare to serve HTTPS to visitors while using HTTP to connect to origin.

**Steps (via Cloudflare Dashboard):**
1. Log in to https://dash.cloudflare.com
2. Select domain: **simondatalab.de**
3. Go to **SSL/TLS** → **Overview**
4. Change SSL/TLS encryption mode from "Full" to **"Flexible"**
5. Wait 1-2 minutes for propagation
6. Test: `curl -I https://www.simondatalab.de` should return 200 OK

**Security Note:** Cloudflare→Origin traffic uses HTTP. For sensitive data, use Option B.

---

### Option B: Add HTTPS to Origin (More Secure)
Configure nginx on CT 10.0.0.150 to listen on port 443 with SSL.

**SSH to origin:**
```bash
ssh -A -J root@136.243.155.166:2222 root@10.0.0.150
```

**1. Create self-signed certificate (quick, works with Cloudflare):**
```bash
mkdir -p /etc/nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/simondatalab.key \
  -out /etc/nginx/ssl/simondatalab.crt \
  -subj '/CN=www.simondatalab.de/O=SimonDataLab/C=DE'
chmod 600 /etc/nginx/ssl/simondatalab.key
chmod 644 /etc/nginx/ssl/simondatalab.crt
```

**2. Update nginx config:**
Edit `/etc/nginx/sites-enabled/default`:
```bash
nano /etc/nginx/sites-enabled/default
```

Add this server block (or modify existing):
```nginx
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;

    ssl_certificate /etc/nginx/ssl/simondatalab.crt;
    ssl_certificate_key /etc/nginx/ssl/simondatalab.key;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    root /var/www/html;
    index index.html index.htm;

    server_name www.simondatalab.de simondatalab.de;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-XSS-Protection "1; mode=block";
}
```

**3. Test and reload nginx:**
```bash
nginx -t
systemctl reload nginx
ss -tulpn | grep :443   # Should show nginx listening
```

**4. Update Cloudflare SSL mode to "Full":**
- Dashboard → SSL/TLS → Overview → **"Full"** (accepts self-signed certs)

**5. Test:**
```bash
curl -I https://www.simondatalab.de
```

---

### Option C: Let's Encrypt Certificate (Most Secure - Production Ready)
Use certbot to get a valid certificate.

**Prerequisites:** DNS must resolve to the origin for ACME challenge.

```bash
ssh -A -J root@136.243.155.166:2222 root@10.0.0.150

# Install certbot
apt-get update
apt-get install -y certbot python3-certbot-nginx

# Get certificate (certbot will auto-configure nginx)
certbot --nginx -d www.simondatalab.de -d simondatalab.de --non-interactive --agree-tos --email sn.renauld@gmail.com

# Test renewal
certbot renew --dry-run
```

Then set Cloudflare SSL/TLS mode to **"Full (strict)"**.

---

## 🧪 Testing Commands

### From pve (Proxmox host):
```bash
# Test origin directly
curl -I http://10.0.0.150
curl -I https://10.0.0.150 -k  # -k accepts self-signed

# Check DNAT rules
sudo iptables -t nat -L PREROUTING --line-numbers -n -v
sudo iptables -L FORWARD -n -v --line-numbers | head -20
```

### From your workstation:
```bash
# Test public site
curl -I http://www.simondatalab.de     # Should 301 to HTTPS
curl -I https://www.simondatalab.de    # Should 200 OK
```

---

## 📋 Current NAT Configuration (pve)

**PREROUTING (DNAT):**
```
1. tcp dpt:443 → 10.0.0.150:443  (vmbr0)
2. tcp dpt:80  → 10.0.0.150:80   (vmbr0)
```

**FORWARD:**
```
1. ACCEPT tcp → 10.0.0.150 multiport dports 80,443
```

---

## 🔐 Cloudflare Settings (Manual - Dashboard)

Your API token lacks permission for these settings. Apply via Dashboard:

1. **SSL/TLS Mode:**
   - Path: SSL/TLS → Overview
   - Set to: **Flexible** (Option A) or **Full** (Option B)

2. **Always Use HTTPS:**
   - Path: SSL/TLS → Edge Certificates
   - Toggle: **ON**

3. **Automatic HTTPS Rewrites:**
   - Path: SSL/TLS → Edge Certificates
   - Toggle: **ON**

4. **Purge Cache:**
   - Path: Caching → Configuration
   - Click: **Purge Everything**

---

## 💾 Persist iptables Rules (pve)

After verifying everything works:

```bash
# Option 1: iptables-persistent
sudo apt-get install -y iptables-persistent
sudo netfilter-persistent save

# Option 2: Manual save
sudo iptables-save > /etc/iptables/rules.v4
```

---

## 🎯 Recommended Next Steps (In Order)

1. ✅ **Choose Option A (Flexible SSL)** - Set in Cloudflare Dashboard (fastest fix)
2. ⏱️ **Wait 2 minutes** for Cloudflare propagation
3. 🧪 **Test:** `curl -I https://www.simondatalab.de`
4. ✅ **Enable "Always Use HTTPS"** in Cloudflare Dashboard
5. ✅ **Enable "Automatic HTTPS Rewrites"** in Cloudflare Dashboard
6. 🗑️ **Purge Cloudflare cache**
7. 💾 **Persist iptables on pve** (optional but recommended)
8. 🔄 **Later:** Upgrade to Let's Encrypt (Option C) for production security

---

## 🐛 Troubleshooting

### Still getting 521?
- Check Cloudflare SSL/TLS mode matches your origin config
- Verify origin nginx is listening: `ssh ... root@10.0.0.150 'ss -tulpn | grep 443'`
- Check Cloudflare cache: purge and retry

### Connection timeout from Cloudflare?
- Verify DNAT on pve: `sudo iptables -t nat -L PREROUTING -n -v`
- Check Hetzner firewall allows 80/443 (already verified ✅)
- Ping origin from pve: `ping 10.0.0.150`

### Certificate errors?
- If using self-signed: Cloudflare SSL mode must be "Full" (not "Full strict")
- If using Let's Encrypt: SSL mode should be "Full (strict)"

---

## 📞 Support Commands

```bash
# Check all services on origin
ssh -A -J root@136.243.155.166:2222 root@10.0.0.150 'systemctl status nginx && ss -tulpn | egrep ":80|:443"'

# View nginx error log
ssh -A -J root@136.243.155.166:2222 root@10.0.0.150 'tail -n 50 /var/log/nginx/error.log'

# Check NAT on pve
sudo iptables -t nat -L -n -v
sudo iptables -L FORWARD -n -v

# Test Cloudflare edge
curl -vI https://www.simondatalab.de 2>&1 | grep -E 'HTTP|cf-|server:'
```

---

**Status:** DNAT configured ✅ | Origin HTTP working ✅ | HTTPS pending Cloudflare SSL mode change 🔄
