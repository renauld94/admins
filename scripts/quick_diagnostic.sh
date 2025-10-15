#!/bin/bash
# Quick Diagnostic - Copy/Paste into Proxmox Host Terminal
# Identifies simondatalab.de → moodle redirect conflict

echo "=== QUICK DIAGNOSTIC FOR REDIRECT CONFLICT ==="
echo "Date: $(date)"
echo "Host: $(hostname)"
echo ""

echo "=== 1. IPTABLES NAT RULES (Port 80/443) ==="
iptables -t nat -L PREROUTING -n -v --line-numbers | grep -E "dpt:80|dpt:443|Chain"
echo ""

echo "=== 2. LISTENING ON PORT 80 ==="
netstat -tuln | grep ":80 "
echo ""

echo "=== 3. NGINX CHECK ==="
if command -v nginx &> /dev/null; then
    echo "Nginx is installed"
    systemctl status nginx --no-pager | head -5
    echo ""
    echo "Nginx sites-enabled:"
    ls -la /etc/nginx/sites-enabled/
    echo ""
    echo "Nginx configs with simondatalab:"
    grep -r "simondatalab.de" /etc/nginx/ 2>/dev/null | head -20
    echo ""
    echo "Nginx configs with moodle:"
    grep -r "moodle" /etc/nginx/ 2>/dev/null | head -20
else
    echo "Nginx not installed"
fi
echo ""

echo "=== 4. CADDY CHECK ==="
if command -v caddy &> /dev/null; then
    echo "Caddy is installed"
    systemctl status caddy --no-pager | head -5
    echo ""
    if [ -f "/etc/caddy/Caddyfile" ]; then
        echo "Caddyfile content:"
        cat /etc/caddy/Caddyfile
    fi
else
    echo "Caddy not installed"
fi
echo ""

echo "=== 5. CLOUDFLARED CHECK ==="
systemctl status cloudflared --no-pager 2>&1 | head -10
echo ""
if [ -f "/etc/cloudflared/config.yml" ]; then
    echo "Cloudflared config:"
    cat /etc/cloudflared/config.yml
fi
if [ -f "/root/.cloudflared/config.yml" ]; then
    echo "Cloudflared config (root):"
    cat /root/.cloudflared/config.yml
fi
echo ""

echo "=== 6. HTTP TEST ==="
echo "Test localhost:"
curl -sI http://localhost/ | head -5
echo ""
echo "Test simondatalab.de:"
curl -sI -H "Host: simondatalab.de" http://localhost/ | head -5
echo ""
echo "Test www.simondatalab.de:"
curl -sI -H "Host: www.simondatalab.de" http://localhost/ | head -5
echo ""

echo "=== 7. PROXMOX CONTAINERS ==="
if command -v pct &> /dev/null; then
    echo "CT 150 (portfolio):"
    pct status 150
    echo ""
    echo "CT 104 (moodle):"
    pct status 104
    echo ""
fi

echo "=== DIAGNOSTIC COMPLETE ==="
echo "Look for:"
echo "1. iptables DNAT rules pointing to wrong IP"
echo "2. Nginx/Caddy default_server catching all traffic"
echo "3. Cloudflared routing to wrong backend"
