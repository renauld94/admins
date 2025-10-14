#!/bin/bash

# Deploy Jellyfin TV Channels Setup via ProxyJump (Corrected)
# This script deploys the TV channels setup to Proxmox VM 200 using your existing SSH config

set -e

echo "📺 Deploying Jellyfin TV Channels Setup via ProxyJump (Corrected)"
echo "================================================================="

# Configuration based on your SSH config
PROXY_HOST="136.243.155.166"
PROXY_PORT="2222"
PROXY_USER="root"
VM_HOST="10.0.0.103"  # VM 200 internal IP (need to verify)
VM_USER="simonadmin"
VM_ID="200"
JELLYFIN_CONTAINER="jellyfin-simonadmin"

# Local files
LOCAL_SCRIPT="/home/simon/Desktop/Learning Management System Academy/add_jellyfin_tv_channels.sh"

echo "📋 Configuration:"
echo "  Proxy Host: $PROXY_HOST:$PROXY_PORT"
echo "  Proxy User: $PROXY_USER"
echo "  VM Host: $VM_HOST (VM $VM_ID)"
echo "  VM User: $VM_USER"
echo "  Jellyfin Container: $JELLYFIN_CONTAINER"
echo ""

# Function to test different connection methods
test_connection_methods() {
    echo "🔍 Testing different connection methods..."
    
    # Method 1: Direct proxy jump with port 2222
    echo "Testing Method 1: Direct ProxyJump with port 2222..."
    if ssh -o ConnectTimeout=10 -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" $VM_USER@$VM_HOST "echo 'Method 1 successful'" > /dev/null 2>&1; then
        echo "✅ Method 1: Direct ProxyJump works"
        CONNECTION_METHOD="direct"
        return 0
    fi
    
    # Method 2: Using existing SSH config hosts
    echo "Testing Method 2: Using SSH config hosts..."
    if ssh -o ConnectTimeout=10 jump "ssh $VM_USER@$VM_HOST 'echo Method 2 successful'" > /dev/null 2>&1; then
        echo "✅ Method 2: SSH config hosts work"
        CONNECTION_METHOD="config"
        return 0
    fi
    
    # Method 3: Try different VM IPs
    echo "Testing Method 3: Trying different VM IPs..."
    for ip in "10.0.0.200" "10.0.0.103" "192.168.1.200"; do
        echo "Trying IP: $ip"
        if ssh -o ConnectTimeout=5 -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" $VM_USER@$ip "echo 'IP $ip works'" > /dev/null 2>&1; then
            echo "✅ Found working IP: $ip"
            VM_HOST="$ip"
            CONNECTION_METHOD="direct"
            return 0
        fi
    done
    
    echo "❌ All connection methods failed"
    echo "💡 Please check:"
    echo "   - VM 200 is running"
    echo "   - VM IP address is correct"
    echo "   - SSH keys are properly configured"
    echo "   - VM is accessible from Proxmox"
    return 1
}

# Function to deploy via direct ProxyJump
deploy_direct() {
    echo "🚀 Deploying via direct ProxyJump..."
    
    # Upload script
    echo "📤 Uploading script to VM..."
    scp -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" "$LOCAL_SCRIPT" $VM_USER@$VM_HOST:/tmp/
    
    # Run setup
    echo "🚀 Running TV channels setup..."
    ssh -o ProxyJump="$PROXY_USER@$PROXY_HOST:$PROXY_PORT" $VM_USER@$VM_HOST << 'EOF'
        echo "📺 Setting up Jellyfin TV Channels..."
        chmod +x /tmp/add_jellyfin_tv_channels.sh
        /tmp/add_jellyfin_tv_channels.sh
EOF
}

# Function to deploy via SSH config
deploy_config() {
    echo "🚀 Deploying via SSH config..."
    
    # Upload script
    echo "📤 Uploading script to VM..."
    scp -o ProxyJump=jump "$LOCAL_SCRIPT" $VM_USER@$VM_HOST:/tmp/
    
    # Run setup
    echo "🚀 Running TV channels setup..."
    ssh jump "ssh $VM_USER@$VM_HOST 'chmod +x /tmp/add_jellyfin_tv_channels.sh && /tmp/add_jellyfin_tv_channels.sh'"
}

# Function to create manual deployment commands
create_manual_commands() {
    echo "⌨️  Manual Deployment Commands:"
    echo "==============================="
    echo ""
    
    echo "Option 1: Direct ProxyJump (if VM IP is correct)"
    echo "scp -o ProxyJump='root@136.243.155.166:2222' add_jellyfin_tv_channels.sh simonadmin@10.0.0.103:/tmp/"
    echo "ssh -o ProxyJump='root@136.243.155.166:2222' simonadmin@10.0.0.103 'chmod +x /tmp/add_jellyfin_tv_channels.sh && /tmp/add_jellyfin_tv_channels.sh'"
    echo ""
    
    echo "Option 2: Using SSH config"
    echo "scp -o ProxyJump=jump add_jellyfin_tv_channels.sh simonadmin@10.0.0.103:/tmp/"
    echo "ssh jump 'ssh simonadmin@10.0.0.103 \"chmod +x /tmp/add_jellyfin_tv_channels.sh && /tmp/add_jellyfin_tv_channels.sh\"'"
    echo ""
    
    echo "Option 3: Direct command execution"
    echo "ssh -o ProxyJump='root@136.243.155.166:2222' simonadmin@10.0.0.103 << 'EOF'"
    echo "  TEMP_DIR=\"/tmp/jellyfin_tv_setup\""
    echo "  mkdir -p \"\$TEMP_DIR\""
    echo "  cd \"\$TEMP_DIR\""
    echo "  curl -o samsung_tv_plus.m3u \"https://rb.gy/soxjxl\""
    echo "  curl -o plex_live.m3u \"https://rb.gy/rhktaz\""
    echo "  curl -o tubi_tv.m3u \"https://www.apsattv.com/tubi.m3u\""
    echo "  curl -o samsung_epg.xml \"https://rb.gy/csudmm\""
    echo "  curl -o plex_epg.xml \"https://rb.gy/uoqt9v\""
    echo "  docker cp samsung_tv_plus.m3u jellyfin-simonadmin:/config/"
    echo "  docker cp plex_live.m3u jellyfin-simonadmin:/config/"
    echo "  docker cp tubi_tv.m3u jellyfin-simonadmin:/config/"
    echo "  docker cp samsung_epg.xml jellyfin-simonadmin:/config/"
    echo "  docker cp plex_epg.xml jellyfin-simonadmin:/config/"
    echo "  docker exec jellyfin-simonadmin chown -R jellyfin:jellyfin /config"
    echo "  docker restart jellyfin-simonadmin"
    echo "  cd / && rm -rf \"\$TEMP_DIR\""
    echo "EOF"
    echo ""
}

# Function to provide troubleshooting
troubleshooting() {
    echo "🛠️  Troubleshooting:"
    echo "==================="
    echo ""
    
    echo "1. Check VM 200 status:"
    echo "   - Go to Proxmox: https://136.243.155.166:8006"
    echo "   - Verify VM 200 is running"
    echo "   - Check VM IP address"
    echo ""
    
    echo "2. Test SSH connection:"
    echo "   ssh -o ProxyJump='root@136.243.155.166:2222' simonadmin@<VM_IP>"
    echo ""
    
    echo "3. Check Docker container:"
    echo "   ssh -o ProxyJump='root@136.243.155.166:2222' simonadmin@<VM_IP> 'docker ps | grep jellyfin'"
    echo ""
    
    echo "4. Alternative VM IPs to try:"
    echo "   - 10.0.0.200"
    echo "   - 10.0.0.103"
    echo "   - 192.168.1.200"
    echo "   - Check Proxmox console for actual IP"
    echo ""
}

# Main execution
main() {
    echo "🚀 Starting Jellyfin TV channels deployment via ProxyJump..."
    echo ""
    
    if test_connection_methods; then
        echo ""
        if [ "$CONNECTION_METHOD" = "direct" ]; then
            deploy_direct
        elif [ "$CONNECTION_METHOD" = "config" ]; then
            deploy_config
        fi
        
        echo ""
        echo "✅ Deployment completed successfully!"
        echo ""
        echo "📋 Next Steps:"
        echo "1. Go to: http://136.243.155.166:8096/web/"
        echo "2. Log in as: simonadmin"
        echo "3. Admin Panel → Live TV"
        echo "4. Add M3U Tuner with: /config/samsung_tv_plus.m3u"
        echo "5. Add XMLTV EPG with: /config/samsung_epg.xml"
        echo "6. Refresh Guide Data"
        echo ""
    else
        echo ""
        create_manual_commands
        troubleshooting
        echo ""
        echo "💡 Try the manual commands above or check the troubleshooting steps"
    fi
}

# Run main function
main "$@"
