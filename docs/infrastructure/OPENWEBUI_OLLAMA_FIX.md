# OpenWebUI and Ollama Configuration Fix

## Date: October 15, 2025 08:42 UTC

## Problem
- `https://openwebui.simondatalab.de/` was not accessible
- `https://ollama.simondatalab.de/` routing needed verification
- OpenWebUI container was stopped on VM 159

## Root Cause
1. **OpenWebUI container was EXITED (not running)**
2. **No nginx configuration enabled** for openwebui.simondatalab.de
3. **Old configuration** pointed to wrong VM (10.0.0.104 instead of 10.0.0.110)

## Solution Implemented

### 1. Started OpenWebUI Container (VM 159)

**Container Status Before:**
```
1d897caa6fd4   ghcr.io/open-webui/open-webui:main   Exited (0) About an hour ago
```

**Action:**
```bash
ssh simonadmin@10.0.0.110 'docker start openwebui'
ssh simonadmin@10.0.0.110 'docker update --restart unless-stopped openwebui'
```

**Container Status After:**
```
1d897caa6fd4   ghcr.io/open-webui/open-webui:main   Up 7 seconds (health: starting)   0.0.0.0:3001->8080/tcp
```

### 2. Created Nginx Configuration (Proxmox)

**File:** `/etc/nginx/sites-available/openwebui.simondatalab.de.conf`

```nginx
# HTTP redirect to HTTPS
server {
    listen 80;
    server_name openwebui.simondatalab.de;
    
    # Allow Let's Encrypt challenges
    location ^~ /.well-known/acme-challenge/ {
        root /var/www/letsencrypt;
        default_type text/plain;
        try_files $uri =404;
    }
    
    # Redirect all other HTTP traffic to HTTPS
    location / {
        return 301 https://$host$request_uri;
    }
}

# HTTPS server for OpenWebUI
server {
    listen 443 ssl http2;
    server_name openwebui.simondatalab.de;
    
    ssl_certificate /etc/letsencrypt/live/ollama.simondatalab.de/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/ollama.simondatalab.de/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    
    # Security headers
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-XSS-Protection "1; mode=block";
    
    # Proxy to OpenWebUI on VM 159
    location / {
        proxy_pass http://10.0.0.110:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        
        # Timeout settings for AI/LLM operations
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
    }
}
```

### 3. Enabled Configuration

```bash
ln -sf /etc/nginx/sites-available/openwebui.simondatalab.de.conf /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx
```

## Services on VM 159 (10.0.0.110)

| Service | Container | Port | Status | URL |
|---------|-----------|------|--------|-----|
| OpenWebUI | openwebui | 3001→8080 | ✅ Running | https://openwebui.simondatalab.de |
| Ollama | ollama | 11434 | ✅ Running | https://ollama.simondatalab.de |
| MLflow | mlflow | 5000 | ✅ Running | https://mlflow.simondatalab.de |

## Verification

### OpenWebUI Test:
```bash
$ curl -I https://openwebui.simondatalab.de/
HTTP/2 200 
content-type: text/html; charset=utf-8
x-content-type-options: nosniff
x-frame-options: SAMEORIGIN
x-xss-protection: 1; mode=block
```

### Ollama Test:
```bash
$ curl -I https://ollama.simondatalab.de/
HTTP/2 200 
server: nginx/1.22.1
content-type: text/plain; charset=utf-8
```

## Auto-Start Configuration

OpenWebUI is now configured to auto-start on VM boot:

```bash
$ docker inspect openwebui | grep -A 2 RestartPolicy
"RestartPolicy": {
    "Name": "unless-stopped",
    "MaximumRetryCount": 0
}
```

## Network Architecture

```
Internet (ports 80/443)
    ↓
Proxmox Host (136.243.155.166)
    ├─ nginx reverse proxy
    │
    ├─→ openwebui.simondatalab.de → VM 159:3001 (OpenWebUI)
    ├─→ ollama.simondatalab.de    → VM 159:11434 (Ollama API)
    ├─→ mlflow.simondatalab.de    → VM 159:5000 (MLflow)
    ├─→ simondatalab.de           → CT 150:80 (Portfolio)
    └─→ moodle.simondatalab.de    → VM 9001:8086 (Moodle)
```

## Files Modified

| Location | File | Action |
|----------|------|--------|
| Proxmox | `/etc/nginx/sites-available/openwebui.simondatalab.de.conf` | Created |
| Proxmox | `/etc/nginx/sites-enabled/openwebui.simondatalab.de.conf` | Symlinked |
| VM 159 | Docker container `openwebui` | Started + auto-restart enabled |

## SSL/TLS Certificate

**Certificate:** Let's Encrypt SAN certificate
**Location:** `/etc/letsencrypt/live/ollama.simondatalab.de/`
**Domains covered:**
- ollama.simondatalab.de
- openwebui.simondatalab.de
- mlflow.simondatalab.de
- moodle.simondatalab.de
- simondatalab.de
- www.simondatalab.de
- grafana.simondatalab.de
- booklore.simondatalab.de

## Container Details (VM 159)

```bash
$ ssh simonadmin@10.0.0.110 'docker ps'

CONTAINER ID   IMAGE                                CREATED       STATUS              PORTS
1d897caa6fd4   ghcr.io/open-webui/open-webui:main   2 days ago    Up 7 seconds        0.0.0.0:3001->8080/tcp
b48c2f033076   ollama/ollama:0.12.2                 2 weeks ago   Up 56 minutes       0.0.0.0:11434->11434/tcp
1d85542a9ca1   ghcr.io/mlflow/mlflow:latest         8 weeks ago   Up 56 minutes       0.0.0.0:5000->5000/tcp
```

## Maintenance Commands

### Check OpenWebUI Status:
```bash
ssh -p 2222 root@136.243.155.166 "ssh simonadmin@10.0.0.110 'docker ps | grep openwebui'"
```

### Restart OpenWebUI:
```bash
ssh -p 2222 root@136.243.155.166 "ssh simonadmin@10.0.0.110 'docker restart openwebui'"
```

### View OpenWebUI Logs:
```bash
ssh -p 2222 root@136.243.155.166 "ssh simonadmin@10.0.0.110 'docker logs -f openwebui'"
```

### Check nginx Status:
```bash
ssh -p 2222 root@136.243.155.166 "nginx -t && systemctl status nginx"
```

## Troubleshooting

### If OpenWebUI is not accessible:

1. **Check container status:**
   ```bash
   docker ps | grep openwebui
   ```

2. **If not running, start it:**
   ```bash
   docker start openwebui
   ```

3. **Check nginx configuration:**
   ```bash
   nginx -t
   systemctl status nginx
   ```

4. **Check port accessibility:**
   ```bash
   curl http://10.0.0.110:3001/
   ```

5. **Check SSL certificate:**
   ```bash
   openssl s_client -connect openwebui.simondatalab.de:443 -servername openwebui.simondatalab.de
   ```

## Security Considerations

✅ **HTTPS enforced** - HTTP redirects to HTTPS
✅ **Security headers** - X-Content-Type-Options, X-Frame-Options, X-XSS-Protection
✅ **TLS 1.2/1.3 only** - Secure protocols
✅ **WebSocket support** - For real-time AI chat
✅ **Long timeouts** - 300s for AI/LLM operations
✅ **Let's Encrypt certificate** - Valid trusted certificate

## Related Documentation

- [REDIRECT_ISSUE_FIXED.md](./REDIRECT_ISSUE_FIXED.md) - simondatalab.de redirect fix
- [DROPDOWN_FIX_SUMMARY.md](./DROPDOWN_FIX_SUMMARY.md) - Portfolio dropdown UI fix
- [SIMONDATALAB_REDIRECT_FIX_COMPLETE_DOCUMENTATION.md](../SIMONDATALAB_REDIRECT_FIX_COMPLETE_DOCUMENTATION.md)

## Success Metrics

✅ https://openwebui.simondatalab.de/ - HTTP/2 200 (Working)
✅ https://ollama.simondatalab.de/ - HTTP/2 200 (Working)  
✅ https://mlflow.simondatalab.de/ - HTTP/2 200 (Working)
✅ https://simondatalab.de/ - HTTP/2 200 (Working)
✅ https://moodle.simondatalab.de/ - HTTP/2 200 (Working)

---
**Status:** ✅ COMPLETED  
**Created:** October 15, 2025 08:42 UTC  
**All services operational**
