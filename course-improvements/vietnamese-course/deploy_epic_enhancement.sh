#!/bin/bash
#
# Epic Vietnamese Course Enhancement - Deployment Script
# Deploys and monitors 24-hour autonomous enhancement agent
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVICE_NAME="vietnamese-epic-enhancement"
LOG_FILE="${SCRIPT_DIR}/epic_enhancement.log"
PID_FILE="${SCRIPT_DIR}/enhancement_agent.pid"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      EPIC VIETNAMESE COURSE ENHANCEMENT - DEPLOYMENT                 ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo

# Function to print colored messages
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python3 is not installed"
        exit 1
    fi
    print_status "Python3 found: $(python3 --version)"
    
    # Check required Python packages
    python3 -c "import requests" 2>/dev/null || {
        print_warning "requests module not found, installing..."
        pip3 install requests
    }
    
    python3 -c "import gtts" 2>/dev/null || {
        print_warning "gtts module not found, installing..."
        pip3 install gtts
    }
    
    # Check SSH access
    if ! ssh -o ConnectTimeout=5 moodle-vm9001 "echo test" &> /dev/null; then
        print_error "Cannot connect to moodle-vm9001 via SSH"
        exit 1
    fi
    print_status "SSH connection to moodle-vm9001 verified"
    
    # Check Ollama
    if ! curl -s http://localhost:11434/api/tags &> /dev/null; then
        print_warning "Ollama API not accessible at localhost:11434"
        print_info "Agent will attempt to use Ollama anyway..."
    else
        print_status "Ollama API accessible"
    fi
    
    # Check moodle_client.py
    if [ ! -f "${SCRIPT_DIR}/moodle_client.py" ]; then
        print_error "moodle_client.py not found"
        exit 1
    fi
    print_status "moodle_client.py found"
    
    echo
}

# Install systemd service
install_service() {
    print_info "Installing systemd service..."
    
    # Use absolute path to service file
    SERVICE_FILE="/home/simon/Learning-Management-System-Academy/.continue/systemd/${SERVICE_NAME}.service"
    
    if [ ! -f "$SERVICE_FILE" ]; then
        print_error "Service file not found: $SERVICE_FILE"
        exit 1
    fi
    
    sudo cp "$SERVICE_FILE" "/etc/systemd/system/${SERVICE_NAME}.service"
    
    sudo systemctl daemon-reload
    sudo systemctl enable "${SERVICE_NAME}.service"
    
    print_status "Service installed and enabled"
    echo
}

# Start enhancement agent
start_agent() {
    print_info "Starting enhancement agent..."
    
    if sudo systemctl is-active --quiet "${SERVICE_NAME}"; then
        print_warning "Agent is already running"
        echo
        return
    fi
    
    sudo systemctl start "${SERVICE_NAME}"
    sleep 2
    
    if sudo systemctl is-active --quiet "${SERVICE_NAME}"; then
        print_status "Enhancement agent started successfully"
        
        # Show status
        sudo systemctl status "${SERVICE_NAME}" --no-pager | head -15
    else
        print_error "Failed to start enhancement agent"
        sudo journalctl -u "${SERVICE_NAME}" -n 20 --no-pager
        exit 1
    fi
    
    echo
}

# Monitor progress
monitor_progress() {
    print_info "Monitoring enhancement progress..."
    echo
    
    print_info "Live log tail (Ctrl+C to stop monitoring):"
    echo -e "${YELLOW}──────────────────────────────────────────────────────────────────────${NC}"
    
    # Tail log file
    tail -f "${LOG_FILE}" 2>/dev/null &
    TAIL_PID=$!
    
    # Wait for user interrupt
    trap "kill $TAIL_PID 2>/dev/null; exit 0" INT
    wait $TAIL_PID
}

# Show status
show_status() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  ENHANCEMENT AGENT STATUS${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════${NC}"
    echo
    
    if sudo systemctl is-active --quiet "${SERVICE_NAME}"; then
        print_status "Agent is RUNNING"
        
        # Show recent metrics
        if [ -f "${LOG_FILE}" ]; then
            echo
            print_info "Recent activity:"
            grep -E "Enhanced page|Widget injected|Media generated|✅|❌" "${LOG_FILE}" | tail -10
        fi
    else
        print_error "Agent is NOT RUNNING"
    fi
    
    echo
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════${NC}"
    
    # Show metrics if available
    if [ -f "enhancement_report.txt" ]; then
        echo
        print_info "Latest enhancement report:"
        cat enhancement_report.txt
    fi
}

# Stop agent
stop_agent() {
    print_info "Stopping enhancement agent..."
    
    if ! sudo systemctl is-active --quiet "${SERVICE_NAME}"; then
        print_warning "Agent is not running"
        return
    fi
    
    sudo systemctl stop "${SERVICE_NAME}"
    sleep 2
    
    if ! sudo systemctl is-active --quiet "${SERVICE_NAME}"; then
        print_status "Enhancement agent stopped"
    else
        print_error "Failed to stop enhancement agent"
        exit 1
    fi
    
    echo
}

# Verify media files
verify_media() {
    print_info "Verifying media files..."
    echo
    
    MEDIA_DIR="${SCRIPT_DIR}/generated/professional"
    
    if [ ! -d "$MEDIA_DIR" ]; then
        print_warning "Media directory not found: $MEDIA_DIR"
        return
    fi
    
    # Count files
    AUDIO_COUNT=$(find "$MEDIA_DIR" -name "*.mp3" 2>/dev/null | wc -l)
    FLASHCARD_COUNT=$(find "$MEDIA_DIR" -name "*flashcard*.csv" 2>/dev/null | wc -l)
    DIALOGUE_COUNT=$(find "$MEDIA_DIR" -name "*dialogue*.txt" 2>/dev/null | wc -l)
    
    echo "Media Files:"
    echo "  Audio files (MP3):       $AUDIO_COUNT"
    echo "  Flashcard decks (CSV):   $FLASHCARD_COUNT"
    echo "  Dialogue texts (TXT):    $DIALOGUE_COUNT"
    
    if [ $AUDIO_COUNT -gt 0 ]; then
        print_status "Audio files available"
        find "$MEDIA_DIR" -name "*.mp3" | head -5
    else
        print_warning "No audio files found"
    fi
    
    echo
}

# Show help
show_help() {
    cat << EOF
Epic Vietnamese Course Enhancement Agent

USAGE:
    $0 [COMMAND]

COMMANDS:
    install     Install systemd service
    start       Start the enhancement agent
    stop        Stop the enhancement agent
    status      Show agent status and metrics
    monitor     Monitor live progress (tail logs)
    verify      Verify media files are being generated
    restart     Restart the enhancement agent
    logs        Show recent logs
    help        Show this help message

EXAMPLES:
    # Initial deployment
    $0 install
    $0 start
    $0 monitor

    # Check progress
    $0 status
    $0 verify

    # Stop after 24 hours
    $0 stop

LOGS:
    - Main log:   ${LOG_FILE}
    - Error log:  ${LOG_FILE/.log/_error.log}
    - Report:     ${SCRIPT_DIR}/enhancement_report.txt

EOF
}

# Show logs
show_logs() {
    if [ -f "${LOG_FILE}" ]; then
        print_info "Recent logs (last 50 lines):"
        echo
        tail -50 "${LOG_FILE}"
    else
        print_warning "Log file not found: ${LOG_FILE}"
    fi
}

# Main menu
main() {
    case "${1:-help}" in
        install)
            check_prerequisites
            install_service
            ;;
        start)
            check_prerequisites
            start_agent
            print_info "Run '$0 monitor' to watch progress"
            print_info "Run '$0 status' to check metrics"
            ;;
        stop)
            stop_agent
            ;;
        status)
            show_status
            ;;
        monitor)
            monitor_progress
            ;;
        verify)
            verify_media
            ;;
        restart)
            stop_agent
            start_agent
            ;;
        logs)
            show_logs
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
