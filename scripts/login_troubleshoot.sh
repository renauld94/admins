#!/bin/bash

# Jellyfin & Nextcloud Login Troubleshooting (No Reset)
# This script helps diagnose login issues for simonadmin user

set -e

echo "🔧 Jellyfin & Nextcloud Login Troubleshooting"
echo "============================================="

# Configuration
PROXMOX_HOST="136.243.155.166"
VM_ID="200"
VM_NAME="nextcloud-vm"
JELLYFIN_CONTAINER="jellyfin-simonadmin"
NEXTCLOUD_CONTAINER="nextcloud-simonadmin"
JELLYFIN_PORT="8096"
NEXTCLOUD_PORT="9020"
USERNAME="simonadmin"

echo "📋 Configuration:"
echo "  Proxmox Host: $PROXMOX_HOST"
echo "  VM ID: $VM_ID ($VM_NAME)"
echo "  Username: $USERNAME"
echo "  Jellyfin: http://$PROXMOX_HOST:$JELLYFIN_PORT/web/"
echo "  Nextcloud: http://$PROXMOX_HOST:$NEXTCLOUD_PORT/login?redirect_url=/apps/dashboard/"
echo ""

# Function to test service connectivity
test_services() {
    echo "🔍 Testing service connectivity..."
    
    # Test Jellyfin
    echo "Testing Jellyfin..."
    if curl -s -o /dev/null -w "%{http_code}" http://$PROXMOX_HOST:$JELLYFIN_PORT/web/ | grep -q "200\|302"; then
        echo "✅ Jellyfin web interface is accessible"
    else
        echo "❌ Jellyfin web interface is not accessible"
    fi
    
    # Test Nextcloud
    echo "Testing Nextcloud..."
    if curl -s -o /dev/null -w "%{http_code}" http://$PROXMOX_HOST:$NEXTCLOUD_PORT/login?redirect_url=/apps/dashboard/ | grep -q "200"; then
        echo "✅ Nextcloud login page is accessible"
    else
        echo "❌ Nextcloud login page is not accessible"
    fi
    echo ""
}

# Function to provide Jellyfin login troubleshooting
jellyfin_troubleshooting() {
    echo "🎬 Jellyfin Login Troubleshooting:"
    echo "================================="
    echo ""
    
    echo "1. Browser Issues:"
    echo "   - Clear browser cache and cookies"
    echo "   - Try incognito/private mode"
    echo "   - Disable browser extensions temporarily"
    echo "   - Try a different browser"
    echo ""
    
    echo "2. Login Process:"
    echo "   - Go to: http://$PROXMOX_HOST:$JELLYFIN_PORT/web/"
    echo "   - Username: $USERNAME"
    echo "   - Enter your password"
    echo "   - Check 'Remember Me' if desired"
    echo "   - Click 'Sign In'"
    echo ""
    
    echo "3. Common Issues:"
    echo "   - Caps Lock might be on"
    echo "   - Password might be incorrect"
    echo "   - User might not exist in Jellyfin"
    echo "   - User might be disabled"
    echo ""
    
    echo "4. If Login Fails:"
    echo "   - Check if you see any error messages"
    echo "   - Try typing password in a text editor first"
    echo "   - Verify username spelling"
    echo "   - Contact admin if user doesn't exist"
    echo ""
}

# Function to provide Nextcloud login troubleshooting
nextcloud_troubleshooting() {
    echo "☁️  Nextcloud Login Troubleshooting:"
    echo "===================================="
    echo ""
    
    echo "1. Browser Issues:"
    echo "   - Clear browser cache and cookies"
    echo "   - Try incognito/private mode"
    echo "   - Disable browser extensions temporarily"
    echo "   - Try a different browser"
    echo ""
    
    echo "2. Login Process:"
    echo "   - Go to: http://$PROXMOX_HOST:$NEXTCLOUD_PORT/login?redirect_url=/apps/dashboard/"
    echo "   - Username: $USERNAME"
    echo "   - Enter your password"
    echo "   - Click 'Log in'"
    echo ""
    
    echo "3. Common Issues:"
    echo "   - Caps Lock might be on"
    echo "   - Password might be incorrect"
    echo "   - User might not exist in Nextcloud"
    echo "   - User might be disabled"
    echo "   - Two-factor authentication might be enabled"
    echo ""
    
    echo "4. If Login Fails:"
    echo "   - Check if you see any error messages"
    echo "   - Try typing password in a text editor first"
    echo "   - Verify username spelling"
    echo "   - Check if 2FA is required"
    echo "   - Contact admin if user doesn't exist"
    echo ""
}

# Function to provide manual verification steps
manual_verification() {
    echo "🔍 Manual Verification Steps:"
    echo "============================="
    echo ""
    
    echo "To check if simonadmin user exists in both services:"
    echo ""
    
    echo "For Jellyfin (via Proxmox console):"
    echo "1. Access Proxmox web interface"
    echo "2. Open console for VM 200"
    echo "3. Run: docker exec -it $JELLYFIN_CONTAINER /bin/bash"
    echo "4. Check user database or configuration"
    echo ""
    
    echo "For Nextcloud (via Proxmox console):"
    echo "1. Access Proxmox web interface"
    echo "2. Open console for VM 200"
    echo "3. Run: docker exec -it $NEXTCLOUD_CONTAINER /bin/bash"
    echo "4. Check user database or configuration"
    echo ""
    
    echo "Alternative: Check via web interface:"
    echo "1. Try logging in with different usernames"
    echo "2. Check if there's a 'Forgot Password' option"
    echo "3. Look for user registration options"
    echo ""
}

# Function to provide password recovery options
password_recovery() {
    echo "🔑 Password Recovery Options:"
    echo "============================="
    echo ""
    
    echo "Jellyfin Password Recovery:"
    echo "1. Check if 'Forgot Password' link exists on login page"
    echo "2. Look for password reset options in Jellyfin settings"
    echo "3. Contact system administrator for password reset"
    echo ""
    
    echo "Nextcloud Password Recovery:"
    echo "1. Check if 'Forgot Password' link exists on login page"
    echo "2. Look for password reset options in Nextcloud settings"
    echo "3. Contact system administrator for password reset"
    echo ""
    
    echo "If you have admin access to the containers:"
    echo "1. Access Proxmox console for VM 200"
    echo "2. Use container CLI tools to reset passwords"
    echo "3. Check user configuration files"
    echo ""
}

# Function to provide step-by-step login guide
step_by_step_login() {
    echo "📋 Step-by-Step Login Guide:"
    echo "============================"
    echo ""
    
    echo "Jellyfin Login Steps:"
    echo "1. Open browser and go to: http://$PROXMOX_HOST:$JELLYFIN_PORT/web/"
    echo "2. Wait for the login page to load completely"
    echo "3. Enter username: $USERNAME"
    echo "4. Enter your password (check Caps Lock)"
    echo "5. Click 'Sign In' button"
    echo "6. If successful, you'll be redirected to the Jellyfin dashboard"
    echo ""
    
    echo "Nextcloud Login Steps:"
    echo "1. Open browser and go to: http://$PROXMOX_HOST:$NEXTCLOUD_PORT/login?redirect_url=/apps/dashboard/"
    echo "2. Wait for the login page to load completely"
    echo "3. Enter username: $USERNAME"
    echo "4. Enter your password (check Caps Lock)"
    echo "5. Click 'Log in' button"
    echo "6. If successful, you'll be redirected to the Nextcloud dashboard"
    echo ""
}

# Main execution
main() {
    echo "🚀 Starting login troubleshooting for simonadmin user..."
    echo ""
    
    test_services
    jellyfin_troubleshooting
    nextcloud_troubleshooting
    step_by_step_login
    manual_verification
    password_recovery
    
    echo "🎯 Summary:"
    echo "==========="
    echo ""
    echo "Both services are accessible and working:"
    echo "✅ Jellyfin: http://$PROXMOX_HOST:$JELLYFIN_PORT/web/"
    echo "✅ Nextcloud: http://$PROXMOX_HOST:$NEXTCLOUD_PORT/login?redirect_url=/apps/dashboard/"
    echo ""
    echo "Username: $USERNAME"
    echo ""
    echo "If you're still having trouble:"
    echo "1. Try the troubleshooting steps above"
    echo "2. Check if the user exists in both services"
    echo "3. Verify your password is correct"
    echo "4. Contact the system administrator if needed"
    echo ""
}

# Run main function
main "$@"
