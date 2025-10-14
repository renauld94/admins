#!/bin/bash

# Jellyfin User Verification and Fix Script
# This script helps verify and fix Jellyfin user issues

set -e

echo "🔧 Jellyfin User Verification and Fix"
echo "====================================="

# Configuration
PROXMOX_HOST="136.243.155.166"
VM_ID="200"
VM_NAME="nextcloud-vm"
JELLYFIN_CONTAINER="jellyfin-simonadmin"
JELLYFIN_PORT="8096"
USERNAME="simonadmin"

echo "📋 Configuration:"
echo "  Proxmox Host: $PROXMOX_HOST"
echo "  VM ID: $VM_ID ($VM_NAME)"
echo "  Jellyfin Container: $JELLYFIN_CONTAINER"
echo "  Username: $USERNAME"
echo ""

# Function to provide manual verification steps
manual_verification() {
    echo "🔍 Manual Verification Steps:"
    echo "============================="
    echo ""
    
    echo "Step 1: Access Proxmox Console"
    echo "1. Go to Proxmox web interface: https://$PROXMOX_HOST:8006"
    echo "2. Log in with your Proxmox credentials"
    echo "3. Navigate to VM 200 (nextcloud-vm)"
    echo "4. Click 'Console' to open VM console"
    echo ""
    
    echo "Step 2: Check Jellyfin Container"
    echo "1. In VM console, run: docker ps | grep jellyfin"
    echo "2. Verify container is running"
    echo "3. Run: docker exec -it $JELLYFIN_CONTAINER /bin/bash"
    echo ""
    
    echo "Step 3: Check Jellyfin Configuration"
    echo "1. Inside container, run: ls -la /config"
    echo "2. Check if user database exists: ls -la /config/data/"
    echo "3. Look for files like: users.db, jellyfin.db"
    echo ""
    
    echo "Step 4: Check Jellyfin Logs"
    echo "1. Exit container: exit"
    echo "2. Run: docker logs $JELLYFIN_CONTAINER --tail 50"
    echo "3. Look for user-related errors or messages"
    echo ""
}

# Function to provide user creation options
user_creation_options() {
    echo "👤 User Creation Options:"
    echo "========================"
    echo ""
    
    echo "Option 1: Create User via Jellyfin Web Interface"
    echo "1. Go to: http://$PROXMOX_HOST:$JELLYFIN_PORT/web/"
    echo "2. Look for 'Create Account' or 'Sign Up' link"
    echo "3. If available, create simonadmin user"
    echo "4. Set password and complete registration"
    echo ""
    
    echo "Option 2: Check for Admin User"
    echo "1. Try common admin usernames:"
    echo "   - admin"
    echo "   - administrator"
    echo "   - root"
    echo "   - jellyfin"
    echo "2. Try common passwords:"
    echo "   - admin"
    echo "   - password"
    echo "   - jellyfin"
    echo "   - 123456"
    echo ""
    
    echo "Option 3: Reset Admin Password via Container"
    echo "1. Access Proxmox console for VM 200"
    echo "2. Run: docker exec -it $JELLYFIN_CONTAINER /bin/bash"
    echo "3. Navigate to Jellyfin config directory"
    echo "4. Use Jellyfin CLI tools to reset admin password"
    echo ""
}

# Function to provide database inspection
database_inspection() {
    echo "🗄️  Database Inspection:"
    echo "========================"
    echo ""
    
    echo "Check Jellyfin Database Files:"
    echo "1. Access Proxmox console for VM 200"
    echo "2. Run: docker exec -it $JELLYFIN_CONTAINER /bin/bash"
    echo "3. Run: ls -la /config/data/"
    echo "4. Look for these files:"
    echo "   - jellyfin.db (main database)"
    echo "   - users.db (user database)"
    echo "   - library.db (library database)"
    echo ""
    
    echo "Check User Table (if SQLite is available):"
    echo "1. Inside container, run: sqlite3 /config/data/jellyfin.db"
    echo "2. Run: .tables (to see available tables)"
    echo "3. Run: SELECT * FROM Users; (to see users)"
    echo "4. Run: .quit (to exit SQLite)"
    echo ""
}

# Function to provide alternative access methods
alternative_access() {
    echo "🔄 Alternative Access Methods:"
    echo "============================="
    echo ""
    
    echo "Method 1: Check for Default Admin"
    echo "1. Try username: admin"
    echo "2. Try password: admin"
    echo "3. Try username: administrator"
    echo "4. Try password: password"
    echo ""
    
    echo "Method 2: Check Jellyfin Documentation"
    echo "1. Look for default credentials in Jellyfin docs"
    echo "2. Check if there's a setup wizard"
    echo "3. Look for initial admin creation process"
    echo ""
    
    echo "Method 3: Check Container Environment Variables"
    echo "1. Access Proxmox console for VM 200"
    echo "2. Run: docker inspect $JELLYFIN_CONTAINER"
    echo "3. Look for environment variables with admin credentials"
    echo "4. Check for JELLYFIN_ADMIN_USER or similar variables"
    echo ""
}

# Function to provide troubleshooting steps
troubleshooting_steps() {
    echo "🛠️  Troubleshooting Steps:"
    echo "==========================="
    echo ""
    
    echo "Step 1: Verify Container Status"
    echo "1. Check if Jellyfin container is running"
    echo "2. Verify container health status"
    echo "3. Check container logs for errors"
    echo ""
    
    echo "Step 2: Check Network Connectivity"
    echo "1. Verify port 8096 is accessible"
    echo "2. Test from different browser/device"
    echo "3. Check if firewall is blocking access"
    echo ""
    
    echo "Step 3: Check Jellyfin Configuration"
    echo "1. Verify Jellyfin config directory exists"
    echo "2. Check file permissions"
    echo "3. Look for configuration errors"
    echo ""
    
    echo "Step 4: Check User Database"
    echo "1. Verify user database exists"
    echo "2. Check if users table is accessible"
    echo "3. Look for user creation errors"
    echo ""
}

# Function to provide quick fixes
quick_fixes() {
    echo "⚡ Quick Fixes:"
    echo "==============="
    echo ""
    
    echo "Fix 1: Try Different Usernames"
    echo "1. admin"
    echo "2. administrator"
    echo "3. root"
    echo "4. jellyfin"
    echo "5. simon"
    echo "6. admin@localhost"
    echo ""
    
    echo "Fix 2: Try Common Passwords"
    echo "1. admin"
    echo "2. password"
    echo "3. jellyfin"
    echo "4. 123456"
    echo "5. admin123"
    echo "6. password123"
    echo ""
    
    echo "Fix 3: Check for Setup Wizard"
    echo "1. Go to: http://$PROXMOX_HOST:$JELLYFIN_PORT/web/"
    echo "2. Look for initial setup wizard"
    echo "3. Complete setup if available"
    echo "4. Create admin user during setup"
    echo ""
}

# Main execution
main() {
    echo "🚀 Starting Jellyfin user verification..."
    echo ""
    
    manual_verification
    user_creation_options
    database_inspection
    alternative_access
    troubleshooting_steps
    quick_fixes
    
    echo "🎯 Summary:"
    echo "==========="
    echo ""
    echo "The 'Invalid username or password' error means:"
    echo "1. User 'simonadmin' doesn't exist in Jellyfin"
    echo "2. Password is incorrect"
    echo "3. User exists but is disabled"
    echo ""
    echo "Next Steps:"
    echo "1. Try the quick fixes above"
    echo "2. Check if there's a setup wizard"
    echo "3. Look for default admin credentials"
    echo "4. Access Proxmox console to inspect database"
    echo ""
    echo "🌐 Jellyfin URL: http://$PROXMOX_HOST:$JELLYFIN_PORT/web/"
    echo ""
}

# Run main function
main "$@"
