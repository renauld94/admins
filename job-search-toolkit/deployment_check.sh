#!/bin/bash
#
# EPIC Agent - Deployment Checklist
# ==================================
# Verify all components are ready for production use
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║  EPIC Agent - Deployment Checklist                         ║"
echo "║  Version: 1.0 EPIC | November 9, 2025                     ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

CHECKS_PASSED=0
CHECKS_TOTAL=0

check() {
    ((CHECKS_TOTAL++))
    local name="$1"
    local cmd="$2"
    
    echo -n "  ◻ $name..."
    
    if eval "$cmd" > /dev/null 2>&1; then
        echo " ✅"
        ((CHECKS_PASSED++))
        return 0
    else
        echo " ❌"
        return 1
    fi
}

# ===== PYTHON CHECKS =====
echo "🔍 CHECKING ENVIRONMENT"
echo ""

check "Python 3.8+" "python3 --version | grep -E 'Python 3\.[8-9]|Python 3\.1[0-9]'"
check "Python modules (pathlib)" "python3 -c 'import pathlib'"
check "Python modules (sqlite3)" "python3 -c 'import sqlite3'"
check "Python modules (json)" "python3 -c 'import json'"
check "Python modules (asyncio)" "python3 -c 'import asyncio'"

# ===== FILE STRUCTURE CHECKS =====
echo ""
echo "📁 CHECKING FILE STRUCTURE"
echo ""

check "Project directory exists" "[ -d '$PROJECT_DIR' ]"
check "data/ directory" "[ -d '$PROJECT_DIR/data' ]"
check "config/ directory" "[ -d '$PROJECT_DIR/config' ]"
check "outputs/ directory" "[ -d '$PROJECT_DIR/outputs' ]"
check "logs/ directory" "[ -d '$PROJECT_DIR/outputs/logs' ]"

# ===== DATABASE CHECKS =====
echo ""
echo "💾 CHECKING DATABASES"
echo ""

check "job_search.db" "[ -f '$PROJECT_DIR/data/job_search.db' ]"
check "linkedin_contacts.db" "[ -f '$PROJECT_DIR/data/linkedin_contacts.db' ]"
check "networking_crm.db" "[ -f '$PROJECT_DIR/data/networking_crm.db' ]"
check "job_search_metrics.db" "[ -f '$PROJECT_DIR/data/job_search_metrics.db' ]"

# ===== COMPONENT CHECKS =====
echo ""
echo "🔧 CHECKING COMPONENTS"
echo ""

cd "$PROJECT_DIR"

check "epic_job_search_agent.py" "[ -f 'epic_job_search_agent.py' ] && python3 -m py_compile epic_job_search_agent.py"
check "advanced_job_scorer.py" "[ -f 'advanced_job_scorer.py' ] && python3 -m py_compile advanced_job_scorer.py"
check "linkedin_contact_orchestrator.py" "[ -f 'linkedin_contact_orchestrator.py' ] && python3 -m py_compile linkedin_contact_orchestrator.py"
check "networking_crm.py" "[ -f 'networking_crm.py' ] && python3 -m py_compile networking_crm.py"
check "job_search_dashboard.py" "[ -f 'job_search_dashboard.py' ] && python3 -m py_compile job_search_dashboard.py"

# ===== SCRIPT CHECKS =====
echo ""
echo "🚀 CHECKING AUTOMATION SCRIPTS"
echo ""

check "run_daily_job_search.sh executable" "[ -x 'run_daily_job_search.sh' ]"
check "run_weekly_job_search.sh executable" "[ -x 'run_weekly_job_search.sh' ]"
check "setup_agent.sh executable" "[ -x 'setup_agent.sh' ]"
check "quickstart.sh executable" "[ -x 'quickstart.sh' ]"

# ===== FUNCTIONALITY CHECKS =====
echo ""
echo "✅ CHECKING FUNCTIONALITY"
echo ""

check "Agent initialization" "python3 epic_job_search_agent.py init"
check "Job scorer" "python3 advanced_job_scorer.py score --title 'Test' --company 'Test' --location 'Test' --description 'Python'"
check "Dashboard" "python3 job_search_dashboard.py daily"
check "LinkedIn orchestrator" "python3 linkedin_contact_orchestrator.py status"
check "CRM" "python3 networking_crm.py report"

# ===== SUMMARY =====
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo ""
echo "✅ DEPLOYMENT STATUS"
echo ""
echo "   Checks Passed: $CHECKS_PASSED / $CHECKS_TOTAL"
PERCENTAGE=$((CHECKS_PASSED * 100 / CHECKS_TOTAL))
echo "   Success Rate: $PERCENTAGE%"
echo ""

if [ $CHECKS_PASSED -eq $CHECKS_TOTAL ]; then
    echo "🎉 ALL SYSTEMS GO! Ready for production."
    echo ""
    echo "Next steps:"
    echo "  1. Configure profile: nano config/profile.json"
    echo "  2. Run test: python3 epic_job_search_agent.py daily"
    echo "  3. Schedule cron: crontab -e"
    echo ""
    exit 0
else
    FAILED=$((CHECKS_TOTAL - CHECKS_PASSED))
    echo "⚠️  $FAILED check(s) failed. Please review errors above."
    echo ""
    exit 1
fi
