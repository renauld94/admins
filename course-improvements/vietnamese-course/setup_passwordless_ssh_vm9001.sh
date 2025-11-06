#!/bin/bash
# Setup Passwordless SSH to VM 9001
# This script configures SSH key authentication for VM 9001 via Proxmox

set -e

BASTION_HOST="136.243.155.166"
BASTION_PORT="2222"
BASTION_USER="root"
VM_ID="9001"
VM_IP="10.0.0.104"
VM_USER="simonadmin"

echo "========================================================================"
echo "  SETUP PASSWORDLESS SSH TO VM 9001"
echo "========================================================================"
echo ""

# Detect available SSH keys
SSH_KEY=""
SSH_KEY_PUB=""

if [ -f ~/.ssh/id_ed25519 ]; then
    SSH_KEY=~/.ssh/id_ed25519
    SSH_KEY_PUB=~/.ssh/id_ed25519.pub
    echo "✓ Using existing Ed25519 key: $SSH_KEY"
elif [ -f ~/.ssh/id_rsa ]; then
    SSH_KEY=~/.ssh/id_rsa
    SSH_KEY_PUB=~/.ssh/id_rsa.pub
    echo "✓ Using existing RSA key: $SSH_KEY"
else
    echo "No SSH key found. Generating new Ed25519 key..."
    ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N "" -C "access-to-vm9001"
    SSH_KEY=~/.ssh/id_ed25519
    SSH_KEY_PUB=~/.ssh/id_ed25519.pub
    echo "✓ SSH key generated: $SSH_KEY"
fi
echo ""

# Check Proxmox connectivity
echo "Checking Proxmox connectivity..."
if ! ssh -p "$BASTION_PORT" -o ConnectTimeout=5 "${BASTION_USER}@${BASTION_HOST}" "echo 'Proxmox OK'" 2>/dev/null; then
    echo "❌ Cannot connect to Proxmox server"
    exit 1
fi
echo "✓ Proxmox connection successful"
echo ""

# Get public key
PUB_KEY=$(cat "$SSH_KEY_PUB")
echo "Public key to install:"
echo "$PUB_KEY"
echo ""

# Method 1: Try via Proxmox pct/qm commands
echo "Attempting to install SSH key via Proxmox..."
echo "========================================================================"

ssh -p "$BASTION_PORT" "${BASTION_USER}@${BASTION_HOST}" bash << PROXMOX_EOF
set -e

echo "Checking VM $VM_ID status..."
VM_STATUS=\$(qm status $VM_ID | awk '{print \$2}')
if [ "\$VM_STATUS" != "running" ]; then
    echo "❌ VM $VM_ID is not running"
    exit 1
fi
echo "✓ VM is running"
echo ""

# Create a script to add the SSH key
cat > /tmp/add_ssh_key.sh << 'KEY_SCRIPT'
#!/bin/bash
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Add the public key if not already present
if ! grep -q "$PUB_KEY" ~/.ssh/authorized_keys 2>/dev/null; then
    echo "$PUB_KEY" >> ~/.ssh/authorized_keys
    echo "✓ SSH key added to authorized_keys"
else
    echo "✓ SSH key already in authorized_keys"
fi

# Ensure SSH service is running
systemctl enable ssh 2>/dev/null || systemctl enable sshd 2>/dev/null || true
systemctl start ssh 2>/dev/null || systemctl start sshd 2>/dev/null || true
systemctl status ssh 2>/dev/null || systemctl status sshd 2>/dev/null || true

echo ""
echo "SSH key installation complete!"
KEY_SCRIPT

# Replace the placeholder with actual key
sed -i "s|\\\$PUB_KEY|$PUB_KEY|g" /tmp/add_ssh_key.sh

echo "Attempting to copy and execute script in VM..."
echo ""

# Try different methods to access the VM
if pct exec $VM_ID -- test -d /root 2>/dev/null; then
    echo "Using pct (container method)..."
    pct push $VM_ID /tmp/add_ssh_key.sh /tmp/add_ssh_key.sh
    pct exec $VM_ID -- bash /tmp/add_ssh_key.sh
    echo "✓ Key installed via pct"
elif qm guest exec $VM_ID -- test -d /root 2>/dev/null; then
    echo "Using qm guest exec..."
    qm guest exec $VM_ID -- bash -c "cat > /tmp/add_ssh_key.sh" < /tmp/add_ssh_key.sh
    qm guest exec $VM_ID -- bash /tmp/add_ssh_key.sh
    echo "✓ Key installed via qm guest exec"
else
    echo "⚠ Automated methods failed. Manual installation required."
    echo ""
    echo "Please run these commands manually:"
    echo ""
    echo "1. Access VM console:"
    echo "   qm terminal $VM_ID"
    echo ""
    echo "2. Run these commands in the VM:"
    echo "   mkdir -p ~/.ssh"
    echo "   chmod 700 ~/.ssh"
    echo "   cat >> ~/.ssh/authorized_keys << 'PUBKEY'"
    echo "   $PUB_KEY"
    echo "   PUBKEY"
    echo "   chmod 600 ~/.ssh/authorized_keys"
    echo "   systemctl enable ssh"
    echo "   systemctl start ssh"
    echo ""
    echo "3. Then run this script again to test"
    exit 1
fi

rm -f /tmp/add_ssh_key.sh
PROXMOX_EOF

INSTALL_STATUS=$?

echo ""
echo "========================================================================"

if [ $INSTALL_STATUS -eq 0 ]; then
    echo "✓ SSH key installation completed!"
    echo ""
    echo "Testing connection..."
    sleep 2
    
    if ssh -o ProxyJump="${BASTION_USER}@${BASTION_HOST}:${BASTION_PORT}" \
           -o ConnectTimeout=10 \
           -o StrictHostKeyChecking=accept-new \
           "${VM_USER}@${VM_IP}" "echo 'Passwordless SSH works!'" 2>/dev/null; then
        echo "✓ SUCCESS! Passwordless SSH is working!"
        echo ""
        echo "You can now run:"
        echo "  ./enable_moodle_webservices_cli.sh"
    else
        echo "⚠ Connection test failed. You may need to:"
        echo "  1. Wait a few seconds for SSH to restart"
        echo "  2. Check VM firewall settings"
        echo "  3. Verify SSH service is running in VM"
        echo ""
        echo "Try testing manually:"
        echo "  ssh -o ProxyJump=${BASTION_USER}@${BASTION_HOST}:${BASTION_PORT} ${VM_USER}@${VM_IP}"
    fi
else
    echo "⚠ Automated installation had issues"
    echo ""
    echo "Please follow the manual steps shown above"
fi

echo ""
echo "========================================================================"
echo "  CONFIGURATION FOR ~/.ssh/config"
echo "========================================================================"
echo ""
echo "Add this to your ~/.ssh/config for easier access:"
echo ""
cat << SSHCONFIG
Host moodle-vm9001
    HostName ${VM_IP}
    User ${VM_USER}
    ProxyJump ${BASTION_USER}@${BASTION_HOST}:${BASTION_PORT}
    IdentityFile ${SSH_KEY}
    IdentitiesOnly yes
    StrictHostKeyChecking accept-new
    ServerAliveInterval 30
    ServerAliveCountMax 4

SSHCONFIG
echo ""
echo "Then you can simply use: ssh moodle-vm9001"
echo ""
