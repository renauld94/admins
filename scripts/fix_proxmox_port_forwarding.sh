#!/bin/bash

# Fix Proxmox Port Forwarding for Jellyfin and Nextcloud
# This script diagnoses and fixes external access issues for Docker containers running on VM 200

set -e

echo "🔧 Proxmox Port Forwarding Fix for Jellyfin & Nextcloud"
echo "======================================================"

# Configuration
PROXMOX_HOST="136.243.155.166"
VM_ID="200"
VM_NAME="nextcloud-vm"
JELLYFIN_PORT="8096"
NEXTCLOUD_PORT="9020"
VM_INTERNAL_IP="10.0.0.103"

echo "📋 Configuration:"
echo "  Proxmox Host: $PROXMOX_HOST"
echo "  VM ID: $VM_ID ($VM_NAME)"
echo "  VM Internal IP: $VM_INTERNAL_IP"
echo "  Jellyfin Port: $JELLYFIN_PORT"
echo "  Nextcloud Port: $NEXTCLOUD_PORT"
echo ""

# Function to check if port is accessible
check_port() {
    local port=$1
    local service=$2
    
    echo "🔍 Testing external access to $service on port $port..."
    
    if timeout 10 bash -c "</dev/tcp/$PROXMOX_HOST/$port" 2>/dev/null; then
        echo "✅ Port $port is accessible externally"
        return 0
    else
        echo "❌ Port $port is NOT accessible externally"
        return 1
    fi
}

# Function to check Proxmox firewall status
check_proxmox_firewall() {
    echo "🔍 Checking Proxmox firewall status..."
    
    # Check if firewall is enabled
    if ssh root@$PROXMOX_HOST "pve-firewall status" 2>/dev/null | grep -q "enabled"; then
        echo "⚠️  Proxmox firewall is ENABLED"
        return 0
    else
        echo "✅ Proxmox firewall is DISABLED"
        return 1
    fi
}

# Function to check VM firewall status
check_vm_firewall() {
    echo "🔍 Checking VM firewall status..."
    
    # Check if VM has firewall enabled
    if ssh root@$PROXMOX_HOST "qm guest exec $VM_ID -- ufw status" 2>/dev/null | grep -q "Status: active"; then
        echo "⚠️  VM firewall is ENABLED"
        return 0
    else
        echo "✅ VM firewall is DISABLED or not configured"
        return 1
    fi
}

# Function to add Proxmox firewall rules
add_proxmox_firewall_rules() {
    echo "🔧 Adding Proxmox firewall rules..."
    
    # Add rules for Jellyfin
    ssh root@$PROXMOX_HOST "pve-firewall add $VM_ID $JELLYFIN_PORT" 2>/dev/null || true
    echo "  ✅ Added rule for Jellyfin port $JELLYFIN_PORT"
    
    # Add rules for Nextcloud
    ssh root@$PROXMOX_HOST "pve-firewall add $VM_ID $NEXTCLOUD_PORT" 2>/dev/null || true
    echo "  ✅ Added rule for Nextcloud port $NEXTCLOUD_PORT"
}

# Function to add VM firewall rules
add_vm_firewall_rules() {
    echo "🔧 Adding VM firewall rules..."
    
    # Add rules for Jellyfin
    ssh root@$PROXMOX_HOST "qm guest exec $VM_ID -- ufw allow $JELLYFIN_PORT" 2>/dev/null || true
    echo "  ✅ Added VM rule for Jellyfin port $JELLYFIN_PORT"
    
    # Add rules for Nextcloud
    ssh root@$PROXMOX_HOST "qm guest exec $VM_ID -- ufw allow $NEXTCLOUD_PORT" 2>/dev/null || true
    echo "  ✅ Added VM rule for Nextcloud port $NEXTCLOUD_PORT"
}

# Function to check Docker container status
check_docker_containers() {
    echo "🔍 Checking Docker container status..."
    
    # Check Jellyfin container
    if ssh root@$PROXMOX_HOST "qm guest exec $VM_ID -- docker ps | grep jellyfin" 2>/dev/null; then
        echo "✅ Jellyfin container is running"
    else
        echo "❌ Jellyfin container is NOT running"
        return 1
    fi
    
    # Check Nextcloud container
    if ssh root@$PROXMOX_HOST "qm guest exec $VM_ID -- docker ps | grep nextcloud" 2>/dev/null; then
        echo "✅ Nextcloud container is running"
    else
        echo "❌ Nextcloud container is NOT running"
        return 1
    fi
    
    return 0
}

# Function to restart Docker containers
restart_docker_containers() {
    echo "🔄 Restarting Docker containers..."
    
    # Restart Jellyfin
    ssh root@$PROXMOX_HOST "qm guest exec $VM_ID -- docker restart jellyfin-simonadmin" 2>/dev/null || true
    echo "  ✅ Restarted Jellyfin container"
    
    # Restart Nextcloud
    ssh root@$PROXMOX_HOST "qm guest exec $VM_ID -- docker restart nextcloud-simonadmin" 2>/dev/null || true
    echo "  ✅ Restarted Nextcloud container"
    
    # Wait for containers to start
    echo "⏳ Waiting for containers to start..."
    sleep 10
}

# Function to test internal connectivity
test_internal_connectivity() {
    echo "🔍 Testing internal connectivity..."
    
    # Test Jellyfin internally
    if ssh root@$PROXMOX_HOST "qm guest exec $VM_ID -- curl -s -o /dev/null -w '%{http_code}' http://localhost:$JELLYFIN_PORT" 2>/dev/null | grep -q "200"; then
        echo "✅ Jellyfin is accessible internally"
    else
        echo "❌ Jellyfin is NOT accessible internally"
        return 1
    fi
    
    # Test Nextcloud internally
    if ssh root@$PROXMOX_HOST "qm guest exec $VM_ID -- curl -s -o /dev/null -w '%{http_code}' http://localhost:$NEXTCLOUD_PORT" 2>/dev/null | grep -q "200"; then
        echo "✅ Nextcloud is accessible internally"
    else
        echo "❌ Nextcloud is NOT accessible internally"
        return 1
    fi
    
    return 0
}

# Main execution
main() {
    echo "🚀 Starting port forwarding diagnosis and fix..."
    echo ""
    
    # Step 1: Check Docker containers
    if ! check_docker_containers; then
        echo "❌ Docker containers are not running properly. Please check VM 200."
        exit 1
    fi
    echo ""
    
    # Step 2: Test internal connectivity
    if ! test_internal_connectivity; then
        echo "❌ Internal connectivity failed. Restarting containers..."
        restart_docker_containers
        if ! test_internal_connectivity; then
            echo "❌ Internal connectivity still failing. Please check Docker configuration."
            exit 1
        fi
    fi
    echo ""
    
    # Step 3: Test external connectivity
    jellyfin_accessible=$(check_port $JELLYFIN_PORT "Jellyfin")
    nextcloud_accessible=$(check_port $NEXTCLOUD_PORT "Nextcloud")
    echo ""
    
    # Step 4: Check firewall status
    proxmox_firewall_enabled=$(check_proxmox_firewall)
    vm_firewall_enabled=$(check_vm_firewall)
    echo ""
    
    # Step 5: Apply fixes if needed
    if [ "$jellyfin_accessible" = "false" ] || [ "$nextcloud_accessible" = "false" ]; then
        echo "🔧 Applying fixes for external access..."
        
        if [ "$proxmox_firewall_enabled" = "true" ]; then
            add_proxmox_firewall_rules
        fi
        
        if [ "$vm_firewall_enabled" = "true" ]; then
            add_vm_firewall_rules
        fi
        
        echo ""
        echo "⏳ Waiting for firewall rules to take effect..."
        sleep 5
        
        # Test again
        echo "🔍 Re-testing external access..."
        jellyfin_accessible=$(check_port $JELLYFIN_PORT "Jellyfin")
        nextcloud_accessible=$(check_port $NEXTCLOUD_PORT "Nextcloud")
    fi
    
    # Final status
    echo ""
    echo "📊 Final Status:"
    echo "================"
    
    if [ "$jellyfin_accessible" = "true" ]; then
        echo "✅ Jellyfin: http://$PROXMOX_HOST:$JELLYFIN_PORT/"
    else
        echo "❌ Jellyfin: http://$PROXMOX_HOST:$JELLYFIN_PORT/ (NOT ACCESSIBLE)"
    fi
    
    if [ "$nextcloud_accessible" = "true" ]; then
        echo "✅ Nextcloud: http://$PROXMOX_HOST:$NEXTCLOUD_PORT/login?redirect_url=/apps/dashboard/"
    else
        echo "❌ Nextcloud: http://$PROXMOX_HOST:$NEXTCLOUD_PORT/login?redirect_url=/apps/dashboard/ (NOT ACCESSIBLE)"
    fi
    
    echo ""
    if [ "$jellyfin_accessible" = "true" ] && [ "$nextcloud_accessible" = "true" ]; then
        echo "🎉 All services are now accessible externally!"
    else
        echo "⚠️  Some services are still not accessible. Check the following:"
        echo "   1. Proxmox firewall configuration"
        echo "   2. VM firewall configuration"
        echo "   3. Docker container port mappings"
        echo "   4. Network configuration"
    fi
}

# Run main function
main "$@"
