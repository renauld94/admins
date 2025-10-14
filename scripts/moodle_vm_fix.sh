#!/bin/bash

# MOODLE VM FIX SCRIPT
# Connects to VM 9001 and fixes Moodle issues

echo "🎓 MOODLE VM FIX SCRIPT"
echo "======================="
echo ""
echo "Target: moodle.simondatalab.de"
echo "VM: 9001"
echo "Host: simonadmin@10.0.0.104"
echo ""

# Check if we can connect to the VM
echo "🔍 CHECKING VM CONNECTIVITY:"
echo "============================"
echo ""

echo "Testing SSH connection to VM..."
if ssh -o ConnectTimeout=10 -o BatchMode=yes simonadmin@10.0.0.104 "echo 'SSH connection successful'" 2>/dev/null; then
    echo "✅ SSH connection to VM successful"
    VM_ACCESSIBLE=true
else
    echo "❌ SSH connection to VM failed"
    echo "   This could be due to:"
    echo "   - VM is down"
    echo "   - SSH service not running"
    echo "   - Network connectivity issues"
    echo "   - SSH key authentication issues"
    VM_ACCESSIBLE=false
fi

echo ""

if [ "$VM_ACCESSIBLE" = "true" ]; then
    echo "🔧 RUNNING VM DIAGNOSTICS:"
    echo "=========================="
    echo ""
    
    echo "1. Checking VM status:"
    ssh simonadmin@10.0.0.104 "uptime && echo 'VM is running'"
    
    echo ""
    echo "2. Checking Apache status:"
    ssh simonadmin@10.0.0.104 "sudo systemctl status apache2 --no-pager -l"
    
    echo ""
    echo "3. Checking MySQL status:"
    ssh simonadmin@10.0.0.104 "sudo systemctl status mysql --no-pager -l"
    
    echo ""
    echo "4. Checking Moodle directory:"
    ssh simonadmin@10.0.0.104 "ls -la /var/www/html/ | grep moodle"
    
    echo ""
    echo "5. Checking Moodle config:"
    ssh simonadmin@10.0.0.104 "cat /var/www/html/moodle/config.php | grep -E 'dbhost|dbname|wwwroot' | head -5"
    
    echo ""
    echo "6. Checking SSL certificate:"
    ssh simonadmin@10.0.0.104 "sudo openssl x509 -in /etc/ssl/certs/ssl-cert-snakeoil.pem -text -noout | grep -E 'Subject:|Not After'"
    
    echo ""
    echo "7. Checking Apache error logs:"
    ssh simonadmin@10.0.0.104 "sudo tail -10 /var/log/apache2/error.log"
    
    echo ""
    echo "8. Checking Apache access logs:"
    ssh simonadmin@10.0.0.104 "sudo tail -10 /var/log/apache2/access.log"
    
    echo ""
    echo "🛠️  APPLYING FIXES:"
    echo "=================="
    echo ""
    
    echo "1. Restarting Apache:"
    ssh simonadmin@10.0.0.104 "sudo systemctl restart apache2 && echo 'Apache restarted'"
    
    echo ""
    echo "2. Restarting MySQL:"
    ssh simonadmin@10.0.0.104 "sudo systemctl restart mysql && echo 'MySQL restarted'"
    
    echo ""
    echo "3. Checking Moodle database:"
    ssh simonadmin@10.0.0.104 "cd /var/www/html/moodle && php admin/cli/check_database_schema.php"
    
    echo ""
    echo "4. Fixing Moodle permissions:"
    ssh simonadmin@10.0.0.104 "sudo chown -R www-data:www-data /var/www/html/moodle && sudo chmod -R 755 /var/www/html/moodle"
    
    echo ""
    echo "5. Checking SSL configuration:"
    ssh simonadmin@10.0.0.104 "sudo a2enmod ssl && sudo a2enmod rewrite && sudo systemctl reload apache2"
    
    echo ""
    echo "6. Testing local connection:"
    ssh simonadmin@10.0.0.104 "curl -I http://localhost/ && curl -I https://localhost/"
    
    echo ""
    echo "✅ VM FIXES APPLIED"
    echo "=================="
    echo ""
    echo "Waiting 30 seconds for services to stabilize..."
    sleep 30
    
    echo ""
    echo "🧪 TESTING EXTERNAL CONNECTION:"
    echo "==============================="
    echo ""
    
    echo "Testing HTTP connection:"
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://moodle.simondatalab.de/)
    echo "HTTP Status: $HTTP_STATUS"
    
    echo ""
    echo "Testing HTTPS connection:"
    HTTPS_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://moodle.simondatalab.de/)
    echo "HTTPS Status: $HTTPS_STATUS"
    
    if [ "$HTTPS_STATUS" = "200" ]; then
        echo "✅ Moodle is now accessible!"
        echo ""
        echo "🌐 Test URLs:"
        echo "  HTTP: http://moodle.simondatalab.de/"
        echo "  HTTPS: https://moodle.simondatalab.de/"
    else
        echo "⚠️  Moodle still has issues"
        echo ""
        echo "Additional troubleshooting needed:"
        echo "1. Check Cloudflare SSL settings"
        echo "2. Verify SSL certificate configuration"
        echo "3. Check firewall rules"
        echo "4. Review Apache virtual host configuration"
    fi
    
else
    echo "❌ CANNOT ACCESS VM"
    echo "=================="
    echo ""
    echo "The VM is not accessible via SSH. Possible solutions:"
    echo ""
    echo "1. Check if VM is running:"
    echo "   - Log into Proxmox dashboard"
    echo "   - Check VM 9001 status"
    echo "   - Start VM if it's stopped"
    echo ""
    echo "2. Check network connectivity:"
    echo "   - Verify VM IP address (10.0.0.104)"
    echo "   - Check if VM is reachable from this machine"
    echo "   - Verify firewall rules"
    echo ""
    echo "3. Check SSH service:"
    echo "   - SSH service may be down"
    echo "   - SSH port may be blocked"
    echo "   - SSH key authentication may be required"
    echo ""
    echo "4. Manual VM access:"
    echo "   - Access VM via Proxmox console"
    echo "   - Check VM status manually"
    echo "   - Restart services if needed"
    echo ""
    echo "🔄 To retry VM connection:"
    echo "  ./moodle_vm_fix.sh"
fi

echo ""
echo "📋 SUMMARY:"
echo "==========="
echo ""
echo "Target: moodle.simondatalab.de"
echo "VM: 9001 (10.0.0.104)"
echo "Status: $(if [ "$VM_ACCESSIBLE" = "true" ]; then echo "VM accessible, fixes applied"; else echo "VM not accessible"; fi)"
echo "HTTP Status: $HTTP_STATUS"
echo "HTTPS Status: $HTTPS_STATUS"
echo ""
echo "Next steps:"
echo "1. Test Moodle login functionality"
echo "2. Check Cloudflare SSL settings if HTTPS still fails"
echo "3. Monitor logs for any remaining issues"
