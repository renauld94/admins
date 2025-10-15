#!/bin/bash

# ============================================================================
# NGINX SIMONDATALAB.DE REDIRECT FIX SCRIPT
# ============================================================================
# 
# ISSUE: Origin server (136.243.155.166) nginx is serving Moodle PHP 
#        for simondatalab.de instead of proxying to Container 150 (10.0.0.150)
#
# ROOT CAUSE: curl -H "Host: simondatalab.de" https://136.243.155.166/
#             Returns: HTTP/2 303, x-powered-by: PHP/8.2.29, x-redirect-by: Moodle
#             Should return: Portfolio content from 10.0.0.150:80
#
# CLOUDFLARE TUNNEL ROUTES (CORRECT):
#   1. simondatalab.de → http://10.0.0.150:80 ✅
#   2. www.simondatalab.de → http://10.0.0.150:80 ✅  
#   3. moodle.simondatalab.de → http://10.0.0.104:80 ✅
#
# INFRASTRUCTURE:
#   - Proxmox Host: 136.243.155.166 (nginx reverse proxy + SSL termination)
#   - Container 150: portfolio-web-1000150 at 10.0.0.150:80 (portfolio nginx)
#   - VM 9001: moodle-lms-9001-1000104 at 10.0.0.104:80/9001 (Moodle PHP)
#
# Created: $(date)
# Author: GitHub Copilot + Simon Renauld
# ============================================================================

set -euo pipefail

# Configuration
PROXMOX_HOST="136.243.155.166"
SSH_PORT="2222"
PORTFOLIO_BACKEND="10.0.0.150:80"
MOODLE_BACKEND="10.0.0.104:80"
LOG_FILE="/tmp/nginx_fix_$(date +%Y%m%d_%H%M%S).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================================${NC}"
echo -e "${BLUE}NGINX SIMONDATALAB.DE REDIRECT FIX${NC}"
echo -e "${BLUE}============================================================================${NC}"
echo "Log file: $LOG_FILE"
echo

# Function to log and display
log_and_echo() {
    local message="$1"
    echo -e "$message"
    echo -e "$message" >> "$LOG_FILE"
}

# Function to run SSH command on Proxmox
ssh_run() {
    local cmd="$1"
    log_and_echo "${YELLOW}[PROXMOX]${NC} Running: $cmd"
    ssh -p $SSH_PORT root@$PROXMOX_HOST "$cmd" 2>&1 | tee -a "$LOG_FILE"
}

# Function to test current configuration
test_current_config() {
    log_and_echo "\n${BLUE}=== TESTING CURRENT CONFIGURATION ===${NC}"
    
    log_and_echo "${YELLOW}Testing simondatalab.de (should proxy to $PORTFOLIO_BACKEND):${NC}"
    curl -sI -H "Host: simondatalab.de" -k https://$PROXMOX_HOST/ | head -10 | tee -a "$LOG_FILE"
    
    log_and_echo "\n${YELLOW}Testing www.simondatalab.de (should proxy to $PORTFOLIO_BACKEND):${NC}"
    curl -sI -H "Host: www.simondatalab.de" -k https://$PROXMOX_HOST/ | head -10 | tee -a "$LOG_FILE"
    
    log_and_echo "\n${YELLOW}Testing moodle.simondatalab.de (should proxy to $MOODLE_BACKEND):${NC}"
    curl -sI -H "Host: moodle.simondatalab.de" -k https://$PROXMOX_HOST/ | head -10 | tee -a "$LOG_FILE"
}

# Function to backup nginx configuration
backup_nginx_config() {
    log_and_echo "\n${BLUE}=== BACKING UP NGINX CONFIGURATION ===${NC}"
    
    ssh_run "mkdir -p /root/nginx_backups/\$(date +%Y%m%d_%H%M%S)"
    ssh_run "cp -r /etc/nginx/ /root/nginx_backups/\$(date +%Y%m%d_%H%M%S)/"
    ssh_run "nginx -T > /root/nginx_backups/\$(date +%Y%m%d_%H%M%S)/nginx_full_config.txt"
    
    log_and_echo "${GREEN}✅ Nginx configuration backed up${NC}"
}

# Function to diagnose current nginx config
diagnose_nginx_config() {
    log_and_echo "\n${BLUE}=== DIAGNOSING NGINX CONFIGURATION ===${NC}"
    
    log_and_echo "${YELLOW}Checking nginx sites-enabled:${NC}"
    ssh_run "ls -la /etc/nginx/sites-enabled/"
    
    log_and_echo "\n${YELLOW}Searching for simondatalab.de server blocks:${NC}"
    ssh_run "nginx -T 2>/dev/null | grep -A 20 -B 5 'server_name.*simondatalab.de' || echo 'No simondatalab.de server block found'"
    
    log_and_echo "\n${YELLOW}Checking for default server blocks:${NC}"
    ssh_run "nginx -T 2>/dev/null | grep -A 10 -B 5 'listen.*default_server' || echo 'No default_server found'"
    
    log_and_echo "\n${YELLOW}Checking for proxy_pass configurations:${NC}"
    ssh_run "nginx -T 2>/dev/null | grep -B 5 -A 5 'proxy_pass.*10.0.0' || echo 'No 10.0.0.x proxy_pass found'"
}

# Function to create correct nginx configuration
create_correct_config() {
    log_and_echo "\n${BLUE}=== CREATING CORRECT NGINX CONFIGURATION ===${NC}"
    
    # Create the correct server block configuration
    cat > /tmp/simondatalab_nginx_config.conf << 'EOF'
# ============================================================================
# SIMONDATALAB.DE NGINX CONFIGURATION
# ============================================================================
# Purpose: Reverse proxy for simondatalab.de domains
# Created: $(date)
# 
# ROUTING:
#   simondatalab.de, www.simondatalab.de → 10.0.0.150:80 (Portfolio Container)
#   moodle.simondatalab.de → 10.0.0.104:80 (Moodle VM)
# ============================================================================

# Portfolio Website - simondatalab.de and www.simondatalab.de
server {
    listen 80;
    listen [::]:80;
    server_name simondatalab.de www.simondatalab.de;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name simondatalab.de www.simondatalab.de;
    
    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/simondatalab.de/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/simondatalab.de/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self' http: https: data: blob: 'unsafe-inline'" always;
    
    # Proxy to Portfolio Container (10.0.0.150:80)
    location / {
        proxy_pass http://10.0.0.150:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $server_name;
        proxy_redirect off;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # Buffer settings
        proxy_buffering on;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
    }
    
    # Logging
    access_log /var/log/nginx/simondatalab.de_access.log;
    error_log /var/log/nginx/simondatalab.de_error.log;
}

# Moodle LMS - moodle.simondatalab.de
server {
    listen 80;
    listen [::]:80;
    server_name moodle.simondatalab.de;
    
    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name moodle.simondatalab.de;
    
    # SSL Configuration (using same cert with SAN)
    ssl_certificate /etc/letsencrypt/live/simondatalab.de/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/simondatalab.de/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    # Security Headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    
    # Proxy to Moodle VM (10.0.0.104:80)
    location / {
        proxy_pass http://10.0.0.104:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $server_name;
        proxy_redirect off;
        
        # Moodle specific settings
        client_max_body_size 100M;
        proxy_connect_timeout 300s;
        proxy_send_timeout 300s;
        proxy_read_timeout 300s;
        
        # Buffer settings
        proxy_buffering on;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
    }
    
    # Logging
    access_log /var/log/nginx/moodle.simondatalab.de_access.log;
    error_log /var/log/nginx/moodle.simondatalab.de_error.log;
}
EOF

    log_and_echo "${GREEN}✅ Created correct nginx configuration${NC}"
}

# Function to apply the fix
apply_nginx_fix() {
    log_and_echo "\n${BLUE}=== APPLYING NGINX FIX ===${NC}"
    
    # Upload the configuration
    scp -P $SSH_PORT /tmp/simondatalab_nginx_config.conf root@$PROXMOX_HOST:/etc/nginx/sites-available/simondatalab.de
    
    # Remove old conflicting configs and enable new one
    ssh_run "rm -f /etc/nginx/sites-enabled/default"
    ssh_run "rm -f /etc/nginx/sites-enabled/simondatalab.de"
    ssh_run "ln -s /etc/nginx/sites-available/simondatalab.de /etc/nginx/sites-enabled/"
    
    # Test nginx configuration
    log_and_echo "\n${YELLOW}Testing nginx configuration:${NC}"
    ssh_run "nginx -t"
    
    # Reload nginx
    log_and_echo "\n${YELLOW}Reloading nginx:${NC}"
    ssh_run "systemctl reload nginx"
    
    log_and_echo "${GREEN}✅ Nginx configuration applied and reloaded${NC}"
}

# Function to verify the fix
verify_fix() {
    log_and_echo "\n${BLUE}=== VERIFYING FIX ===${NC}"
    
    # Wait a moment for nginx to fully reload
    sleep 3
    
    log_and_echo "${YELLOW}Testing simondatalab.de (should now show portfolio):${NC}"
    curl -sI -H "Host: simondatalab.de" -k https://$PROXMOX_HOST/ | tee -a "$LOG_FILE"
    
    log_and_echo "\n${YELLOW}Testing for portfolio content:${NC}"
    if curl -s -H "Host: simondatalab.de" -k https://$PROXMOX_HOST/ | grep -q "Simon.*Data.*Engineer\|Portfolio\|Innovation"; then
        log_and_echo "${GREEN}✅ SUCCESS: Portfolio content detected!${NC}"
    else
        log_and_echo "${RED}❌ FAIL: No portfolio content detected${NC}"
    fi
    
    log_and_echo "\n${YELLOW}Testing moodle.simondatalab.de (should still work):${NC}"
    curl -sI -H "Host: moodle.simondatalab.de" -k https://$PROXMOX_HOST/ | head -5 | tee -a "$LOG_FILE"
}

# Function to test external access
test_external_access() {
    log_and_echo "\n${BLUE}=== TESTING EXTERNAL ACCESS ===${NC}"
    
    log_and_echo "${YELLOW}Testing https://www.simondatalab.de/ (external):${NC}"
    curl -sI https://www.simondatalab.de/ | head -8 | tee -a "$LOG_FILE"
    
    log_and_echo "\n${YELLOW}Testing https://simondatalab.de/ (external):${NC}"
    curl -sI https://simondatalab.de/ | head -8 | tee -a "$LOG_FILE"
}

# Function to create documentation
create_documentation() {
    log_and_echo "\n${BLUE}=== CREATING DOCUMENTATION ===${NC}"
    
    cat > "/home/simon/Learning-Management-System-Academy/SIMONDATALAB_NGINX_CONFIG_DOCUMENTATION.md" << 'EOF'
# SimonDataLab.de Nginx Configuration Documentation

## Overview
This document details the nginx reverse proxy configuration for simondatalab.de domains on Proxmox host 136.243.155.166.

## Problem Fixed
**Issue**: simondatalab.de was incorrectly serving Moodle PHP instead of proxying to the portfolio container.

**Root Cause**: Nginx server blocks were misconfigured, causing all traffic to be served by Moodle instead of proper domain-based routing.

**Solution**: Created dedicated server blocks for each domain with correct proxy_pass directives.

## Infrastructure Layout

```
Cloudflare Tunnel → Proxmox Host (136.243.155.166) → Backend Services
                    nginx reverse proxy + SSL termination

Domain Routing:
├── simondatalab.de        → 10.0.0.150:80 (Container 150: Portfolio)
├── www.simondatalab.de    → 10.0.0.150:80 (Container 150: Portfolio) 
├── moodle.simondatalab.de → 10.0.0.104:80 (VM 9001: Moodle LMS)
└── *.simondatalab.de      → Various containers/VMs per subdomain
```

## Configuration Files

### Primary Configuration
**File**: `/etc/nginx/sites-available/simondatalab.de`
**Symlink**: `/etc/nginx/sites-enabled/simondatalab.de`

### SSL Certificates
**Path**: `/etc/letsencrypt/live/simondatalab.de/`
- `fullchain.pem` - Full certificate chain
- `privkey.pem` - Private key

## Server Blocks

### 1. Portfolio Website (simondatalab.de, www.simondatalab.de)
- **Backend**: Container 150 at 10.0.0.150:80
- **SSL**: TLS 1.2/1.3 with modern ciphers
- **Features**: Security headers, proper proxy headers, optimized buffers

### 2. Moodle LMS (moodle.simondatalab.de)
- **Backend**: VM 9001 at 10.0.0.104:80
- **SSL**: Same certificate with SAN
- **Features**: Large file uploads (100M), extended timeouts for Moodle

## Key Configuration Elements

### Proxy Headers
```nginx
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header X-Forwarded-Host $server_name;
```

### Security Headers
```nginx
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "no-referrer-when-downgrade" always;
```

## Maintenance Commands

### Backup Configuration
```bash
mkdir -p /root/nginx_backups/$(date +%Y%m%d_%H%M%S)
cp -r /etc/nginx/ /root/nginx_backups/$(date +%Y%m%d_%H%M%S)/
nginx -T > /root/nginx_backups/$(date +%Y%m%d_%H%M%S)/nginx_full_config.txt
```

### Test Configuration
```bash
nginx -t
```

### Reload Configuration
```bash
systemctl reload nginx
```

### Check Status
```bash
systemctl status nginx
```

## Testing Commands

### Test Local (on Proxmox host)
```bash
# Portfolio
curl -H "Host: simondatalab.de" http://localhost/
curl -H "Host: www.simondatalab.de" http://localhost/

# Moodle
curl -H "Host: moodle.simondatalab.de" http://localhost/
```

### Test External
```bash
curl -I https://simondatalab.de/
curl -I https://www.simondatalab.de/
curl -I https://moodle.simondatalab.de/
```

## Troubleshooting

### Common Issues
1. **502 Bad Gateway**: Backend service down
   - Check container/VM status: `pct status 150` or `qm status 9001`
   - Check network connectivity: `curl http://10.0.0.150` or `curl http://10.0.0.104`

2. **SSL Certificate Errors**: Certificate renewal needed
   - Check certificate expiry: `openssl x509 -in /etc/letsencrypt/live/simondatalab.de/fullchain.pem -text -noout | grep "Not After"`
   - Renew: `certbot renew`

3. **Wrong Content Served**: Configuration conflict
   - Check server block order and specificity
   - Verify `server_name` directives

### Log Files
- **Access**: `/var/log/nginx/simondatalab.de_access.log`
- **Error**: `/var/log/nginx/simondatalab.de_error.log`
- **Moodle Access**: `/var/log/nginx/moodle.simondatalab.de_access.log`
- **Moodle Error**: `/var/log/nginx/moodle.simondatalab.de_error.log`

## Change History

| Date | Change | Author |
|------|--------|--------|
| $(date +%Y-%m-%d) | Initial configuration fix for redirect issue | GitHub Copilot + Simon Renauld |

## Contact
For issues or modifications, contact: sn.renauld@gmail.com
EOF

    log_and_echo "${GREEN}✅ Documentation created at: /home/simon/Learning-Management-System-Academy/SIMONDATALAB_NGINX_CONFIG_DOCUMENTATION.md${NC}"
}

# Main execution
main() {
    log_and_echo "${BLUE}Starting nginx configuration fix...${NC}"
    
    # Test current problematic state
    test_current_config
    
    # Backup existing configuration
    backup_nginx_config
    
    # Diagnose current issue
    diagnose_nginx_config
    
    # Create correct configuration
    create_correct_config
    
    # Apply the fix
    apply_nginx_fix
    
    # Verify the fix worked
    verify_fix
    
    # Test external access
    test_external_access
    
    # Create documentation
    create_documentation
    
    log_and_echo "\n${GREEN}============================================================================${NC}"
    log_and_echo "${GREEN}NGINX FIX COMPLETED!${NC}"
    log_and_echo "${GREEN}============================================================================${NC}"
    log_and_echo "📋 Full log: $LOG_FILE"
    log_and_echo "📖 Documentation: /home/simon/Learning-Management-System-Academy/SIMONDATALAB_NGINX_CONFIG_DOCUMENTATION.md"
    log_and_echo ""
    log_and_echo "🔍 Next steps:"
    log_and_echo "   1. Wait 30-60 seconds for Cloudflare cache to update"
    log_and_echo "   2. Test in browser: https://www.simondatalab.de/"
    log_and_echo "   3. Verify portfolio content loads correctly"
}

# Execute main function
main "$@"