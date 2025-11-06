#!/bin/bash
# LinkedIn & Job Search Quick Start
# Run this after updating your LinkedIn profile

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 LINKEDIN JOB SEARCH - QUICK START"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if profile is updated
echo "📋 PRE-FLIGHT CHECKLIST"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "Have you updated your LinkedIn headline? (y/n) " headline
read -p "Have you updated your LinkedIn About section? (y/n) " about
read -p "Have you enabled 'Open to Work'? (y/n) " opentowork
read -p "Have you added your resume to Featured? (y/n) " featured
echo ""

if [[ "$headline" != "y" || "$about" != "y" || "$opentowork" != "y" || "$featured" != "y" ]]; then
    echo "⚠️  Please complete LinkedIn profile updates first"
    echo "📖 See: LINKEDIN_PROFILE_UPDATE_2025.md"
    echo ""
    exit 1
fi

echo "✅ LinkedIn profile ready!"
echo ""

# Setup CRM database if not exists
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "💾 SETTING UP CRM DATABASE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if command -v psql &> /dev/null; then
    echo "✅ PostgreSQL found"
    
    # Check if database exists
    if psql -lqt | cut -d \| -f 1 | grep -qw universal_crm; then
        echo "✅ CRM database exists"
    else
        echo "📦 Creating CRM database..."
        read -p "Run setup-crm-database.sh? (y/n) " setupcrm
        if [[ "$setupcrm" == "y" ]]; then
            ./setup-crm-database.sh
        else
            echo "⚠️  Skipping CRM setup"
        fi
    fi
else
    echo "⚠️  PostgreSQL not found - CRM features disabled"
    echo "   To enable: sudo apt install postgresql"
fi
echo ""

# Job search targets
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎯 JOB SEARCH CONFIGURATION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Target Roles:"
echo "  • Lead Data Engineer"
echo "  • Senior Data Engineer"
echo "  • QA & QC Manager (Data)"
echo "  • Data Quality Engineer"
echo "  • Analytics Engineering Lead"
echo ""
echo "Target Locations:"
echo "  • Singapore"
echo "  • Australia (Sydney, Melbourne)"
echo "  • Europe (Berlin, Amsterdam, Dublin, London)"
echo "  • Remote (APAC/EMEA timezones)"
echo ""

# Ask if user wants to run automated search
read -p "Run automated LinkedIn job search now? (y/n) " runsearch

if [[ "$runsearch" == "y" ]]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔍 RUNNING JOB SEARCH"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Check if venv exists
    if [ ! -d "venv" ]; then
        echo "📦 Creating Python virtual environment..."
        python3 -m venv venv
        source venv/bin/activate
        pip install --quiet python-dotenv playwright
        ./venv/bin/python -m playwright install chromium
    else
        source venv/bin/activate
    fi
    
    # Check credentials
    if [ ! -f .env ] || ! grep -q "^LINKEDIN_EMAIL=" .env || ! grep -q "^LINKEDIN_PASSWORD=" .env; then
        echo "⚠️  LinkedIn credentials not found"
        echo ""
        read -p "Set up LinkedIn credentials now? (y/n) " setupcreds
        if [[ "$setupcreds" == "y" ]]; then
            ./setup-linkedin-credentials.sh
        else
            echo "❌ Cannot run job search without credentials"
            exit 1
        fi
    fi
    
    echo "🔍 Searching for jobs..."
    echo "   This will take 15-20 minutes"
    echo ""
    
    # Run search with a smaller subset for quick test
    echo "Running quick search (top 5 roles, 3 locations)..."
    ./venv/bin/python job_search_automation.py \
        --quick \
        --remote-only \
        --locations "Singapore" "Remote" "Australia"
    
    echo ""
    echo "✅ Job search complete!"
    echo ""
    echo "Results saved to: outputs/jobs/"
    ls -lh outputs/jobs/ | tail -5
    
else
    echo "⏭️  Skipping automated search"
    echo "   Run manually: python job_search_automation.py --quick --remote-only"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 NEXT STEPS"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "1️⃣  Daily (30 min):"
echo "   • Check LinkedIn job alerts"
echo "   • Apply to 3-5 Easy Apply jobs"
echo "   • Engage with 5-10 posts (like/comment)"
echo ""
echo "2️⃣  Weekly (2 hours):"
echo "   • Send 10-15 InMails (referrals/hiring managers)"
echo "   • Post 2-3 times (technical tips, insights)"
echo "   • Follow up on applications from last week"
echo ""
echo "3️⃣  Track Everything:"
echo "   • Applications sent: 10-15/week"
echo "   • Responses: 10-20% target"
echo "   • Interviews: 1-2/week by Week 3-4"
echo ""
echo "📖 Resources:"
echo "   • Profile guide: LINKEDIN_PROFILE_UPDATE_2025.md"
echo "   • Job targets: job_search_targets.json"
echo "   • CRM dashboard: python crm_database.py dashboard"
echo ""
echo "💡 Pro Tips:"
echo "   • Apply within 10 min of posting → Top Applicant badge"
echo "   • Use InMail for hiring managers, not recruiters"
echo "   • Post 2-3x per week to stay visible"
echo "   • Check 'Who viewed your profile' daily"
echo ""
echo "🚀 Good luck with your job search!"
echo ""
