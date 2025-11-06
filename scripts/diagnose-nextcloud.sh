#!/bin/bash
# Nextcloud Diagnostic Script

echo "=========================================="
echo "Nextcloud Diagnostic Report"
echo "=========================================="
echo ""

echo "1. DNS Configuration:"
echo "   nextcloud.simondatalab.de:"
dig +short nextcloud.simondatalab.de A
dig +short nextcloud.simondatalab.de CNAME
echo ""

echo "2. HTTPS Access Test:"
curl -sI -L --max-time 10 https://nextcloud.simondatalab.de/ 2>&1 | grep -E "HTTP|Server|Location|cloudflare" | head -10
echo ""

echo "3. Direct IP Access Test (port 9020):"
timeout 3 curl -sI http://136.243.155.166:9020/ 2>&1 || echo "   ❌ Port 9020 not accessible"
echo ""

echo "4. Cloudflare Tunnel Check:"
ps aux | grep -i cloudflared | grep -v grep || echo "   No Cloudflare Tunnel process found"
echo ""

echo "5. Local Port Check:"
sudo netstat -tlnp 2>/dev/null | grep :9020 || echo "   Port 9020 not listening locally"
echo ""

echo "=========================================="
echo "Summary:"
echo "=========================================="
echo ""
echo "Domain: https://nextcloud.simondatalab.de"

# Test if working
if curl -s --max-time 5 https://nextcloud.simondatalab.de/ > /dev/null 2>&1; then
    echo "Status: ✅ WORKING via HTTPS (Cloudflare proxy)"
    echo ""
    echo "Access Method: Cloudflare is proxying requests"
    echo "  - Cloudflare handles SSL/TLS encryption"
    echo "  - Backend server might be via Cloudflare Tunnel"
    echo "  - Direct port 9020 access not needed"
else
    echo "Status: ❌ NOT ACCESSIBLE"
fi

echo ""
echo "Next Steps:"
echo "1. Verify Nextcloud loads in browser: https://nextcloud.simondatalab.de"
echo "2. If working: SSL is already configured via Cloudflare"
echo "3. If not working: Check Cloudflare Tunnel or backend service"
