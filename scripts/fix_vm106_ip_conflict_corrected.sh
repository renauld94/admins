#!/bin/bash

# Fix VM 106 IP Conflict Script (Corrected)
# Changes VM 106 from 10.0.0.110 to 10.0.0.111 to resolve IP conflict

set -e

echo "🔧 Fixing VM 106 IP Conflict (Corrected)"
echo "========================================"
echo ""

# Configuration
PROXMOX_HOST="136.243.155.166"
PROXMOX_PORT="2222"
VM_ID="106"
VM_NAME="vm106-geoneural1000110"
OLD_IP="10.0.0.110"
NEW_IP="10.0.0.111"
VM_USER="simonadmin"

echo "📋 Configuration:"
echo "  Proxmox Host: $PROXMOX_HOST:$PROXMOX_PORT"
echo "  VM ID: $VM_ID ($VM_NAME)"
echo "  Old IP: $OLD_IP"
echo "  New IP: $NEW_IP"
echo "  VM User: $VM_USER"
echo ""

# Function to check if IP is available
check_ip_availability() {
    local ip=$1
    echo "🔍 Checking if IP $ip is available..."
    
    if ping -c 1 -W 1 $ip >/dev/null 2>&1; then
        echo "❌ IP $ip is already in use"
        return 1
    else
        echo "✅ IP $ip appears to be available"
        return 0
    fi
}

# Function to check VM status
check_vm_status() {
    echo "🔍 Checking VM $VM_ID status..."
    
    if ssh -p $PROXMOX_PORT root@$PROXMOX_HOST "qm status $VM_ID" 2>/dev/null | grep -q "running"; then
        echo "✅ VM $VM_ID is running"
        return 0
    else
        echo "❌ VM $VM_ID is not running"
        return 1
    fi
}

# Function to update VM network configuration properly
update_vm_network() {
    echo "🔧 Updating VM $VM_ID network configuration..."
    
    # Create a temporary script to run on the VM
    cat > /tmp/update_vm_network.sh << 'EOF'
#!/bin/bash
set -e

NEW_IP="$1"
echo "Updating network configuration to $NEW_IP..."

# Backup current netplan config
sudo cp /etc/netplan/*.yaml /tmp/netplan_backup.yaml 2>/dev/null || true

# Remove old netplan files
sudo rm -f /etc/netplan/*.yaml

# Create new netplan configuration
sudo tee /etc/netplan/01-netcfg.yaml > /dev/null << NETPLANEOF
network:
  version: 2
  ethernets:
    enp6s18:
      dhcp4: false
      addresses:
        - $NEW_IP/24
      routes:
        - to: default
          via: 10.0.0.1
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
NETPLANEOF

# Set proper permissions
sudo chmod 600 /etc/netplan/01-netcfg.yaml

# Apply new configuration
sudo netplan apply

echo "Network configuration updated to $NEW_IP"
EOF

    # Copy script to VM and execute
    scp -P $PROXMOX_PORT -o ProxyJump="root@$PROXMOX_HOST" /tmp/update_vm_network.sh $VM_USER@$OLD_IP:/tmp/
    ssh -p $PROXMOX_PORT -o ProxyJump="root@$PROXMOX_HOST" $VM_USER@$OLD_IP "chmod +x /tmp/update_vm_network.sh && /tmp/update_vm_network.sh $NEW_IP"
    
    # Clean up
    rm -f /tmp/update_vm_network.sh
}

# Function to update SSH configuration files
update_ssh_config() {
    echo "🔧 Updating SSH configuration files..."
    
    # Update ssh_config_corrected
    if [ -f "ssh_config_corrected" ]; then
        sed -i "s/$OLD_IP/$NEW_IP/g" ssh_config_corrected
        echo "✅ Updated ssh_config_corrected"
    fi
    
    # Update ~/.ssh/config if it exists
    if [ -f ~/.ssh/config ]; then
        sed -i "s/$OLD_IP/$NEW_IP/g" ~/.ssh/config
        echo "✅ Updated ~/.ssh/config"
    fi
    
    # Update other configuration files that reference the old IP
    echo "🔍 Updating other configuration files..."
    
    # Find and update files containing the old IP
    find . -name "*.sh" -type f -exec grep -l "$OLD_IP" {} \; 2>/dev/null | while read file; do
        if [ "$file" != "./fix_vm106_ip_conflict_corrected.sh" ]; then
            sed -i "s/$OLD_IP/$NEW_IP/g" "$file"
            echo "✅ Updated $file"
        fi
    done
}

# Function to verify the change
verify_change() {
    echo "🔍 Verifying IP change..."
    
    # Wait for network to stabilize
    echo "⏳ Waiting for network to stabilize..."
    sleep 10
    
    # Test new IP connectivity
    if ping -c 3 $NEW_IP >/dev/null 2>&1; then
        echo "✅ New IP $NEW_IP is reachable"
        
        # Test SSH connectivity
        if ssh -o ConnectTimeout=10 -o BatchMode=yes $VM_USER@$NEW_IP "echo 'SSH connection successful'" 2>/dev/null; then
            echo "✅ SSH connection to $NEW_IP successful"
            return 0
        else
            echo "❌ SSH connection to $NEW_IP failed"
            return 1
        fi
    else
        echo "❌ New IP $NEW_IP is not reachable"
        return 1
    fi
}

# Function to restart services if needed
restart_services() {
    echo "🔄 Restarting services on VM..."
    
    # Wait a bit more for network to be fully ready
    sleep 5
    
    ssh -o ConnectTimeout=15 $VM_USER@$NEW_IP << 'EOF'
        echo "Restarting network services..."
        
        # Restart networking
        sudo systemctl restart systemd-networkd
        
        # Restart any Docker containers if they exist
        if command -v docker >/dev/null 2>&1; then
            echo "Restarting Docker containers..."
            docker restart $(docker ps -q) 2>/dev/null || true
        fi
        
        echo "Services restarted"
EOF
}

# Main execution
main() {
    echo "🚀 Starting VM 106 IP conflict resolution..."
    echo ""
    
    # Step 1: Check IP availability
    if ! check_ip_availability $NEW_IP; then
        echo "❌ Cannot proceed - IP $NEW_IP is not available"
        echo "💡 Please choose a different IP address"
        exit 1
    fi
    
    # Step 2: Check VM status
    if ! check_vm_status; then
        echo "❌ Cannot proceed - VM $VM_ID is not running"
        echo "💡 Please start VM $VM_ID first"
        exit 1
    fi
    
    # Step 3: Update VM network configuration
    update_vm_network
    
    # Step 4: Update SSH configuration files
    update_ssh_config
    
    # Step 5: Restart services
    restart_services
    
    # Step 6: Verify the change
    if verify_change; then
        echo ""
        echo "🎉 SUCCESS! VM 106 IP conflict resolved"
        echo "======================================"
        echo "✅ VM 106 now uses IP: $NEW_IP"
        echo "✅ SSH configuration updated"
        echo "✅ All services restarted"
        echo ""
        echo "🔗 New connection command:"
        echo "   ssh geoserver-vm"
        echo "   # or"
        echo "   ssh $VM_USER@$NEW_IP"
        echo ""
        echo "📋 Updated services:"
        echo "   - OpenWebUI: http://$NEW_IP:3001"
        echo "   - Ollama: http://$NEW_IP:11434"
        echo "   - MLflow: http://$NEW_IP:5000"
    else
        echo ""
        echo "❌ FAILED! IP change verification failed"
        echo "======================================="
        echo "💡 Please check:"
        echo "   - VM is running and accessible"
        echo "   - Network configuration is correct"
        echo "   - Firewall rules allow the new IP"
        echo ""
        echo "🔄 Manual verification commands:"
        echo "   ping $NEW_IP"
        echo "   ssh $VM_USER@$NEW_IP"
    fi
}

# Run main function
main "$@"
