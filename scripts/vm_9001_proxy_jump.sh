#!/bin/bash

# VM 9001 PROXY JUMP EXECUTION SCRIPT
# Executes commands on VM 9001 via proxy jump

echo "🔧 VM 9001 PROXY JUMP EXECUTION SCRIPT"
echo "======================================"
echo ""
echo "Target: VM 9001 (moodle-lms-9001-1000104)"
echo "User: simon@admin10.0.0.104"
echo "Services: Moodle (port 8086), Grafana (port 3000)"
echo ""

# Check if we can connect to the VM
echo "🔍 CHECKING VM CONNECTIVITY:"
echo "============================"
echo ""

echo "Testing SSH connection to VM..."
if ssh -o ConnectTimeout=10 -o BatchMode=yes simon@10.0.0.104 "echo 'SSH connection successful'" 2>/dev/null; then
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
    ssh simon@10.0.0.104 "uptime && echo 'VM is running'"
    
    echo ""
    echo "2. Checking Moodle service status:"
    ssh simon@10.0.0.104 "systemctl status moodle --no-pager -l"
    
    echo ""
    echo "3. Checking Grafana service status:"
    ssh simon@10.0.0.104 "systemctl status grafana --no-pager -l"
    
    echo ""
    echo "4. Checking Nginx service status:"
    ssh simon@10.0.0.104 "systemctl status nginx --no-pager -l"
    
    echo ""
    echo "5. Checking listening ports:"
    ssh simon@10.0.0.104 "netstat -tlnp | grep -E ':(8086|3000|80|443)'"
    
    echo ""
    echo "6. Checking NAT rules:"
    ssh simon@10.0.0.104 "sudo iptables -t nat -L -n -v"
    
    echo ""
    echo "7. Checking firewall rules:"
    ssh simon@10.0.0.104 "sudo iptables -L -n -v"
    
    echo ""
    echo "8. Checking Nginx configuration:"
    ssh simon@10.0.0.104 "sudo nginx -t"
    
    echo ""
    echo "9. Checking Nginx sites:"
    ssh simon@10.0.0.104 "ls -la /etc/nginx/sites-available/ | grep -E '(moodle|grafana)'"
    
    echo ""
    echo "10. Testing local HTTP connections:"
    ssh simon@10.0.0.104 "curl -I http://localhost:8086/ 2>/dev/null || echo 'Moodle HTTP failed'"
    ssh simon@10.0.0.104 "curl -I http://localhost:3000/ 2>/dev/null || echo 'Grafana HTTP failed'"
    
    echo ""
    echo "🛠️  APPLYING FIXES:"
    echo "=================="
    echo ""
    
    echo "1. Restarting Moodle service:"
    ssh simon@10.0.0.104 "sudo systemctl restart moodle && echo 'Moodle restarted'"
    
    echo ""
    echo "2. Restarting Grafana service:"
    ssh simon@10.0.0.104 "sudo systemctl restart grafana && echo 'Grafana restarted'"
    
    echo ""
    echo "3. Restarting Nginx service:"
    ssh simon@10.0.0.104 "sudo systemctl restart nginx && echo 'Nginx restarted'"
    
    echo ""
    echo "4. Checking service status after restart:"
    ssh simon@10.0.0.104 "systemctl is-active moodle grafana nginx"
    
    echo ""
    echo "5. Testing services after restart:"
    ssh simon@10.0.0.104 "curl -I http://localhost:8086/ 2>/dev/null | head -1 || echo 'Moodle still not responding'"
    ssh simon@10.0.0.104 "curl -I http://localhost:3000/ 2>/dev/null | head -1 || echo 'Grafana still not responding'"
    
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
    
    echo "Testing Moodle tunnel route:"
    MOODLE_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://moodle.simondatalab.de/)
    echo "Moodle Status: $MOODLE_STATUS"
    
    echo ""
    echo "Testing Grafana tunnel route:"
    GRAFANA_STATUS=$(curl -s -o /dev/null -w "%{http_code}" https://grafana.simondatalab.de/)
    echo "Grafana Status: $GRAFANA_STATUS"
    
    if [ "$MOODLE_STATUS" = "200" ] && [ "$GRAFANA_STATUS" = "200" ]; then
        echo "✅ Both services are now accessible!"
        echo ""
        echo "🌐 Test URLs:"
        echo "  Moodle: https://moodle.simondatalab.de/"
        echo "  Grafana: https://grafana.simondatalab.de/"
    else
        echo "⚠️  Services still have issues"
        echo ""
        echo "Additional troubleshooting needed:"
        echo "1. Check Cloudflare SSL settings"
        echo "2. Verify tunnel configuration"
        echo "3. Check service logs"
        echo "4. Review NAT rules"
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
    echo "   - SSH port may be blocked by firewall"
    echo "   - SSH may be configured on different port"
    echo ""
    echo "4. Manual VM access:"
    echo "   - Access VM via Proxmox console"
    echo "   - Check VM status manually"
    echo "   - Restart services if needed"
    echo ""
    echo "🔄 To retry VM connection:"
    echo "  ./vm_9001_proxy_jump.sh"
fi

echo ""
echo "📋 SUMMARY:"
echo "==========="
echo ""
echo "Target: VM 9001 (moodle-lms-9001-1000104)"
echo "User: simon@admin10.0.0.104"
echo "Status: $(if [ "$VM_ACCESSIBLE" = "true" ]; then echo "VM accessible, fixes applied"; else echo "VM not accessible"; fi)"
echo "Moodle Status: $MOODLE_STATUS"
echo "Grafana Status: $GRAFANA_STATUS"
echo ""
echo "Next steps:"
echo "1. Test Moodle and Grafana functionality"
echo "2. Check Cloudflare SSL settings if services still fail"
echo "3. Monitor logs for any remaining issues"
