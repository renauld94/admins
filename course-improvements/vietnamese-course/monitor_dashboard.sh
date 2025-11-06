#!/bin/bash

# Vietnamese Course Enhancement - Live Monitoring Dashboard
# Real-time visualization of agent progress, metrics, and control

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/epic_enhancement.log"
METRICS_FILE="${SCRIPT_DIR}/enhancement_metrics.json"
SERVICE_NAME="vietnamese-epic-enhancement"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Unicode characters
CHECK="✓"
CROSS="✗"
ARROW="→"
BULLET="•"
STAR="★"
CLOCK="⏱"
FIRE="🔥"
ROCKET="🚀"
CHART="📊"
GEAR="⚙️"
WARNING="⚠️"
INFO="ℹ️"

# Clear screen
clear_screen() {
    printf '\033[2J\033[H'
}

# Get system metrics
get_system_metrics() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    local mem_usage=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}')
    local disk_usage=$(df -h "$SCRIPT_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')
    
    echo "$cpu_usage|$mem_usage|$disk_usage"
}

# Get agent status
get_agent_status() {
    if systemctl is-active --quiet "$SERVICE_NAME"; then
        echo "RUNNING"
    else
        echo "STOPPED"
    fi
}

# Get agent PID
get_agent_pid() {
    systemctl show -p MainPID "$SERVICE_NAME" | cut -d'=' -f2
}

# Get runtime duration
get_runtime() {
    if [ "$(get_agent_status)" = "RUNNING" ]; then
        local start_time=$(systemctl show -p ActiveEnterTimestamp "$SERVICE_NAME" | cut -d'=' -f2)
        if [ -n "$start_time" ]; then
            local start_epoch=$(date -d "$start_time" +%s 2>/dev/null)
            local now_epoch=$(date +%s)
            local duration=$((now_epoch - start_epoch))
            
            local hours=$((duration / 3600))
            local minutes=$(((duration % 3600) / 60))
            local seconds=$((duration % 60))
            
            printf "%02d:%02d:%02d" $hours $minutes $seconds
        else
            echo "00:00:00"
        fi
    else
        echo "00:00:00"
    fi
}

# Get estimated time remaining (24 hours total)
get_time_remaining() {
    local runtime=$(get_runtime)
    if [ "$runtime" = "00:00:00" ]; then
        echo "24:00:00"
        return
    fi
    
    local hours=$(echo "$runtime" | cut -d':' -f1)
    local minutes=$(echo "$runtime" | cut -d':' -f2)
    local seconds=$(echo "$runtime" | cut -d':' -f3)
    
    local elapsed_seconds=$((hours * 3600 + minutes * 60 + seconds))
    local total_seconds=$((24 * 3600))
    local remaining_seconds=$((total_seconds - elapsed_seconds))
    
    if [ $remaining_seconds -lt 0 ]; then
        echo "00:00:00"
        return
    fi
    
    local rem_hours=$((remaining_seconds / 3600))
    local rem_minutes=$(((remaining_seconds % 3600) / 60))
    local rem_seconds=$((remaining_seconds % 60))
    
    printf "%02d:%02d:%02d" $rem_hours $rem_minutes $rem_seconds
}

# Parse latest metrics from log
get_latest_metrics() {
    if [ ! -f "$LOG_FILE" ]; then
        echo "0|0|0|0|0|0.0|0.0"
        return
    fi
    
    local pages=$(grep -oP "Pages Enhanced:\s+\K\d+" "$LOG_FILE" | tail -1 || echo "0")
    local widgets=$(grep -oP "Widgets Deployed:\s+\K\d+" "$LOG_FILE" | tail -1 || echo "0")
    local media=$(grep -oP "Media Generated:\s+\K\d+" "$LOG_FILE" | tail -1 || echo "0")
    local features=$(grep -oP "Features Added:\s+\K\d+" "$LOG_FILE" | tail -1 || echo "0")
    local errors=$(grep -oP "Errors:\s+\K\d+" "$LOG_FILE" | tail -1 || echo "0")
    local time_elapsed=$(grep -oP "Time Elapsed:\s+\K[\d.]+" "$LOG_FILE" | tail -1 || echo "0.0")
    local success_rate=$(grep -oP "SUCCESS RATE:\s+\K[\d.]+" "$LOG_FILE" | tail -1 || echo "0.0")
    
    echo "$pages|$widgets|$media|$features|$errors|$time_elapsed|$success_rate"
}

# Get current phase
get_current_phase() {
    if [ ! -f "$LOG_FILE" ]; then
        echo "Initializing"
        return
    fi
    
    local last_phase=$(grep -E "PHASE [1-4]:" "$LOG_FILE" | tail -1)
    if [ -z "$last_phase" ]; then
        echo "Initializing"
    else
        echo "$last_phase" | sed 's/.*PHASE/PHASE/' | sed 's/:.*//'
    fi
}

# Get latest log entries
get_latest_logs() {
    local count=${1:-10}
    if [ ! -f "$LOG_FILE" ]; then
        echo "No logs yet"
        return
    fi
    tail -n "$count" "$LOG_FILE" | sed 's/^[0-9-]* [0-9:,]* - [^ ]* - //'
}

# Progress bar
draw_progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=0; i<empty; i++)); do printf "░"; done
    printf "] %3d%%" "$percentage"
}

# Draw header
draw_header() {
    local status=$1
    local runtime=$2
    local remaining=$3
    
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║${WHITE}          🚀 VIETNAMESE COURSE EPIC ENHANCEMENT - LIVE DASHBOARD 🚀          ${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    # Status bar
    if [ "$status" = "RUNNING" ]; then
        echo -e "${GREEN}${BOLD}${FIRE} STATUS: ACTIVE & ENHANCING${NC}"
    else
        echo -e "${RED}${BOLD}${CROSS} STATUS: STOPPED${NC}"
    fi
    
    echo -e "${GRAY}────────────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "${CYAN}${CLOCK} Runtime:${NC}    ${WHITE}${runtime}${NC}    ${YELLOW}${ARROW} Remaining:${NC} ${WHITE}${remaining}${NC}"
    echo -e "${GRAY}────────────────────────────────────────────────────────────────────────────────${NC}"
    echo
}

# Draw metrics
draw_metrics() {
    local metrics=$1
    IFS='|' read -r pages widgets media features errors time_elapsed success_rate <<< "$metrics"
    
    echo -e "${BOLD}${MAGENTA}${CHART} ENHANCEMENT METRICS${NC}"
    echo -e "${GRAY}════════════════════════════════════════════════════════════════════════════════${NC}"
    
    # Pages enhanced
    echo -e "${CYAN}${BULLET} Pages Enhanced:${NC}      ${WHITE}${pages}${NC} / ${GRAY}83${NC}     $(draw_progress_bar "$pages" 83)"
    
    # Widgets deployed
    echo -e "${CYAN}${BULLET} Widgets Deployed:${NC}    ${WHITE}${widgets}${NC} / ${GRAY}83${NC}     $(draw_progress_bar "$widgets" 83)"
    
    # Media generated
    echo -e "${CYAN}${BULLET} Media Generated:${NC}     ${WHITE}${media}${NC} / ${GRAY}200${NC}    $(draw_progress_bar "$media" 200)"
    
    # Features added
    echo -e "${CYAN}${BULLET} Features Added:${NC}      ${WHITE}${features}${NC} / ${GRAY}20${NC}     $(draw_progress_bar "$features" 20)"
    
    echo
    
    # Success rate
    local success_color=$RED
    if (( $(echo "$success_rate > 80" | bc -l 2>/dev/null || echo 0) )); then
        success_color=$GREEN
    elif (( $(echo "$success_rate > 50" | bc -l 2>/dev/null || echo 0) )); then
        success_color=$YELLOW
    fi
    
    echo -e "${BOLD}${success_color}${STAR} Success Rate:${NC}        ${WHITE}${success_rate}%${NC}"
    
    # Errors
    local error_color=$GREEN
    if [ "$errors" -gt 10 ]; then
        error_color=$RED
    elif [ "$errors" -gt 5 ]; then
        error_color=$YELLOW
    fi
    
    echo -e "${BOLD}${error_color}${WARNING} Errors:${NC}               ${WHITE}${errors}${NC}"
    
    echo -e "${GRAY}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo
}

# Draw current phase
draw_phase() {
    local phase=$1
    
    echo -e "${BOLD}${BLUE}${GEAR} CURRENT PHASE${NC}"
    echo -e "${GRAY}────────────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "${WHITE}${phase}${NC}"
    echo -e "${GRAY}────────────────────────────────────────────────────────────────────────────────${NC}"
    echo
}

# Draw system resources
draw_system() {
    local metrics=$1
    IFS='|' read -r cpu mem disk <<< "$metrics"
    
    echo -e "${BOLD}${YELLOW}${ROCKET} SYSTEM RESOURCES${NC}"
    echo -e "${GRAY}────────────────────────────────────────────────────────────────────────────────${NC}"
    
    # CPU
    local cpu_color=$GREEN
    if (( $(echo "$cpu > 80" | bc -l 2>/dev/null || echo 0) )); then
        cpu_color=$RED
    elif (( $(echo "$cpu > 50" | bc -l 2>/dev/null || echo 0) )); then
        cpu_color=$YELLOW
    fi
    echo -e "${cpu_color}${BULLET} CPU:${NC}     ${cpu}%    $(draw_progress_bar "${cpu%.*}" 100)"
    
    # Memory
    local mem_color=$GREEN
    if (( $(echo "$mem > 80" | bc -l 2>/dev/null || echo 0) )); then
        mem_color=$RED
    elif (( $(echo "$mem > 50" | bc -l 2>/dev/null || echo 0) )); then
        mem_color=$YELLOW
    fi
    echo -e "${mem_color}${BULLET} Memory:${NC}  ${mem}%    $(draw_progress_bar "${mem%.*}" 100)"
    
    # Disk
    local disk_color=$GREEN
    if [ "$disk" -gt 80 ]; then
        disk_color=$RED
    elif [ "$disk" -gt 50 ]; then
        disk_color=$YELLOW
    fi
    echo -e "${disk_color}${BULLET} Disk:${NC}    ${disk}%    $(draw_progress_bar "$disk" 100)"
    
    echo -e "${GRAY}────────────────────────────────────────────────────────────────────────────────${NC}"
    echo
}

# Draw recent logs
draw_logs() {
    echo -e "${BOLD}${GREEN}${INFO} RECENT ACTIVITY (Last 8 entries)${NC}"
    echo -e "${GRAY}════════════════════════════════════════════════════════════════════════════════${NC}"
    
    get_latest_logs 8 | while IFS= read -r line; do
        if [[ "$line" == *"ERROR"* ]]; then
            echo -e "${RED}${CROSS}${NC} ${GRAY}${line}${NC}"
        elif [[ "$line" == *"SUCCESS"* ]] || [[ "$line" == *"✓"* ]]; then
            echo -e "${GREEN}${CHECK}${NC} ${WHITE}${line}${NC}"
        elif [[ "$line" == *"INFO"* ]]; then
            echo -e "${CYAN}${INFO}${NC} ${line}"
        else
            echo -e "${GRAY}${BULLET}${NC} ${line}"
        fi
    done
    
    echo -e "${GRAY}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo
}

# Draw controls
draw_controls() {
    echo -e "${BOLD}${WHITE}${GEAR} CONTROLS${NC}"
    echo -e "${GRAY}────────────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "${CYAN}[R]${NC} Restart Agent    ${CYAN}[S]${NC} Stop Agent    ${CYAN}[P]${NC} Pause/Resume    ${CYAN}[L]${NC} Full Logs    ${CYAN}[Q]${NC} Quit"
    echo -e "${GRAY}────────────────────────────────────────────────────────────────────────────────${NC}"
}

# Main dashboard loop
main_dashboard() {
    local refresh_interval=2
    
    while true; do
        clear_screen
        
        # Get all data
        local status=$(get_agent_status)
        local runtime=$(get_runtime)
        local remaining=$(get_time_remaining)
        local metrics=$(get_latest_metrics)
        local phase=$(get_current_phase)
        local system=$(get_system_metrics)
        
        # Draw dashboard
        draw_header "$status" "$runtime" "$remaining"
        draw_metrics "$metrics"
        draw_phase "$phase"
        draw_system "$system"
        draw_logs
        draw_controls
        
        echo -e "${GRAY}Last updated: $(date '+%Y-%m-%d %H:%M:%S')${NC}    ${GRAY}Refresh: ${refresh_interval}s${NC}"
        
        # Wait for input or timeout
        read -t "$refresh_interval" -n 1 key
        
        case "$key" in
            r|R)
                echo -e "\n${YELLOW}Restarting agent...${NC}"
                sudo systemctl restart "$SERVICE_NAME"
                sleep 2
                ;;
            s|S)
                echo -e "\n${YELLOW}Stopping agent...${NC}"
                sudo systemctl stop "$SERVICE_NAME"
                sleep 2
                ;;
            p|P)
                if [ "$status" = "RUNNING" ]; then
                    echo -e "\n${YELLOW}Pausing agent...${NC}"
                    sudo systemctl stop "$SERVICE_NAME"
                else
                    echo -e "\n${YELLOW}Resuming agent...${NC}"
                    sudo systemctl start "$SERVICE_NAME"
                fi
                sleep 2
                ;;
            l|L)
                clear_screen
                echo -e "${BOLD}${GREEN}Full Log View${NC} (Press Ctrl+C to return)"
                echo -e "${GRAY}════════════════════════════════════════════════════════════════════════════════${NC}"
                tail -f "$LOG_FILE"
                ;;
            q|Q)
                clear_screen
                echo -e "${GREEN}Dashboard closed. Agent continues running.${NC}"
                exit 0
                ;;
        esac
    done
}

# Run dashboard
main_dashboard
