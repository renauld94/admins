#!/bin/bash
#
# EPIC Job Search Agent - Setup & Initialization
# =============================================
# Sets up all components and schedules automation
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║   EPIC Job Search Agent - Setup                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# ===== CHECK PYTHON =====
echo "✓ Checking Python installation..."
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 not found. Please install Python 3.8+"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | awk '{print $2}')
echo "  ✅ Python $PYTHON_VERSION found"

# ===== CREATE DIRECTORIES =====
echo ""
echo "✓ Creating directories..."
mkdir -p "$PROJECT_DIR"/{config,data,outputs/{logs,reports}}
echo "  ✅ Directories created"

# ===== CREATE CONFIG FILES =====
echo ""
echo "✓ Creating configuration..."

# Profile config
if [ ! -f "$PROJECT_DIR/config/profile.json" ]; then
    cat > "$PROJECT_DIR/config/profile.json" << 'EOF'
{
    "name": "Simon Renauld",
    "title": "Data Engineer & QA Automation",
    "email": "simon@example.com",
    "years_experience": 8,
    "current_level": "senior",
    "remote_preference": true,
    "core_skills": {
        "languages": ["Python", "SQL", "Scala"],
        "data_platforms": ["Apache Airflow", "Spark", "Kafka"],
        "cloud": ["AWS", "GCP"],
        "data_tools": ["Snowflake", "BigQuery", "PostgreSQL"],
        "testing": ["pytest", "CI/CD"],
        "architecture": ["ETL", "Data Governance"]
    },
    "target_roles": [
        "Lead Data Engineer",
        "Data Platform Engineer",
        "Analytics Lead",
        "QA Manager"
    ],
    "target_locations": [
        "Remote",
        "Singapore",
        "Australia",
        "Ho Chi Minh City"
    ],
    "salary_expectations": {
        "min": 80000,
        "target": 120000,
        "max": 200000,
        "currency": "USD"
    },
    "values": [
        "Technical excellence",
        "Team collaboration",
        "Continuous learning",
        "Impact"
    ]
}
EOF
    echo "  ✅ Profile config created: $PROJECT_DIR/config/profile.json"
else
    echo "  ⚠️  Profile config already exists"
fi

# ===== INITIALIZE DATABASES =====
echo ""
echo "✓ Initializing databases..."
cd "$PROJECT_DIR"

python3 << 'EOF'
from pathlib import Path
import sys

# Import agent modules
sys.path.insert(0, str(Path.cwd()))

try:
    from epic_job_search_agent import EPICJobSearchAgent, JobSearchDB
    from linkedin_contact_orchestrator import LinkedInContactOrchestrator
    from networking_crm import NetworkingCRM
    from job_search_dashboard import JobSearchDashboard
    
    print("  ✓ Initializing job search agent...")
    agent = EPICJobSearchAgent()
    print("    ✅ Agent initialized")
    
    print("  ✓ Initializing LinkedIn orchestrator...")
    linkedin = LinkedInContactOrchestrator()
    print("    ✅ LinkedIn orchestrator initialized")
    
    print("  ✓ Initializing CRM...")
    crm = NetworkingCRM()
    print("    ✅ CRM initialized")
    
    print("  ✓ Initializing dashboard...")
    dashboard = JobSearchDashboard()
    print("    ✅ Dashboard initialized")
    
    print("\n  ✅ All databases initialized")
    
except Exception as e:
    print(f"\n  ❌ Initialization failed: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
EOF

# ===== MAKE SCRIPTS EXECUTABLE =====
echo ""
echo "✓ Setting up automation scripts..."
chmod +x "$PROJECT_DIR/run_daily_job_search.sh"
chmod +x "$PROJECT_DIR/run_weekly_job_search.sh"
echo "  ✅ Scripts are executable"

# ===== CRON SETUP (OPTIONAL) =====
echo ""
echo "✓ Cron job setup (optional)"
echo "  To enable automation, add these lines to your crontab:"
echo ""
echo "  # Daily at 7 AM"
echo "  0 7 * * * cd $PROJECT_DIR && ./run_daily_job_search.sh"
echo ""
echo "  # Weekly on Sunday at 6 PM"
echo "  0 18 * * 0 cd $PROJECT_DIR && ./run_weekly_job_search.sh"
echo ""
echo "  To add to crontab:"
echo "  crontab -e"
echo ""

# ===== FINAL SUMMARY =====
echo "╔════════════════════════════════════════════════════════╗"
echo "║   ✅ SETUP COMPLETE                                    ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "📁 Project directory: $PROJECT_DIR"
echo "📋 Configuration: $PROJECT_DIR/config/profile.json"
echo "💾 Data directory: $PROJECT_DIR/data/"
echo "📊 Reports: $PROJECT_DIR/outputs/reports/"
echo "📝 Logs: $PROJECT_DIR/outputs/logs/"
echo ""
echo "🚀 Quick start:"
echo "   1. Review config: nano $PROJECT_DIR/config/profile.json"
echo "   2. Run agent: cd $PROJECT_DIR && python3 epic_job_search_agent.py daily"
echo "   3. Check status: python3 epic_job_search_agent.py status"
echo ""
echo "📚 See README.md for detailed documentation"
echo ""
