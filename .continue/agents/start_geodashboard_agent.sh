#!/bin/bash
#
# Start EPIC Geodashboard Enhancement Agent
# Professional portfolio and geospatial dashboard improvement agent
# Runs for 24-48 hours to enhance portfolio and geodashboards
#

AGENT_DIR="/home/simon/Learning-Management-System-Academy/.continue/agents"
AGENT_SCRIPT="$AGENT_DIR/geodashboard_epic_agent.py"
LOG_DIR="$AGENT_DIR/logs"
VENV_PATH="/home/simon/Learning-Management-System-Academy/venv"

# Create logs directory
mkdir -p "$LOG_DIR"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}EPIC Geodashboard Enhancement Agent${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if Python agent exists
if [ ! -f "$AGENT_SCRIPT" ]; then
    echo -e "${YELLOW}Error: Agent script not found at $AGENT_SCRIPT${NC}"
    exit 1
fi

# Activate virtual environment if it exists
if [ -d "$VENV_PATH" ]; then
    echo -e "${GREEN}Activating Python virtual environment...${NC}"
    source "$VENV_PATH/bin/activate"
fi

# Check for required Python packages
echo -e "${GREEN}Checking dependencies...${NC}"
python3 -c "import requests" 2>/dev/null || {
    echo -e "${YELLOW}Installing requests library...${NC}"
    pip3 install requests
}

# Make agent executable
chmod +x "$AGENT_SCRIPT"

# Start agent
echo -e "${GREEN}Starting EPIC Geodashboard Agent...${NC}"
echo -e "${GREEN}Agent will run for 24-48 hours${NC}"
echo -e "${GREEN}Logs: $LOG_DIR${NC}"
echo ""

# Run agent with nohup for background execution
nohup python3 "$AGENT_SCRIPT" > "$LOG_DIR/agent_console_$(date +%Y%m%d_%H%M%S).log" 2>&1 &

AGENT_PID=$!
echo -e "${GREEN}Agent started with PID: $AGENT_PID${NC}"
echo "$AGENT_PID" > "$AGENT_DIR/agent.pid"

echo ""
echo -e "${BLUE}Commands:${NC}"
echo -e "  View logs:    tail -f $LOG_DIR/EPIC_Geodashboard_Agent_*.log"
echo -e "  Stop agent:   kill $AGENT_PID"
echo -e "  Check status: ps -p $AGENT_PID"
echo ""

# Show first few lines of log
sleep 2
echo -e "${BLUE}Initial log output:${NC}"
tail -20 "$LOG_DIR"/EPIC_Geodashboard_Agent_*.log 2>/dev/null | tail -20
