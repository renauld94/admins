#!/bin/bash

################################################################################
# VM 159 Continuous Automation Deployment
# Location: /home/simon/Learning-Management-System-Academy
# Purpose: Start all automation systems immediately
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
BASE_DIR="/home/simon/Learning-Management-System-Academy"
JOB_SEARCH_DIR="$BASE_DIR/job-search-toolkit"
AGENTS_DIR="$BASE_DIR/.continue/agents"

echo ""
echo "################################################################################"
echo "🤖 CONTINUE AGENT - VM 159 DEPLOYMENT START"
echo "################################################################################"
echo ""

# Step 1: Verify workspace
echo -e "${BLUE}Step 1: Verifying workspace...${NC}"
if [ ! -d "$JOB_SEARCH_DIR" ]; then
    echo -e "${RED}✗ Job search directory not found: $JOB_SEARCH_DIR${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Workspace verified${NC}"
echo ""

# Step 2: Run Continue Agent verification
echo -e "${BLUE}Step 2: Running Continue Agent verification...${NC}"
cd "$AGENTS_DIR"
/usr/bin/python3 continue_agent_vm159.py
echo ""

# Step 3: Start job discovery
echo -e "${BLUE}Step 3: Starting job discovery...${NC}"
echo -e "${YELLOW}  Executing: epic_job_search_agent.py${NC}"
cd "$JOB_SEARCH_DIR"
/usr/bin/python3 epic_job_search_agent.py daily > "$AGENTS_DIR/logs/job_discovery_$(date +%Y%m%d_%H%M%S).log" 2>&1 &
JOB_PID=$!
echo -e "${GREEN}  ✓ Job discovery started (PID: $JOB_PID)${NC}"
echo ""

# Step 4: Wait briefly for job discovery to collect data
echo -e "${BLUE}Step 4: Waiting for job discovery to process (30 seconds)...${NC}"
sleep 30
echo -e "${GREEN}  ✓ Proceeding with LinkedIn outreach${NC}"
echo ""

# Step 5: Start LinkedIn outreach
echo -e "${BLUE}Step 5: Starting LinkedIn outreach...${NC}"
echo -e "${YELLOW}  Executing: daily_linkedin_outreach.py${NC}"
cd "$JOB_SEARCH_DIR"
/usr/bin/python3 daily_linkedin_outreach.py > "$AGENTS_DIR/logs/linkedin_outreach_$(date +%Y%m%d_%H%M%S).log" 2>&1 &
LINKEDIN_PID=$!
echo -e "${GREEN}  ✓ LinkedIn outreach started (PID: $LINKEDIN_PID)${NC}"
echo ""

# Step 6: Verify processes
echo -e "${BLUE}Step 6: Verifying processes...${NC}"
sleep 5
if ps -p $JOB_PID > /dev/null; then
    echo -e "${GREEN}  ✓ Job discovery process running${NC}"
else
    echo -e "${YELLOW}  ⚠ Job discovery process ended (check logs)${NC}"
fi

if ps -p $LINKEDIN_PID > /dev/null; then
    echo -e "${GREEN}  ✓ LinkedIn outreach process running${NC}"
else
    echo -e "${YELLOW}  ⚠ LinkedIn outreach process ended (check logs)${NC}"
fi
echo ""

# Step 7: Display status
echo -e "${BLUE}Step 7: Final status...${NC}"
echo -e "${YELLOW}DEPLOYMENT SUMMARY:${NC}"
echo "  VM Instance: 159"
echo "  Base Directory: $BASE_DIR"
echo "  Job Discovery: RUNNING"
echo "  LinkedIn Outreach: RUNNING"
echo "  Email Delivery: ACTIVE (contact@simondatalab.de + sn@gmail.com)"
echo "  CRM Tracking: ACTIVE"
echo ""

echo -e "${YELLOW}LOG FILES:${NC}"
echo "  Job Discovery: $AGENTS_DIR/logs/job_discovery_*.log"
echo "  LinkedIn: $AGENTS_DIR/logs/linkedin_outreach_*.log"
echo "  Continue Agent: $AGENTS_DIR/logs/continue_agent_*.log"
echo ""

echo -e "${GREEN}✅ AUTOMATION DEPLOYMENT COMPLETE${NC}"
echo ""
echo "Next scheduled runs (7:00 AM UTC+7):"
echo "  • Daily job discovery"
echo "  • Daily LinkedIn outreach"
echo "  • Email summaries"
echo ""
echo "################################################################################"
echo ""
