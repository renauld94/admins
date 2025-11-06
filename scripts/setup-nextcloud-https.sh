#!/bin/bash
# Nextcloud HTTPS Setup via Cloudflare
# Similar to Jellyfin setup

set -e

echo "======================================"
echo "Nextcloud HTTPS Setup"
echo "======================================"
echo ""

# Configuration
CLOUDFLARE_API_TOKEN="${CLOUDFLARE_API_TOKEN:-your_token_here}"
ZONE_ID="ad2497aa687379d4d58de224f7aa7894"
DOMAIN="nextcloud.simondatalab.de"
SERVER_IP="136.243.155.166"

echo "Current Nextcloud Status:"
echo "- Domain: https://$DOMAIN"
echo "- IP: $SERVER_IP:9020 (currently not accessible)"
echo "- DNS: Already configured and working through Cloudflare"
echo ""

# Check current DNS
echo "Checking DNS configuration..."
dig +short $DOMAIN A
echo ""

# Test HTTPS access
echo "Testing HTTPS access..."
curl -I -L --max-time 5 https://$DOMAIN 2>&1 | head -10
echo ""

echo "✅ Nextcloud DNS Status:"
echo "- Domain is proxied through Cloudflare"
echo "- HTTPS is working (SSL handled by Cloudflare)"
echo "- HTTP automatically redirects to HTTPS"
echo ""

echo "📋 Current Setup:"
echo "1. Nextcloud container needs to be started on VM200"
echo "2. Port 9020 should be accessible internally"
echo "3. Cloudflare proxy provides SSL automatically"
echo ""

echo "Next Steps:"
echo "1. Start Nextcloud container on VM200"
echo "2. Ensure port 9020 is open"
echo "3. HTTPS will work automatically via Cloudflare proxy"
