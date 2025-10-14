#!/bin/bash

echo "🔗 CT 150 PORTFOLIO CONNECTION SCRIPT"
echo "====================================="
echo "Portfolio Website: https://www.simondatalab.de/"
echo "Proxmox Server: 136.243.155.166"
echo "CT 150 Server: 10.0.0.150 (portfolio-web-1000150)"
echo "Date: $(date)"
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to test connectivity
test_connectivity() {
    local host=$1
    local port=${2:-22}
    local timeout=${3:-5}
    
    print_status "Testing connectivity to $host:$port..."
    if timeout $timeout bash -c "</dev/tcp/$host/$port" 2>/dev/null; then
        print_success "Connection to $host:$port successful"
        return 0
    else
        print_error "Connection to $host:$port failed"
        return 1
    fi
}

# Step 1: Test Proxmox connectivity
print_status "Step 1: Testing Proxmox server connectivity..."
if test_connectivity "136.243.155.166" 22; then
    print_success "Proxmox server is reachable"
else
    print_error "Cannot reach Proxmox server"
    print_status "Please check:"
    echo "1. Internet connectivity"
    echo "2. Proxmox server status"
    echo "3. Firewall rules"
    exit 1
fi

# Step 2: Test CT 150 connectivity through Proxmox
print_status "Step 2: Testing CT 150 connectivity through Proxmox..."
if ssh -o ConnectTimeout=10 -o BatchMode=yes root@136.243.155.166 "ping -c 2 10.0.0.150" 2>/dev/null; then
    print_success "CT 150 is reachable through Proxmox"
else
    print_warning "CT 150 may not be reachable through Proxmox"
    print_status "This could be due to:"
    echo "1. CT 150 server is down"
    echo "2. Network configuration issues"
    echo "3. Firewall rules blocking access"
fi

# Step 3: Attempt direct connection
print_status "Step 3: Attempting direct connection to CT 150..."
print_status "Command: ssh -J root@136.243.155.166 simonadmin@10.0.0.150"

# Create SSH config if it doesn't exist
SSH_CONFIG="$HOME/.ssh/config"
if [ ! -f "$SSH_CONFIG" ]; then
    print_status "Creating SSH config file..."
    mkdir -p "$HOME/.ssh"
    touch "$SSH_CONFIG"
    chmod 600 "$SSH_CONFIG"
fi

# Add CT 150 configuration to SSH config
print_status "Adding CT 150 configuration to SSH config..."
if ! grep -q "Host ct150" "$SSH_CONFIG"; then
    cat >> "$SSH_CONFIG" << 'EOF'

# CT 150 Portfolio Server Configuration
Host ct150
    HostName 10.0.0.150
    User simonadmin
    ProxyJump root@136.243.155.166
    Port 22
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
    Compression yes
    ForwardAgent yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

# Proxmox Jump Host
Host proxmox
    HostName 136.243.155.166
    User root
    Port 22
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
    Compression yes
    ForwardAgent yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF
    print_success "SSH config updated"
else
    print_status "SSH config already contains CT 150 configuration"
fi

# Step 4: Test SSH connection
print_status "Step 4: Testing SSH connection to CT 150..."
if ssh -o ConnectTimeout=15 ct150 "echo 'Connected to CT 150 successfully' && hostname && whoami" 2>/dev/null; then
    print_success "SSH connection to CT 150 successful!"
    print_status "You can now use: ssh ct150"
else
    print_error "SSH connection to CT 150 failed"
    print_status "Troubleshooting steps:"
    echo "1. Check if CT 150 server is running"
    echo "2. Verify user 'simonadmin' exists on CT 150"
    echo "3. Check SSH key authentication"
    echo "4. Verify Proxmox server access"
    echo ""
    print_status "Manual connection commands:"
    echo "ssh -J root@136.243.155.166 simonadmin@10.0.0.150"
    echo "ssh -J root@136.243.155.166 root@10.0.0.150"
fi

# Step 5: Provide alternative connection methods
print_status "Step 5: Alternative connection methods..."
echo ""
print_status "If direct SSH fails, try these alternatives:"
echo ""
echo "1. Connect to Proxmox first, then to CT 150:"
echo "   ssh root@136.243.155.166"
echo "   ssh simonadmin@10.0.0.150"
echo ""
echo "2. Use different user:"
echo "   ssh -J root@136.243.155.166 root@10.0.0.150"
echo ""
echo "3. Check Proxmox web interface:"
echo "   https://136.243.155.166:8006"
echo ""
echo "4. Access CT 150 console via Proxmox:"
echo "   - Login to Proxmox web interface"
echo "   - Go to CT 1000150 (portfolio-web)"
echo "   - Click Console to access directly"

# Step 6: Check if we can run the portfolio update script
print_status "Step 6: Checking if portfolio update script can be executed..."
if [ -f "ct150_portfolio_fix.sh" ]; then
    print_success "Portfolio update script found: ct150_portfolio_fix.sh"
    print_status "To run the portfolio update script on CT 150:"
    echo "1. Copy the script to CT 150:"
    echo "   scp ct150_portfolio_fix.sh ct150:/tmp/"
    echo ""
    echo "2. Connect to CT 150 and run:"
    echo "   ssh ct150"
    echo "   sudo bash /tmp/ct150_portfolio_fix.sh"
else
    print_warning "Portfolio update script not found in current directory"
fi

echo ""
print_success "CT 150 connection setup completed!"
print_status "Next steps:"
echo "1. Test connection: ssh ct150"
echo "2. Run update script on CT 150"
echo "3. Purge Cloudflare cache"
echo "4. Verify website functionality"
