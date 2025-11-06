#!/bin/bash
# Fix Moodle SSL Certificate Issues
# Replaces self-signed certificate with trusted certificate

set -e

VM_HOST="moodle-vm9001"
DOMAIN="moodle.simondatalab.de"
NGINX_CONF="/etc/nginx/sites-available/moodle.simondatalab.de.conf"

show_help() {
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  --use-letsencrypt   Use existing Let's Encrypt certificate"
    echo "  --certbot           Generate new Let's Encrypt certificate"
    echo "  --cloudflare        Use Cloudflare origin certificate (manual)"
    echo "  --help              Show this help"
    echo ""
}

backup_config() {
    echo "📦 Backing up nginx configuration..."
    ssh $VM_HOST "sudo cp $NGINX_CONF ${NGINX_CONF}.backup.\$(date +%s)"
    echo "✓ Backup created"
}

use_letsencrypt() {
    echo "========================================================================"
    echo "  USING EXISTING LET'S ENCRYPT CERTIFICATE"
    echo "========================================================================"
    echo ""
    
    backup_config
    
    echo "🔧 Updating nginx configuration..."
    ssh $VM_HOST "sudo bash -c '
        # Update SSL certificate paths
        sed -i \"s|ssl_certificate .*;|ssl_certificate /etc/letsencrypt/live/simondatalab.de/fullchain.pem;|\" $NGINX_CONF
        sed -i \"s|ssl_certificate_key .*;|ssl_certificate_key /etc/letsencrypt/live/simondatalab.de/privkey.pem;|\" $NGINX_CONF
        
        # Test configuration
        nginx -t
    '"
    
    echo ""
    echo "✓ Configuration updated"
    echo ""
    echo "🔄 Reloading nginx..."
    ssh $VM_HOST "sudo systemctl reload nginx"
    echo "✓ Nginx reloaded"
    echo ""
    
    test_certificate
}

use_certbot() {
    echo "========================================================================"
    echo "  GENERATING NEW LET'S ENCRYPT CERTIFICATE WITH CERTBOT"
    echo "========================================================================"
    echo ""
    
    backup_config
    
    echo "📦 Installing certbot..."
    ssh $VM_HOST "sudo apt update && sudo apt install -y certbot python3-certbot-nginx"
    echo "✓ Certbot installed"
    echo ""
    
    echo "🔐 Generating certificate for $DOMAIN..."
    echo "Note: This will automatically update nginx configuration"
    ssh $VM_HOST "sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@simondatalab.de || echo 'Manual intervention may be required'"
    echo ""
    
    echo "🔄 Reloading nginx..."
    ssh $VM_HOST "sudo systemctl reload nginx"
    echo "✓ Nginx reloaded"
    echo ""
    
    test_certificate
}

use_cloudflare() {
    echo "========================================================================"
    echo "  CLOUDFLARE ORIGIN CERTIFICATE SETUP"
    echo "========================================================================"
    echo ""
    echo "⚠️  This requires manual steps in Cloudflare Dashboard"
    echo ""
    echo "Steps:"
    echo "1. Go to Cloudflare Dashboard"
    echo "2. Select your domain: simondatalab.de"
    echo "3. Go to SSL/TLS → Origin Server"
    echo "4. Click 'Create Certificate'"
    echo "5. Use these settings:"
    echo "   - Private key type: RSA (2048)"
    echo "   - Hostnames: moodle.simondatalab.de, *.simondatalab.de"
    echo "   - Validity: 15 years"
    echo "6. Copy the certificate and private key"
    echo ""
    echo "7. Save certificate to a local file: cloudflare_origin.crt"
    echo "8. Save private key to a local file: cloudflare_origin.key"
    echo ""
    echo "9. Upload to server:"
    echo "   scp cloudflare_origin.crt $VM_HOST:/tmp/"
    echo "   scp cloudflare_origin.key $VM_HOST:/tmp/"
    echo ""
    echo "10. Install on server:"
    cat << 'INSTALL'
    ssh $VM_HOST "sudo bash -c '
        mv /tmp/cloudflare_origin.crt /etc/nginx/ssl/
        mv /tmp/cloudflare_origin.key /etc/nginx/ssl/
        chmod 644 /etc/nginx/ssl/cloudflare_origin.crt
        chmod 600 /etc/nginx/ssl/cloudflare_origin.key
        
        # Update nginx config
        sed -i "s|ssl_certificate .*;|ssl_certificate /etc/nginx/ssl/cloudflare_origin.crt;|" /etc/nginx/sites-available/moodle.simondatalab.de.conf
        sed -i "s|ssl_certificate_key .*;|ssl_certificate_key /etc/nginx/ssl/cloudflare_origin.key;|" /etc/nginx/sites-available/moodle.simondatalab.de.conf
        
        nginx -t && systemctl reload nginx
    '"
INSTALL
    echo ""
}

test_certificate() {
    echo "========================================================================"
    echo "  TESTING CERTIFICATE"
    echo "========================================================================"
    echo ""
    
    echo "🔍 Certificate details:"
    openssl s_client -connect $DOMAIN:443 -servername $DOMAIN < /dev/null 2>&1 | openssl x509 -noout -dates -subject -issuer
    echo ""
    
    echo "🔍 Verification:"
    VERIFY=$(openssl s_client -connect $DOMAIN:443 -servername $DOMAIN < /dev/null 2>&1 | grep "Verify return code")
    echo "  $VERIFY"
    echo ""
    
    if echo "$VERIFY" | grep -q "0 (ok)"; then
        echo "✅ Certificate is VALID and TRUSTED!"
    else
        echo "⚠️  Certificate verification failed"
    fi
    echo ""
    
    echo "🌐 Testing in browser:"
    echo "  https://$DOMAIN"
    echo ""
    echo "✓ Certificate update complete!"
}

# Main script
case "$1" in
    --use-letsencrypt)
        use_letsencrypt
        ;;
    --certbot)
        use_certbot
        ;;
    --cloudflare)
        use_cloudflare
        ;;
    --help|"")
        show_help
        ;;
    *)
        echo "Unknown option: $1"
        show_help
        exit 1
        ;;
esac
