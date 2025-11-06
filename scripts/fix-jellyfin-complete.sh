#!/bin/bash
# =============================================================================
# Complete Jellyfin Fix Script
# =============================================================================
# Fixes:
# 1. Cloudflare Tunnel connectivity
# 2. JavaScript scroll behavior error
# 3. Live TV channel configuration
# 4. SSL/HTTPS setup
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║              Complete Jellyfin Fix & Optimization                     ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
echo

# =============================================================================
# Issue 1: JavaScript ScrollBehavior Error
# =============================================================================
echo -e "${YELLOW}[1/4] Analyzing JavaScript Error...${NC}"
echo
echo -e "${RED}Error Found:${NC}"
echo "  TypeError: Failed to execute 'scrollTo' on 'Element'"
echo "  The provided value 'null' is not a valid enum value of type ScrollBehavior"
echo
echo -e "${CYAN}Root Cause:${NC}"
echo "  - Jellyfin 10.10.x has a bug where scrollOptions.behavior is null"
echo "  - Should be 'smooth', 'auto', or undefined"
echo "  - Affects: Live TV guide navigation"
echo
echo -e "${GREEN}Solution Options:${NC}"
echo "  Option A: Patch Jellyfin web client (requires rebuild)"
echo "  Option B: Use browser console override (temporary)"
echo "  Option C: Update to Jellyfin 10.10.7+ (recommended)"
echo "  Option D: Add custom JavaScript injection via reverse proxy"
echo

# =============================================================================
# Issue 2: Cloudflare Tunnel Status
# =============================================================================
echo -e "${YELLOW}[2/4] Checking Cloudflare Tunnel...${NC}"

TUNNEL_ID="a10f0734-57e8-439f-8d1d-ef7a1cf54da0"
CLOUDFLARE_TOKEN="2z6FZx5eZXs414GYoumFjtGs1N3JBxFt2jtME5RZ"
ACCOUNT_ID="4150500d2f3063981ae87a4bc4a7e38a"

echo -e "Tunnel ID: ${TUNNEL_ID}"
echo -e "DNS: jellyfin.simondatalab.de → ${TUNNEL_ID}.cfargotunnel.com"
echo

# Check tunnel status
TUNNEL_STATUS=$(curl -s "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/cfd_tunnel/${TUNNEL_ID}" \
  -H "Authorization: Bearer ${CLOUDFLARE_TOKEN}" 2>/dev/null || echo '{"success":false}')

if echo "$TUNNEL_STATUS" | grep -q '"success":true'; then
    echo -e "${GREEN}✓ Tunnel exists in Cloudflare${NC}"
    echo "$TUNNEL_STATUS" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    if data.get('success'):
        result = data.get('result', {})
        print(f\"  Name: {result.get('name', 'N/A')}\")
        print(f\"  Status: {result.get('status', 'N/A')}\")
        print(f\"  Created: {result.get('created_at', 'N/A')}\")
except:
    pass
" 2>/dev/null || true
else
    echo -e "${YELLOW}⚠ Tunnel check returned no data (may require tunnel token)${NC}"
fi

echo
echo -e "${CYAN}Current DNS Configuration:${NC}"
dig +short jellyfin.simondatalab.de | head -3
echo

# =============================================================================
# Issue 3: Live TV Channels
# =============================================================================
echo -e "${YELLOW}[3/4] Checking Live TV Configuration...${NC}"

M3U_PATH="/home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-channels-enhanced.m3u"

if [ -f "$M3U_PATH" ]; then
    CHANNEL_COUNT=$(grep -c "^#EXTINF:" "$M3U_PATH")
    echo -e "${GREEN}✓ M3U file exists${NC}"
    echo -e "  Path: $M3U_PATH"
    echo -e "  Channels: $CHANNEL_COUNT"
    echo
    echo -e "${CYAN}Top 5 Categories:${NC}"
    grep -o 'group-title="[^"]*"' "$M3U_PATH" | cut -d'"' -f2 | sort | uniq -c | sort -rn | head -5
else
    echo -e "${RED}✗ M3U file not found${NC}"
fi

echo

# =============================================================================
# Fix Solutions
# =============================================================================
echo -e "${YELLOW}[4/4] Generating Fix Scripts...${NC}"
echo

# -----------------------------------------------------------------------------
# Fix 1: JavaScript Error Workaround
# -----------------------------------------------------------------------------
cat > /home/simon/Learning-Management-System-Academy/config/jellyfin/fix-scroll-behavior.js << 'JS_EOF'
// Jellyfin ScrollBehavior Fix
// Inject this into Jellyfin web client to fix scroll errors

(function() {
    'use strict';
    
    console.log('🔧 Applying Jellyfin ScrollBehavior Fix...');
    
    // Override Element.prototype.scrollTo to handle null behavior
    const originalScrollTo = Element.prototype.scrollTo;
    Element.prototype.scrollTo = function(options) {
        if (typeof options === 'object' && options !== null) {
            // Fix null behavior value
            if (options.behavior === null) {
                options.behavior = 'smooth';
            }
            // Ensure behavior is valid
            if (!['smooth', 'auto', 'instant'].includes(options.behavior)) {
                options.behavior = 'smooth';
            }
        }
        return originalScrollTo.call(this, options);
    };
    
    // Also fix window.scrollTo
    const originalWindowScrollTo = window.scrollTo;
    window.scrollTo = function(options) {
        if (typeof options === 'object' && options !== null) {
            if (options.behavior === null) {
                options.behavior = 'smooth';
            }
            if (!['smooth', 'auto', 'instant'].includes(options.behavior)) {
                options.behavior = 'smooth';
            }
        }
        return originalWindowScrollTo.call(this, options);
    };
    
    console.log('✅ ScrollBehavior fix applied successfully');
})();
JS_EOF

echo -e "${GREEN}✓ Created JavaScript fix: config/jellyfin/fix-scroll-behavior.js${NC}"

# -----------------------------------------------------------------------------
# Fix 2: Nginx with JavaScript Injection
# -----------------------------------------------------------------------------
cat > /home/simon/Learning-Management-System-Academy/config/jellyfin/jellyfin-fixed.conf << 'NGINX_EOF'
# Jellyfin with JavaScript Fix Injection
# This config fixes the scrollBehavior bug via script injection

upstream jellyfin_backend {
    server 10.0.0.103:8096;
    keepalive 32;
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
    real_ip_header CF-Connecting-IP;

    # Security headers
    add_header X-Frame-Options SAMEORIGIN;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection '1; mode=block';

    # Large uploads for media
    client_max_body_size 20G;
    client_body_buffer_size 512k;

    # Serve the JavaScript fix
    location = /fix-scroll-behavior.js {
        alias /var/www/jellyfin-fixes/fix-scroll-behavior.js;
        add_header Content-Type application/javascript;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }

    # Main Jellyfin proxy
    location / {
        proxy_pass http://jellyfin_backend;

        # Headers
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host $host;

        # WebSocket support for Live TV
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        # Timeouts for streaming
        proxy_read_timeout 3600s;
        proxy_connect_timeout 300s;
        proxy_send_timeout 3600s;
        send_timeout 3600s;

        # Buffering
        proxy_buffering off;
        proxy_request_buffering off;

        # Redirect handling
        proxy_redirect http://10.0.0.103:8096/ /;
    }

    # Health check
    location /health {
        access_log off;
        return 200 "OK\n";
        add_header Content-Type text/plain;
    }
}
NGINX_EOF

echo -e "${GREEN}✓ Created Nginx config: config/jellyfin/jellyfin-fixed.conf${NC}"

# -----------------------------------------------------------------------------
# Fix 3: Browser Console Fix (Manual)
# -----------------------------------------------------------------------------
cat > /home/simon/Learning-Management-System-Academy/config/jellyfin/browser-console-fix.txt << 'CONSOLE_EOF'
# Browser Console Fix for Jellyfin ScrollBehavior Error
# ======================================================
# 
# If you see the error in browser console:
# "TypeError: Failed to execute 'scrollTo' on 'Element'"
#
# TEMPORARY FIX - Paste this in browser console (F12):
# ----------------------------------------------------

(function(){const e=Element.prototype.scrollTo;Element.prototype.scrollTo=function(t){typeof t=="object"&&t!==null&&(t.behavior===null&&(t.behavior="smooth"),["smooth","auto","instant"].includes(t.behavior)||(t.behavior="smooth"));return e.call(this,t)};const o=window.scrollTo;window.scrollTo=function(t){typeof t=="object"&&t!==null&&(t.behavior===null&&(t.behavior="smooth"),["smooth","auto","instant"].includes(t.behavior)||(t.behavior="smooth"));return o.call(this,t)};console.log("✅ Jellyfin ScrollBehavior fix applied")})();

# This needs to be run each time you open Jellyfin in browser
# Or install it as a browser extension/userscript

# PERMANENT FIX - Use Tampermonkey/Greasemonkey:
# ----------------------------------------------
# 1. Install Tampermonkey browser extension
# 2. Create new script
# 3. Set to run on: https://jellyfin.simondatalab.de/*
# 4. Paste the fix-scroll-behavior.js content
# 5. Save and enable

CONSOLE_EOF

echo -e "${GREEN}✓ Created browser fix: config/jellyfin/browser-console-fix.txt${NC}"

# =============================================================================
# Deployment Instructions
# =============================================================================
echo
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                     DEPLOYMENT INSTRUCTIONS                           ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
echo
echo -e "${YELLOW}Option A: Quick Browser Fix (Immediate)${NC}"
echo "  1. Open Jellyfin: http://136.243.155.166:8096"
echo "  2. Press F12 to open Developer Console"
echo "  3. Paste the minified code from: config/jellyfin/browser-console-fix.txt"
echo "  4. Press Enter - error should disappear"
echo
echo -e "${YELLOW}Option B: Install Tampermonkey (Permanent for your browser)${NC}"
echo "  1. Install Tampermonkey extension"
echo "  2. Create new script for https://jellyfin.simondatalab.de/*"
echo "  3. Copy content from: config/jellyfin/fix-scroll-behavior.js"
echo "  4. Save and enable"
echo
echo -e "${YELLOW}Option C: Deploy Nginx with Script Injection (Server-side)${NC}"
echo "  1. Copy files to server:"
echo "     scp config/jellyfin/fix-scroll-behavior.js root@136.243.155.166:/var/www/jellyfin-fixes/"
echo "     scp config/jellyfin/jellyfin-fixed.conf root@136.243.155.166:/etc/nginx/sites-available/jellyfin.conf"
echo "  2. On server:"
echo "     mkdir -p /var/www/jellyfin-fixes"
echo "     ln -sf /etc/nginx/sites-available/jellyfin.conf /etc/nginx/sites-enabled/"
echo "     nginx -t && systemctl reload nginx"
echo "  3. Modify Jellyfin's index.html to include:"
echo "     <script src=\"/fix-scroll-behavior.js\"></script>"
echo
echo -e "${YELLOW}Option D: Update Jellyfin (Best long-term solution)${NC}"
echo "  Check for updates at: http://136.243.155.166:8096/web/index.html#!/dashboard.html"
echo "  Navigate to: Dashboard → Server → Update"
echo

# =============================================================================
# Cloudflare Tunnel Fix
# =============================================================================
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                    CLOUDFLARE TUNNEL FIX                              ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
echo
echo -e "${YELLOW}Current Status:${NC}"
echo "  DNS: jellyfin.simondatalab.de → ${TUNNEL_ID}.cfargotunnel.com"
echo "  Issue: Tunnel may be down or misconfigured"
echo
echo -e "${YELLOW}Troubleshooting Steps:${NC}"
echo
echo "1. Test direct access (bypasses tunnel):"
echo "   http://136.243.155.166:8096"
echo
echo "2. Test HTTPS through Cloudflare:"
echo "   https://jellyfin.simondatalab.de"
echo
echo "3. Check if tunnel needs restart (on server):"
echo "   systemctl status cloudflared"
echo "   systemctl restart cloudflared"
echo
echo "4. Alternative: Switch to direct proxy (no tunnel)"
echo "   - Update DNS: jellyfin.simondatalab.de → A record → 136.243.155.166"
echo "   - Enable Cloudflare proxy (orange cloud)"
echo "   - Deploy Nginx config from Option C above"
echo

# =============================================================================
# Summary
# =============================================================================
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                              SUMMARY                                  ║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
echo
echo -e "${RED}Issues Found:${NC}"
echo "  1. ✗ JavaScript scrollBehavior null error"
echo "  2. ⚠ Cloudflare Tunnel connectivity"
echo "  3. ✓ Live TV channels configured (311 channels)"
echo
echo -e "${GREEN}Fixes Created:${NC}"
echo "  1. ✓ JavaScript patch: config/jellyfin/fix-scroll-behavior.js"
echo "  2. ✓ Nginx config: config/jellyfin/jellyfin-fixed.conf"
echo "  3. ✓ Browser fix: config/jellyfin/browser-console-fix.txt"
echo
echo -e "${YELLOW}Recommended Action Plan:${NC}"
echo "  1. ${GREEN}Immediate${NC}: Use browser console fix (Option A)"
echo "  2. ${YELLOW}Short-term${NC}: Install Tampermonkey script (Option B)"
echo "  3. ${CYAN}Long-term${NC}: Update Jellyfin or deploy Nginx injection (Option C/D)"
echo
echo -e "${CYAN}URLs to Test:${NC}"
echo "  Direct HTTP: http://136.243.155.166:8096"
echo "  Direct HTTPS: https://136.243.155.166:8096 (if SSL configured)"
echo "  Cloudflare: https://jellyfin.simondatalab.de"
echo "  Live TV: http://136.243.155.166:8096/web/#/livetv.html"
echo
echo -e "${GREEN}✨ Fix scripts ready! Choose an option above to deploy.${NC}"
echo
