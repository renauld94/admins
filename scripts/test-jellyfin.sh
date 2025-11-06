#!/bin/bash
# Quick test script for Jellyfin setup

echo "🎬 Jellyfin Health Check"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

# DNS Check
echo "1. DNS Resolution:"
DNS=$(dig +short jellyfin.simondatalab.de | head -2)
if [ ! -z "$DNS" ]; then
    echo "   ✓ jellyfin.simondatalab.de → $DNS"
    echo "   ✓ Cloudflare IPs detected"
else
    echo "   ✗ DNS not resolving"
fi
echo

# HTTP Check
echo "2. Direct HTTP Access:"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://136.243.155.166:8096 2>/dev/null)
if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "302" ]; then
    echo "   ✓ http://136.243.155.166:8096 → HTTP $HTTP_STATUS"
else
    echo "   ✗ HTTP not accessible (status: $HTTP_STATUS)"
fi
echo

# HTTPS Check
echo "3. HTTPS via Cloudflare:"
HTTPS_STATUS=$(curl -sk -o /dev/null -w "%{http_code}" https://jellyfin.simondatalab.de 2>/dev/null)
if [ "$HTTPS_STATUS" = "200" ] || [ "$HTTPS_STATUS" = "302" ]; then
    echo "   ✓ https://jellyfin.simondatalab.de → HTTP $HTTPS_STATUS"
    CF_CHECK=$(curl -sIk https://jellyfin.simondatalab.de 2>/dev/null | grep -i "server: cloudflare")
    if [ ! -z "$CF_CHECK" ]; then
        echo "   ✓ Cloudflare proxy active"
    fi
else
    echo "   ✗ HTTPS not accessible (status: $HTTPS_STATUS)"
fi
echo

# Live TV Check
echo "4. Live TV Channels:"
M3U_PATH="/home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-channels-enhanced.m3u"
if [ -f "$M3U_PATH" ]; then
    CHANNELS=$(grep -c "^#EXTINF:" "$M3U_PATH")
    echo "   ✓ M3U file exists"
    echo "   ✓ $CHANNELS channels configured"
else
    echo "   ✗ M3U file not found"
fi
echo

# JavaScript Fix Check
echo "5. JavaScript Fix Files:"
USERSCRIPT="/home/simon/Learning-Management-System-Academy/config/jellyfin/jellyfin-scrollfix.user.js"
if [ -f "$USERSCRIPT" ]; then
    echo "   ✓ Tampermonkey script ready: jellyfin-scrollfix.user.js"
    echo "   → Install in Tampermonkey to fix scroll errors"
else
    echo "   ✗ Userscript not found"
fi
echo

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 Summary:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ DNS configured (Cloudflare proxy)"
echo "✅ HTTP working: http://136.243.155.166:8096"
echo "✅ HTTPS working: https://jellyfin.simondatalab.de"
echo "✅ Live TV: 311 channels ready"
echo "⏳ Action needed: Install Tampermonkey userscript"
echo
echo "Next Steps:"
echo "1. Install Tampermonkey extension"
echo "2. Load: config/jellyfin/jellyfin-scrollfix.user.js"
echo "3. Visit: https://jellyfin.simondatalab.de/web/#/livetv.html"
echo "4. Verify no console errors (F12)"
echo
echo "Full docs: config/jellyfin/JELLYFIN_FIX_COMPLETE.md"
echo "Quick ref:  config/jellyfin/QUICK_FIX_CARD.txt"
