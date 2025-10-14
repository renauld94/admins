#!/bin/bash

# Portfolio Deployment Script for Proxmox Server
# This script deploys the modernized portfolio to the Proxmox server

echo "🚀 Deploying Modernized Portfolio to Proxmox Server"
echo "=================================================="

# Configuration
SERVER="136.243.155.166"
SSH_KEY="$HOME/.ssh/proxmox_key"
REMOTE_PATH="/var/www/html"
LOCAL_PATH="/home/simon/Desktop/Learning Management System Academy/portofio_simon_rennauld/simonrenauld.github.io"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Test SSH connection
echo "Testing SSH connection..."
if ! ssh -i "$SSH_KEY" -o ConnectTimeout=5 -o BatchMode=yes root@"$SERVER" "echo 'SSH connection successful'" >/dev/null 2>&1; then
    print_error "SSH connection failed!"
    echo "Please ensure SSH is running on the server."
    echo "Access Proxmox web interface at: https://$SERVER:8006"
    echo "Then run: systemctl start ssh"
    exit 1
fi

print_status "SSH connection established"

# Create backup of current files
echo "Creating backup of current files..."
ssh -i "$SSH_KEY" root@"$SERVER" "cd $REMOTE_PATH && tar -czf backup_$(date +%Y%m%d_%H%M%S).tar.gz * 2>/dev/null || true"

# Deploy files
echo "Deploying portfolio files..."
rsync -avz --delete -e "ssh -i $SSH_KEY" "$LOCAL_PATH/" root@"$SERVER":"$REMOTE_PATH/"

if [ $? -eq 0 ]; then
    print_status "Portfolio deployed successfully!"
    echo "🌐 Your portfolio is now live at: http://$SERVER:8082/"
else
    print_error "Deployment failed!"
    exit 1
fi

# Verify deployment
echo "Verifying deployment..."
if ssh -i "$SSH_KEY" root@"$SERVER" "test -f $REMOTE_PATH/index.html && echo 'index.html exists'"; then
    print_status "Deployment verified - files are in place"
else
    print_warning "Could not verify deployment - please check manually"
fi

echo ""
echo "🎉 Deployment complete!"
echo "📱 Portfolio URL: http://$SERVER:8082/"
echo "🔧 Management: https://$SERVER:8006"
