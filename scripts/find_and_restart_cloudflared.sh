#!/bin/bash
#
# Find and Restart Cloudflared Tunnel
# This script locates the cloudflared container and restarts it
#

echo "🔍 Searching for cloudflared tunnel connector..."
echo

# List of VMs to check
VMS=(
    "10.0.0.150:VM 150 (Portfolio/Main Website)"
    "10.0.0.104:VM 104 (Moodle)"
    "10.0.0.110:VM 110 (Open WebUI/Ollama)"
    "10.0.0.106:VM 106 (GeoNeuralViz)"
    "10.0.0.103:VM 200 (Jellyfin)"
)

PROXY="root@136.243.155.166:2222"
FOUND=false

for vm_info in "${VMS[@]}"; do
    IFS=':' read -r vm_ip vm_name <<< "$vm_info"
    
    echo "Checking $vm_name ($vm_ip)..."
    
    # Check for cloudflared container
    result=$(ssh -J $PROXY simonadmin@$vm_ip 'docker ps --format "{{.Names}}" | grep -i cloudflare' 2>/dev/null)
    
    if [[ -n "$result" ]]; then
        echo "✅ FOUND cloudflared on $vm_name!"
        echo "   Container(s): $result"
        echo
        echo "Restarting cloudflared tunnel..."
        
        # Restart all cloudflared containers found
        while IFS= read -r container; do
            echo "  → Restarting: $container"
            ssh -J $PROXY simonadmin@$vm_ip "docker restart $container"
        done <<< "$result"
        
        echo
        echo "✅ Cloudflared restarted successfully!"
        echo
        echo "Wait 30-60 seconds, then test:"
        echo "  curl -I https://jellyfin.simondatalab.de"
        echo
        FOUND=true
        break
    fi
done

if [[ "$FOUND" == false ]]; then
    echo "❌ Cloudflared container not found on any VM!"
    echo
    echo "Manual check commands:"
    for vm_info in "${VMS[@]}"; do
        IFS=':' read -r vm_ip vm_name <<< "$vm_info"
        echo "  ssh -J $PROXY simonadmin@$vm_ip 'docker ps | grep -i cloud'"
    done
    echo
    echo "Alternative: The tunnel may be running directly on the Proxmox host"
    echo "  ssh -p 2222 root@136.243.155.166 'systemctl status cloudflared'"
    exit 1
fi

exit 0
