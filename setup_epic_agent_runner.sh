#!/bin/bash
# ============================================================================
# 🚀 EPIC BACKGROUND AGENT RUNNER - SETUP & DEPLOYMENT SCRIPT
# ============================================================================
# Sets up and starts all AI agents in the background with VM 159 models
# for the online Vietnamese course

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
BASE_DIR="/home/simon/Learning-Management-System-Academy"
LOG_DIR="$BASE_DIR/logs/agents"
DATA_DIR="$BASE_DIR/data/agents"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# VM 159 Configuration
VM159_IP="10.0.0.110"
VM159_USER="simonadmin"
SSH_TUNNEL_PORT=11434

# Service ports
declare -A PORTS=(
    [orchestrator]=5100
    [code_agent]=5101
    [data_agent]=5102
    [course_agent]=5103
    [tutor_agent]=5104
    [dashboard]=5110
)

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

print_header() {
    echo -e "${CYAN}"
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║  $1"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
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

print_step() {
    echo -e "${CYAN}▶  $1${NC}"
}

# ============================================================================
# CHECKS & VALIDATION
# ============================================================================

check_prerequisites() {
    print_header "CHECKING PREREQUISITES"
    
    print_step "Python 3.9+"
    if command -v python3 &> /dev/null; then
        PY_VERSION=$(python3 --version | cut -d' ' -f2)
        print_success "Python $PY_VERSION found"
    else
        print_error "Python 3 not found. Please install Python 3.9+"
        exit 1
    fi
    
    print_step "SSH access to VM 159"
    if ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$VM159_USER@$VM159_IP" "echo 'SSH OK'" &> /dev/null; then
        print_success "SSH connection to VM 159 verified"
    else
        print_warning "Cannot reach VM 159 via SSH. Make sure you have SSH keys configured."
        echo "Setup: ssh-copy-id $VM159_USER@$VM159_IP"
    fi
    
    print_step "Required Python packages"
    for pkg in fastapi uvicorn requests; do
        if python3 -c "import $pkg" 2>/dev/null; then
            print_success "$pkg installed"
        else
            print_warning "$pkg not found. Installing..."
            pip3 install -q "$pkg"
        fi
    done
    
    echo ""
}

check_vm159_models() {
    print_header "CHECKING VM 159 OLLAMA MODELS"
    
    print_step "Connecting to VM 159 Ollama..."
    
    # First try direct connection
    if timeout 5 curl -s "http://$VM159_IP:11434/api/tags" &> /dev/null; then
        print_success "Direct connection to VM 159 Ollama"
        OLLAMA_ACCESSIBLE="direct"
    else
        print_info "VM 159 Ollama not directly accessible, will use SSH tunnel"
        OLLAMA_ACCESSIBLE="tunnel"
    fi
}

# ============================================================================
# SETUP FUNCTIONS
# ============================================================================

setup_directories() {
    print_header "SETTING UP DIRECTORIES"
    
    print_step "Creating log directory: $LOG_DIR"
    mkdir -p "$LOG_DIR"
    print_success "Log directory ready"
    
    print_step "Creating data directory: $DATA_DIR"
    mkdir -p "$DATA_DIR"
    print_success "Data directory ready"
    
    print_step "Creating assets directory"
    mkdir -p "$BASE_DIR/assets/agent-dashboard"
    print_success "Assets directory ready"
    
    echo ""
}

setup_ssh_tunnel() {
    print_header "SETTING UP SSH TUNNEL TO VM 159"
    
    print_step "Checking existing tunnel..."
    TUNNEL_PID=$(pgrep -f "ssh -N -L $SSH_TUNNEL_PORT" || true)
    
    if [ -n "$TUNNEL_PID" ]; then
        print_success "SSH tunnel already running (PID: $TUNNEL_PID)"
        return
    fi
    
    print_step "Starting SSH tunnel to VM 159..."
    ssh -N -L "$SSH_TUNNEL_PORT:localhost:11434" "$VM159_USER@$VM159_IP" &
    TUNNEL_PID=$!
    sleep 2
    
    if ps -p "$TUNNEL_PID" > /dev/null; then
        print_success "SSH tunnel started (PID: $TUNNEL_PID)"
        echo "$TUNNEL_PID" > "$DATA_DIR/.tunnel_pid"
    else
        print_error "Failed to start SSH tunnel"
        exit 1
    fi
    
    echo ""
}

verify_ollama() {
    print_header "VERIFYING OLLAMA CONNECTIVITY"
    
    print_step "Testing Ollama API (localhost:$SSH_TUNNEL_PORT)..."
    
    for i in {1..10}; do
        if curl -s "http://localhost:$SSH_TUNNEL_PORT/api/tags" > /dev/null 2>&1; then
            print_success "Ollama API is accessible"
            
            print_step "Checking available models..."
            MODELS=$(curl -s "http://localhost:$SSH_TUNNEL_PORT/api/tags" | python3 -c "import sys, json; data=json.load(sys.stdin); print('\\n'.join([m['name'] for m in data.get('models', [])]))")
            
            if [ -z "$MODELS" ]; then
                print_warning "No models found on VM 159 Ollama"
            else
                echo -e "${GREEN}Available models:${NC}"
                echo "$MODELS" | sed 's/^/  ✓ /'
            fi
            return 0
        fi
        
        if [ $i -lt 10 ]; then
            print_warning "Ollama not ready, retrying... ($i/10)"
            sleep 1
        fi
    done
    
    print_error "Could not connect to Ollama. Check VM 159 status."
    return 1
}

# ============================================================================
# SERVICE MANAGEMENT
# ============================================================================

install_systemd_service() {
    print_header "INSTALLING SYSTEMD SERVICE"
    
    SERVICE_DIR="$HOME/.config/systemd/user"
    SERVICE_FILE="$SERVICE_DIR/epic-agent-runner.service"
    
    mkdir -p "$SERVICE_DIR"
    
    print_step "Creating systemd service file..."
    cat > "$SERVICE_FILE" << 'EOF'
[Unit]
Description=Epic Background Agent Runner - Multi-Model AI Orchestrator
Documentation=file:///home/simon/Learning-Management-System-Academy/EPIC_AGENT_RUNNER.md
After=network-online.target
Wants=network-online.target
StartLimitBurst=3
StartLimitIntervalSec=300

[Service]
Type=simple
User=simon
WorkingDirectory=/home/simon/Learning-Management-System-Academy
ExecStart=/usr/bin/python3 /home/simon/Learning-Management-System-Academy/epic_background_agent_runner.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=epic-agent-runner

PrivateTmp=yes
NoNewPrivileges=true

CPUQuota=400%
MemoryLimit=4G

Environment="PYTHONUNBUFFERED=1"
Environment="OLLAMA_HOST=http://localhost:11434"
Environment="PATH=/home/simon/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

[Install]
WantedBy=multi-user.target
EOF
    
    print_success "Service file created: $SERVICE_FILE"
    
    print_step "Reloading systemd daemon..."
    systemctl --user daemon-reload
    print_success "Systemd daemon reloaded"
    
    echo ""
}

start_services() {
    print_header "STARTING AGENT ORCHESTRATOR"
    
    print_step "Starting epic-agent-runner service..."
    systemctl --user start epic-agent-runner || {
        print_warning "Service start may need permissions. Trying direct start..."
        nohup python3 "$BASE_DIR/epic_background_agent_runner.py" > "$LOG_DIR/orchestrator.log" 2>&1 &
    }
    
    sleep 3
    
    print_step "Verifying service is running..."
    if systemctl --user is-active --quiet epic-agent-runner 2>/dev/null || \
       curl -s "http://localhost:5100/health" > /dev/null 2>&1; then
        print_success "Agent orchestrator is running"
    else
        print_warning "Service may still be starting. Checking in 5 seconds..."
        sleep 5
    fi
    
    echo ""
}

enable_auto_start() {
    print_header "ENABLING AUTO-START"
    
    print_step "Enabling epic-agent-runner to start on boot..."
    systemctl --user enable epic-agent-runner 2>/dev/null || print_warning "Could not enable auto-start. Run manually if needed."
    
    print_success "Service will auto-start on login"
    echo ""
}

# ============================================================================
# STATUS & TESTING
# ============================================================================

test_orchestrator() {
    print_header "TESTING ORCHESTRATOR"
    
    print_step "Testing /health endpoint..."
    if HEALTH=$(curl -s "http://localhost:5100/health" 2>/dev/null); then
        print_success "Orchestrator is responding"
        echo "$HEALTH" | python3 -m json.tool | sed 's/^/  /'
    else
        print_error "Orchestrator not responding at http://localhost:5100"
        return 1
    fi
    
    print_step "Testing /status endpoint..."
    if STATUS=$(curl -s "http://localhost:5100/status" 2>/dev/null); then
        AGENTS_RUNNING=$(echo "$STATUS" | python3 -c "import sys, json; d=json.load(sys.stdin); print(sum(1 for a in d.get('agents', {}).values() if a['status']=='running'))" 2>/dev/null || echo "?")
        print_success "Status: $AGENTS_RUNNING agents running"
    else
        print_warning "Could not fetch status"
    fi
    
    echo ""
}

show_access_info() {
    print_header "🌐 ACCESS INFORMATION"
    
    echo -e "${GREEN}Agent Services:${NC}"
    echo "  • Orchestrator API:      http://localhost:${PORTS[orchestrator]}"
    echo "  • Code Agent:            http://localhost:${PORTS[code_agent]}"
    echo "  • Data Agent:            http://localhost:${PORTS[data_agent]}"
    echo "  • Course Agent:          http://localhost:${PORTS[course_agent]}"
    echo "  • Tutor Agent:           http://localhost:${PORTS[tutor_agent]}"
    echo "  • Dashboard:             http://localhost:${PORTS[dashboard]}"
    
    echo ""
    echo -e "${GREEN}Configuration:${NC}"
    echo "  • VM 159 IP:             $VM159_IP"
    echo "  • SSH Tunnel Port:       $SSH_TUNNEL_PORT"
    echo "  • Log Directory:         $LOG_DIR"
    echo "  • Data Directory:        $DATA_DIR"
    
    echo ""
    echo -e "${GREEN}Service Management:${NC}"
    echo "  • Start:   systemctl --user start epic-agent-runner"
    echo "  • Stop:    systemctl --user stop epic-agent-runner"
    echo "  • Status:  systemctl --user status epic-agent-runner"
    echo "  • Logs:    journalctl --user -u epic-agent-runner -f"
    
    echo ""
    echo -e "${GREEN}Quick Commands:${NC}"
    echo "  • Open Dashboard:        firefox http://localhost:${PORTS[dashboard]}"
    echo "  • Test API:              curl http://localhost:${PORTS[orchestrator]}/health"
    echo "  • List Models:           curl http://localhost:${PORTS[orchestrator]}/models"
    
    echo ""
}

show_next_steps() {
    print_header "📋 NEXT STEPS"
    
    echo -e "${BLUE}1. Monitor Agent Status${NC}"
    echo "   journalctl --user -u epic-agent-runner -f"
    echo ""
    
    echo -e "${BLUE}2. Check Dashboard${NC}"
    echo "   Open browser: http://localhost:${PORTS[dashboard]}"
    echo ""
    
    echo -e "${BLUE}3. Deploy to Course${NC}"
    echo "   python3 deploy_epic_system.py"
    echo ""
    
    echo -e "${BLUE}4. Monitor Logs${NC}"
    echo "   tail -f $LOG_DIR/orchestrator.log"
    echo ""
}

# ============================================================================
# CLEANUP
# ============================================================================

cleanup() {
    print_header "CLEANUP"
    
    print_step "Stopping services..."
    systemctl --user stop epic-agent-runner 2>/dev/null || true
    
    print_step "Closing SSH tunnel..."
    if [ -f "$DATA_DIR/.tunnel_pid" ]; then
        TUNNEL_PID=$(cat "$DATA_DIR/.tunnel_pid")
        kill "$TUNNEL_PID" 2>/dev/null || true
        rm "$DATA_DIR/.tunnel_pid"
    fi
    
    pkill -f "ssh -N -L $SSH_TUNNEL_PORT" || true
    
    print_success "Cleanup complete"
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    print_header "🚀 EPIC BACKGROUND AGENT RUNNER SETUP"
    
    # Handle interrupt
    trap cleanup EXIT INT TERM
    
    # Check if help requested
    if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
        echo "Usage: $0 [OPTION]"
        echo ""
        echo "Options:"
        echo "  (no option)  Full setup and start services"
        echo "  --status     Show current status"
        echo "  --logs       Show live logs"
        echo "  --stop       Stop all services"
        echo "  --clean      Clean up and stop"
        exit 0
    fi
    
    # Status only
    if [ "$1" = "--status" ]; then
        test_orchestrator
        exit 0
    fi
    
    # Logs only
    if [ "$1" = "--logs" ]; then
        journalctl --user -u epic-agent-runner -f
        exit 0
    fi
    
    # Stop services
    if [ "$1" = "--stop" ]; then
        cleanup
        exit 0
    fi
    
    # Full setup
    check_prerequisites
    setup_directories
    check_vm159_models
    setup_ssh_tunnel
    verify_ollama || exit 1
    install_systemd_service
    start_services
    enable_auto_start
    test_orchestrator
    show_access_info
    show_next_steps
    
    echo ""
    print_header "✨ SETUP COMPLETE!"
    echo "Your AI agents are now running in the background!"
    echo ""
}

# Run main
main "$@"
