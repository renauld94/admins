#!/bin/bash
# Deploy LinkedIn Lead Search to VM for Background Execution
# This will run the search on a VM so you can close VS Code

set -e

echo "🚀 LinkedIn Lead Search - VM Deployment"
echo "========================================"
echo ""

# Configuration
VM_USER="simon"
VM_HOST=""
VM_NAME=""
REMOTE_DIR="/home/simon/linkedin-lead-search"

# Detect available VMs
echo "📡 Detecting available VMs..."
echo ""

# Check ProxmoxMCP for VM list
if command -v qm &> /dev/null; then
    echo "Available VMs on this Proxmox host:"
    qm list
    echo ""
    read -p "Enter VM ID to use: " VM_ID
    
    # Get VM IP
    VM_IP=$(qm guest cmd $VM_ID network-get-interfaces | jq -r '.[] | select(.name=="eth0") | .["ip-addresses"][] | select(.["ip-address-type"]=="ipv4") | .["ip-address"]' 2>/dev/null || echo "")
    
    if [ -z "$VM_IP" ]; then
        echo "⚠️  Could not auto-detect VM IP"
        read -p "Enter VM IP address: " VM_IP
    fi
    VM_HOST="$VM_IP"
    VM_NAME="VM-$VM_ID"
else
    # Manual VM selection
    echo "Enter VM details:"
    read -p "VM hostname/IP: " VM_HOST
    read -p "VM username (default: simon): " VM_USER_INPUT
    VM_USER="${VM_USER_INPUT:-simon}"
    read -p "VM name (for display): " VM_NAME
fi

echo ""
echo "📦 Deployment Configuration:"
echo "   VM: $VM_NAME ($VM_HOST)"
echo "   User: $VM_USER"
echo "   Remote directory: $REMOTE_DIR"
echo ""
read -p "Continue? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "❌ Deployment cancelled"
    exit 1
fi

echo ""
echo "📤 Deploying to $VM_NAME..."

# Test SSH connection
echo "   Testing SSH connection..."
if ! ssh -o ConnectTimeout=5 "$VM_USER@$VM_HOST" "echo '✅ SSH connection successful'" 2>/dev/null; then
    echo "❌ SSH connection failed"
    echo "   Make sure you can SSH to the VM: ssh $VM_USER@$VM_HOST"
    echo "   Consider setting up SSH keys: ssh-copy-id $VM_USER@$VM_HOST"
    exit 1
fi

# Create remote directory
echo "   Creating remote directory..."
ssh "$VM_USER@$VM_HOST" "mkdir -p $REMOTE_DIR"

# Copy files
echo "   Copying files..."
rsync -avz --progress \
    --exclude='outputs/' \
    --exclude='__pycache__/' \
    --exclude='*.pyc' \
    --exclude='.git/' \
    ./ "$VM_USER@$VM_HOST:$REMOTE_DIR/"

# Copy .env (credentials)
echo "   Copying credentials..."
scp .env "$VM_USER@$VM_HOST:$REMOTE_DIR/.env"

# Install dependencies on VM
echo "   Installing dependencies on VM..."
ssh "$VM_USER@$VM_HOST" << 'ENDSSH'
cd /home/simon/linkedin-lead-search

# Update package list
sudo apt-get update -qq

# Install Python and dependencies
sudo apt-get install -y python3 python3-pip postgresql postgresql-contrib

# Install Python packages
pip3 install --user playwright psycopg2-binary python-dotenv pandas

# Install Playwright browsers
python3 -m playwright install chromium
python3 -m playwright install-deps

# Setup PostgreSQL if not already set up
if ! sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw universal_crm; then
    echo "Setting up PostgreSQL..."
    sudo -u postgres createuser -s simon 2>/dev/null || true
    createdb universal_crm 2>/dev/null || true
    psql universal_crm < database/schema.sql
fi

echo "✅ Dependencies installed"
ENDSSH

# Create run script on VM
echo "   Creating run script..."
ssh "$VM_USER@$VM_HOST" << 'ENDSSH'
cat > /home/simon/linkedin-lead-search/run-search.sh << 'EOF'
#!/bin/bash
# LinkedIn Lead Search - Background Runner

cd /home/simon/linkedin-lead-search

# Create output directory
mkdir -p outputs/batch_searches

# Run search in background with nohup
nohup python3 batch_lead_search.py > outputs/batch_searches/search_$(date +%Y%m%d_%H%M%S).log 2>&1 &

PID=$!
echo $PID > search.pid

echo "🚀 Search started in background"
echo "   PID: $PID"
echo "   Log: outputs/batch_searches/search_$(date +%Y%m%d_%H%M%S).log"
echo ""
echo "📊 Monitor progress:"
echo "   tail -f outputs/batch_searches/search_*.log"
echo ""
echo "🛑 Stop search:"
echo "   kill $(cat search.pid)"
echo ""
echo "📥 Download results:"
echo "   scp -r simon@$(hostname -I | awk '{print $1}'):/home/simon/linkedin-lead-search/outputs/batch_searches/ ."
EOF

chmod +x /home/simon/linkedin-lead-search/run-search.sh
ENDSSH

# Create monitoring script
echo "   Creating monitoring script..."
cat > monitor-vm-search.sh << EOF
#!/bin/bash
# Monitor LinkedIn Search on VM

VM_HOST="$VM_HOST"
VM_USER="$VM_USER"
REMOTE_DIR="$REMOTE_DIR"

echo "📊 Monitoring LinkedIn Search on $VM_NAME"
echo "=========================================="
echo ""

# Check if search is running
echo "🔍 Process status:"
ssh \$VM_USER@\$VM_HOST "cd \$REMOTE_DIR && if [ -f search.pid ]; then PID=\\\$(cat search.pid); if ps -p \\\$PID > /dev/null; then echo '✅ Search is RUNNING (PID: '\\\$PID')'; else echo '❌ Search has STOPPED'; fi; else echo '⚠️  No search.pid found'; fi"
echo ""

# Show recent log output
echo "📄 Recent log output (last 30 lines):"
echo "--------------------------------------"
ssh \$VM_USER@\$VM_HOST "cd \$REMOTE_DIR && tail -30 outputs/batch_searches/*.log 2>/dev/null || echo 'No log files found'"
echo ""

# Show CRM stats
echo "📊 CRM Database Stats:"
echo "----------------------"
ssh \$VM_USER@\$VM_HOST "cd \$REMOTE_DIR && python3 crm_database.py dashboard 2>/dev/null || echo 'Could not fetch CRM stats'"
echo ""

echo "🔄 Refresh monitor: ./monitor-vm-search.sh"
echo "📥 Download results: ./download-vm-results.sh"
echo "🛑 Stop search: ./stop-vm-search.sh"
EOF

chmod +x monitor-vm-search.sh

# Create download script
echo "   Creating download script..."
cat > download-vm-results.sh << EOF
#!/bin/bash
# Download results from VM

VM_HOST="$VM_HOST"
VM_USER="$VM_USER"
REMOTE_DIR="$REMOTE_DIR"

echo "📥 Downloading results from $VM_NAME..."
echo ""

# Download outputs
rsync -avz --progress "\$VM_USER@\$VM_HOST:\$REMOTE_DIR/outputs/" ./outputs/

echo ""
echo "✅ Results downloaded to ./outputs/"
echo ""
echo "📊 View dashboard:"
echo "   python3 crm_database.py dashboard"
EOF

chmod +x download-vm-results.sh

# Create stop script
echo "   Creating stop script..."
cat > stop-vm-search.sh << EOF
#!/bin/bash
# Stop LinkedIn Search on VM

VM_HOST="$VM_HOST"
VM_USER="$VM_USER"
REMOTE_DIR="$REMOTE_DIR"

echo "🛑 Stopping LinkedIn Search on $VM_NAME..."

ssh \$VM_USER@\$VM_HOST "cd \$REMOTE_DIR && if [ -f search.pid ]; then kill \\\$(cat search.pid) 2>/dev/null && echo '✅ Search stopped' || echo '⚠️  Process not found'; rm search.pid; else echo '⚠️  No search.pid found'; fi"
EOF

chmod +x stop-vm-search.sh

echo ""
echo "✅ Deployment complete!"
echo ""
echo "═══════════════════════════════════════"
echo "🚀 NEXT STEPS"
echo "═══════════════════════════════════════"
echo ""
echo "1️⃣  Start the search on VM:"
echo "   ssh $VM_USER@$VM_HOST 'cd $REMOTE_DIR && ./run-search.sh'"
echo ""
echo "2️⃣  Monitor progress:"
echo "   ./monitor-vm-search.sh"
echo ""
echo "3️⃣  Download results:"
echo "   ./download-vm-results.sh"
echo ""
echo "4️⃣  Stop search (if needed):"
echo "   ./stop-vm-search.sh"
echo ""
echo "═══════════════════════════════════════"
echo ""
echo "💡 TIP: The search will run in background on the VM."
echo "   You can close VS Code and even shut down your laptop!"
echo ""
