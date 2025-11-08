#!/usr/bin/env bash
# ============================================================================
# 🚀 EPIC AGENT RUNNER - COMPREHENSIVE DEPLOYMENT SCRIPT
# ============================================================================
# One-command deployment for all AI agents with background monitoring

set -e

BASE_DIR="/home/simon/Learning-Management-System-Academy"
PID_FILE="$BASE_DIR/.epic_agent_pids"
LOG_DIR="$BASE_DIR/logs/agents"
DATA_DIR="$BASE_DIR/data/agents"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

# ============================================================================
# CLEANUP PREVIOUS PROCESSES
# ============================================================================

cleanup_old_processes() {
    print_info "Cleaning up old processes..."
    
    # Kill old agent runners
    pkill -f "epic_background_agent_runner.py" || true
    pkill -f "port 5100" || true
    pkill -f "port 5101" || true
    pkill -f "port 5102" || true
    pkill -f "port 5103" || true
    pkill -f "port 5104" || true
    
    sleep 2
    print_success "Old processes cleaned up"
}

# ============================================================================
# START SERVICES
# ============================================================================

start_services() {
    print_info "Starting Epic Agent Runner..."
    
    mkdir -p "$LOG_DIR"
    
    # Start agent runner in background
    nohup python3 "$BASE_DIR/epic_background_agent_runner.py" \
        > "$LOG_DIR/orchestrator.log" 2>&1 &
    
    ORCHESTRATOR_PID=$!
    echo "$ORCHESTRATOR_PID" > "$PID_FILE"
    
    # Wait for startup
    sleep 3
    
    # Check if running
    if ps -p "$ORCHESTRATOR_PID" > /dev/null; then
        print_success "Agent Orchestrator started (PID: $ORCHESTRATOR_PID)"
    else
        print_error "Failed to start Agent Orchestrator"
        cat "$LOG_DIR/orchestrator.log" | tail -20
        exit 1
    fi
}

# ============================================================================
# VERIFY SERVICES
# ============================================================================

verify_services() {
    print_info "Verifying services..."
    
    # Wait for services to be ready
    MAX_RETRIES=10
    RETRY=0
    
    while [ $RETRY -lt $MAX_RETRIES ]; do
        if curl -s http://localhost:5100/health > /dev/null 2>&1; then
            print_success "Orchestrator is responding"
            break
        fi
        
        if [ $RETRY -eq 0 ]; then
            print_warning "Waiting for orchestrator to start..."
        fi
        
        RETRY=$((RETRY + 1))
        sleep 1
    done
    
    if [ $RETRY -eq $MAX_RETRIES ]; then
        print_error "Orchestrator failed to start"
        cat "$LOG_DIR/orchestrator.log" | tail -30
        exit 1
    fi
    
    # Get status
    STATUS=$(curl -s http://localhost:5100/health)
    echo "$STATUS" | python3 -m json.tool 2>/dev/null || true
}

# ============================================================================
# SHOW STATUS
# ============================================================================

show_status() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                     🚀 SERVICES RUNNING                       ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    print_success "Orchestrator: http://localhost:5100"
    print_success "Dashboard:   http://localhost:5110"
    print_success "API Status:  http://localhost:5100/health"
    print_success "API Status:  http://localhost:5100/status"
    print_success "Models List: http://localhost:5100/models"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Agent Services:"
    echo "  • Code Agent (DeepSeek):  http://localhost:5101"
    echo "  • Data Agent (Llama):     http://localhost:5102"
    echo "  • Course Agent (Qwen):    http://localhost:5103"
    echo "  • Tutor Agent (Mistral):  http://localhost:5104"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Quick Commands:"
    echo "  • View logs:    tail -f $LOG_DIR/orchestrator.log"
    echo "  • Stop service: kill \$(cat $PID_FILE)"
    echo "  • Check status: curl http://localhost:5100/health"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    print_info "Full documentation: $BASE_DIR/EPIC_AGENT_RUNNER.md"
    echo ""
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║        🚀 EPIC BACKGROUND AGENT RUNNER - DEPLOYMENT           ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    cleanup_old_processes
    start_services
    verify_services
    show_status
    
    echo "✨ All services deployed and running!"
    echo ""
    echo "Agents will continue running in the background."
    echo "Logs are saved to: $LOG_DIR/orchestrator.log"
    echo ""
}

main
