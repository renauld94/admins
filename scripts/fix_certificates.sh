#!/bin/bash

# SSL/TLS CERTIFICATE FIX SCRIPT
# Fixes certificate issues across all services

echo "🔐 SSL/TLS CERTIFICATE FIX SCRIPT"
echo "================================="
echo ""

echo "🔍 CHECKING CERTIFICATE STATUS:"
echo "==============================="
echo ""

# Check main domain certificate
echo "1. Checking main domain certificate:"
MAIN_DOMAIN_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://www.simondatalab.de/)
echo "   simondatalab.de HTTPS Status: $MAIN_DOMAIN_STATUS"

if [ "$MAIN_DOMAIN_STATUS" = "200" ]; then
    echo "   ✅ Main domain certificate is working"
else
    echo "   ❌ Main domain certificate has issues"
fi

echo ""

# Check Moodle certificate
echo "2. Checking Moodle certificate:"
MOODLE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://moodle.simondatalab.de/)
echo "   moodle.simondatalab.de HTTPS Status: $MOODLE_STATUS"

if [ "$MOODLE_STATUS" = "200" ]; then
    echo "   ✅ Moodle certificate is working"
else
    echo "   ❌ Moodle certificate has issues (HTTP $MOODLE_STATUS)"
fi

echo ""

# Check other services
echo "3. Checking other services:"
SERVICES=("grafana.simondatalab.de" "jellyfin.simondatalab.de" "nextcloud.simondatalab.de")
for service in "${SERVICES[@]}"; do
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://$service/ 2>/dev/null || echo "FAILED")
    if [ "$STATUS" = "200" ]; then
        echo "   ✅ $service certificate is working"
    else
        echo "   ❌ $service certificate has issues (HTTP $STATUS)"
    fi
done

echo ""

echo "🚨 IDENTIFIED CERTIFICATE ISSUES:"
echo "================================="

if [ "$MOODLE_STATUS" = "526" ]; then
    echo "❌ Moodle: HTTP 526 - Cloudflare SSL/TLS handshake failure"
    echo "   - Cloudflare cannot connect to origin server"
    echo "   - SSL mode mismatch or origin server SSL issues"
fi

if [ "$MAIN_DOMAIN_STATUS" != "200" ]; then
    echo "❌ Main domain: Certificate issues detected"
    echo "   - May need certificate renewal"
    echo "   - SSL configuration problems"
fi

echo ""

echo "🛠️  CERTIFICATE FIX STRATEGIES:"
echo "=============================="
echo ""

echo "STRATEGY 1: Cloudflare SSL Configuration"
echo "----------------------------------------"
echo "1. Go to Cloudflare dashboard"
echo "2. Select affected domain"
echo "3. SSL/TLS > Overview:"
echo "   - Set SSL mode to 'Full' or 'Full (strict)'"
echo "   - NOT 'Flexible' or 'Off'"
echo "4. SSL/TLS > Origin Server:"
echo "   - Enable 'Authenticated Origin Pulls'"
echo "   - Or configure 'Origin Certificates'"
echo ""

echo "STRATEGY 2: Origin Server SSL Fix"
echo "--------------------------------"
echo "1. Access server via SSH or console"
echo "2. Check SSL certificate status:"
echo "   sudo openssl x509 -in /etc/ssl/certs/ssl-cert-snakeoil.pem -text -noout"
echo "3. Enable SSL modules:"
echo "   sudo a2enmod ssl"
echo "   sudo a2enmod rewrite"
echo "4. Check Apache SSL configuration:"
echo "   sudo nano /etc/apache2/sites-available/default-ssl"
echo "5. Restart web server:"
echo "   sudo systemctl restart apache2"
echo ""

echo "STRATEGY 3: Certificate Renewal"
echo "-----------------------------"
echo "1. Check certificate expiration:"
echo "   openssl x509 -in /etc/ssl/certs/ssl-cert-snakeoil.pem -noout -dates"
echo "2. Generate new certificate if needed:"
echo "   sudo make-ssl-cert generate-default-snakeoil"
echo "3. Or use Let's Encrypt:"
echo "   sudo certbot --apache -d domain.com"
echo ""

echo "🔧 DETAILED FIX COMMANDS:"
echo "========================"
echo ""

echo "For Moodle (HTTP 526 error):"
echo "---------------------------"
echo "1. Cloudflare SSL mode fix:"
echo "   - Go to Cloudflare dashboard"
echo "   - Select moodle.simondatalab.de"
echo "   - Change SSL mode to 'Full'"
echo ""
echo "2. Origin server SSL fix:"
echo "   sudo a2enmod ssl"
echo "   sudo a2enmod rewrite"
echo "   sudo systemctl restart apache2"
echo ""

echo "For Main Domain:"
echo "---------------"
echo "1. Check certificate:"
echo "   openssl s_client -connect www.simondatalab.de:443 -servername www.simondatalab.de"
echo "2. Check certificate expiration:"
echo "   echo | openssl s_client -connect www.simondatalab.de:443 2>/dev/null | openssl x509 -noout -dates"
echo ""

echo "For Other Services:"
echo "------------------"
echo "1. Check each service individually"
echo "2. Verify SSL configuration"
echo "3. Check certificate validity"
echo "4. Restart services if needed"
echo ""

echo "🧪 TESTING COMMANDS:"
echo "==================="
echo ""
echo "Test SSL connectivity:"
echo "  openssl s_client -connect domain.com:443 -servername domain.com"
echo ""
echo "Test HTTPS status:"
echo "  curl -I https://domain.com/"
echo ""
echo "Check certificate details:"
echo "  echo | openssl s_client -connect domain.com:443 2>/dev/null | openssl x509 -noout -text"
echo ""

echo "📋 CERTIFICATE CHECKLIST:"
echo "========================"
echo ""
echo "□ Cloudflare SSL mode set to 'Full' or 'Full (strict)'"
echo "□ Origin server SSL properly configured"
echo "□ SSL certificates are valid and not expired"
echo "□ SSL modules enabled on web server"
echo "□ Virtual hosts configured for SSL"
echo "□ Services restarted after SSL changes"
echo ""

echo "🎯 EXPECTED RESULTS:"
echo "==================="
echo ""
echo "After fixing certificates:"
echo "✅ All HTTPS connections return HTTP 200"
echo "✅ SSL certificates are valid"
echo "✅ Cloudflare can connect to origin servers"
echo "✅ All services accessible via HTTPS"
echo ""

echo "🚨 COMMON CERTIFICATE ISSUES:"
echo "============================"
echo ""
echo "1. Cloudflare SSL Mode Mismatch:"
echo "   - 'Flexible' mode with HTTPS origin"
echo "   - Solution: Change to 'Full' mode"
echo ""
echo "2. Invalid SSL Certificate:"
echo "   - Self-signed certificate not trusted"
echo "   - Certificate doesn't match domain"
echo "   - Solution: Use valid certificate"
echo ""
echo "3. SSL Configuration Issues:"
echo "   - SSL modules not enabled"
echo "   - Virtual host not configured for SSL"
echo "   - Solution: Fix SSL configuration"
echo ""

echo "🔄 MONITORING:"
echo "============="
echo ""
echo "Monitor certificate status:"
echo "  watch -n 30 'curl -s -o /dev/null -w \"%{http_code}\" https://moodle.simondatalab.de/'"
echo ""
echo "Check certificate expiration:"
echo "  echo | openssl s_client -connect moodle.simondatalab.de:443 2>/dev/null | openssl x509 -noout -dates"
echo ""

echo "📞 IMMEDIATE ACTIONS:"
echo "===================="
echo ""
echo "1. Fix Moodle SSL (HTTP 526):"
echo "   - Update Cloudflare SSL mode to 'Full'"
echo "   - Check origin server SSL configuration"
echo ""
echo "2. Verify main domain certificate:"
echo "   - Check certificate validity"
echo "   - Renew if expired"
echo ""
echo "3. Test all services:"
echo "   - Verify HTTPS access"
echo "   - Check SSL certificates"
echo ""
echo "🔄 To run this diagnostic again:"
echo "  ./fix_certificates.sh"
