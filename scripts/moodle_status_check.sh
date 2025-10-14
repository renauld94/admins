#!/bin/bash

# MOODLE VM STATUS CHECK AND ALTERNATIVE FIXES
# Checks VM status and provides alternative solutions

echo "🎓 MOODLE VM STATUS CHECK AND ALTERNATIVE FIXES"
echo "==============================================="
echo ""
echo "Target: moodle.simondatalab.de"
echo "VM: 9001"
echo "Host: simonadmin@10.0.0.104"
echo ""

# Check if we can reach the VM at all
echo "🔍 CHECKING VM REACHABILITY:"
echo "============================"
echo ""

echo "1. Testing network connectivity to VM:"
if ping -c 3 10.0.0.104 >/dev/null 2>&1; then
    echo "   ✅ VM is reachable via ping"
    VM_REACHABLE=true
else
    echo "   ❌ VM is not reachable via ping"
    VM_REACHABLE=false
fi

echo ""
echo "2. Testing SSH port connectivity:"
if nc -z -w5 10.0.0.104 22 >/dev/null 2>&1; then
    echo "   ✅ SSH port 22 is open"
    SSH_PORT_OPEN=true
else
    echo "   ❌ SSH port 22 is not accessible"
    SSH_PORT_OPEN=false
fi

echo ""
echo "3. Testing HTTP port connectivity:"
if nc -z -w5 10.0.0.104 80 >/dev/null 2>&1; then
    echo "   ✅ HTTP port 80 is open"
    HTTP_PORT_OPEN=true
else
    echo "   ❌ HTTP port 80 is not accessible"
    HTTP_PORT_OPEN=false
fi

echo ""
echo "4. Testing HTTPS port connectivity:"
if nc -z -w5 10.0.0.104 443 >/dev/null 2>&1; then
    echo "   ✅ HTTPS port 443 is open"
    HTTPS_PORT_OPEN=true
else
    echo "   ❌ HTTPS port 443 is not accessible"
    HTTPS_PORT_OPEN=false
fi

echo ""
echo "🚨 DIAGNOSIS:"
echo "============"

if [ "$VM_REACHABLE" = "false" ]; then
    echo "❌ VM is completely unreachable"
    echo "   - VM may be down or stopped"
    echo "   - Network connectivity issues"
    echo "   - Wrong IP address"
    echo ""
    echo "🛠️  SOLUTIONS:"
    echo "1. Check Proxmox dashboard for VM 9001 status"
    echo "2. Start VM if it's stopped"
    echo "3. Check VM network configuration"
    echo "4. Verify IP address assignment"
    
elif [ "$SSH_PORT_OPEN" = "false" ]; then
    echo "❌ VM is reachable but SSH is not accessible"
    echo "   - SSH service may be down"
    echo "   - SSH port may be blocked by firewall"
    echo "   - SSH may be configured on different port"
    echo ""
    echo "🛠️  SOLUTIONS:"
    echo "1. Access VM via Proxmox console"
    echo "2. Check SSH service status"
    echo "3. Check firewall rules"
    echo "4. Try different SSH port"
    
elif [ "$HTTP_PORT_OPEN" = "false" ] && [ "$HTTPS_PORT_OPEN" = "false" ]; then
    echo "❌ VM is reachable but web services are not accessible"
    echo "   - Apache/Nginx may be down"
    echo "   - Web services may be configured on different ports"
    echo "   - Firewall may be blocking web traffic"
    echo ""
    echo "🛠️  SOLUTIONS:"
    echo "1. Access VM via Proxmox console"
    echo "2. Check Apache/Nginx service status"
    echo "3. Check web server configuration"
    echo "4. Check firewall rules"
    
else
    echo "✅ VM appears to be running and accessible"
    echo "   - Network connectivity: OK"
    echo "   - Web services: OK"
    echo "   - Issue may be with Moodle configuration or SSL"
    echo ""
    echo "🛠️  SOLUTIONS:"
    echo "1. Check Moodle configuration"
    echo "2. Check SSL certificate"
    echo "3. Check Cloudflare SSL settings"
    echo "4. Check Apache virtual host configuration"
fi

echo ""
echo "🔧 ALTERNATIVE FIX METHODS:"
echo "=========================="
echo ""

echo "Method 1: Proxmox Console Access"
echo "--------------------------------"
echo "1. Log into Proxmox dashboard"
echo "2. Navigate to VM 9001"
echo "3. Click 'Console' to access VM directly"
echo "4. Run these commands in the console:"
echo "   sudo systemctl status apache2"
echo "   sudo systemctl status mysql"
echo "   sudo systemctl restart apache2"
echo "   sudo systemctl restart mysql"
echo "   sudo systemctl restart moodle"
echo ""

echo "Method 2: Cloudflare SSL Settings"
echo "----------------------------------"
echo "1. Go to Cloudflare dashboard"
echo "2. Select moodle.simondatalab.de"
echo "3. Go to SSL/TLS > Overview"
echo "4. Check SSL mode (should be 'Full' or 'Full (strict)')"
echo "5. Go to SSL/TLS > Origin Server"
echo "6. Check if 'Origin Certificates' is enabled"
echo ""

echo "Method 3: Direct VM Access (if possible)"
echo "----------------------------------------"
echo "1. Try different SSH ports:"
echo "   ssh -p 2222 simonadmin@10.0.0.104"
echo "   ssh -p 2200 simonadmin@10.0.0.104"
echo "2. Try with password authentication:"
echo "   ssh -o PreferredAuthentications=password simonadmin@10.0.0.104"
echo ""

echo "Method 4: Network Troubleshooting"
echo "--------------------------------"
echo "1. Check if VM is on correct network:"
echo "   - Verify VM network configuration"
echo "   - Check if VM has correct IP assignment"
echo "2. Check firewall rules:"
echo "   - Verify ports 22, 80, 443 are open"
echo "   - Check if VM firewall is blocking connections"
echo ""

echo "🧪 TESTING COMMANDS:"
echo "==================="
echo ""
echo "Test VM connectivity:"
echo "  ping 10.0.0.104"
echo "  nc -z -v 10.0.0.104 22"
echo "  nc -z -v 10.0.0.104 80"
echo "  nc -z -v 10.0.0.104 443"
echo ""
echo "Test Moodle externally:"
echo "  curl -I http://moodle.simondatalab.de/"
echo "  curl -I https://moodle.simondatalab.de/"
echo ""

echo "📋 NEXT STEPS:"
echo "=============="
echo ""
echo "1. Check Proxmox dashboard for VM 9001 status"
echo "2. Access VM via Proxmox console if SSH fails"
echo "3. Check Cloudflare SSL settings"
echo "4. Verify Moodle configuration"
echo "5. Test Moodle functionality after fixes"
echo ""

echo "🔄 To retry VM connection:"
echo "  ./moodle_vm_fix.sh"
echo ""
echo "🔄 To run this diagnostic again:"
echo "  ./moodle_status_check.sh"
