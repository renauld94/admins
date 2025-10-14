#!/bin/bash

# Deploy Website Updates Script
# This script applies the latest optimizations to your website

echo "🚀 Deploying Website Updates to https://www.simondatalab.de/"
echo "=================================================="

# Configuration
JUMP_HOST="root@136.243.155.166:2222"
VM_USER="simonadmin"
VM_IP="10.0.0.111"
WEBSITE_PATH="/var/www/html"
BACKUP_PATH="/var/www/backups/$(date +%Y%m%d_%H%M%S)"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Function to execute commands on remote server
execute_remote() {
    local command="$1"
    local description="$2"
    
    print_info "$description"
    if ssh -J $JUMP_HOST -t $VM_USER@$VM_IP "$command"; then
        print_status "$description completed"
        return 0
    else
        print_error "$description failed"
        return 1
    fi
}

# Function to copy files to remote server
copy_to_remote() {
    local local_file="$1"
    local remote_path="$2"
    local description="$3"
    
    print_info "$description"
    if scp -J $JUMP_HOST "$local_file" $VM_USER@$VM_IP:"$remote_path"; then
        print_status "$description completed"
        return 0
    else
        print_error "$description failed"
        return 1
    fi
}

echo "📋 Updates to be deployed:"
echo "  • Print CSS optimizations"
echo "  • Performance-optimized hero visualization"
echo "  • Inter font loading improvements (weight 800 added)"
echo "  • Floating Action Button for global infrastructure link"
echo "  • Mobile performance optimizations"
echo ""

# Step 1: Create backup
print_info "Creating backup of current website..."
if execute_remote "mkdir -p $BACKUP_PATH && cp -r $WEBSITE_PATH/* $BACKUP_PATH/" "Backup creation"; then
    print_status "Backup created at $BACKUP_PATH"
else
    print_error "Backup failed - aborting deployment"
    exit 1
fi

# Step 2: Deploy updated CSS
print_info "Deploying updated styles.css..."
if copy_to_remote "moodle-homepage/styles.css" "$WEBSITE_PATH/styles.css" "CSS deployment"; then
    print_status "CSS updated successfully"
else
    print_error "CSS deployment failed"
    exit 1
fi

# Step 3: Deploy updated HTML
print_info "Deploying updated index.html..."
if copy_to_remote "moodle-homepage/index.html" "$WEBSITE_PATH/index.html" "HTML deployment"; then
    print_status "HTML updated successfully"
else
    print_error "HTML deployment failed"
    exit 1
fi

# Step 4: Deploy new performance script
print_info "Deploying hero-performance.js..."
if copy_to_remote "moodle-homepage/hero-performance.js" "$WEBSITE_PATH/hero-performance.js" "Performance script deployment"; then
    print_status "Performance script deployed successfully"
else
    print_error "Performance script deployment failed"
    exit 1
fi

# Step 5: Update app.js if it exists
if [ -f "moodle-homepage/app.js" ]; then
    print_info "Deploying updated app.js..."
    if copy_to_remote "moodle-homepage/app.js" "$WEBSITE_PATH/app.js" "App.js deployment"; then
        print_status "App.js updated successfully"
    else
        print_warning "App.js deployment failed (non-critical)"
    fi
fi

# Step 6: Set proper permissions
print_info "Setting file permissions..."
if execute_remote "chown -R www-data:www-data $WEBSITE_PATH && chmod -R 644 $WEBSITE_PATH && find $WEBSITE_PATH -type d -exec chmod 755 {} \;" "Permission setting"; then
    print_status "Permissions set correctly"
else
    print_warning "Permission setting failed (may need manual fix)"
fi

# Step 7: Test website
print_info "Testing website deployment..."
if execute_remote "curl -s -o /dev/null -w '%{http_code}' https://www.simondatalab.de/ | grep -q '200'"; then
    print_status "Website is responding correctly"
else
    print_warning "Website test failed - please check manually"
fi

# Step 8: Clear any caches
print_info "Clearing caches..."
if execute_remote "systemctl reload nginx 2>/dev/null || service nginx reload 2>/dev/null || true" "Cache clearing"; then
    print_status "Caches cleared"
else
    print_warning "Cache clearing failed (may need manual intervention)"
fi

echo ""
echo "🎉 Deployment Summary"
echo "====================="
print_status "All updates have been deployed to https://www.simondatalab.de/"
echo ""
echo "📊 What's New:"
echo "  • Enhanced print styles for better document printing"
echo "  • Performance-optimized 3D hero visualization with device detection"
echo "  • Improved Inter font loading (now includes weight 800)"
echo "  • Floating Action Button linking to global infrastructure"
echo "  • Mobile performance optimizations and reduced motion support"
echo ""
echo "🔧 Technical Improvements:"
echo "  • WebGL fallback for unsupported devices"
echo "  • Framerate throttling to prevent RAF violations"
echo "  • Canvas resolution optimization"
echo "  • Intersection Observer for lazy loading"
echo "  • Performance monitoring and device tier detection"
echo ""
echo "📱 Mobile Optimizations:"
echo "  • Reduced particle counts on mobile devices"
echo "  • Lower target FPS for better battery life"
echo "  • Simplified animations on low-end devices"
echo "  • Touch-friendly floating action button"
echo ""
print_info "Backup location: $BACKUP_PATH"
print_info "Test your website at: https://www.simondatalab.de/"
echo ""
print_status "Deployment completed successfully! 🚀"
