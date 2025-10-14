#!/bin/bash

# VM 9001 DIAGNOSTIC SCRIPT
# Checks VM 9001 (10.0.0.104) services and configuration

echo "🔍 VM 9001 DIAGNOSTIC SCRIPT"
echo "============================"
echo ""
echo "Target: VM 9001 (10.0.0.104)"
echo "Services: Moodle (port 8086), Grafana (port 3000)"
echo ""

echo "🔍 CHECKING VM CONNECTIVITY:"
echo "============================"
echo ""

echo "1. Testing VM reachability:"
if ping -c 3 10.0.0.104 >/dev/null 2>&1; then
    echo "   ✅ VM 9001 is reachable via ping"
    VM_REACHABLE=true
else
    echo "   ❌ VM 9001 is not reachable via ping"
    VM_REACHABLE=false
fi

echo ""
echo "2. Testing service ports:"
echo "   Moodle (port 8086):"
if nc -z -w5 10.0.0.104 8086 >/dev/null 2>&1; then
    echo "   ✅ Port 8086 is open"
    MOODLE_PORT_OPEN=true
else
    echo "   ❌ Port 8086 is not accessible"
    MOODLE_PORT_OPEN=false
fi

echo "   Grafana (port 3000):"
if nc -z -w5 10.0.0.104 3000 >/dev/null 2>&1; then
    echo "   ✅ Port 3000 is open"
    GRAFANA_PORT_OPEN=true
else
    echo "   ❌ Port 3000 is not accessible"
    GRAFANA_PORT_OPEN=false
fi

echo ""
echo "3. Testing HTTP responses:"
echo "   Moodle HTTP test:"
MOODLE_HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://10.0.0.104:8086/ 2>/dev/null || echo "FAILED")
echo "   HTTP Status: $MOODLE_HTTP"

echo "   Grafana HTTP test:"
GRAFANA_HTTP=$(curl -s -o /dev/null -w "%{http_code}" http://10.0.0.104:3000/ 2>/dev/null || echo "FAILED")
echo "   HTTP Status: $GRAFANA_HTTP"

echo ""
echo "🚨 DIAGNOSIS:"
echo "============"

if [ "$VM_REACHABLE" = "false" ]; then
    echo "❌ VM 9001 is completely unreachable"
    echo "   - VM may be down or stopped"
    echo "   - Network connectivity issues"
    echo "   - Wrong IP address"
    echo ""
    echo "🛠️  SOLUTIONS:"
    echo "1. Check Proxmox dashboard for VM 9001 status"
    echo "2. Start VM if it's stopped"
    echo "3. Check VM network configuration"
    echo "4. Verify IP address assignment"
    
elif [ "$MOODLE_PORT_OPEN" = "false" ] || [ "$GRAFANA_PORT_OPEN" = "false" ]; then
    echo "❌ VM is reachable but services are not accessible"
    echo "   - Services may be down"
    echo "   - Ports may be blocked by firewall"
    echo "   - Services may be configured on different ports"
    echo ""
    echo "🛠️  SOLUTIONS:"
    echo "1. Access VM via Proxmox console"
    echo "2. Check service status"
    echo "3. Check firewall rules"
    echo "4. Check NAT rules"
    
elif [ "$MOODLE_HTTP" != "200" ] || [ "$GRAFANA_HTTP" != "200" ]; then
    echo "❌ Services are running but not responding correctly"
    echo "   - Services may be misconfigured"
    echo "   - Reverse proxy issues"
    echo "   - Service startup problems"
    echo ""
    echo "🛠️  SOLUTIONS:"
    echo "1. Check service logs"
    echo "2. Restart services"
    echo "3. Check configuration files"
    echo "4. Verify reverse proxy setup"
    
else
    echo "✅ VM 9001 services are working correctly"
    echo "   - VM is reachable"
    echo "   - Services are running"
    echo "   - HTTP responses are correct"
    echo ""
    echo "🔍 ISSUE IS LIKELY CLOUDFLARE TUNNEL CONFIGURATION"
    echo "Check Cloudflare SSL mode and tunnel routes"
fi

echo ""
echo "🔧 VM 9001 TROUBLESHOOTING COMMANDS:"
echo "===================================="
echo ""
echo "Access VM via Proxmox console and run:"
echo ""
echo "1. Check service status:"
echo "   systemctl status moodle"
echo "   systemctl status grafana"
echo "   systemctl status nginx"
echo ""
echo "2. Check NAT rules:"
echo "   iptables -t nat -L -n -v"
echo ""
echo "3. Check firewall rules:"
echo "   iptables -L -n -v"
echo ""
echo "4. Check listening ports:"
echo "   netstat -tlnp | grep -E ':(8086|3000)'"
echo ""
echo "5. Check Nginx configuration:"
echo "   nginx -t"
echo "   cat /etc/nginx/sites-available/moodle"
echo "   cat /etc/nginx/sites-available/grafana"
echo ""
echo "6. Check service logs:"
echo "   journalctl -u moodle -f"
echo "   journalctl -u grafana -f"
echo "   journalctl -u nginx -f"
echo ""

echo "🧪 TESTING COMMANDS:"
echo "==================="
echo ""
echo "Test VM connectivity:"
echo "  ping 10.0.0.104"
echo "  nc -z -v 10.0.0.104 8086"
echo "  nc -z -v 10.0.0.104 3000"
echo ""
echo "Test HTTP services:"
echo "  curl -I http://10.0.0.104:8086/"
echo "  curl -I http://10.0.0.104:3000/"
echo ""
echo "Test tunnel routes:"
echo "  curl -I https://moodle.simondatalab.de/"
echo "  curl -I https://grafana.simondatalab.de/"
echo ""

echo "📋 VM 9001 CHECKLIST:"
echo "===================="
echo ""
echo "□ VM is running and accessible"
echo "□ Services are running on correct ports"
echo "□ NAT rules allow traffic to services"
echo "□ Firewall rules allow internal traffic"
echo "□ Nginx configured for reverse proxy"
echo "□ Services responding to HTTP requests"
echo "□ Cloudflare tunnel routes configured correctly"
echo "□ SSL mode set to 'Flexible'"
echo ""

echo "🎯 EXPECTED RESULTS:"
echo "=================="
echo ""
echo "After fixing VM 9001 issues:"
echo "✅ VM is reachable via ping"
echo "✅ Ports 8086 and 3000 are open"
echo "✅ HTTP services return 200"
echo "✅ Tunnel routes work correctly"
echo "✅ No more HTTP 526 errors"
echo ""

echo "📞 NEXT STEPS:"
echo "============="
echo ""
echo "1. Check VM 9001 status in Proxmox"
echo "2. Access VM via console if needed"
echo "3. Check service status and configuration"
echo "4. Verify NAT and firewall rules"
echo "5. Test tunnel routes after fixes"
echo ""
echo "🔄 To run this diagnostic again:"
echo "  ./vm_9001_diagnostic.sh"
