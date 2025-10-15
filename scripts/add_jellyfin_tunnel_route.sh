#!/bin/bash
#
# Add Jellyfin to Cloudflare Tunnel
# This script adds a tunnel route for jellyfin.simondatalab.de
#

echo "╔════════════════════════════════════════════════════════════╗"
echo "║    Cloudflare Tunnel Route - Jellyfin Setup Guide         ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo

echo "Current Situation:"
echo "  • jellyfin.simondatalab.de DNS record already exists ✓"
echo "  • Jellyfin running on VM 200: 10.0.0.103:8096 ✓"
echo "  • Tunnel: simondatalab-tunnel ✓"
echo

echo "════════════════════════════════════════════════════════════"
echo "  SOLUTION: Add Route Using Existing DNS Record"
echo "════════════════════════════════════════════════════════════"
echo

echo "Method 1: Via Cloudflare Dashboard (Easiest)"
echo "────────────────────────────────────────────────────────────"
echo "1. Go to: https://one.dash.cloudflare.com/"
echo "2. Navigate to: Zero Trust → Access → Tunnels"
echo "3. Select: simondatalab-tunnel"
echo "4. Click: 'Add a public hostname'"
echo "5. Configure:"
echo "   • Subdomain: jellyfin"
echo "   • Domain: simondatalab.de"
echo "   • Path: (leave empty)"
echo "   • Service:"
echo "     - Type: HTTP"
echo "     - URL: 10.0.0.103:8096"
echo "6. Advanced settings (optional):"
echo "   • HTTP Host Header: (leave default)"
echo "   • Origin Server Name: (leave default)"
echo "   • No TLS Verify: OFF (keep secure)"
echo "7. Click 'Save hostname'"
echo

echo "Expected Result:"
echo "  ✓ Route added to tunnel configuration"
echo "  ✓ Uses existing jellyfin.simondatalab.de DNS record"
echo "  ✓ Accessible at: https://jellyfin.simondatalab.de"
echo

echo "════════════════════════════════════════════════════════════"
echo "  Alternative: Use Different Subdomain"
echo "════════════════════════════════════════════════════════════"
echo

echo "If you encounter DNS conflicts, try these alternatives:"
echo "  • tv.simondatalab.de"
echo "  • jf.simondatalab.de"
echo "  • media.simondatalab.de"
echo "  • stream.simondatalab.de"
echo

echo "════════════════════════════════════════════════════════════"
echo "  Verification Commands"
echo "════════════════════════════════════════════════════════════"
echo

echo "After adding the route, verify with:"
echo

echo "# Check DNS resolution"
echo "nslookup jellyfin.simondatalab.de"
echo

echo "# Test HTTP connection"
echo "curl -I https://jellyfin.simondatalab.de"
echo

echo "# Check if Jellyfin responds"
echo "curl -L https://jellyfin.simondatalab.de/web/ | head -n 20"
echo

echo "════════════════════════════════════════════════════════════"
echo "  Your Current Published Routes"
echo "════════════════════════════════════════════════════════════"
echo

cat << 'ROUTES'
 #  | Hostname                        | Service
────┼─────────────────────────────────┼──────────────────────────
 1  | simondatalab.de                 | http://10.0.0.150:80
 2  | www.simondatalab.de             | http://10.0.0.150:80
 3  | moodle.simondatalab.de          | http://10.0.0.104:80
 4  | grafana.simondatalab.de         | http://10.0.0.104:3000
 5  | openwebui.simondatalab.de       | http://10.0.0.110:3001
 6  | geoneuralviz.simondatalab.de    | http://10.0.0.106:8080
 7  | booklore.simondatalab.de        | http://10.0.0.103:6060
 8  | ollama.simondatalab.de          | http://10.0.0.110:11434
 9  | mlflow.simondatalab.de          | http://10.0.0.110:5000
────┴─────────────────────────────────┴──────────────────────────
ROUTES

echo
echo "After adding Jellyfin route, you'll have:"
echo " 10 | jellyfin.simondatalab.de        | http://10.0.0.103:8096"
echo

echo "════════════════════════════════════════════════════════════"
echo "  Next Steps After Route is Added"
echo "════════════════════════════════════════════════════════════"
echo

echo "1. Access Jellyfin via tunnel:"
echo "   https://jellyfin.simondatalab.de"
echo

echo "2. Or continue using direct IP:"
echo "   http://136.243.155.166:8096/web/"
echo

echo "3. Set up IPTV channels:"
echo "   cd /home/simon/Learning-Management-System-Academy/scripts"
echo "   ./setup_jellyfin_iptv.sh"
echo

echo "4. Configure in Jellyfin:"
echo "   Admin Dashboard → Live TV → Add Tuner → M3U Tuner"
echo

echo "════════════════════════════════════════════════════════════"

exit 0
