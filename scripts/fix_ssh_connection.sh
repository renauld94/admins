#!/bin/bash

# SSH Connection Fix Script for Proxmox VM
# This script helps diagnose and fix SSH connection issues

echo "🔧 SSH Connection Fix Script"
echo "============================"

# Configuration
JUMP_HOST="root@136.243.155.166:2222"
VM_USER="simonadmin"
VM_IP="10.0.0.111"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

echo "1. Testing basic connectivity..."
if ping -c 1 136.243.155.166 > /dev/null 2>&1; then
    print_status "Jump host (136.243.155.166) is reachable"
else
    print_error "Jump host (136.243.155.166) is not reachable"
    exit 1
fi

echo ""
echo "2. Testing jump host SSH connection..."
if ssh -o ConnectTimeout=10 -o BatchMode=yes -p 2222 root@136.243.155.166 "echo 'Jump host SSH working'" > /dev/null 2>&1; then
    print_status "Jump host SSH connection working"
else
    print_error "Jump host SSH connection failed"
    echo "💡 Try: ssh -p 2222 root@136.243.155.166"
    exit 1
fi

echo ""
echo "3. Testing VM connectivity through jump host..."
if ssh -J root@136.243.155.166:2222 -o ConnectTimeout=10 -o BatchMode=yes $VM_USER@$VM_IP "echo 'VM SSH working'" > /dev/null 2>&1; then
    print_status "VM SSH connection working"
else
    print_error "VM SSH connection failed"
    echo ""
    echo "🔧 Troubleshooting steps:"
    echo ""
    echo "A. Check if VM is running:"
    echo "   ssh -p 2222 root@136.243.155.166 'qm status 110'"
    echo ""
    echo "B. Check VM network:"
    echo "   ssh -p 2222 root@136.243.155.166 'ping -c 1 10.0.0.111'"
    echo ""
    echo "C. Check SSH service on VM:"
    echo "   ssh -p 2222 root@136.243.155.166 'ssh 10.0.0.111 systemctl status ssh'"
    echo ""
    echo "D. Try direct connection to VM:"
    echo "   ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.111'"
    echo ""
    echo "E. Check SSH keys:"
    echo "   ls -la ~/.ssh/"
    echo "   ssh-keygen -l -f ~/.ssh/id_rsa.pub"
    exit 1
fi

echo ""
echo "4. Testing Docker access..."
DOCKER_TEST=$(ssh -J root@136.243.155.166:2222 -o ConnectTimeout=10 -o BatchMode=yes $VM_USER@$VM_IP "docker ps --format '{{.Names}}'" 2>/dev/null)

if [ $? -eq 0 ]; then
    print_status "Docker access working"
    echo "Running containers:"
    echo "$DOCKER_TEST" | sed 's/^/   - /'
else
    print_error "Docker access failed"
fi

echo ""
echo "5. Testing specific container access..."
OLLAMA_TEST=$(ssh -J root@136.243.155.166:2222 -o ConnectTimeout=10 -o BatchMode=yes $VM_USER@$VM_IP "docker ps | grep ollama" 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$OLLAMA_TEST" ]; then
    print_status "Ollama container found"
    echo "$OLLAMA_TEST"
else
    print_warning "Ollama container not found or not running"
fi

echo ""
echo "📋 Summary:"
if ssh -J root@136.243.155.166:2222 -o ConnectTimeout=10 -o BatchMode=yes $VM_USER@$VM_IP "echo 'test'" > /dev/null 2>&1; then
    print_status "SSH connection is working"
    echo "🚀 You can now run Docker commands!"
    echo ""
    echo "Example commands:"
    echo "   ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.111 'docker ps'"
    echo "   ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.111 'docker restart ollama'"
else
    print_error "SSH connection needs manual fixing"
    echo "💡 Check the troubleshooting steps above"
fi

