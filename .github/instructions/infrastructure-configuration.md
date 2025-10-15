# 🏗️ Infrastructure Configuration Documentation
## Simon Data Lab - Complete System Architecture

**Last Updated:** October 15, 2025  
**Maintainer:** Simon Renauld  
**Environment:** Production

---

## 📋 Table of Contents

1. [Network Architecture](#network-architecture)
2. [SSL/TLS Certificates](#ssltls-certificates)
3. [Nginx Configuration](#nginx-configuration)
4. [Firewall & NAT Rules](#firewall--nat-rules)
5. [Container & VM Mapping](#container--vm-mapping)
6. [DNS Configuration](#dns-configuration)
7. [Service Ports](#service-ports)
8. [Backup & Recovery](#backup--recovery)

---

## 🌐 Network Architecture

### External Access

**Public IP Address:** `136.243.155.166`  
**SSH Port:** `2222` (custom, not default 22)  
**Provider:** Hetzner  
**Server:** Proxmox VE 6.8.12-14-pve

### Internal Network

**Bridge:** `vmbr0`  
**Network:** `10.0.0.0/24`  
**Gateway:** `10.0.0.1` (Proxmox host)

```
┌─────────────────────────────────────────────────┐
│   Internet                                       │
│   ↓                                              │
│   136.243.155.166 (Public IP)                   │
└─────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────┐
│   Proxmox VE Host (136.243.155.166)            │
│   - Nginx Reverse Proxy (SSL Termination)      │
│   - Let's Encrypt Certificates                  │
│   - iptables NAT/Firewall                       │
└─────────────────────────────────────────────────┘
                    ↓
         Internal Network (10.0.0.0/24)
                    ↓
        ┌───────────┴───────────┐
        ↓                       ↓
┌──────────────────┐    ┌──────────────────┐
│  Container 150   │    │  VM 9001         │
│  10.0.0.150      │    │  10.0.0.104      │
│  Portfolio Web   │    │  Moodle LMS      │
└──────────────────┘    └──────────────────┘
```

---

## 🔐 SSL/TLS Certificates

### Certificate Authority

**Provider:** Let's Encrypt  
**Challenge Method:** DNS-01 (Cloudflare API)  
**Auto-Renewal:** Enabled via certbot  
**Renewal Command:** `certbot renew --dns-cloudflare`

### Certificate Details

**Primary Certificate Location:**
```
/etc/letsencrypt/live/ollama.simondatalab.de/
├── fullchain.pem    (Certificate + Chain)
├── privkey.pem      (Private Key)
├── cert.pem         (Certificate Only)
└── chain.pem        (CA Chain Only)
```

**Certificate Information:**
- **Subject CN:** simondatalab.de
- **Issuer:** Let's Encrypt (E8)
- **Issued:** October 14, 2025
- **Expires:** January 12, 2026 (90 days)
- **Algorithm:** ECDSA
- **Key Size:** 256-bit

### Subject Alternative Names (SANs)

The certificate at `/etc/letsencrypt/live/ollama.simondatalab.de/` includes **ALL** domains:

```
DNS:booklore.simondatalab.de
DNS:geoneuralviz.simondatalab.de
DNS:grafana.simondatalab.de
DNS:moodle.simondatalab.de
DNS:mlflow.simondatalab.de
DNS:ollama.simondatalab.de
DNS:simondatalab.de
DNS:www.simondatalab.de
```

### ❓ Why Use `/etc/letsencrypt/live/ollama.simondatalab.de/` Path?

**IMPORTANT:** The path `/etc/letsencrypt/live/ollama.simondatalab.de/` is **NOT** specific to the ollama service!

**Explanation:**

1. **Certbot Naming Convention:**
   - Let's Encrypt/Certbot names the certificate directory after the **first domain** in the certificate request
   - When we ran: `certbot certonly --dns-cloudflare -d simondatalab.de -d www.simondatalab.de -d moodle.simondatalab.de -d grafana.simondatalab.de -d ollama.simondatalab.de -d mlflow.simondatalab.de -d booklore.simondatalab.de -d geoneuralviz.simondatalab.de`
   - The domains were processed alphabetically or in request order
   - Certbot chose `ollama.simondatalab.de` as the directory name (possibly because it was processed first or existed from a previous certificate)

2. **Single Multi-Domain Certificate:**
   - This is **ONE certificate** that covers **ALL 8 domains**
   - Using a single certificate simplifies management and renewal
   - All domains share the same private key and certificate chain

3. **Path is Just a Label:**
   - The directory name `ollama.simondatalab.de` is simply a filesystem label
   - The actual certificate works for **all SANs** listed above
   - You could rename the directory to anything (e.g., `simondatalab-all`) and it would still work

4. **Best Practice:**
   - Using one multi-domain certificate is better than managing 8 separate certificates
   - All nginx configs point to the **same certificate path**
   - Renewal happens once for all domains simultaneously

### Alternative Certificate Naming

If you want to rename for clarity:

```bash
# Stop nginx
systemctl stop nginx

# Rename certificate directory
mv /etc/letsencrypt/live/ollama.simondatalab.de /etc/letsencrypt/live/simondatalab-multi
mv /etc/letsencrypt/renewal/ollama.simondatalab.de.conf /etc/letsencrypt/renewal/simondatalab-multi.conf

# Update all nginx configs to use new path:
# ssl_certificate /etc/letsencrypt/live/simondatalab-multi/fullchain.pem;
# ssl_certificate_key /etc/letsencrypt/live/simondatalab-multi/privkey.pem;

# Start nginx
systemctl start nginx
```

**However, this is NOT necessary** - the current setup works perfectly fine.

### Certbot Configuration

**Cloudflare API Credentials:**
```
/root/.secrets/cloudflare.ini
```

**Content:**
```ini
dns_cloudflare_api_token = __T2DKmktZTZzQebbus4RgSa0Fz4bgQZGlexK_Rq
```

**Permissions:** `600` (root only)

**Renewal Configuration:**
```
/etc/letsencrypt/renewal/ollama.simondatalab.de.conf
```

**Auto-Renewal:**
```bash
# Certbot timer (runs twice daily)
systemctl status certbot.timer

# Manual renewal test
certbot renew --dry-run

# Force renewal (if needed)
certbot renew --force-renewal
```

---

## ⚙️ Nginx Configuration

### Main Configuration

**Base Path:** `/etc/nginx/`  
**Sites Available:** `/etc/nginx/sites-available/`  
**Sites Enabled:** `/etc/nginx/sites-enabled/` (symlinks)

### Active Configurations

#### 1. Root Domain & WWW (Portfolio)

**File:** `/etc/nginx/sites-enabled/simondatalab-https.conf`

```nginx
server {
    listen 443 ssl http2;
    server_name simondatalab.de www.simondatalab.de;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/ollama.simondatalab.de/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ollama.simondatalab.de/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    # Proxy to Container 150 (Portfolio)
    location / {
        proxy_pass http://10.0.0.150:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**Backend:** Container 150 (10.0.0.150:80)  
**Purpose:** Portfolio website

#### 2. Moodle LMS

**File:** `/etc/nginx/sites-enabled/moodle.simondatalab.de.conf`

```nginx
# HTTP to HTTPS Redirect
server {
    listen 80;
    server_name moodle.simondatalab.de;

    location ^~ /.well-known/acme-challenge/ {
        root /var/www/letsencrypt;
        default_type text/plain;
        try_files $uri =404;
    }

    return 301 https://$host$request_uri;
}

# HTTPS Server
server {
    listen 443 ssl http2;
    server_name moodle.simondatalab.de;

    # SSL Configuration (SAME CERTIFICATE AS ALL OTHER SERVICES)
    ssl_certificate /etc/letsencrypt/live/ollama.simondatalab.de/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ollama.simondatalab.de/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;

    # Serve Custom Theme Files (Epic Course Theme)
    location ~ ^/(epic-course-theme\.css|epic-course-interactive\.js)$ {
        root /var/www/moodle-assets;
        expires 1h;
        add_header Cache-Control "public, must-revalidate";
        add_header Access-Control-Allow-Origin "*";
        access_log off;
    }

    # Proxy to VM 9001 (Moodle Application)
    location / {
        proxy_pass http://10.0.0.104:9001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port $server_port;

        # WebSocket Support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # Timeouts
        proxy_connect_timeout 600;
        proxy_send_timeout 600;
        proxy_read_timeout 600;
        send_timeout 600;
    }
}
```

**Backend:** VM 9001 (10.0.0.104:9001)  
**Purpose:** Moodle LMS  
**Custom Assets:** `/var/www/moodle-assets/` (theme files)

#### 3. ACME Challenge Handler

**File:** `/etc/nginx/sites-enabled/000-auth-redirect.conf`

```nginx
server {
    listen 80 default_server;
    server_name _;

    location ^~ /.well-known/acme-challenge/ {
        root /var/www/letsencrypt;
        default_type text/plain;
        try_files $uri =404;
    }

    # Proxy other requests to Container 150
    location / {
        proxy_pass http://10.0.0.150:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

**Purpose:** Handle Let's Encrypt HTTP-01 challenges (backup method)

### Nginx Service Management

```bash
# Test configuration
nginx -t

# Reload (graceful, no downtime)
systemctl reload nginx

# Restart (full restart)
systemctl restart nginx

# Status
systemctl status nginx

# Enable auto-start
systemctl enable nginx
```

---

## 🔥 Firewall & NAT Rules

### IPTables Configuration

**Configuration File:** `/etc/iptables/rules.v4`  
**Applied On Boot:** Yes (via `iptables-persistent`)

### Current Rules (Cleaned - October 15, 2025)

#### NAT Table

**View Rules:**
```bash
iptables -t nat -L -n -v --line-numbers
```

**Current PREROUTING (Port Forwarding):**

```bash
# Port 8088 → Container 103 (Jellyfin Admin)
DNAT tcp dpt:8088 to:10.0.0.103:8088

# Port 8096 → Container 103 (Jellyfin)
DNAT tcp dpt:8096 to:10.0.0.103:8096

# Port 9020 → Container 103 (Service)
DNAT tcp dpt:9020 to:10.0.0.103:9020

# Port 9001 → VM 104 (Moodle - LEGACY, replaced by nginx proxy)
DNAT tcp dpt:9001 to:10.0.0.104:8086
```

**Current POSTROUTING (Masquerade):**

```bash
# Masquerade for external interface
MASQUERADE on enp0s31f6 for 10.0.0.0/24

# Masquerade for internal bridge
MASQUERADE on vmbr0 for 10.0.0.0/24

# Service-specific masquerade rules
MASQUERADE for 10.0.0.103:8088
MASQUERADE for 10.0.0.103:8096
MASQUERADE for 10.0.0.103:9020
MASQUERADE for 10.0.0.150:80 (Container 150 - Portfolio HTTP)
MASQUERADE for 10.0.0.104:8086
MASQUERADE for 10.0.0.104:80 (VM 104 - Legacy)
```

### ⚠️ REMOVED NAT Rules (October 15, 2025)

**Previously existed, now REMOVED:**

```bash
# REMOVED: Port 443 → Container 150
# These were causing conflicts with Proxmox nginx SSL termination
MASQUERADE for 10.0.0.150:443 (REMOVED)
MASQUERADE for 10.0.0.150:443 (REMOVED - duplicate)
```

**Why removed:** 
- All SSL/TLS termination now happens at Proxmox nginx level
- Container 150 only serves HTTP on port 80
- No containers or VMs handle SSL directly anymore

### Save & Restore IPTables

**Save current rules:**
```bash
iptables-save > /etc/iptables/rules.v4
```

**Restore on boot:**
```bash
# Automatic via iptables-persistent service
systemctl enable netfilter-persistent
systemctl start netfilter-persistent
```

**Manual restore:**
```bash
iptables-restore < /etc/iptables/rules.v4
```

### Firewall Rules (FILTER table)

**Allow established connections:**
```bash
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
```

**Allow loopback:**
```bash
iptables -A INPUT -i lo -j ACCEPT
```

**Allow SSH (custom port 2222):**
```bash
iptables -A INPUT -p tcp --dport 2222 -j ACCEPT
```

**Allow HTTP/HTTPS:**
```bash
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
```

**Allow Proxmox Web Interface (8006):**
```bash
iptables -A INPUT -p tcp --dport 8006 -j ACCEPT
```

---

## 🖥️ Container & VM Mapping

### Container 150 - Portfolio Web Server

**Type:** LXC Container  
**ID:** 150  
**Name:** `portfolio-web-1000150`  
**IP Address:** `10.0.0.150`  
**OS:** Debian/Ubuntu  
**Auto-start:** Yes (`onboot=1`)

**Configuration File:** `/etc/pve/lxc/150.conf`

**Mount Points:**
```bash
# ACME challenge directory for Let's Encrypt
mp0: /var/www/letsencrypt,mp=/var/www/letsencrypt
```

**Services:**
- **Nginx:** Port 80 (HTTP only, no SSL)
- **Content:** Portfolio website HTML/CSS/JS

**Web Root:** `/var/www/html/`

**Key Files:**
- `/var/www/html/index.html` (68,824 bytes)
- `/var/www/html/styles.css` (33 KB)
- `/var/www/html/neural-geoserver-styles.css` (8.6 KB)
- `/var/www/html/globe-fab.css` (2.7 KB)

**Access:**
```bash
# Via Proxmox
pct exec 150 -- bash

# Direct SSH (if configured)
ssh root@10.0.0.150
```

**Management:**
```bash
# Start
pct start 150

# Stop
pct stop 150

# Status
pct status 150

# Console
pct console 150
```

---

### VM 9001 - Moodle LMS Server

**Type:** QEMU Virtual Machine  
**ID:** 9001  
**Name:** `moodle-lms-9001-1000104`  
**IP Address:** `10.0.0.104`  
**RAM:** 8192 MB (8 GB)  
**Disk:** 64 GB  
**OS:** Linux (full VM, not container)  
**Auto-start:** Yes

**Configuration File:** `/etc/pve/qemu-server/9001.conf`

**Services Running:**
- **Moodle Application:** Port 9001 (HTTP)
- **Grafana:** Port 3000
- **Nginx:** Port 443 (SELF-SIGNED SSL - should be disabled)

**⚠️ Important Note:**
- VM 9001 has its own nginx running on port 443 with self-signed certificate
- This should ideally be disabled since Proxmox handles all SSL
- Current workaround: Proxmox nginx intercepts traffic before it reaches VM

**Access:**
```bash
# Via Proxmox console
qm console 9001

# Via VNC (if configured)
# Check Proxmox web interface

# SSH (requires key/password configured in VM)
# ssh root@10.0.0.104
```

**Management:**
```bash
# Start
qm start 9001

# Stop
qm stop 9001

# Status
qm status 9001

# Shutdown gracefully
qm shutdown 9001
```

---

### Container 103 - Jellyfin Media Server

**Type:** LXC Container  
**ID:** 103  
**IP Address:** `10.0.0.103`  
**Services:**
- Port 8088: Jellyfin Admin
- Port 8096: Jellyfin Web UI
- Port 9020: Additional Service

**NAT Rules:** Active (see Firewall section)

---

## 🌍 DNS Configuration

### Cloudflare Setup

**Zone ID:** `8721a7620b0d4b0d29e926fda5525d23`  
**API Token:** `__T2DKmktZTZzQebbus4RgSa0Fz4bgQZGlexK_Rq`  
**Management:** Cloudflare Dashboard or API

### DNS Records (All DNS-Only Mode)

**Status:** Proxied = FALSE (DNS-only, no Cloudflare CDN/proxy)  
**TTL:** 120 seconds (2 minutes) - for quick updates

| Record Type | Name | Value | Proxied | TTL |
|-------------|------|-------|---------|-----|
| A | simondatalab.de | 136.243.155.166 | ❌ No | 120 |
| A | www | 136.243.155.166 | ❌ No | 120 |
| A | moodle | 136.243.155.166 | ❌ No | 120 |
| A | grafana | 136.243.155.166 | ❌ No | 120 |
| A | ollama | 136.243.155.166 | ❌ No | 120 |
| A | mlflow | 136.243.155.166 | ❌ No | 120 |
| A | booklore | 136.243.155.166 | ❌ No | 120 |
| A | geoneuralviz | 136.243.155.166 | ❌ No | 120 |

### Update DNS via API

```bash
# Update single record
curl -X PUT "https://api.cloudflare.com/client/v4/zones/8721a7620b0d4b0d29e926fda5525d23/dns_records/{record_id}" \
  -H "Authorization: Bearer __T2DKmktZTZzQebbus4RgSa0Fz4bgQZGlexK_Rq" \
  -H "Content-Type: application/json" \
  --data '{
    "type": "A",
    "name": "moodle",
    "content": "136.243.155.166",
    "ttl": 120,
    "proxied": false
  }'
```

### DNS Propagation Check

```bash
# Check from external DNS
dig +short simondatalab.de @8.8.8.8
dig +short moodle.simondatalab.de @8.8.8.8

# Check from Cloudflare
dig +short simondatalab.de @1.1.1.1
```

---

## 🔌 Service Ports

### External Ports (Public)

| Port | Protocol | Service | Destination |
|------|----------|---------|-------------|
| 22 | TCP | SSH (DISABLED) | - |
| 2222 | TCP | SSH (Custom) | Proxmox Host |
| 80 | TCP | HTTP | Nginx → Containers/VMs |
| 443 | TCP | HTTPS | Nginx SSL Termination |
| 8006 | TCP | Proxmox Web UI | Proxmox Management |
| 8088 | TCP | Jellyfin Admin | NAT → 10.0.0.103:8088 |
| 8096 | TCP | Jellyfin Web | NAT → 10.0.0.103:8096 |
| 9001 | TCP | Moodle Direct | NAT → 10.0.0.104:8086 |
| 9020 | TCP | Service | NAT → 10.0.0.103:9020 |

### Internal Ports (10.0.0.0/24)

| Container/VM | IP | Port | Service |
|--------------|-----|------|---------|
| CT 150 | 10.0.0.150 | 80 | Nginx (Portfolio HTTP) |
| VM 9001 | 10.0.0.104 | 9001 | Moodle Application |
| VM 9001 | 10.0.0.104 | 3000 | Grafana |
| VM 9001 | 10.0.0.104 | 443 | Nginx (Self-Signed, should disable) |
| CT 103 | 10.0.0.103 | 8088 | Jellyfin Admin |
| CT 103 | 10.0.0.103 | 8096 | Jellyfin Web |
| CT 103 | 10.0.0.103 | 9020 | Service |

---

## 💾 Backup & Recovery

### Nginx Configuration Backups

**Location:** `/etc/nginx/sites-enabled/*.backup-*`

**Latest Backups:**
```bash
/etc/nginx/sites-enabled/moodle.simondatalab.de.conf.backup-20251015-022822
```

**Create manual backup:**
```bash
cp /etc/nginx/sites-enabled/moodle.simondatalab.de.conf \
   /etc/nginx/sites-enabled/moodle.simondatalab.de.conf.backup-$(date +%Y%m%d-%H%M%S)
```

### SSL Certificate Backups

**Automatic:** Let's Encrypt keeps archived certificates in:
```
/etc/letsencrypt/archive/ollama.simondatalab.de/
```

**Manual backup:**
```bash
tar -czf letsencrypt-backup-$(date +%Y%m%d).tar.gz /etc/letsencrypt/
```

### IPTables Backup

**Current rules saved in:**
```
/etc/iptables/rules.v4
```

**Manual backup:**
```bash
iptables-save > /root/iptables-backup-$(date +%Y%m%d).rules
```

### Container Backup

**Via Proxmox:**
```bash
# Backup container 150
vzdump 150 --mode snapshot --compress gzip --storage local

# List backups
ls -lh /var/lib/vz/dump/
```

### VM Backup

**Via Proxmox:**
```bash
# Backup VM 9001
vzdump 9001 --mode snapshot --compress gzip --storage local
```

---

## 🔧 Troubleshooting Commands

### Check SSL Certificate

```bash
# From server
echo | openssl s_client -connect moodle.simondatalab.de:443 -servername moodle.simondatalab.de 2>/dev/null | grep -E "subject|issuer|Verify"

# Check certificate SANs
openssl x509 -in /etc/letsencrypt/live/ollama.simondatalab.de/fullchain.pem -noout -text | grep -A 10 "Subject Alternative Name"

# Check expiry
openssl x509 -in /etc/letsencrypt/live/ollama.simondatalab.de/fullchain.pem -noout -dates
```

### Test Nginx Configuration

```bash
# Test config
nginx -t

# Check which configs are loaded
nginx -T | grep "server_name"

# Find duplicate server blocks
nginx -T 2>&1 | grep -A 5 "conflicting server name"
```

### Network Connectivity

```bash
# Test internal connectivity
curl -I http://10.0.0.150
curl -I http://10.0.0.104:9001

# Test DNS resolution
nslookup moodle.simondatalab.de
dig moodle.simondatalab.de

# Test external HTTPS
curl -I https://moodle.simondatalab.de
```

### View Active Connections

```bash
# Show all listening ports
ss -tlnp

# Show nginx connections
ss -tlnp | grep nginx

# Show connections to specific port
ss -tn dst :443
```

### Container/VM Status

```bash
# List all containers
pct list

# List all VMs
qm list

# Check specific container
pct status 150

# Check specific VM
qm status 9001
```

---

## 📊 Architecture Summary

### Request Flow for HTTPS Requests

```
Client Request
    ↓
https://moodle.simondatalab.de/
    ↓
DNS Resolution (Cloudflare) → 136.243.155.166
    ↓
Proxmox Nginx :443 (SSL Termination)
    ↓
Certificate: /etc/letsencrypt/live/ollama.simondatalab.de/fullchain.pem
(This cert includes moodle.simondatalab.de in SANs)
    ↓
SSL Handshake Success
    ↓
Nginx matches server_name: moodle.simondatalab.de
    ↓
Check location: /epic-course-theme.css or /epic-course-interactive.js?
    ├─ YES → Serve from /var/www/moodle-assets/
    └─ NO → proxy_pass http://10.0.0.104:9001
              ↓
         VM 9001 Moodle Application
              ↓
         Response (HTML/JSON/etc)
              ↓
    Proxmox Nginx (add headers, encrypt)
              ↓
         Client receives HTTPS response
```

### Why All Services Use Same Certificate Path

1. **Single Multi-Domain Certificate**
   - One certificate covers all 8 domains
   - Simpler management (one renewal, one private key)
   - Cost-effective (Let's Encrypt free tier limit: 50 certs/week)

2. **Certbot Directory Naming**
   - Directory name is arbitrary (just a filesystem label)
   - Actual certificate CN and SANs determine which domains it covers
   - Path could be renamed to anything without affecting functionality

3. **Nginx Configuration**
   - All server blocks point to same certificate
   - Each server_name matches different domain
   - SNI (Server Name Indication) determines which virtual host to serve

---

## 🔐 Security Checklist

- ✅ SSH on custom port (2222, not 22)
- ✅ Let's Encrypt certificates (auto-renewal enabled)
- ✅ TLS 1.2 and 1.3 only (no older versions)
- ✅ Strong cipher suites (ECDHE, AES-GCM)
- ✅ HSTS headers enabled (31536000 seconds)
- ✅ X-Frame-Options: SAMEORIGIN
- ✅ X-Content-Type-Options: nosniff
- ✅ No iptables NAT for port 443 (all SSL at Proxmox level)
- ✅ Firewall rules limiting external access
- ❌ **TODO:** Disable self-signed SSL on VM 9001:443

---

## 📝 Maintenance Tasks

### Daily
- ✅ Auto: Certbot renewal check (twice daily via systemd timer)
- ✅ Auto: Log rotation

### Weekly
- Check nginx error logs: `tail -100 /var/log/nginx/error.log`
- Review iptables rules: `iptables -L -n -v`

### Monthly
- Test certificate renewal: `certbot renew --dry-run`
- Update system packages: `apt update && apt upgrade`
- Review disk space: `df -h`
- Check container/VM resource usage

### Quarterly
- Full backup of containers and VMs
- Review and update firewall rules
- Audit user access and SSH keys
- Update this documentation

---

## 📞 Emergency Contacts

**Hosting Provider:** Hetzner  
**Domain Registrar:** Cloudflare  
**SSL Provider:** Let's Encrypt (automated)

---

## 📚 Related Documentation

- [Moodle Theme Deployment](../MOODLE_THEME_DEPLOYMENT.md)
- [SSL Fix Documentation](../SIMONDATALAB_REDIRECT_FIX_COMPLETE_DOCUMENTATION.md)
- [Portfolio Deployment](../PORTFOLIO_FIX_SUMMARY.md)

---

**Document Version:** 1.0.0  
**Last Verified:** October 15, 2025, 02:40 UTC  
**Author:** Simon Renauld  
**Status:** 🟢 All Systems Operational
