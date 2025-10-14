#!/bin/bash

# Jellyfin Login Troubleshooting Script
# This script helps diagnose and fix Jellyfin authentication issues

set -e

echo "🔧 Jellyfin Login Troubleshooting"
echo "================================="

# Configuration
PROXMOX_HOST="136.243.155.166"
VM_ID="200"
VM_NAME="nextcloud-vm"
JELLYFIN_CONTAINER="jellyfin-simonadmin"
JELLYFIN_PORT="8096"

echo "📋 Configuration:"
echo "  Proxmox Host: $PROXMOX_HOST"
echo "  VM ID: $VM_ID ($VM_NAME)"
echo "  Jellyfin Container: $JELLYFIN_CONTAINER"
echo "  Jellyfin Port: $JELLYFIN_PORT"
echo ""

# Function to check Jellyfin container status
check_container_status() {
    echo "🔍 Checking Jellyfin container status..."
    
    # This would need SSH access to Proxmox, but we'll provide manual steps
    echo "📝 Manual check required:"
    echo "  1. Access Proxmox console for VM 200"
    echo "  2. Run: docker ps | grep jellyfin"
    echo "  3. Verify container is running and healthy"
    echo ""
}

# Function to check Jellyfin logs
check_jellyfin_logs() {
    echo "🔍 Checking Jellyfin logs for authentication issues..."
    
    echo "📝 Manual log check required:"
    echo "  1. Access Proxmox console for VM 200"
    echo "  2. Run: docker logs $JELLYFIN_CONTAINER --tail 50"
    echo "  3. Look for authentication errors or database issues"
    echo ""
}

# Function to reset Jellyfin admin password
reset_admin_password() {
    echo "🔧 Jellyfin Admin Password Reset Options:"
    echo ""
    echo "Option 1: Reset via Jellyfin Web Interface"
    echo "  1. Go to: http://$PROXMOX_HOST:$JELLYFIN_PORT/web/"
    echo "  2. Click 'Forgot Password' if available"
    echo "  3. Follow password reset instructions"
    echo ""
    
    echo "Option 2: Reset via Container Command"
    echo "  1. Access Proxmox console for VM 200"
    echo "  2. Run: docker exec -it $JELLYFIN_CONTAINER /bin/bash"
    echo "  3. Navigate to Jellyfin config directory"
    echo "  4. Use Jellyfin CLI tools to reset password"
    echo ""
    
    echo "Option 3: Reset via Configuration File"
    echo "  1. Access Proxmox console for VM 200"
    echo "  2. Stop container: docker stop $JELLYFIN_CONTAINER"
    echo "  3. Edit Jellyfin configuration files"
    echo "  4. Restart container: docker start $JELLYFIN_CONTAINER"
    echo ""
}

# Function to check Jellyfin database
check_database() {
    echo "🔍 Checking Jellyfin database status..."
    
    echo "📝 Database check required:"
    echo "  1. Access Proxmox console for VM 200"
    echo "  2. Run: docker exec -it $JELLYFIN_CONTAINER ls -la /config"
    echo "  3. Check if database files exist and are accessible"
    echo "  4. Look for any permission issues"
    echo ""
}

# Function to provide troubleshooting steps
provide_troubleshooting_steps() {
    echo "🛠️  Jellyfin Login Troubleshooting Steps:"
    echo "=========================================="
    echo ""
    
    echo "Step 1: Verify Container Status"
    echo "  - Ensure Jellyfin container is running"
    echo "  - Check container health status"
    echo "  - Verify port mapping is correct"
    echo ""
    
    echo "Step 2: Check Logs"
    echo "  - Review Jellyfin container logs"
    echo "  - Look for authentication errors"
    echo "  - Check for database connectivity issues"
    echo ""
    
    echo "Step 3: Database Issues"
    echo "  - Verify Jellyfin database files exist"
    echo "  - Check file permissions"
    echo "  - Ensure database is not corrupted"
    echo ""
    
    echo "Step 4: Password Reset"
    echo "  - Try password reset via web interface"
    echo "  - Use container CLI tools if available"
    echo "  - Reset via configuration files if needed"
    echo ""
    
    echo "Step 5: Network Issues"
    echo "  - Clear browser cache and cookies"
    echo "  - Try incognito/private browsing mode"
    echo "  - Test from different browser or device"
    echo ""
}

# Function to create Jellyfin reset script
create_reset_script() {
    echo "📝 Creating Jellyfin reset script..."
    
    cat > jellyfin_reset.sh << 'EOF'
#!/bin/bash

# Jellyfin Reset Script
# Run this script on the Proxmox VM 200 console

echo "🔄 Jellyfin Reset Script"
echo "========================"

CONTAINER_NAME="jellyfin-simonadmin"
BACKUP_DIR="/tmp/jellyfin_backup_$(date +%Y%m%d_%H%M%S)"

echo "📋 Configuration:"
echo "  Container: $CONTAINER_NAME"
echo "  Backup Directory: $BACKUP_DIR"
echo ""

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Stop Jellyfin container
echo "🛑 Stopping Jellyfin container..."
docker stop "$CONTAINER_NAME"

# Backup current configuration
echo "💾 Backing up current configuration..."
docker cp "$CONTAINER_NAME:/config" "$BACKUP_DIR/"

# Remove problematic database files (if needed)
echo "🗑️  Removing problematic database files..."
docker exec "$CONTAINER_NAME" rm -f /config/data/jellyfin.db
docker exec "$CONTAINER_NAME" rm -f /config/data/jellyfin.db-shm
docker exec "$CONTAINER_NAME" rm -f /config/data/jellyfin.db-wal

# Start Jellyfin container
echo "🚀 Starting Jellyfin container..."
docker start "$CONTAINER_NAME"

# Wait for container to start
echo "⏳ Waiting for Jellyfin to start..."
sleep 30

# Check container status
echo "🔍 Checking container status..."
docker ps | grep "$CONTAINER_NAME"

echo ""
echo "✅ Jellyfin reset complete!"
echo "🌐 Access Jellyfin at: http://136.243.155.166:8096/web/"
echo "📝 You may need to complete the initial setup again"
echo ""
echo "💾 Backup saved to: $BACKUP_DIR"
EOF

    chmod +x jellyfin_reset.sh
    echo "✅ Created jellyfin_reset.sh"
    echo "📝 To use: Copy this script to VM 200 and run it"
    echo ""
}

# Main execution
main() {
    echo "🚀 Starting Jellyfin login troubleshooting..."
    echo ""
    
    check_container_status
    check_jellyfin_logs
    check_database
    provide_troubleshooting_steps
    reset_admin_password
    create_reset_script
    
    echo "🎯 Quick Solutions:"
    echo "=================="
    echo ""
    echo "1. Try clearing browser cache and cookies"
    echo "2. Use incognito/private browsing mode"
    echo "3. Try a different browser"
    echo "4. Check if Caps Lock is on"
    echo "5. Verify you're using the correct username: simonadmin"
    echo ""
    echo "6. If all else fails, run the reset script on VM 200:"
    echo "   ./jellyfin_reset.sh"
    echo ""
    echo "🌐 Jellyfin URL: http://$PROXMOX_HOST:$JELLYFIN_PORT/web/"
    echo "📧 Username: simonadmin"
    echo ""
}

# Run main function
main "$@"
