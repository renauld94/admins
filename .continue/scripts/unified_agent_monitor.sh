#!/bin/bash

# Unified Agent Monitoring Dashboard
# Monitors all agents in the system with real-time metrics

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEMD_DIR="/home/simon/Learning-Management-System-Academy/.continue/systemd"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'

# Unicode
CHECK="✓"
CROSS="✗"
ARROW="→"
BULLET="•"
STAR="★"
FIRE="🔥"
ROCKET="🚀"
GEAR="⚙️"
CHART="📊"
CLOCK="⏱"

# Define all agents to monitor
declare -A AGENTS=(
    ["agent-core_dev"]="Core Development Agent"
    ["agent-data_science"]="Data Science Agent"
    ["agent-geo_intel"]="GeoIntelligence Agent"
    ["agent-legal_advisor"]="Legal Advisor Agent"
    ["agent-portfolio"]="Portfolio Management Agent"
    ["agent-systemops"]="System Operations Agent"
    ["agent-web_lms"]="Web/LMS Agent"
    ["vietnamese-epic-enhancement"]="Vietnamese Course Enhancement"
    ["vietnamese-tutor-agent"]="Vietnamese Tutor Agent"
    ["smart-agent"]="Smart Agent"
    ["poll-to-sse"]="SSE Polling Service"
    ["mcp-agent"]="MCP Agent"
    ["ollama-code-assistant"]="Ollama Code Assistant"
)

# Support services
declare -A SUPPORT_SERVICES=(
    ["mcp-tunnel"]="MCP SSH Tunnel"
    ["ssh-agent"]="SSH Agent"
    ["health-check"]="Health Check Service"
)

# Clear screen
clear_screen() {
    printf '\033[2J\033[H'
}

# Get agent status
get_agent_status() {
    local service=$1
    if systemctl is-active --quiet "${service}.service" 2>/dev/null; then
        echo "RUNNING"
    else
        echo "STOPPED"
    fi
}

# Get agent PID
get_agent_pid() {
    local service=$1
    systemctl show -p MainPID "${service}.service" 2>/dev/null | cut -d'=' -f2
}

# Get agent memory usage
get_agent_memory() {
    local pid=$1
    if [ -n "$pid" ] && [ "$pid" != "0" ]; then
        ps -o rss= -p "$pid" 2>/dev/null | awk '{printf "%.1f", $1/1024}' || echo "0"
    else
        echo "0"
    fi
}

# Get agent CPU usage
get_agent_cpu() {
    local pid=$1
    if [ -n "$pid" ] && [ "$pid" != "0" ]; then
        ps -o %cpu= -p "$pid" 2>/dev/null | awk '{printf "%.1f", $1}' || echo "0"
    else
        echo "0"
    fi
}

# Get agent uptime
get_agent_uptime() {
    local service=$1
    if [ "$(get_agent_status "$service")" = "RUNNING" ]; then
        local start_time=$(systemctl show -p ActiveEnterTimestamp "${service}.service" 2>/dev/null | cut -d'=' -f2)
        if [ -n "$start_time" ]; then
            local start_epoch=$(date -d "$start_time" +%s 2>/dev/null)
            local now_epoch=$(date +%s)
            local duration=$((now_epoch - start_epoch))
            
            local days=$((duration / 86400))
            local hours=$(((duration % 86400) / 3600))
            local minutes=$(((duration % 3600) / 60))
            
            if [ $days -gt 0 ]; then
                echo "${days}d ${hours}h"
            elif [ $hours -gt 0 ]; then
                echo "${hours}h ${minutes}m"
            else
                echo "${minutes}m"
            fi
        else
            echo "0m"
        fi
    else
        echo "-"
    fi
}

# Get system metrics
get_system_metrics() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
    local mem_total=$(free -m | awk 'NR==2{print $2}')
    local mem_used=$(free -m | awk 'NR==2{print $3}')
    local mem_percent=$(echo "scale=1; $mem_used * 100 / $mem_total" | bc)
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    local load_avg=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs)
    
    echo "$cpu_usage|$mem_used|$mem_total|$mem_percent|$disk_usage|$load_avg"
}

# Count running agents
count_running_agents() {
    local count=0
    for service in "${!AGENTS[@]}"; do
        if [ "$(get_agent_status "$service")" = "RUNNING" ]; then
            ((count++))
        fi
    done
    echo $count
}

# Draw header
draw_header() {
    local total_agents=${#AGENTS[@]}
    local running_agents=$(count_running_agents)
    
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║${WHITE}              🚀 UNIFIED AGENT MONITORING DASHBOARD 🚀                       ${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}╠══════════════════════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${BOLD}${CYAN}║${NC}  ${GREEN}Running: ${WHITE}${running_agents}${NC}/${WHITE}${total_agents}${NC}  ${GRAY}|${NC}  ${CYAN}Active Agents${NC}  ${GRAY}|${NC}  ${YELLOW}$(date '+%Y-%m-%d %H:%M:%S')${NC}     ${CYAN}║${NC}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo
}

# Draw agent table
draw_agent_table() {
    echo -e "${BOLD}${MAGENTA}${CHART} PRIMARY AGENTS${NC}"
    echo -e "${GRAY}════════════════════════════════════════════════════════════════════════════════${NC}"
    
    printf "${BOLD}%-30s %-10s %-10s %-10s %-10s${NC}\n" "Agent" "Status" "Uptime" "CPU%" "Memory"
    echo -e "${GRAY}────────────────────────────────────────────────────────────────────────────────${NC}"
    
    for service in $(echo "${!AGENTS[@]}" | tr ' ' '\n' | sort); do
        local name="${AGENTS[$service]}"
        local status=$(get_agent_status "$service")
        local pid=$(get_agent_pid "$service")
        local uptime=$(get_agent_uptime "$service")
        local cpu=$(get_agent_cpu "$pid")
        local mem=$(get_agent_memory "$pid")
        
        # Status color
        local status_color=$RED
        local status_icon=$CROSS
        if [ "$status" = "RUNNING" ]; then
            status_color=$GREEN
            status_icon=$CHECK
        fi
        
        # CPU color
        local cpu_color=$GREEN
        if (( $(echo "$cpu > 50" | bc -l 2>/dev/null || echo 0) )); then
            cpu_color=$YELLOW
        fi
        if (( $(echo "$cpu > 80" | bc -l 2>/dev/null || echo 0) )); then
            cpu_color=$RED
        fi
        
        printf "%-30s ${status_color}%-10s${NC} %-10s ${cpu_color}%-10s${NC} %-10s\n" \
            "$name" "${status_icon} ${status}" "$uptime" "${cpu}%" "${mem}MB"
    done
    
    echo -e "${GRAY}════════════════════════════════════════════════════════════════════════════════${NC}"
    echo
}

# Draw support services
draw_support_services() {
    echo -e "${BOLD}${BLUE}${GEAR} SUPPORT SERVICES${NC}"
    echo -e "${GRAY}────────────────────────────────────────────────────────────────────────────────${NC}"
    
    for service in $(echo "${!SUPPORT_SERVICES[@]}" | tr ' ' '\n' | sort); do
        local name="${SUPPORT_SERVICES[$service]}"
        local status=$(get_agent_status "$service")
        
        local status_color=$RED
        local status_icon=$CROSS
        if [ "$status" = "RUNNING" ]; then
            status_color=$GREEN
            status_icon=$CHECK
        fi
        
        printf "${BULLET} %-40s ${status_color}[${status_icon} %s]${NC}\n" "$name" "$status"
    done
    
    echo -e "${GRAY}────────────────────────────────────────────────────────────────────────────────${NC}"
    echo
}

# Draw system resources
draw_system_resources() {
    local metrics=$(get_system_metrics)
    IFS='|' read -r cpu mem_used mem_total mem_percent disk load_avg <<< "$metrics"
    
    echo -e "${BOLD}${YELLOW}${ROCKET} SYSTEM RESOURCES${NC}"
    echo -e "${GRAY}────────────────────────────────────────────────────────────────────────────────${NC}"
    
    # CPU
    local cpu_bar=$(printf "%.0f" "$cpu")
    local cpu_filled=$((cpu_bar / 5))
    local cpu_empty=$((20 - cpu_filled))
    local cpu_color=$GREEN
    if (( $(echo "$cpu > 50" | bc -l 2>/dev/null || echo 0) )); then cpu_color=$YELLOW; fi
    if (( $(echo "$cpu > 80" | bc -l 2>/dev/null || echo 0) )); then cpu_color=$RED; fi
    
    printf "${cpu_color}CPU:${NC}     %5.1f%% [" "$cpu"
    for ((i=0; i<cpu_filled; i++)); do printf "█"; done
    for ((i=0; i<cpu_empty; i++)); do printf "░"; done
    printf "] Load: %s\n" "$load_avg"
    
    # Memory
    local mem_bar=$(printf "%.0f" "$mem_percent")
    local mem_filled=$((mem_bar / 5))
    local mem_empty=$((20 - mem_filled))
    local mem_color=$GREEN
    if (( $(echo "$mem_percent > 50" | bc -l 2>/dev/null || echo 0) )); then mem_color=$YELLOW; fi
    if (( $(echo "$mem_percent > 80" | bc -l 2>/dev/null || echo 0) )); then mem_color=$RED; fi
    
    printf "${mem_color}Memory:${NC}  %5.1f%% [" "$mem_percent"
    for ((i=0; i<mem_filled; i++)); do printf "█"; done
    for ((i=0; i<mem_empty; i++)); do printf "░"; done
    printf "] %s / %s MB\n" "$mem_used" "$mem_total"
    
    # Disk
    local disk_filled=$((disk / 5))
    local disk_empty=$((20 - disk_filled))
    local disk_color=$GREEN
    if [ "$disk" -gt 50 ]; then disk_color=$YELLOW; fi
    if [ "$disk" -gt 80 ]; then disk_color=$RED; fi
    
    printf "${disk_color}Disk:${NC}    %5s%% [" "$disk"
    for ((i=0; i<disk_filled; i++)); do printf "█"; done
    for ((i=0; i<disk_empty; i++)); do printf "░"; done
    printf "]\n"
    
    echo -e "${GRAY}────────────────────────────────────────────────────────────────────────────────${NC}"
    echo
}

# Draw controls
draw_controls() {
    echo -e "${BOLD}${WHITE}${GEAR} CONTROLS & COMMANDS${NC}"
    echo -e "${GRAY}────────────────────────────────────────────────────────────────────────────────${NC}"
    echo -e "${CYAN}[1-9]${NC} Select Agent   ${CYAN}[A]${NC} Start All   ${CYAN}[S]${NC} Stop All   ${CYAN}[R]${NC} Restart All   ${CYAN}[L]${NC} Logs   ${CYAN}[Q]${NC} Quit"
    echo -e "${GRAY}────────────────────────────────────────────────────────────────────────────────${NC}"
}

# Agent selection menu
select_agent() {
    clear_screen
    echo -e "${BOLD}${CYAN}SELECT AGENT TO MANAGE:${NC}\n"
    
    local i=1
    local services=()
    for service in $(echo "${!AGENTS[@]}" | tr ' ' '\n' | sort); do
        services+=("$service")
        local name="${AGENTS[$service]}"
        local status=$(get_agent_status "$service")
        local status_color=$RED
        if [ "$status" = "RUNNING" ]; then status_color=$GREEN; fi
        
        echo -e "${CYAN}[$i]${NC} ${name} ${GRAY}(${status_color}${status}${GRAY})${NC}"
        ((i++))
    done
    
    echo -e "\n${CYAN}[0]${NC} Back to dashboard"
    echo -ne "\n${BOLD}Select (0-${#services[@]}): ${NC}"
    read -r choice
    
    if [ "$choice" -gt 0 ] && [ "$choice" -le "${#services[@]}" ]; then
        local selected="${services[$((choice-1))]}"
        manage_agent "$selected"
    fi
}

# Manage individual agent
manage_agent() {
    local service=$1
    local name="${AGENTS[$service]}"
    
    clear_screen
    echo -e "${BOLD}${CYAN}MANAGING: ${WHITE}${name}${NC}\n"
    
    local status=$(get_agent_status "$service")
    echo -e "Status: $([ "$status" = "RUNNING" ] && echo -e "${GREEN}RUNNING${NC}" || echo -e "${RED}STOPPED${NC}")"
    
    echo -e "\n${CYAN}[1]${NC} Start"
    echo -e "${CYAN}[2]${NC} Stop"
    echo -e "${CYAN}[3]${NC} Restart"
    echo -e "${CYAN}[4]${NC} View Logs"
    echo -e "${CYAN}[5]${NC} View Status"
    echo -e "${CYAN}[0]${NC} Back"
    
    echo -ne "\n${BOLD}Select action: ${NC}"
    read -r action
    
    case "$action" in
        1)
            echo -e "\n${YELLOW}Starting ${name}...${NC}"
            sudo systemctl start "${service}.service"
            sleep 2
            ;;
        2)
            echo -e "\n${YELLOW}Stopping ${name}...${NC}"
            sudo systemctl stop "${service}.service"
            sleep 2
            ;;
        3)
            echo -e "\n${YELLOW}Restarting ${name}...${NC}"
            sudo systemctl restart "${service}.service"
            sleep 2
            ;;
        4)
            clear_screen
            echo -e "${BOLD}${GREEN}Logs for ${name}${NC} (Ctrl+C to exit)\n"
            sudo journalctl -u "${service}.service" -f
            ;;
        5)
            clear_screen
            echo -e "${BOLD}${GREEN}Status for ${name}${NC}\n"
            sudo systemctl status "${service}.service"
            echo -e "\n${GRAY}Press Enter to continue...${NC}"
            read -r
            ;;
    esac
}

# Start all agents
start_all_agents() {
    echo -e "\n${YELLOW}Starting all agents...${NC}"
    sudo systemctl start agents.target
    sleep 3
}

# Stop all agents
stop_all_agents() {
    echo -e "\n${YELLOW}Stopping all agents...${NC}"
    for service in "${!AGENTS[@]}"; do
        sudo systemctl stop "${service}.service" 2>/dev/null
    done
    sleep 2
}

# Restart all agents
restart_all_agents() {
    echo -e "\n${YELLOW}Restarting all agents...${NC}"
    for service in "${!AGENTS[@]}"; do
        if [ "$(get_agent_status "$service")" = "RUNNING" ]; then
            sudo systemctl restart "${service}.service" 2>/dev/null
        fi
    done
    sleep 3
}

# View aggregated logs
view_all_logs() {
    clear_screen
    echo -e "${BOLD}${GREEN}Aggregated Agent Logs${NC} (Ctrl+C to exit)\n"
    echo -e "${GRAY}────────────────────────────────────────────────────────────────────────────────${NC}"
    
    # Create temporary pattern for all services
    local pattern=""
    for service in "${!AGENTS[@]}"; do
        pattern="${pattern} -u ${service}.service"
    done
    
    sudo journalctl $pattern -f --since "1 hour ago"
}

# Main dashboard loop
main_dashboard() {
    local refresh_interval=3
    
    while true; do
        clear_screen
        
        draw_header
        draw_agent_table
        draw_support_services
        draw_system_resources
        draw_controls
        
        echo -e "${GRAY}Auto-refresh: ${refresh_interval}s | Last update: $(date '+%H:%M:%S')${NC}"
        
        # Wait for input or timeout
        read -t "$refresh_interval" -n 1 key
        
        case "$key" in
            1|2|3|4|5|6|7|8|9)
                select_agent
                ;;
            a|A)
                start_all_agents
                ;;
            s|S)
                stop_all_agents
                ;;
            r|R)
                restart_all_agents
                ;;
            l|L)
                view_all_logs
                ;;
            q|Q)
                clear_screen
                echo -e "${GREEN}Dashboard closed. Agents continue running.${NC}"
                exit 0
                ;;
        esac
    done
}

# Run dashboard
main_dashboard
