# Monitoring Dashboard HTTPS Access Configuration

## ✅ COMPLETED: Grafana

**URL:** https://grafana.simondatalab.de  
**Status:** ✅ **WORKING** - Valid SSL certificate, secure HTTPS access

### Configuration
- **SSL Certificate:** Let's Encrypt (auto-renewing)
- **Certificate Path:** `/etc/letsencrypt/live/grafana.simondatalab.de/`
- **Nginx Config:** `/etc/nginx/sites-enabled/grafana-proxy.conf`
- **Backend:** http://10.0.0.104:3000 (VM 104)
- **DNS:** A record → 136.243.155.166 (DNS only mode)

### Test Result
```bash
curl -I https://grafana.simondatalab.de
# HTTP/2 302
# server: nginx/1.22.1
# strict-transport-security: max-age=31536000; includeSubDomains
```

## ⚠️ PENDING: Prometheus

**URL:** https://prometheus.simondatalab.de  
**Status:** ⏳ **PENDING DNS CHANGE**

### Current Issue
- **Current DNS:** CNAME → `a10f0734-57e8-439f-8d1d-ef7a1cf54da0.cfargotunnel.com` (Proxied)
- **Problem:** Cloudflare Tunnel blocked by firewall (TCP port 7844 timeout)
- **Solution:** Change to direct A record + Nginx reverse proxy

### Required DNS Change in Cloudflare

**ACTION REQUIRED:** Update Cloudflare DNS for `prometheus.simondatalab.de`

**Current:**
```
Type: CNAME
Name: prometheus
Content: a10f0734-57e8-439f-8d1d-ef7a1cf54da0.cfargotunnel.com
Proxy status: Proxied
```

**Change to:**
```
Type: A
Name: prometheus
Content: 136.243.155.166
Proxy status: Proxied (for DDoS protection)
TTL: Auto
```

### Steps After DNS Change

1. **Wait for DNS propagation** (2-5 minutes with Proxied status):
   ```bash
   dig prometheus.simondatalab.de
   # Should return Cloudflare IPs (proxied mode)
   ```

2. **Obtain SSL certificate** via SSH to Proxmox:
   ```bash
   ssh -p 2222 root@136.243.155.166
   certbot certonly --nginx -d prometheus.simondatalab.de \
       --non-interactive --agree-tos --email admin@simondatalab.de
   ```

3. **Enable Nginx site**:
   ```bash
   ln -sf /etc/nginx/sites-available/prometheus-proxy.conf \
          /etc/nginx/sites-enabled/prometheus-proxy.conf
   nginx -t && systemctl reload nginx
   ```

4. **Verify HTTPS access**:
   ```bash
   curl -I https://prometheus.simondatalab.de
   # Should return HTTP/2 302 with valid SSL
   ```

## Configuration Files

### Grafana Nginx Config
**Location:** `/etc/nginx/sites-enabled/grafana-proxy.conf`
- HTTP → HTTPS redirect (port 80 → 443)
- Let's Encrypt auto-renewal support
- WebSocket support for live features
- Security headers (HSTS, X-Frame-Options)

### Prometheus Nginx Config (Ready to Enable)
**Location:** `/etc/nginx/sites-available/prometheus-proxy.conf`
- HTTP → HTTPS redirect (port 80 → 443)
- Reverse proxy to http://127.0.0.1:9091
- Security headers (HSTS, X-Frame-Options)
- **Status:** Disabled (waiting for DNS + SSL certificate)

## Network Architecture

```
User Browser
    ↓
Cloudflare CDN (proxied A record)
    ↓
Hetzner Server (136.243.155.166)
    ↓
Nginx Reverse Proxy
    ├─→ Grafana: http://10.0.0.104:3000 (VM 104) ✅
    └─→ Prometheus: http://127.0.0.1:9091 (Proxmox host) ⏳
```

## Security Features

✅ **TLS 1.2/1.3** encryption  
✅ **HSTS** headers (force HTTPS)  
✅ **Let's Encrypt** auto-renewal  
✅ **Cloudflare DDoS** protection (Proxied mode)  
✅ **X-Frame-Options** (clickjacking protection)  
✅ **X-Content-Type-Options** (MIME sniffing protection)

## Troubleshooting

### Why Not Use Cloudflare Tunnel?

**Problem:** Hetzner dedicated server has firewall blocking TCP port 7844  
**Evidence:** `nc -zv 104.16.132.229 7844` → Connection timed out  
**Solution:** Direct Nginx reverse proxy with Let's Encrypt SSL

### SSL Certificate Renewal

Certbot auto-renewal is configured via systemd timer:
```bash
systemctl status certbot.timer
systemctl list-timers certbot
```

Certificates auto-renew 30 days before expiration.

## Access Summary

| Service | URL | Status | Backend |
|---------|-----|--------|---------|
| Grafana | https://grafana.simondatalab.de | ✅ Working | VM 104:3000 |
| Prometheus | https://prometheus.simondatalab.de | ⏳ DNS pending | Host:9091 |

## Next Steps

1. ✅ **Grafana:** Ready to use - login and configure dashboards
2. ⏳ **Prometheus DNS:** Change CNAME to A record in Cloudflare
3. 🔄 **After DNS:** Run certbot and enable Nginx site
4. 📊 **Configure:** Import Grafana dashboards and add Prometheus data source

---

**Last Updated:** October 16, 2025  
**Grafana Status:** ✅ **SECURE & ACCESSIBLE**  
**Prometheus Status:** ⏳ **DNS CHANGE REQUIRED**