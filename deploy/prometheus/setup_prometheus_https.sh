#!/bin/bash
# Complete Prometheus HTTPS Setup Script
# Run this after DNS has been updated

set -euo pipefail

echo "🚀 Prometheus HTTPS Configuration"
echo "=================================="
echo ""

# Check if running on Proxmox host
if [ ! -f /etc/pve/.version ]; then
    echo "⚠️  This script must be run on the Proxmox host"
    echo "   SSH to: ssh -p 2222 root@136.243.155.166"
    exit 1
fi

echo "✅ Running on Proxmox host"
echo ""

# Check DNS propagation
echo "📡 Checking DNS propagation..."
DNS_IP=$(dig +short prometheus.simondatalab.de @1.1.1.1 | head -1)

if [ -z "$DNS_IP" ]; then
    echo "❌ DNS not resolved yet. Please wait a few minutes and try again."
    exit 1
fi

echo "✅ DNS resolved to: $DNS_IP"
echo ""

# Obtain SSL certificate
echo "🔒 Obtaining SSL certificate from Let's Encrypt..."
if certbot certonly --nginx \
    -d prometheus.simondatalab.de \
    --non-interactive \
    --agree-tos \
    --email admin@simondatalab.de; then
    echo "✅ SSL certificate obtained"
else
    echo "❌ Failed to obtain SSL certificate"
    echo "   Check: /var/log/letsencrypt/letsencrypt.log"
    exit 1
fi
echo ""

# Enable Nginx site
echo "🌐 Enabling Nginx site..."
if [ -f /etc/nginx/sites-available/prometheus-proxy.conf ]; then
    ln -sf /etc/nginx/sites-available/prometheus-proxy.conf \
           /etc/nginx/sites-enabled/prometheus-proxy.conf
    echo "✅ Nginx site enabled"
else
    echo "❌ Nginx config not found: /etc/nginx/sites-available/prometheus-proxy.conf"
    exit 1
fi
echo ""

# Test Nginx configuration
echo "🧪 Testing Nginx configuration..."
if nginx -t; then
    echo "✅ Nginx configuration valid"
else
    echo "❌ Nginx configuration has errors"
    exit 1
fi
echo ""

# Reload Nginx
echo "🔄 Reloading Nginx..."
if systemctl reload nginx; then
    echo "✅ Nginx reloaded"
else
    echo "❌ Failed to reload Nginx"
    exit 1
fi
echo ""

# Wait a moment for Nginx to settle
sleep 2

# Test HTTPS access
echo "🔍 Testing HTTPS access..."
if curl -sS -I https://prometheus.simondatalab.de | head -5; then
    echo ""
    echo "✅ HTTPS test successful"
else
    echo "❌ HTTPS test failed"
    exit 1
fi
echo ""

echo "🎉 Prometheus HTTPS setup complete!"
echo ""
echo "📊 Access your dashboards:"
echo "   Grafana:    https://grafana.simondatalab.de"
echo "   Prometheus: https://prometheus.simondatalab.de"
echo ""
echo "📝 Next steps:"
echo "   1. Open Grafana and add Prometheus data source"
echo "   2. Import dashboards (Node Exporter: 1860, Docker: 179)"
echo "   3. Monitor your AI infrastructure!"
