#!/bin/bash

# MOODLE INSTANCE DIAGNOSTIC AND FIX SCRIPT
# Fixes Moodle at moodle.simondatalab.de (VM 9001)

echo "🎓 MOODLE INSTANCE DIAGNOSTIC AND FIX"
echo "====================================="
echo ""
echo "Target: moodle.simondatalab.de"
echo "VM: 9001"
echo "Host: simonadmin@10.0.0.104"
echo ""

# Check current status
echo "🔍 CURRENT STATUS CHECK:"
echo "========================"
echo ""

echo "1. Testing HTTP connection:"
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://moodle.simondatalab.de/)
echo "   HTTP Status: $HTTP_STATUS"

echo ""
echo "2. Testing HTTPS connection:"
HTTPS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://moodle.simondatalab.de/)
echo "   HTTPS Status: $HTTPS_STATUS"

if [ "$HTTPS_STATUS" = "526" ]; then
    echo "   ❌ HTTP 526: Cloudflare SSL/TLS error"
    echo "   This means Cloudflare can't connect to the origin server"
fi

echo ""
echo "3. Testing direct VM connection:"
VM_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://10.0.0.104/ 2>/dev/null || echo "FAILED")
echo "   Direct VM Status: $VM_STATUS"

echo ""
echo "🚨 IDENTIFIED ISSUES:"
echo "===================="

if [ "$HTTPS_STATUS" = "526" ]; then
    echo "❌ HTTP 526 Error: Cloudflare SSL/TLS handshake failed"
    echo "   - Cloudflare can't establish secure connection to origin server"
    echo "   - Usually caused by SSL certificate issues on the origin server"
    echo "   - Or origin server not responding on HTTPS port"
fi

if [ "$VM_STATUS" = "FAILED" ]; then
    echo "❌ Direct VM Connection Failed"
    echo "   - VM 9001 may be down or not responding"
    echo "   - Network connectivity issues"
    echo "   - Moodle service not running"
fi

echo ""
echo "🛠️  FIX STRATEGIES:"
echo "=================="
echo ""

echo "1. CHECK VM STATUS:"
echo "   - SSH into VM: ssh simonadmin@10.0.0.104"
echo "   - Check if VM is running: systemctl status"
echo "   - Check Moodle service: systemctl status apache2/nginx"
echo ""

echo "2. CHECK SSL CERTIFICATE:"
echo "   - Verify SSL certificate on origin server"
echo "   - Check if certificate is valid and not expired"
echo "   - Ensure certificate matches the domain"
echo ""

echo "3. CHECK CLOUDFLARE SSL SETTINGS:"
echo "   - Go to Cloudflare dashboard"
echo "   - Check SSL/TLS settings for moodle.simondatalab.de"
echo "   - Verify origin server certificate"
echo ""

echo "4. CHECK MOODLE CONFIGURATION:"
echo "   - Verify Moodle config.php settings"
echo "   - Check database connectivity"
echo "   - Verify file permissions"
echo ""

echo "🔧 QUICK FIXES TO TRY:"
echo "====================="
echo ""

echo "1. Restart Moodle services:"
echo "   sudo systemctl restart apache2"
echo "   sudo systemctl restart mysql"
echo ""

echo "2. Check Moodle logs:"
echo "   tail -f /var/log/apache2/error.log"
echo "   tail -f /var/log/mysql/error.log"
echo ""

echo "3. Verify Moodle installation:"
echo "   cd /var/www/html/moodle"
echo "   php admin/cli/check_database_schema.php"
echo ""

echo "4. Check SSL certificate:"
echo "   openssl s_client -connect 10.0.0.104:443 -servername moodle.simondatalab.de"
echo ""

echo "📋 NEXT STEPS:"
echo "=============="
echo ""
echo "1. SSH into the VM:"
echo "   ssh simonadmin@10.0.0.104"
echo ""
echo "2. Run diagnostic commands:"
echo "   sudo systemctl status apache2"
echo "   sudo systemctl status mysql"
echo "   sudo systemctl status moodle"
echo ""
echo "3. Check logs for errors:"
echo "   sudo journalctl -u apache2 -f"
echo "   sudo journalctl -u mysql -f"
echo ""
echo "4. Verify Moodle configuration:"
echo "   cat /var/www/html/moodle/config.php | grep -E 'dbhost|dbname|wwwroot'"
echo ""

echo "🎯 EXPECTED RESULT:"
echo "=================="
echo ""
echo "After fixes:"
echo "  ✅ HTTPS Status: 200 (instead of 526)"
echo "  ✅ Moodle login page loads correctly"
echo "  ✅ SSL certificate valid"
echo "  ✅ Cloudflare can connect to origin server"
echo ""

echo "🔄 To run this diagnostic again:"
echo "  ./moodle_diagnostic.sh"
