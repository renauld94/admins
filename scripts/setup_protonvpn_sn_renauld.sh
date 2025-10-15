#!/bin/bash

#############################################################################
# ProtonVPN Free Setup Script for sn.renauld@gmail.com
#############################################################################
# This script sets up ProtonVPN Free tier using Gluetun container
# Account: sn.renauld@gmail.com
# Free tier: Unlimited data, 3 server locations (US, Netherlands, Japan)
#############################################################################

set -e

echo "============================================================================"
echo "ProtonVPN Free Setup for sn.renauld@gmail.com"
echo "============================================================================"
echo ""

# Check if Gluetun container already exists
if docker ps -a | grep -q gluetun-proton-free; then
    echo "⚠️  Gluetun container already exists!"
    read -p "Do you want to remove it and recreate? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  Removing existing container..."
        docker stop gluetun-proton-free 2>/dev/null || true
        docker rm gluetun-proton-free 2>/dev/null || true
    else
        echo "❌ Aborting. Please remove the existing container manually."
        exit 1
    fi
fi

# Prompt for OpenVPN credentials
echo "============================================================================"
echo "ProtonVPN OpenVPN Credentials Setup"
echo "============================================================================"
echo ""
echo "📋 IMPORTANT: You need OpenVPN credentials (NOT your ProtonVPN login!)"
echo ""
echo "To get your OpenVPN credentials:"
echo "1. Go to: https://account.protonvpn.com/account"
echo "2. Login with: sn.renauld@gmail.com"
echo "3. Scroll to 'OpenVPN / IKEv2 username' section"
echo "4. Copy your username (format: user+f1234567)"
echo "5. Copy your password (long random string)"
echo ""
echo "If you don't have an account yet:"
echo "1. Sign up at: https://protonvpn.com/free-vpn"
echo "2. Use email: sn.renauld@gmail.com"
echo "3. Then follow steps above to get OpenVPN credentials"
echo ""
read -p "Press ENTER when you have your OpenVPN credentials ready..."
echo ""

# Get OpenVPN username
read -p "Enter your OpenVPN username (e.g., user+f1234567): " PROTON_USER
if [ -z "$PROTON_USER" ]; then
    echo "❌ Error: Username cannot be empty"
    exit 1
fi

# Get OpenVPN password (hidden input)
read -s -p "Enter your OpenVPN password: " PROTON_PASS
echo ""
if [ -z "$PROTON_PASS" ]; then
    echo "❌ Error: Password cannot be empty"
    exit 1
fi

# Choose server location
echo ""
echo "============================================================================"
echo "Choose ProtonVPN Free Server Location"
echo "============================================================================"
echo ""
echo "ProtonVPN Free tier offers 3 server locations:"
echo "  1) United States (us-free)"
echo "  2) Netherlands (nl-free)"
echo "  3) Japan (jp-free)"
echo ""
read -p "Enter your choice (1-3): " SERVER_CHOICE

case $SERVER_CHOICE in
    1)
        COUNTRY="United States"
        echo "✅ Selected: United States"
        ;;
    2)
        COUNTRY="Netherlands"
        echo "✅ Selected: Netherlands"
        ;;
    3)
        COUNTRY="Japan"
        echo "✅ Selected: Japan"
        ;;
    *)
        echo "⚠️  Invalid choice, defaulting to United States"
        COUNTRY="United States"
        ;;
esac

# Create Gluetun container
echo ""
echo "============================================================================"
echo "Installing Gluetun VPN Container"
echo "============================================================================"
echo ""
echo "📦 Creating Gluetun container with ProtonVPN Free..."
echo "   Account: sn.renauld@gmail.com"
echo "   Server: $COUNTRY"
echo "   HTTP Proxy Port: 8888"
echo ""

docker run -d \
  --name=gluetun-proton-free \
  --cap-add=NET_ADMIN \
  --device /dev/net/tun \
  -e VPN_SERVICE_PROVIDER=protonvpn \
  -e OPENVPN_USER="${PROTON_USER}" \
  -e OPENVPN_PASSWORD="${PROTON_PASS}" \
  -e SERVER_COUNTRIES="${COUNTRY}" \
  -e FREE_ONLY=on \
  -e HTTPPROXY=on \
  -e HTTPPROXY_LOG=on \
  -p 8888:8888/tcp \
  --restart=unless-stopped \
  qmcgaw/gluetun

echo ""
echo "⏳ Waiting for container to start..."
sleep 5

# Check container status
if docker ps | grep -q gluetun-proton-free; then
    echo "✅ Gluetun container started successfully!"
    echo ""
    
    # Show container logs
    echo "============================================================================"
    echo "Container Logs (last 30 lines)"
    echo "============================================================================"
    echo ""
    docker logs --tail 30 gluetun-proton-free
    echo ""
    
    # Get VPN IP
    echo "============================================================================"
    echo "VPN Connection Test"
    echo "============================================================================"
    echo ""
    echo "🌐 Testing VPN connection..."
    sleep 10
    
    VPN_IP=$(docker exec gluetun-proton-free wget -qO- https://api.ipify.org 2>/dev/null || echo "Unable to fetch")
    
    if [ "$VPN_IP" != "Unable to fetch" ]; then
        echo "✅ VPN IP Address: $VPN_IP"
        echo "✅ VPN is working!"
    else
        echo "⚠️  Unable to verify VPN IP (container may still be connecting)"
        echo "   Check logs: docker logs gluetun-proton-free"
    fi
    
    echo ""
    echo "============================================================================"
    echo "Next Steps: Configure Jellyfin to Use VPN"
    echo "============================================================================"
    echo ""
    echo "1. Access Jellyfin web interface:"
    echo "   http://136.243.155.166:8096/web/"
    echo ""
    echo "2. Go to: Admin Dashboard → Playback"
    echo ""
    echo "3. Enable HTTP Proxy and enter:"
    echo "   Proxy URL: http://10.0.0.103:8888"
    echo ""
    echo "4. Save changes and restart Jellyfin:"
    echo "   docker restart jellyfin-simonadmin"
    echo ""
    echo "5. Verify VPN is working:"
    echo "   - Play a geo-blocked channel"
    echo "   - Check if it streams successfully"
    echo ""
    echo "============================================================================"
    echo "Useful Commands"
    echo "============================================================================"
    echo ""
    echo "Check VPN status:"
    echo "  docker logs gluetun-proton-free"
    echo ""
    echo "Check VPN IP:"
    echo "  docker exec gluetun-proton-free wget -qO- https://api.ipify.org"
    echo ""
    echo "Restart VPN container:"
    echo "  docker restart gluetun-proton-free"
    echo ""
    echo "Stop VPN container:"
    echo "  docker stop gluetun-proton-free"
    echo ""
    echo "Remove VPN container:"
    echo "  docker stop gluetun-proton-free && docker rm gluetun-proton-free"
    echo ""
    echo "============================================================================"
    echo "✅ ProtonVPN Free Setup Complete!"
    echo "============================================================================"
    
else
    echo "❌ Error: Container failed to start"
    echo ""
    echo "Check logs for details:"
    echo "  docker logs gluetun-proton-free"
    echo ""
    exit 1
fi
