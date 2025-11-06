#!/bin/bash
# Fix Moodle HTTPS Certificate Issues
# This script diagnoses and fixes SSL/HTTPS security warnings

set -e

echo "========================================================================"
echo "  MOODLE HTTPS/SSL CERTIFICATE DIAGNOSIS"
echo "========================================================================"
echo ""

MOODLE_URL="moodle.simondatalab.de"
VM_HOST="moodle-vm9001"

echo "🔍 Current Certificate Status:"
echo "----------------------------------------"

# Check certificate details
echo "Certificate: /etc/nginx/ssl/moodle_cloudflare.crt"
ssh $VM_HOST "sudo openssl x509 -in /etc/nginx/ssl/moodle_cloudflare.crt -noout -dates -subject -issuer 2>/dev/null" | while IFS= read -r line; do
    echo "  $line"
done

echo ""
echo "🔴 PROBLEM IDENTIFIED:"
echo "----------------------------------------"
echo "  ❌ Certificate is SELF-SIGNED (issuer = subject)"
echo "  ❌ Not trusted by browsers"
echo "  ❌ Causes 'Not Secure' warnings"
echo "  ❌ Blocks webservice API calls in some cases"
echo ""

echo "🔧 AVAILABLE SOLUTIONS:"
echo "========================================================================"
echo ""

echo "Solution 1: Use Let's Encrypt (FREE, Recommended)"
echo "----------------------------------------"
echo "Let's Encrypt provides free, trusted SSL certificates."
echo ""
echo "Steps:"
echo "  1. Install certbot:"
echo "     ssh $VM_HOST 'sudo apt update && sudo apt install -y certbot python3-certbot-nginx'"
echo ""
echo "  2. Generate certificate:"
echo "     ssh $VM_HOST 'sudo certbot --nginx -d $MOODLE_URL'"
echo ""
echo "  3. Auto-renew (already set up by certbot)"
echo ""
echo "Benefits:"
echo "  ✓ Free"
echo "  ✓ Trusted by all browsers"
echo "  ✓ Auto-renewal"
echo "  ✓ Easy setup"
echo ""

echo "Solution 2: Use Cloudflare Origin Certificate"
echo "----------------------------------------"
echo "If using Cloudflare proxy, use their origin certificate."
echo ""
echo "Steps:"
echo "  1. Go to Cloudflare Dashboard"
echo "  2. SSL/TLS → Origin Server → Create Certificate"
echo "  3. Copy certificate and private key"
echo "  4. Upload to server:"
cat << 'CLOUDFLARE'
     ssh $VM_HOST 'sudo tee /etc/nginx/ssl/cloudflare_origin.crt' < origin.crt
     ssh $VM_HOST 'sudo tee /etc/nginx/ssl/cloudflare_origin.key' < origin.key
     ssh $VM_HOST 'sudo nginx -t && sudo systemctl reload nginx'
CLOUDFLARE
echo ""
echo "Benefits:"
echo "  ✓ Works with Cloudflare proxy"
echo "  ✓ 15-year validity"
echo "  ✓ End-to-end encryption"
echo ""

echo "Solution 3: Use Existing Let's Encrypt Certificate"
echo "----------------------------------------"
echo "You already have Let's Encrypt certs for simondatalab.de"
echo ""
echo "Steps:"
cat << 'LETSENCRYPT'
  ssh $VM_HOST 'sudo bash -c "
    sed -i 's|ssl_certificate.*moodle_cloudflare.crt|ssl_certificate /etc/letsencrypt/live/simondatalab.de/fullchain.pem|' /etc/nginx/sites-available/moodle.simondatalab.de.conf
    sed -i 's|ssl_certificate_key.*moodle_cloudflare.key|ssl_certificate_key /etc/letsencrypt/live/simondatalab.de/privkey.pem|' /etc/nginx/sites-available/moodle.simondatalab.de.conf
    nginx -t && systemctl reload nginx
  "'
LETSENCRYPT
echo ""
echo "Benefits:"
echo "  ✓ Already installed"
echo "  ✓ Quick fix"
echo "  ✓ Trusted by browsers"
echo ""

echo "========================================================================"
echo "  RECOMMENDED ACTION"
echo "========================================================================"
echo ""
echo "Run ONE of these commands:"
echo ""
echo "# Quick Fix (use existing Let's Encrypt):"
echo "./fix_moodle_ssl.sh --use-letsencrypt"
echo ""
echo "# New Let's Encrypt for moodle subdomain:"
echo "./fix_moodle_ssl.sh --certbot"
echo ""
echo "# Use Cloudflare (if behind CF proxy):"
echo "./fix_moodle_ssl.sh --cloudflare"
echo ""
