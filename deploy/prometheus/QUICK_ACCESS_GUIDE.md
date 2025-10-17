# 🎯 Monitoring Dashboard Access - Quick Guide

## ✅ GRAFANA - READY TO USE

**Access URL:** <https://grafana.simondatalab.de>

**Status:** ✅ **FULLY WORKING** - Secure HTTPS with valid SSL certificate

### How to Access
1. Open browser: <https://grafana.simondatalab.de>
2. Login with Grafana credentials
3. Add Prometheus data source:
   - URL: `http://localhost:9091`
   - Click "Save & Test"
4. Import dashboards:
   - Node Exporter Full: Dashboard ID `1860`
   - Docker Containers: Dashboard ID `179`

---

## ⚠️ PROMETHEUS - ACTION REQUIRED

**Access URL:** <https://prometheus.simondatalab.de>

**Status:** ⏳ **DNS CHANGE NEEDED**

### Required Action in Cloudflare Dashboard

Go to: <https://dash.cloudflare.com> → simondatalab.de → DNS

**Find this record:**
| Type | Name | Content | Status |
|------|------|---------|--------|
| CNAME | prometheus | a10f0734-57e8-439f-8d1d-ef7a1cf54da0.cfargotunnel.com | Proxied |

**Delete it and create:**
| Type | Name | Content | Status |
|------|------|---------|--------|
| A | prometheus | 136.243.155.166 | Proxied ✅ |

### After DNS Change - Run These Commands

```bash
# SSH to Proxmox
ssh -p 2222 root@136.243.155.166

# Obtain SSL certificate
certbot certonly --nginx -d prometheus.simondatalab.de \
    --non-interactive --agree-tos --email admin@simondatalab.de

# Enable Nginx site
ln -sf /etc/nginx/sites-available/prometheus-proxy.conf \
       /etc/nginx/sites-enabled/prometheus-proxy.conf

# Test and reload
nginx -t && systemctl reload nginx

# Test HTTPS (from your local machine)
curl -I https://prometheus.simondatalab.de
```

---

## 📊 Configuration Summary

### What's Working Now

✅ **Grafana HTTPS:** Nginx reverse proxy → VM 104:3000  
✅ **SSL Certificates:** Let's Encrypt auto-renewal enabled  
✅ **Security Headers:** HSTS, X-Frame-Options, CSP  
✅ **Cloudflare Protection:** DDoS mitigation active

### What's Pending

⏳ **Prometheus DNS:** CNAME → A record change required  
⏳ **Prometheus SSL:** Certificate will be issued after DNS update  
⏳ **Prometheus Nginx:** Config ready, waiting for SSL cert

---

## 🔒 Security Status

Both services will have:
- ✅ **TLS 1.2/1.3** encryption
- ✅ **HSTS** headers (force HTTPS)
- ✅ **Cloudflare DDoS** protection
- ✅ **Let's Encrypt** auto-renewal
- ✅ **No "Not Secure" warnings** in browser

---

## 🎉 Quick Access Links

**Grafana:** <https://grafana.simondatalab.de> ✅ **READY NOW**

**Prometheus:** <https://prometheus.simondatalab.de> ⏳ **AFTER DNS CHANGE**

---

## Need Help?

All configuration details: `/deploy/prometheus/HTTPS_ACCESS_CONFIGURATION.md`

Full infrastructure audit: `/PROXMOX_AI_INFRASTRUCTURE_AUDIT_REPORT.md`