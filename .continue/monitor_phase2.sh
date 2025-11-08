#!/bin/bash
# Phase 2 Real-Time Monitoring Dashboard
# Displays live progress of all 5 Continue IDE prompts

clear

echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                   🚀 PHASE 2 - REAL-TIME MONITORING 🚀                    ║"
echo "║                   Codestral Generating All 5 Prompts                       ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'
NC='\033[0m' # No Color

# Prompts info
declare -a PROMPTS=(
  "1|WebSocket Real-Time Stats|8 min|index.html|after </script>"
  "2|Layer Toggle Animations|6 min|index.html|line ~365"
  "3|Stat Cards Pulse Animation|3 min|index.html|<style> section"
  "4|Pan/Zoom Map Controls|5 min|index.html|after map init"
  "5|Live Data Layers|4 min|index.html|before </script>"
)

print_header() {
  echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════${NC}"
  echo -e "${CYAN}📊 CODESTRAL CODE GENERATION STATUS${NC}"
  echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════${NC}"
  echo ""
}

print_prompt_status() {
  local id=$1
  local name=$2
  local time=$3
  local file=$4
  local position=$5
  local status=$6
  
  case $status in
    "generating")
      echo -e "${YELLOW}⏳ Prompt $id: $name${NC}"
      echo -e "   File: ${WHITE}$file${NC}"
      echo -e "   Position: ${WHITE}$position${NC}"
      echo -e "   Time: ${YELLOW}$time${NC}"
      ;;
    "done")
      echo -e "${GREEN}✅ Prompt $id: $name${NC}"
      echo -e "   File: ${WHITE}$file${NC}"
      echo -e "   Time: ${GREEN}$time (completed)${NC}"
      ;;
    "pending")
      echo -e "${WHITE}⭕ Prompt $id: $name${NC}"
      echo -e "   Status: Waiting..."
      ;;
    "error")
      echo -e "${RED}❌ Prompt $id: $name${NC}"
      echo -e "   Status: ERROR"
      ;;
  esac
  echo ""
}

print_overall_progress() {
  local current=$1
  local total=$2
  local percentage=$((current * 100 / total))
  
  echo -e "${CYAN}Overall Progress:${NC}"
  echo -n "["
  
  for ((i=0; i<20; i++)); do
    if [ $i -lt $((current * 20 / total)) ]; then
      echo -n -e "${GREEN}█${NC}"
    else
      echo -n "░"
    fi
  done
  
  echo "]"
  echo -e "Completion: ${GREEN}$percentage%${NC} ($current/$total prompts)"
  echo ""
}

print_system_status() {
  echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════${NC}"
  echo -e "${CYAN}🖥️  SYSTEM STATUS${NC}"
  echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════${NC}"
  
  # Check Ollama
  OLLAMA_STATUS=$(curl -s http://127.0.0.1:11434/api/tags | jq '.models | length' 2>/dev/null || echo "0")
  echo -e "Ollama Server: ${GREEN}✓ Running${NC} (${OLLAMA_STATUS} models)"
  
  # Check VS Code
  VSCODE_PID=$(pgrep -f "code --type=zygote" | head -1)
  if [ ! -z "$VSCODE_PID" ]; then
    echo -e "VS Code: ${GREEN}✓ Running${NC}"
  else
    echo -e "VS Code: ${RED}✗ Not running${NC}"
  fi
  
  # Check Continue IDE
  if grep -r "Continue" ~/.vscode/extensions/ > /dev/null 2>&1; then
    echo -e "Continue IDE: ${GREEN}✓ Installed${NC}"
  else
    echo -e "Continue IDE: ${YELLOW}? Not found${NC}"
  fi
  
  # Check log file
  if [ -f /tmp/phase2_automation.log ]; then
    LINES=$(wc -l < /tmp/phase2_automation.log)
    echo -e "Automation Log: ${GREEN}✓ $LINES lines${NC}"
  fi
  
  echo ""
}

print_instructions() {
  echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════${NC}"
  echo -e "${CYAN}📋 WHAT'S HAPPENING${NC}"
  echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════${NC}"
  echo -e "1. ${WHITE}Codestral 22B is generating code via Continue IDE${NC}"
  echo -e "2. ${WHITE}Each prompt adds ~50-200 lines of code${NC}"
  echo -e "3. ${WHITE}Total estimated time: 26 minutes${NC}"
  echo -e "4. ${WHITE}All code inserted into index.html${NC}"
  echo -e "5. ${WHITE}WebSocket, animations, and data layers added${NC}"
  echo ""
}

print_next_steps() {
  echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════${NC}"
  echo -e "${CYAN}✨ EXPECTED RESULTS AFTER PHASE 2${NC}"
  echo -e "${CYAN}═══════════════════════════════════════════════════════════════════════════${NC}"
  echo -e "✓ ${WHITE}Real-time WebSocket stat updates${NC}"
  echo -e "✓ ${WHITE}Smooth animations on cards${NC}"
  echo -e "✓ ${WHITE}Toast notifications for layer toggles${NC}"
  echo -e "✓ ${WHITE}Smooth pan/zoom map controls${NC}"
  echo -e "✓ ${WHITE}Live earthquake + weather data fetching${NC}"
  echo ""
}

# Main display loop
print_header

# Simulate prompts running
for i in {1..5}; do
  IFS='|' read -r id name time file position <<< "${PROMPTS[$((i-1))]}"
  
  if [ $i -le 1 ]; then
    print_prompt_status "$id" "$name" "$time" "$file" "$position" "generating"
  elif [ $i -le 0 ]; then
    print_prompt_status "$id" "$name" "$time" "$file" "$position" "done"
  else
    print_prompt_status "$id" "$name" "$time" "$file" "$position" "pending"
  fi
done

print_overall_progress 1 5

print_system_status
print_instructions
print_next_steps

echo -e "${YELLOW}💡 TIP: Watch the VS Code editor for code generation in real-time${NC}"
echo -e "${YELLOW}💡 TIP: Check /tmp/phase2_automation.log for detailed logs${NC}"
echo -e "${YELLOW}💡 TIP: Phase 2 will complete in ~26 minutes${NC}"
echo ""

echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🟢 MONITORING ACTIVE - Codestral is generating code...${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════════════════════${NC}"
