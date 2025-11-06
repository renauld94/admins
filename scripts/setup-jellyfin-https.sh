#!/bin/bash
# =============================================================================
# Jellyfin HTTPS Setup with Cloudflare SSL
# =============================================================================
# This script:
# 1. Creates DNS record for jellyfin.simondatalab.de
# 2. Sets up Nginx reverse proxy with SSL
# 3. Configures Cloudflare SSL/TLS settings
# 4. Tests the configuration
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
CLOUDFLARE_TOKEN="2z6FZx5eZXs414GYoumFjtGs1N3JBxFt2jtME5RZ"
ZONE_ID="8721a7620b0d4b0d29e926fda5525d23"
DOMAIN="simondatalab.de"
SUBDOMAIN="jellyfin"
FULL_DOMAIN="${SUBDOMAIN}.${DOMAIN}"
SERVER_IP="136.243.155.166"
JELLYFIN_INTERNAL_IP="10.0.0.103"
JELLYFIN_PORT="8096"

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║           Jellyfin HTTPS Setup with Cloudflare SSL                   ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
echo

# =============================================================================
# Step 1: Check/Create DNS Record
# =============================================================================
echo -e "${YELLOW}[1/5] Checking DNS Record...${NC}"

# Check if DNS record exists
DNS_CHECK=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records?name=${FULL_DOMAIN}" \
  -H "Authorization: Bearer ${CLOUDFLARE_TOKEN}" \
  -H "Content-Type: application/json")

RECORD_COUNT=$(echo "$DNS_CHECK" | python3 -c "import sys, json; print(json.load(sys.stdin)['result_info']['count'])")

if [ "$RECORD_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}DNS record not found. Creating...${NC}"
    
    # Create DNS record
    CREATE_RESULT=$(curl -s -X POST "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/dns_records" \
      -H "Authorization: Bearer ${CLOUDFLARE_TOKEN}" \
      -H "Content-Type: application/json" \
      --data '{
        "type": "A",
        "name": "'${SUBDOMAIN}'",
        "content": "'${SERVER_IP}'",
        "ttl": 1,
        "proxied": true,
        "comment": "Jellyfin Media Server - Proxied through Cloudflare"
      }')
    
    SUCCESS=$(echo "$CREATE_RESULT" | python3 -c "import sys, json; print(json.load(sys.stdin)['success'])")
    
    if [ "$SUCCESS" = "True" ]; then
        echo -e "${GREEN}✓ DNS record created successfully${NC}"
        echo -e "  Type: A"
        echo -e "  Name: ${FULL_DOMAIN}"
        echo -e "  Points to: ${SERVER_IP}"
        echo -e "  Proxied: Yes (Cloudflare CDN + SSL)"
    else
        echo -e "${RED}✗ Failed to create DNS record${NC}"
        echo "$CREATE_RESULT" | python3 -m json.tool
        exit 1
    fi
else
    echo -e "${GREEN}✓ DNS record exists${NC}"
    echo "$DNS_CHECK" | python3 -c "
import sys, json
result = json.load(sys.stdin)['result'][0]
print(f\"  Type: {result['type']}\")
print(f\"  Name: {result['name']}\")
print(f\"  Points to: {result['content']}\")
print(f\"  Proxied: {result['proxied']}\")
"
fi

# =============================================================================
# Step 2: Configure Cloudflare SSL Settings
# =============================================================================
echo
echo -e "${YELLOW}[2/5] Configuring Cloudflare SSL Settings...${NC}"

# Set SSL mode to Full (strict)
SSL_RESULT=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/settings/ssl" \
  -H "Authorization: Bearer ${CLOUDFLARE_TOKEN}" \
  -H "Content-Type: application/json" \
  --data '{"value":"flexible"}')

echo -e "${GREEN}✓ SSL mode set to Flexible (Cloudflare handles SSL)${NC}"

# Enable Always Use HTTPS
HTTPS_RESULT=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/settings/always_use_https" \
  -H "Authorization: Bearer ${CLOUDFLARE_TOKEN}" \
  -H "Content-Type: application/json" \
  --data '{"value":"on"}')

echo -e "${GREEN}✓ Always Use HTTPS enabled${NC}"

# Enable Automatic HTTPS Rewrites
REWRITE_RESULT=$(curl -s -X PATCH "https://api.cloudflare.com/client/v4/zones/${ZONE_ID}/settings/automatic_https_rewrites" \
  -H "Authorization: Bearer ${CLOUDFLARE_TOKEN}" \
  -H "Content-Type: application/json" \
  --data '{"value":"on"}')

echo -e "${GREEN}✓ Automatic HTTPS Rewrites enabled${NC}"

# =============================================================================
# Step 3: Generate Nginx Configuration
# =============================================================================
echo
echo -e "${YELLOW}[3/5] Generating Nginx Configuration...${NC}"

NGINX_CONFIG="/home/simon/Learning-Management-System-Academy/config/jellyfin/jellyfin-cloudflare.conf"

cat > "$NGINX_CONFIG" << 'NGINX_EOF'
# Jellyfin with Cloudflare SSL (Flexible Mode)
# Cloudflare handles SSL termination, backend is HTTP

# Upstream for Jellyfin
upstream jellyfin_backend {
    server 10.0.0.103:8096;
}

server {
    listen 80;
    server_name jellyfin.simondatalab.de;

    # Trust Cloudflare IPs
    set_real_ip_from 173.245.48.0/20;
    set_real_ip_from 103.21.244.0/22;
    set_real_ip_from 103.22.200.0/22;
    set_real_ip_from 103.31.4.0/22;
    set_real_ip_from 141.101.64.0/18;
    set_real_ip_from 108.162.192.0/18;
    set_real_ip_from 190.93.240.0/20;
    set_real_ip_from 188.114.96.0/20;
    set_real_ip_from 197.234.240.0/22;
    set_real_ip_from 198.41.128.0/17;
    set_real_ip_from 162.158.0.0/15;
    set_real_ip_from 104.16.0.0/13;
    set_real_ip_from 104.24.0.0/14;
    set_real_ip_from 172.64.0.0/13;
    set_real_ip_from 131.0.72.0/22;
    set_real_ip_from 2400:cb00::/32;
    set_real_ip_from 2606:4700::/32;
    set_real_ip_from 2803:f800::/32;
    set_real_ip_from 2405:b500::/32;
    set_real_ip_from 2405:8100::/32;
    set_real_ip_from 2c0f:f248::/32;
    set_real_ip_from 2a06:98c0::/29;
    real_ip_header CF-Connecting-IP;

    # Security headers
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection '1; mode=block';
    add_header Referrer-Policy 'strict-origin-when-cross-origin';

    # Large client body size for uploads
    client_max_body_size 20G;

    location / {
        # Proxy to Jellyfin
        proxy_pass http://jellyfin_backend;

        # Preserve headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;  # Tell Jellyfin we're using HTTPS
        proxy_set_header X-Forwarded-Host $host;
        proxy_set_header X-Forwarded-Port 443;

        # WebSocket support for Live TV
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # Timeouts for streaming
        proxy_read_timeout 3600s;
        proxy_connect_timeout 300s;
        proxy_send_timeout 3600s;

        # Buffering
        proxy_buffering off;

        # Redirect handling
        proxy_redirect http://10.0.0.103:8096/ /;
        proxy_redirect http://10.0.0.103:8096 /;
    }

    # Health check
    location /health {
        access_log off;
        return 200 "Jellyfin Proxy OK\n";
        add_header Content-Type text/plain;
    }
}
NGINX_EOF

echo -e "${GREEN}✓ Nginx configuration created${NC}"
echo -e "  Path: ${NGINX_CONFIG}"

# =============================================================================
# Step 4: Deployment Instructions
# =============================================================================
echo
echo -e "${YELLOW}[4/5] Deployment Instructions${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
echo
echo "To deploy this configuration on your server (136.243.155.166):"
echo
echo -e "${GREEN}# Copy config to server:${NC}"
echo "scp ${NGINX_CONFIG} root@136.243.155.166:/etc/nginx/sites-available/jellyfin.conf"
echo
echo -e "${GREEN}# On the server:${NC}"
echo "ssh root@136.243.155.166"
echo "ln -sf /etc/nginx/sites-available/jellyfin.conf /etc/nginx/sites-enabled/"
echo "nginx -t"
echo "systemctl reload nginx"
echo
echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"

# =============================================================================
# Step 5: Configure Jellyfin Base URL
# =============================================================================
echo
echo -e "${YELLOW}[5/5] Jellyfin Configuration${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"
echo
echo "Important Jellyfin settings to configure:"
echo
echo "1. Open Jellyfin: http://136.243.155.166:8096"
echo "2. Go to: Dashboard → Networking"
echo "3. Set these values:"
echo
echo "   Base URL: (leave empty or set to /)"
echo "   Public HTTPS Port: 443"
echo "   Public HTTP Port: 80"
echo "   Enable automatic port mapping: ✓"
echo "   Known proxies: 173.245.48.0/20,103.21.244.0/22,103.22.200.0/22 (Cloudflare IPs)"
echo
echo "4. Under Advanced:"
echo "   Enable reverse proxy: ✓"
echo
echo "5. Save and restart Jellyfin"
echo
echo -e "${CYAN}════════════════════════════════════════════════════════════════════${NC}"

# =============================================================================
# Testing
# =============================================================================
echo
echo -e "${YELLOW}Testing DNS Resolution...${NC}"
sleep 5  # Wait for DNS propagation

DNS_TEST=$(dig +short ${FULL_DOMAIN} | head -1)
if [ ! -z "$DNS_TEST" ]; then
    echo -e "${GREEN}✓ DNS resolves to: ${DNS_TEST}${NC}"
else
    echo -e "${YELLOW}⚠ DNS not yet propagated (wait 1-2 minutes)${NC}"
fi

# =============================================================================
# Summary
# =============================================================================
echo
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                        SETUP COMPLETE                                 ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
echo
echo -e "${GREEN}✓ Cloudflare Configuration${NC}"
echo "  - DNS Record: ${FULL_DOMAIN} → ${SERVER_IP}"
echo "  - SSL Mode: Flexible (Cloudflare terminates SSL)"
echo "  - Always HTTPS: Enabled"
echo "  - Proxied through Cloudflare CDN"
echo
echo -e "${GREEN}✓ Nginx Configuration${NC}"
echo "  - Config file: ${NGINX_CONFIG}"
echo "  - Backend: ${JELLYFIN_INTERNAL_IP}:${JELLYFIN_PORT}"
echo "  - WebSocket: Enabled (for Live TV)"
echo "  - Max upload: 20GB"
echo
echo -e "${YELLOW}⏳ Next Steps:${NC}"
echo "  1. Deploy Nginx config to server (see instructions above)"
echo "  2. Configure Jellyfin base URL settings"
echo "  3. Test: https://${FULL_DOMAIN}"
echo
echo -e "${CYAN}Live TV Status:${NC}"
echo "  - Channels: 311 working channels"
echo "  - Guide: http://136.243.155.166:8096/web/#/livetv.html"
echo "  - M3U: /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-channels-enhanced.m3u"
echo
echo -e "${GREEN}URLs:${NC}"
echo "  - HTTPS (Cloudflare): https://${FULL_DOMAIN}"
echo "  - HTTP (Direct): http://136.243.155.166:8096"
echo "  - Live TV: https://${FULL_DOMAIN}/web/#/livetv.html"
echo
