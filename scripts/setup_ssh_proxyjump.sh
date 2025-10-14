#!/bin/bash

# SSH Config Setup Script for ProxyJump Access
# This script configures SSH config file for easy access to CT 150 via Proxmox

set -e

SSH_CONFIG="$HOME/.ssh/config"
BACKUP_CONFIG="$HOME/.ssh/config.backup.$(date +%Y%m%d_%H%M%S)"

echo "🔧 Setting up SSH config for ProxyJump access..."

# Create .ssh directory if it doesn't exist
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

# Backup existing config if it exists
if [ -f "$SSH_CONFIG" ]; then
    echo "📦 Backing up existing SSH config to $BACKUP_CONFIG"
    cp "$SSH_CONFIG" "$BACKUP_CONFIG"
fi

# Create or append to SSH config
echo "📝 Adding ProxyJump configuration to SSH config..."

# Check if the configuration already exists
if grep -q "Host proxmox" "$SSH_CONFIG" 2>/dev/null; then
    echo "⚠️ ProxyJump configuration already exists in SSH config"
    echo "📋 Current configuration:"
    grep -A 20 "Host proxmox" "$SSH_CONFIG" || true
    echo ""
    echo "💡 To update, manually edit ~/.ssh/config or remove existing entries first"
    exit 0
fi

# Add the configuration
cat >> "$SSH_CONFIG" << 'EOF'

# ProxyJump Configuration for CT 150 Server
# Added by SSH Config Setup Script

Host proxmox
    HostName 136.243.155.166
    User root
    Port 22
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    ServerAliveInterval 60
    ServerAliveCountMax 3

Host ct150
    HostName 10.0.0.150
    User root
    Port 22
    ProxyJump proxmox
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    ServerAliveInterval 60
    ServerAliveCountMax 3

EOF

# Set proper permissions
chmod 600 "$SSH_CONFIG"

echo "✅ SSH config configured successfully!"
echo ""
echo "🔍 Configuration added:"
echo "   - Host: proxmox (136.243.155.166)"
echo "   - Host: ct150 (10.0.0.150 via ProxyJump)"
echo ""
echo "🚀 Usage examples:"
echo "   ssh ct150                    # Connect to CT 150 server"
echo "   ssh proxmox                  # Connect to Proxmox server"
echo "   rsync -avz local/ ct150:/var/www/html/  # Deploy files"
echo "   scp file.txt ct150:/var/www/html/       # Copy single file"
echo ""
echo "🧪 Testing connection..."
if ssh -o ConnectTimeout=10 ct150 "echo 'Connection successful'" 2>/dev/null; then
    echo "✅ ProxyJump connection test successful!"
    echo "🎉 You can now use 'ssh ct150' to connect to the CT 150 server"
else
    echo "❌ ProxyJump connection test failed"
    echo "💡 Please check:"
    echo "   - SSH keys are properly configured"
    echo "   - Proxmox server (136.243.155.166) is accessible"
    echo "   - CT 150 server (10.0.0.150) is accessible from Proxmox"
    echo "   - Firewall settings allow SSH connections"
fi

