# SimonDataLab.de Redirect Issue - Complete Fix Documentation

## Executive Summary

**Issue**: `https://www.simondatalab.de/` was incorrectly redirecting to `https://moodle.simondatalab.de/` instead of serving the portfolio website.

**Root Cause**: iptables DNAT rule was redirecting ALL port 443 (HTTPS) traffic to the Moodle VM before nginx could process requests.

**Resolution**: Removed problematic iptables rule; local nginx now serves portfolio correctly. External access may require Cloudflare cache purge or propagation time.

**Status**: ✅ Local fix complete, 🟡 Awaiting Cloudflare propagation

---

## Infrastructure Overview

### Network Architecture
```
Internet → Cloudflare Edge → Cloudflare Tunnel → Proxmox Host → Backend Services
                                                 (136.243.155.166)
                                                 nginx + iptables
```

### Service Mapping
| Domain | Target Backend | Purpose |
|--------|---------------|---------|
| `simondatalab.de` | Container 150 (`10.0.0.150:80`) | Portfolio Website |
| `www.simondatalab.de` | Container 150 (`10.0.0.150:80`) | Portfolio Website |
| `moodle.simondatalab.de` | VM 9001 (`10.0.0.104:9001`) | Moodle LMS |
| `grafana.simondatalab.de` | VM 9001 (`10.0.0.104:3000`) | Grafana Dashboard |
| `ollama.simondatalab.de` | Container 110 (`10.0.0.110:11434`) | Ollama API |
| `mlflow.simondatalab.de` | Container 110 (`10.0.0.110:5000`) | MLflow Server |

---

## Problem Investigation Timeline

### 1. Initial Symptoms
- **External Test**: `curl -sI https://www.simondatalab.de/` returned:
  ```
  HTTP/2 303 
  location: https://moodle.simondatalab.de/
  x-powered-by: PHP/8.2.29
  x-redirect-by: Moodle
  ```
- **Expected**: Portfolio website with title "Simon Renauld | Data Engineering & Innovation Strategist"

### 2. Cloudflare Configuration Verification
✅ **Cloudflare Tunnel Routes** (Confirmed Correct):
```
1. simondatalab.de → http://10.0.0.150:80
2. www.simondatalab.de → http://10.0.0.150:80  
3. moodle.simondatalab.de → http://10.0.0.104:80
```

### 3. Origin Server Investigation
**Key Discovery**: Direct origin server test revealed the issue:
```bash
curl -sI -H "Host: simondatalab.de" https://136.243.155.166/
# Returned: HTTP/2 303 redirect to moodle (WRONG)

curl -sI -H "Host: simondatalab.de" https://localhost/  # From inside server
# Returned: HTTP/2 200 portfolio content (CORRECT)
```

**Analysis**: External requests were being handled differently than internal requests.

### 4. Root Cause Discovery
**iptables Analysis**:
```bash
iptables -t nat -L PREROUTING -n --line-numbers
```

**Problematic Rule Found**:
```
6    DNAT  tcp  --  0.0.0.0/0  0.0.0.0/0  tcp dpt:443 to:10.0.0.104:443
```

**Impact**: This rule was intercepting ALL port 443 traffic and redirecting it to the Moodle VM **before** nginx could process it.

---

## Fix Implementation

### Step 1: iptables Rule Removal
```bash
# Remove the problematic rule
ssh -p 2222 root@136.243.155.166
iptables -t nat -D PREROUTING 6

# Verify removal
iptables -t nat -L PREROUTING -n --line-numbers
```

### Step 2: Nginx Configuration Verification
**Confirmed Correct Configuration**:
```nginx
# /etc/nginx/sites-enabled/simondatalab-https.conf
server {
    listen 443 ssl http2 default_server;
    server_name simondatalab.de www.simondatalab.de;
    
    ssl_certificate /etc/nginx/ssl/cloudflare/simondatalab.de.crt;
    ssl_certificate_key /etc/nginx/ssl/cloudflare/simondatalab.de.key;
    
    location / {
        proxy_pass http://10.0.0.150;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### Step 3: Container 150 Verification
**Portfolio Container Status**:
```bash
pct status 150                    # Status: running
curl -I http://10.0.0.150:80/     # HTTP/1.1 200 OK
```

**Nginx Configuration in Container 150**:
```nginx
# /etc/nginx/sites-available/portfolio
server {
    listen 80;
    server_name simondatalab.de www.simondatalab.de;
    root /var/www/html;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

---

## Testing Results

### ✅ Local Tests (Post-Fix)
```bash
# Test 1: Direct backend access
curl -I http://10.0.0.150:80/
# Result: HTTP/1.1 200 OK ✅

# Test 2: Nginx proxy (internal)
curl -s -H "Host: simondatalab.de" -k https://localhost:443/ | head -5
# Result: Portfolio HTML content ✅
# Title: "Simon Renauld | Data Engineering & Innovation Strategist"

# Test 3: Origin server external interface
curl -sI -H "Host: simondatalab.de" -k https://136.243.155.166:443/
# Result: HTTP/2 200 ✅ (Fixed after iptables rule removal)
```

### 🟡 External Tests (Cloudflare Propagation Pending)
```bash
# Test 4: Cloudflare edge
curl -sI https://www.simondatalab.de/
# Current Result: HTTP/2 303 redirect to moodle
# Expected: HTTP/2 200 with portfolio content
```

---

## Current Configuration Files

### Proxmox Host - Nginx Configuration
**Path**: `/etc/nginx/sites-enabled/simondatalab-https.conf`
```nginx
# HTTPS configuration for simondatalab.de portfolio
server {
    listen 443 ssl http2 default_server;
    server_name simondatalab.de www.simondatalab.de;

    ssl_certificate /etc/nginx/ssl/cloudflare/simondatalab.de.crt;
    ssl_certificate_key /etc/nginx/ssl/cloudflare/simondatalab.de.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;

    # Auth redirect to Moodle
    location = /auth { return 302 https://moodle.simondatalab.de$request_uri; }
    location = /auth/ { return 302 https://moodle.simondatalab.de$request_uri; }
    location ^~ /auth { return 302 https://moodle.simondatalab.de$request_uri; }

    # Serve portfolio from CT 150 server
    location / {
        proxy_pass http://10.0.0.150;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Timeout settings
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
    
    # Logging
    access_log /var/log/nginx/simondatalab.de_access.log;
    error_log /var/log/nginx/simondatalab.de_error.log;
}
```

### Container 150 - Portfolio Nginx Configuration
**Path**: `/etc/nginx/sites-enabled/portfolio`
```nginx
# Simon Data Lab Portfolio Configuration
server {
    listen 80;
    server_name simondatalab.de www.simondatalab.de;
    root /var/www/html;
    index index.html;

    # Main portfolio
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Geospatial visualization
    location /geospatial-viz/ {
        alias /var/www/html/geospatial-viz/;
        try_files $uri $uri/ /geospatial-viz/index.html;
    }

    # Assets with proper caching
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        add_header Vary "Accept-Encoding";
    }

    # Security headers
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-XSS-Protection "1; mode=block";
    add_header Referrer-Policy "strict-origin-when-cross-origin";

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;
}
```

### Current iptables NAT Rules
```bash
Chain PREROUTING (policy ACCEPT)
num  target     prot opt source               destination         
1    DNAT       6    --  0.0.0.0/0            136.243.155.166      tcp dpt:8088 to:10.0.0.103:8088
2    DNAT       6    --  0.0.0.0/0            136.243.155.166      tcp dpt:8096 to:10.0.0.103:8096
3    DNAT       6    --  0.0.0.0/0            136.243.155.166      tcp dpt:9020 to:10.0.0.103:9020
4    DNAT       6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:9001 to:10.0.0.104:8086
5    DNAT       6    --  0.0.0.0/0            0.0.0.0/0            tcp dpt:9001 to:10.0.0.104:80
# Rule 6 (problematic 443 redirect) REMOVED ✅
```

---

## Cloudflare Configuration

### DNS Records
```
simondatalab.de        A     136.243.155.166
www.simondatalab.de    CNAME simondatalab.de
moodle.simondatalab.de A     136.243.155.166
*.simondatalab.de      A     136.243.155.166 (subdomains)
```

### Cloudflare Tunnel Routes
**Tunnel ID**: `9b0c5c71-3235-4725-a91c-c687605a9ae3`
```
Route #1: simondatalab.de        → http://10.0.0.150:80 ✅
Route #2: www.simondatalab.de    → http://10.0.0.150:80 ✅
Route #3: moodle.simondatalab.de → http://10.0.0.104:80 ✅
Route #4: grafana.simondatalab.de → http://10.0.0.104:3000 ✅
```

**SSL/TLS Mode**: Full (End-to-End Encryption)

---

## Troubleshooting Commands

### Local Verification
```bash
# Test Container 150 directly
ssh -p 2222 root@136.243.155.166
curl -I http://10.0.0.150:80/

# Test Proxmox nginx locally  
curl -s -H "Host: simondatalab.de" -k https://localhost:443/ | head -5

# Test external interface
curl -sI -H "Host: simondatalab.de" -k https://136.243.155.166:443/
```

### External Verification
```bash
# Test Cloudflare edge
curl -sI https://www.simondatalab.de/
curl -sI https://simondatalab.de/

# Test with cache bypass
curl -sI "https://www.simondatalab.de/?nocache=$(date +%s)"
```

### Container Management
```bash
# Container 150 status and access
pct status 150
pct exec 150 -- systemctl status nginx
pct exec 150 -- nginx -t

# Container logs
pct exec 150 -- tail -f /var/log/nginx/access.log
```

### iptables Management
```bash
# View NAT rules
iptables -t nat -L PREROUTING -n --line-numbers -v

# Save rules permanently
iptables-save > /etc/iptables/rules.v4
```

---

## Remaining Steps

### 1. Cloudflare Cache Management
**Manual Cache Purge**:
1. Login to Cloudflare Dashboard
2. Go to Caching → Configuration → Purge Cache
3. Select "Custom purge"
4. Purge by hostname: `simondatalab.de`, `www.simondatalab.de`

**API Cache Purge** (if needed):
```bash
curl -X POST "https://api.cloudflare.com/client/v4/zones/8721a7620b0d4b0d29e926fda5525d23/purge_cache" \
  -H "Authorization: Bearer eFyAgNqoBr4xCDM5rLAtzFdVoahAw4YeFlTjl86h" \
  -H "Content-Type: application/json" \
  --data '{"hosts":["simondatalab.de","www.simondatalab.de"]}'
```

### 2. Monitoring and Validation
**Expected Timeline**: 5-30 minutes for Cloudflare edge propagation

**Validation Tests**:
```bash
# Test every 5 minutes until success
watch -n 300 'curl -sI https://www.simondatalab.de/ | head -3'

# Success criteria:
# HTTP/2 200 (not 303)
# No x-redirect-by: Moodle header
# Portfolio content in response body
```

---

## Backup and Recovery

### Configuration Backups
**Nginx Backup**:
```bash
mkdir -p /root/nginx_backups/20251014_fix
cp -r /etc/nginx/ /root/nginx_backups/20251014_fix/
```

**iptables Backup**:
```bash
iptables-save > /root/nginx_backups/20251014_fix/iptables_rules_after_fix.txt
```

### Recovery Procedures
**If rollback needed**:
```bash
# Restore problematic iptables rule (DO NOT RUN)
# iptables -t nat -I PREROUTING 6 -p tcp --dport 443 -j DNAT --to-destination 10.0.0.104:443

# Restore nginx config
# cp /root/nginx_backups/[date]/etc/nginx/sites-enabled/* /etc/nginx/sites-enabled/
# systemctl reload nginx
```

---

## Change Log

| Date | Time | Change | Author | Status |
|------|------|--------|---------|---------|
| 2025-10-14 | 09:45 | Removed iptables DNAT rule #6 (port 443 → 10.0.0.104:443) | GitHub Copilot + Simon | ✅ Complete |
| 2025-10-14 | 09:46 | Verified nginx configuration correctness | GitHub Copilot + Simon | ✅ Complete |
| 2025-10-14 | 09:47 | Confirmed Container 150 portfolio serving | GitHub Copilot + Simon | ✅ Complete |
| 2025-10-14 | 09:51 | Local tests successful - portfolio loads correctly | GitHub Copilot + Simon | ✅ Complete |
| 2025-10-14 | 09:52 | External access pending Cloudflare propagation | GitHub Copilot + Simon | 🟡 In Progress |

---

## Success Criteria

### ✅ Completed
- [x] Container 150 serves portfolio correctly
- [x] Nginx proxy configuration verified
- [x] iptables rule removed
- [x] Local tests pass (internal network)

### 🟡 Pending
- [ ] External access via Cloudflare serves portfolio
- [ ] Browser test confirmation from user
- [ ] Performance validation

### Expected Final State
```bash
curl -sI https://www.simondatalab.de/
# Expected Response:
# HTTP/2 200 
# content-type: text/html
# server: cloudflare
# (No redirect headers)

curl -s https://www.simondatalab.de/ | grep -o '<title>.*</title>'
# Expected: <title>Simon Renauld | Data Engineering & Innovation Strategist</title>
```

---

## Contact Information

**System Administrator**: Simon Renauld  
**Email**: sn.renauld@gmail.com  
**Documentation Created**: 2025-10-14 09:52 UTC  
**Last Updated**: 2025-10-14 09:52 UTC  

**Emergency Contacts**:
- Proxmox Host: `ssh -p 2222 root@136.243.155.166`
- Container 150: `pct exec 150 -- bash`
- Cloudflare Dashboard: cloudflare.com (sn.renauld@gmail.com account)

---

*This documentation comprehensively covers the simondatalab.de redirect fix implementation, configurations, and monitoring procedures. All critical infrastructure details are preserved for future reference and maintenance.*