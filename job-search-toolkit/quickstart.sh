#!/bin/bash
#
# EPIC Agent - Quick Start Guide
# ==============================
# Get the EPIC job search agent up and running in 5 minutes
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

clear

cat << "EOF"

╔════════════════════════════════════════════════════════════════════╗
║                                                                    ║
║        🚀 EPIC JOB SEARCH AGENT - QUICK START GUIDE 🚀            ║
║                                                                    ║
║   AI-Powered Job Search Orchestrator for Simon Renauld           ║
║   Version: 1.0 EPIC | November 9, 2025                           ║
║                                                                    ║
╚════════════════════════════════════════════════════════════════════╝

EOF

echo ""
echo "📋 WHAT YOU'LL GET:"
echo "   ✅ Automated daily job discovery & scoring"
echo "   ✅ LinkedIn connection automation"
echo "   ✅ Application package generation"
echo "   ✅ Relationship tracking (CRM)"
echo "   ✅ Real-time metrics dashboard"
echo "   ✅ Weekly analytics & insights"
echo ""

echo "⏱️  TIME REQUIRED: ~5 minutes"
echo ""

# Step 1: Navigate to directory
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 1: Navigate to project directory"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📁 Project: $PROJECT_DIR"
echo ""

# Step 2: Test Python
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 2: Verify Python installation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
PYTHON_VERSION=$(python3 --version 2>&1)
echo "   $PYTHON_VERSION"
echo ""

# Step 3: Initialize agent
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 3: Initialize agent components"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$PROJECT_DIR"

echo "   🔧 Initializing job search agent..."
python3 epic_job_search_agent.py init > /dev/null 2>&1
echo "      ✅ Complete"

echo "   🔧 Initializing LinkedIn orchestrator..."
python3 -c "from linkedin_contact_orchestrator import LinkedInContactOrchestrator; LinkedInContactOrchestrator()" > /dev/null 2>&1
echo "      ✅ Complete"

echo "   🔧 Initializing CRM..."
python3 -c "from networking_crm import NetworkingCRM; NetworkingCRM()" > /dev/null 2>&1
echo "      ✅ Complete"

echo "   🔧 Initializing dashboard..."
python3 -c "from job_search_dashboard import JobSearchDashboard; JobSearchDashboard()" > /dev/null 2>&1
echo "      ✅ Complete"

echo ""

# Step 4: Verify databases
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 4: Verify databases"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ -d "data" ]; then
    DB_COUNT=$(find data -name "*.db" 2>/dev/null | wc -l)
    echo "   ✅ Found $DB_COUNT database files in data/ directory"
    find data -name "*.db" -exec du -h {} \; 2>/dev/null | while read size file; do
        echo "      • $(basename $file): $size"
    done
else
    echo "   ⚠️  data/ directory not found"
fi

echo ""

# Step 5: Test components
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "STEP 5: Quick component test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "   ✅ Job Scorer: Testing..."
python3 advanced_job_scorer.py score \
    --title "Lead Data Engineer" \
    --company "Shopee" \
    --location "Singapore" \
    --description "Python, Airflow, AWS" > /dev/null 2>&1
echo "      ✅ Score: Ready"

echo "   ✅ Dashboard: Testing..."
python3 job_search_dashboard.py daily > /dev/null 2>&1
echo "      ✅ Metrics: Ready"

echo "   ✅ CRM: Testing..."
python3 networking_crm.py report > /dev/null 2>&1
echo "      ✅ Network tracking: Ready"

echo ""

# Step 6: Show next steps
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ INITIALIZATION COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "🎯 NEXT STEPS:"
echo ""
echo "1️⃣  RUN A TEST (right now):"
echo ""
echo "    cd $PROJECT_DIR"
echo "    python3 epic_job_search_agent.py daily"
echo ""

echo "2️⃣  CONFIGURE YOUR PROFILE (important!):"
echo ""
echo "    nano config/profile.json"
echo "    # Edit skills, roles, salary expectations"
echo ""

echo "3️⃣  RUN DAILY AUTOMATION:"
echo ""
echo "    python3 epic_job_search_agent.py daily      # Manual run"
echo "    ./run_daily_job_search.sh                    # Full workflow"
echo ""

echo "4️⃣  ENABLE AUTOMATIC SCHEDULING (cron):"
echo ""
echo "    crontab -e"
echo "    # Add: 0 7 * * * cd $PROJECT_DIR && ./run_daily_job_search.sh"
echo ""

echo "5️⃣  VIEW REPORTS:"
echo ""
echo "    python3 job_search_dashboard.py daily        # Today's metrics"
echo "    python3 job_search_dashboard.py weekly       # Weekly analysis"
echo "    python3 job_search_dashboard.py full         # Full dashboard"
echo ""

echo "📖 DOCUMENTATION:"
echo ""
echo "    Full guide: cat EPIC_AGENT_README.md"
echo "    All components are in: $PROJECT_DIR"
echo ""

echo "🚀 READY TO START YOUR JOB SEARCH!"
echo ""
echo "────────────────────────────────────────────────────────────────"
echo ""

# Ask if user wants to run a test now
read -p "👉 Run a quick test now? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "🎯 Running sample job scoring test..."
    echo ""
    cd "$PROJECT_DIR"
    python3 advanced_job_scorer.py score \
        --title "Lead Data Engineer" \
        --company "Shopee" \
        --location "Singapore" \
        --description "Python, Apache Airflow, AWS, data platform, leadership"
fi

echo ""
echo "Have fun! 🚀"
echo ""
