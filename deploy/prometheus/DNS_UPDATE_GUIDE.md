# Prometheus DNS Update via Cloudflare API

## Step 1: Set Your Cloudflare API Token

You need a Cloudflare API token with DNS edit permissions.

### Get Your API Token

1. Go to: <https://dash.cloudflare.com/profile/api-tokens>
2. Click "Create Token"
3. Use template: **Edit zone DNS**
4. Zone Resources: **Include** → **Specific zone** → **simondatalab.de**
5. Click "Continue to summary" → "Create Token"
6. **Copy the token** (you'll only see it once!)

### Set Environment Variables

```bash
# Set your Cloudflare API token
export CLOUDFLARE_API_TOKEN='your_token_here'

# Optional: Set zone ID (script will auto-detect if not set)
export CLOUDFLARE_ZONE_ID='your_zone_id_here'
```

## Step 2: Install Required Python Package

```bash
pip install requests
```

## Step 3: Run the DNS Update Script

```bash
cd /home/simon/Learning-Management-System-Academy/deploy/prometheus
python3 update_prometheus_dns.py
```

### What the Script Does

1. ✅ Connects to Cloudflare API
2. ✅ Finds the `prometheus.simondatalab.de` CNAME record
3. ✅ Shows you current vs new configuration
4. ⚠️  **Asks for confirmation before making changes**
5. ✅ Deletes old CNAME record
6. ✅ Creates new A record pointing to `136.243.155.166`
7. ✅ Enables Cloudflare proxy (DDoS protection)

### Expected Output

```
🚀 Cloudflare DNS Update: prometheus.simondatalab.de
============================================================
✅ Found zone ID: abc123...

📋 Current DNS Record:
   Type: CNAME
   Name: prometheus.simondatalab.de
   Content: a10f0734-57e8-439f-8d1d-ef7a1cf54da0.cfargotunnel.com
   Proxied: True
   ID: xyz789...

⚠️  About to delete CNAME and create A record
   Old: CNAME → a10f0734-57e8-439f-8d1d-ef7a1cf54da0.cfargotunnel.com
   New: A → 136.243.155.166 (Proxied: True)

Proceed? (yes/no): yes

✅ Deleted old CNAME record

✅ Created new A record:
   Type: A
   Name: prometheus.simondatalab.de
   Content: 136.243.155.166
   Proxied: True
   TTL: Auto

🎉 DNS update complete!
```

## Step 4: Wait for DNS Propagation

```bash
# Check DNS propagation (should show Cloudflare IPs due to proxy)
dig prometheus.simondatalab.de

# Check from Cloudflare's DNS
dig prometheus.simondatalab.de @1.1.1.1
```

DNS should update within 2-5 minutes.

## Step 5: Configure SSL Certificate on Proxmox

```bash
# SSH to Proxmox host
ssh -p 2222 root@136.243.155.166

# Run the automated setup script
bash /root/setup_prometheus_https.sh
```

Or run manually:

```bash
# Obtain SSL certificate
certbot certonly --nginx -d prometheus.simondatalab.de \
    --non-interactive --agree-tos --email admin@simondatalab.de

# Enable Nginx site
ln -sf /etc/nginx/sites-available/prometheus-proxy.conf \
       /etc/nginx/sites-enabled/prometheus-proxy.conf

# Test and reload
nginx -t && systemctl reload nginx
```

## Step 6: Verify HTTPS Access

```bash
# Test from your local machine
curl -I https://prometheus.simondatalab.de

# Should return:
# HTTP/2 302
# server: nginx/1.22.1
# strict-transport-security: max-age=31536000
```

## Troubleshooting

### Script Fails with "unauthorized"

- Check your API token is correct
- Ensure token has **DNS Edit** permissions for **simondatalab.de**

### DNS Not Propagating

- Wait up to 5 minutes
- Clear DNS cache: `sudo systemd-resolve --flush-caches`
- Check with: `dig prometheus.simondatalab.de @1.1.1.1`

### Certbot Fails

- Ensure DNS is fully propagated first
- Check: `dig prometheus.simondatalab.de` points to 136.243.155.166 (or Cloudflare IPs if proxied)
- View logs: `tail -f /var/log/letsencrypt/letsencrypt.log`

---

## Quick Command Summary

```bash
# 1. Set API token
export CLOUDFLARE_API_TOKEN='your_token_here'

# 2. Update DNS
cd /home/simon/Learning-Management-System-Academy/deploy/prometheus
python3 update_prometheus_dns.py

# 3. Wait 2-5 minutes, then SSH to Proxmox
ssh -p 2222 root@136.243.155.166

# 4. Copy setup script to Proxmox
scp -P 2222 setup_prometheus_https.sh root@136.243.155.166:/root/

# 5. Run setup on Proxmox
bash /root/setup_prometheus_https.sh

# 6. Test from local machine
curl -I https://prometheus.simondatalab.de
```

---

**After completion, both dashboards will be accessible:**

- ✅ Grafana: <https://grafana.simondatalab.de>
- ✅ Prometheus: <https://prometheus.simondatalab.de>

Both with valid SSL certificates and no browser warnings! 🎉
