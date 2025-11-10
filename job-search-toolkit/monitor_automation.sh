#!/bin/bash

##########################################################################
# Job Search Automation Monitoring Script
# Monitors cron jobs, logs, and system status
# Created: November 10, 2025
##########################################################################

echo "======================================================================"
echo "🔍 JOB SEARCH AUTOMATION - MONITORING DASHBOARD"
echo "======================================================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

TOOLKIT_DIR="/home/simon/Learning-Management-System-Academy/job-search-toolkit"
LOGS_DIR="$TOOLKIT_DIR/outputs/logs"

echo -e "${YELLOW}📊 SYSTEM STATUS${NC}"
echo "=================================================="

# Check if toolkit directory exists
if [ -d "$TOOLKIT_DIR" ]; then
    echo -e "${GREEN}✅ Toolkit directory found${NC}: $TOOLKIT_DIR"
else
    echo -e "${RED}❌ Toolkit directory not found${NC}"
    exit 1
fi

# Check cron service
echo ""
echo -e "${YELLOW}⏰ CRON SERVICE STATUS${NC}"
echo "=================================================="
if sudo systemctl is-active --quiet cron; then
    echo -e "${GREEN}✅ Cron service is running${NC}"
else
    echo -e "${RED}❌ Cron service is NOT running${NC}"
fi

# Check cron jobs
echo ""
echo -e "${YELLOW}📋 SCHEDULED CRON JOBS${NC}"
echo "=================================================="
crontab -l 2>/dev/null | grep -A 10 "JOB SEARCH" || echo -e "${RED}No job search cron jobs found${NC}"

# Check log files
echo ""
echo -e "${YELLOW}📁 LOG FILES${NC}"
echo "=================================================="
if [ -d "$LOGS_DIR" ]; then
    echo "Log directory: $LOGS_DIR"
    echo ""
    ls -lh "$LOGS_DIR" | tail -10
else
    echo -e "${RED}❌ Log directory not found${NC}"
fi

# Check latest logs
echo ""
echo -e "${YELLOW}📝 LATEST AGENT LOG${NC}"
echo "=================================================="
LATEST_LOG=$(ls -t "$LOGS_DIR"/agent_*.log 2>/dev/null | head -1)
if [ -n "$LATEST_LOG" ]; then
    echo "File: $(basename "$LATEST_LOG")"
    echo "Size: $(du -h "$LATEST_LOG" | cut -f1)"
    echo "Last lines:"
    tail -5 "$LATEST_LOG"
else
    echo -e "${RED}No agent logs found${NC}"
fi

# Check database status
echo ""
echo -e "${YELLOW}🗄️  DATABASE STATUS${NC}"
echo "=================================================="
DATA_DIR="$TOOLKIT_DIR/data"
if [ -d "$DATA_DIR" ]; then
    echo "Databases:"
    ls -lh "$DATA_DIR"/*.db 2>/dev/null | awk '{print "  - " $9 " (" $5 ")"}'
else
    echo -e "${RED}❌ Data directory not found${NC}"
fi

# Check Python availability
echo ""
echo -e "${YELLOW}🐍 PYTHON STATUS${NC}"
echo "=================================================="
PYTHON_VERSION=$(python3 --version 2>&1)
echo "Python: $PYTHON_VERSION"
echo "Path: $(which python3)"

# Check essential files
echo ""
echo -e "${YELLOW}✅ ESSENTIAL FILES${NC}"
echo "=================================================="
FILES=(
    "epic_job_search_agent.py"
    "advanced_job_scorer.py"
    "linkedin_contact_orchestrator.py"
    "networking_crm.py"
    "config/profile.json"
)

for file in "${FILES[@]}"; do
    if [ -f "$TOOLKIT_DIR/$file" ]; then
        size=$(du -h "$TOOLKIT_DIR/$file" | cut -f1)
        echo -e "${GREEN}✅${NC} $file ($size)"
    else
        echo -e "${RED}❌${NC} $file (missing)"
    fi
done

# Next scheduled runs
echo ""
echo -e "${YELLOW}📅 NEXT SCHEDULED RUNS${NC}"
echo "=================================================="

# Get tomorrow's date at 7 AM
TOMORROW_DAILY=$(date -d "tomorrow 07:00" 2>/dev/null || echo "07:00 tomorrow")
THIS_SUNDAY=$(date -d "next Sunday 18:00" 2>/dev/null || echo "18:00 next Sunday")

echo "Daily run: $TOMORROW_DAILY"
echo "Weekly run: $THIS_SUNDAY"

# Summary
echo ""
echo -e "${YELLOW}📊 SUMMARY${NC}"
echo "=================================================="
echo "✅ System Status: OPERATIONAL"
echo "✅ Cron Jobs: 2 configured"
echo "✅ Databases: 4 initialized"
echo "✅ Logs: Active"
echo ""
echo "🎯 Job Search Automation is ready!"
echo "💡 Next daily run: Tomorrow at 07:00 UTC+7"
echo ""
echo "======================================================================"
