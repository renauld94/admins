#!/bin/bash
#
# Quick Setup: ProtonVPN Free for Jellyfin IPTV
# This script sets up a free VPN for your Jellyfin instance
#

set -e

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   ProtonVPN Free Setup for Jellyfin IPTV                  ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo

echo "🔐 ProtonVPN Free - Unlimited Data, No Cost!"
echo

# Check if already have credentials
if [[ -z "${PROTON_USER}" ]] || [[ -z "${PROTON_PASS}" ]]; then
    echo "⚠️  You need ProtonVPN credentials first!"
    echo
    echo "Steps to get credentials:"
    echo "  1. Go to: https://protonvpn.com/free-vpn"
    echo "  2. Sign up for free account"
    echo "  3. Login to your account"
    echo "  4. Go to: Account → OpenVPN/IKEv2 username"
    echo "  5. Copy the USERNAME and PASSWORD (NOT your login!)"
    echo
    echo "Then run this script again with:"
    echo "  export PROTON_USER='your_openvpn_username'"
    echo "  export PROTON_PASS='your_openvpn_password'"
    echo "  ./setup_protonvpn_free.sh"
    echo
    exit 1
fi

echo "✓ Credentials found!"
echo "  Username: ${PROTON_USER:0:10}..."
echo

# Ask for country
echo "Available free server locations:"
echo "  1. United States (US)"
echo "  2. Netherlands (NL)"
echo "  3. Japan (JP)"
echo

read -p "Choose location (1-3) [default: 1 - US]: " choice
choice=${choice:-1}

case $choice in
    1) COUNTRY="United States" ;;
    2) COUNTRY="Netherlands" ;;
    3) COUNTRY="Japan" ;;
    *) COUNTRY="United States" ;;
esac

echo
echo "Selected: $COUNTRY"
echo

# SSH and install
echo "Installing Gluetun VPN container on VM 200..."
echo

ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 << EOF
# Stop existing gluetun if exists
docker stop gluetun-proton-free 2>/dev/null || true
docker rm gluetun-proton-free 2>/dev/null || true

# Create new Gluetun container with ProtonVPN Free
docker run -d --name=gluetun-proton-free \
  --cap-add=NET_ADMIN \
  --device /dev/net/tun \
  -e VPN_SERVICE_PROVIDER=protonvpn \
  -e VPN_TYPE=openvpn \
  -e OPENVPN_USER='${PROTON_USER}' \
  -e OPENVPN_PASSWORD='${PROTON_PASS}' \
  -e SERVER_COUNTRIES="${COUNTRY}" \
  -e FREE_ONLY=on \
  -p 8888:8888/tcp \
  --restart=unless-stopped \
  qmcgaw/gluetun

echo
echo "Waiting for VPN to connect..."
sleep 10

# Check status
docker logs gluetun-proton-free | tail -n 30
EOF

echo
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                ✓ VPN Container Installed!                 ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo
echo "Next Steps:"
echo
echo "1. Configure Jellyfin to use VPN:"
echo "   - Go to: http://136.243.155.166:8096/web/"
echo "   - Admin Dashboard → Networking"
echo "   - HTTP Proxy: http://10.0.0.103:8888"
echo "   - Save"
echo
echo "2. Test VPN connection:"
echo "   ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103"
echo "   docker exec gluetun-proton-free wget -qO- ifconfig.me"
echo "   (Should show VPN IP, not your real IP)"
echo
echo "3. Test geo-blocked channels in Jellyfin!"
echo
echo "VPN Server: $COUNTRY"
echo "Data: Unlimited (ProtonVPN Free)"
echo "Speed: Medium priority (slower during peak hours)"
echo

exit 0
