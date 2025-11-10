#!/bin/bash

##########################################################################
# 🚀 EPIC Job Search - FULL SYSTEM STARTUP
# 
# Starts all components:
# 1. Job discovery agent
# 2. Daily automation
# 3. Monitoring
# 4. Analytics dashboard (optional)
#
# Usage: ./START_JOB_SEARCH.sh
##########################################################################

set -e  # Exit on error

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

TOOLKIT_DIR="/home/simon/Learning-Management-System-Academy/job-search-toolkit"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║     🚀 EPIC JOB SEARCH AUTOMATION - SYSTEM STARTUP 🚀         ║"
echo "║                                                                ║"
echo "║              Ready to begin your job search journey             ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Check if toolkit directory exists
if [ ! -d "$TOOLKIT_DIR" ]; then
    echo -e "${RED}❌ Toolkit directory not found: $TOOLKIT_DIR${NC}"
    exit 1
fi

cd "$TOOLKIT_DIR"

echo -e "${BLUE}📋 STARTUP CHECKLIST${NC}"
echo "════════════════════════════════════════════════════════════════"
echo ""

# 1. Verify Python environment
echo -ne "Checking Python environment... "
if python3 --version > /dev/null 2>&1; then
    PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
    echo -e "${GREEN}✅ Python $PYTHON_VERSION${NC}"
else
    echo -e "${RED}❌ Python not found${NC}"
    exit 1
fi

# 2. Check dependencies
echo -ne "Checking dependencies... "
if python3 -c "import requests, bs4, sqlite3" 2>/dev/null; then
    echo -e "${GREEN}✅ All installed${NC}"
else
    echo -e "${YELLOW}⚠️  Some dependencies missing${NC}"
fi

# 3. Verify databases
echo -ne "Verifying databases... "
if [ -d "data" ] && [ -f "data/job_search.db" ]; then
    echo -e "${GREEN}✅ Initialized${NC}"
else
    echo -e "${YELLOW}⚠️  Creating databases...${NC}"
    mkdir -p data outputs/logs
    python3 epic_job_search_agent.py init > /dev/null 2>&1
    echo -e "${GREEN}✅ Created${NC}"
fi

# 4. Verify configuration
echo -ne "Checking configuration... "
if [ -f "config/profile.json" ]; then
    echo -e "${GREEN}✅ Profile ready${NC}"
else
    echo -e "${RED}❌ Profile not found${NC}"
    exit 1
fi

# 5. Verify cron jobs
echo -ne "Checking cron jobs... "
if crontab -l 2>/dev/null | grep -q "job_search"; then
    echo -e "${GREEN}✅ 2 jobs scheduled${NC}"
else
    echo -e "${YELLOW}⚠️  Cron jobs not found${NC}"
fi

# 6. Check cron service
echo -ne "Checking cron service... "
if sudo systemctl is-active --quiet cron; then
    echo -e "${GREEN}✅ Running${NC}"
else
    echo -e "${YELLOW}⚠️  Starting cron service...${NC}"
    sudo systemctl start cron
    echo -e "${GREEN}✅ Started${NC}"
fi

echo ""
echo -e "${BLUE}🎯 STARTING SYSTEM COMPONENTS${NC}"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Start job discovery
echo -e "${YELLOW}▶️  Starting first job discovery run...${NC}"
echo ""

if python3 epic_job_search_agent.py daily 2>&1 | tee outputs/logs/STARTUP_$(date +%s).log; then
    echo ""
    echo -e "${GREEN}✅ Job discovery completed successfully!${NC}"
else
    echo ""
    echo -e "${YELLOW}⚠️  Job discovery completed with warnings${NC}"
fi

echo ""
echo -e "${BLUE}📊 SYSTEM MONITORING${NC}"
echo "════════════════════════════════════════════════════════════════"
echo ""

# Show system status
if [ -f "monitor_automation.sh" ]; then
    bash monitor_automation.sh
else
    echo -e "${YELLOW}⚠️  Monitor script not found${NC}"
fi

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                                                                ║"
echo "║                    ✅ SYSTEM STARTED!                          ║"
echo "║                                                                ║"
echo "║         Your EPIC Job Search Automation is now LIVE            ║"
echo "║                                                                ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

echo -e "${BLUE}📚 NEXT STEPS:${NC}"
echo ""
echo "1. MONITOR YOUR FIRST RUN:"
echo "   tail -f outputs/logs/agent_*.log"
echo ""
echo "2. VIEW DAILY REPORTS:"
echo "   python3 job_search_dashboard.py daily"
echo ""
echo "3. CHECK AUTOMATION STATUS:"
echo "   crontab -l | grep job_search"
echo ""
echo "4. REVIEW CRM:"
echo "   python3 networking_crm.py report"
echo ""

echo -e "${YELLOW}⏰ AUTOMATION SCHEDULE:${NC}"
echo ""
echo "Daily Run: 7:00 AM UTC+7 (Tomorrow)"
echo "Weekly Analysis: 6:00 PM UTC+7 (Every Sunday)"
echo ""
echo "Your system will automatically discover jobs, score them, and"
echo "prepare LinkedIn outreach 24/7!"
echo ""

echo -e "${GREEN}🎉 LET'S GET YOU HIRED! 🎉${NC}"
echo ""

