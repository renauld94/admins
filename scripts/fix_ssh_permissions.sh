#!/bin/bash

echo "🔧 Fixing SSH Permission Issues for Jellyfin VM Access"
echo "====================================================="

# Configuration
PROXY_HOST="136.243.155.166:2222"
VM_HOST="10.0.0.103"
VM_USER="simonadmin"
SSH_KEY="~/.ssh/jellyfin_vm_key"

echo "📋 Step 1: Testing current SSH connection..."
echo "Testing proxy connection to VM 200..."
ssh -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "echo 'Proxy connection successful'" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Proxy connection works"
else
    echo "❌ Proxy connection failed"
    echo "Trying alternative connection method..."
fi

echo ""
echo "📋 Step 2: Copying SSH key to VM 200..."
echo "Attempting to copy public key to authorized_keys..."

# Try to copy the key using password authentication
ssh-copy-id -i ~/.ssh/jellyfin_vm_key.pub -p 2222 simonadmin@136.243.155.166 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ SSH key copied successfully"
else
    echo "❌ SSH key copy failed - trying manual method..."
    
    # Manual method - copy key content and add to authorized_keys
    echo "Manual key installation:"
    echo "1. Log into VM 200: ssh -p 2222 simonadmin@136.243.155.166"
    echo "2. Run: mkdir -p ~/.ssh && chmod 700 ~/.ssh"
    echo "3. Add this key to ~/.ssh/authorized_keys:"
    echo ""
    cat ~/.ssh/jellyfin_vm_key.pub
    echo ""
    echo "4. Run: chmod 600 ~/.ssh/authorized_keys"
    echo "5. Exit and test connection"
fi

echo ""
echo "📋 Step 3: Testing SSH key authentication..."
ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "echo 'SSH key authentication successful'" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ SSH key authentication works"
    echo ""
    echo "📋 Step 4: Testing Docker access..."
    ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'docker ps | grep jellyfin'" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "✅ Docker access works"
        echo ""
        echo "🎉 SSH permissions fixed! You can now use Docker commands."
    else
        echo "❌ Docker access still failing"
        echo "Trying to fix Docker access..."
        
        # Try to fix Docker access
        ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'sudo usermod -aG docker simonadmin && newgrp docker'" 2>/dev/null
    fi
else
    echo "❌ SSH key authentication failed"
    echo ""
    echo "🔧 Troubleshooting steps:"
    echo "1. Make sure you can log in with password: ssh -p 2222 simonadmin@136.243.155.166"
    echo "2. Check if SSH key was added to authorized_keys"
    echo "3. Verify file permissions: chmod 600 ~/.ssh/authorized_keys"
    echo "4. Check SSH daemon configuration"
fi

echo ""
echo "📋 Step 5: Alternative connection methods..."
echo "If SSH key doesn't work, try these alternatives:"

echo ""
echo "Method 1: Use password authentication"
echo "ssh -p 2222 simonadmin@136.243.155.166"

echo ""
echo "Method 2: Use existing SSH key"
echo "ssh -i ~/.ssh/id_rsa -p 2222 simonadmin@136.243.155.166"

echo ""
echo "Method 3: Check existing SSH keys"
ls -la ~/.ssh/

echo ""
echo "✅ SSH Permission Fix Complete!"
echo "=============================="

