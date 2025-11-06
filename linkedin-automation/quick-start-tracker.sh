#!/bin/bash
# Quick Start - Job Search Setup & First Day Actions
# Run this to complete ClickUp setup and start your job search!

set -e

echo "========================================================================"
echo "🚀 JOB SEARCH TRACKER - QUICK START"
echo "========================================================================"
echo ""

# Change to linkedin-automation directory
cd "$(dirname "$0")"

echo "📁 Current directory: $(pwd)"
echo ""

# Check for Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 not found! Please install Python 3.8+"
    exit 1
fi

echo "✅ Python3 found: $(python3 --version)"
echo ""

# Check for .env file
if [ ! -f ".env" ]; then
    echo "📝 Creating .env file..."
    touch .env
    echo "✅ .env file created"
else
    echo "✅ .env file exists"
fi
echo ""

# Check for ClickUp API key
if ! grep -q "CLICKUP_API_KEY" .env; then
    echo "⚠️  ClickUp API key not found in .env"
    echo ""
    echo "📝 To get your API key:"
    echo "   1. Go to: https://app.clickup.com/"
    echo "   2. Click your avatar → Settings"
    echo "   3. Click 'Apps' in sidebar"
    echo "   4. Generate API Token"
    echo "   5. Add to .env file: CLICKUP_API_KEY=your_key_here"
    echo ""
    read -p "Do you have your API key ready? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter your ClickUp API key: " api_key
        echo "CLICKUP_API_KEY=$api_key" >> .env
        echo "✅ API key added to .env"
    else
        echo "⏸️  Setup paused. Get your API key and run this script again."
        exit 0
    fi
else
    echo "✅ ClickUp API key found in .env"
fi
echo ""

# Install Python dependencies if needed
echo "📦 Checking Python dependencies..."
if ! python3 -c "import requests" 2>/dev/null; then
    echo "Installing requests..."
    pip3 install requests python-dotenv
fi
echo "✅ Dependencies ready"
echo ""

# Run ClickUp setup
echo "========================================================================"
echo "⚙️  SETTING UP CLICKUP WORKSPACE"
echo "========================================================================"
echo ""
echo "This will create:"
echo "  📝 Job Applications list"
echo "  🤝 Recruiter Network list"
echo "  🎯 Interview Pipeline list"
echo "  💼 Offers & Negotiations list"
echo "  🏢 Target Companies list"
echo ""
read -p "Ready to create ClickUp workspace? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    python3 clickup_job_tracker.py --setup
    echo ""
    echo "✅ ClickUp workspace created!"
else
    echo "⏭️  Skipping ClickUp setup"
fi
echo ""

# Sync Qode World job
echo "========================================================================"
echo "📋 ADDING QODE WORLD JOB TO TRACKER"
echo "========================================================================"
echo ""

if [ -f "outputs/jobs/qode_world_20251105.json" ]; then
    echo "✅ Qode World job found"
    
    # Check if we have list ID
    if grep -q "CLICKUP_JOB_LIST_ID" .env; then
        echo "🔄 Syncing to ClickUp..."
        python3 clickup_job_tracker.py --sync --jobs-file outputs/jobs/qode_world_20251105.json
    else
        echo "⚠️  ClickUp not fully configured yet"
        echo "   You can manually add this job later"
    fi
else
    echo "⚠️  Qode World job file not found"
fi
echo ""

# Show next steps
echo "========================================================================"
echo "✅ SETUP COMPLETE! HERE'S WHAT'S NEXT:"
echo "========================================================================"
echo ""
echo "📱 Access your tracker:"
echo "   https://app.clickup.com/"
echo ""
echo "🎯 TODAY'S ACTION PLAN (Next 3 hours):"
echo ""
echo "1️⃣  Apply to Qode World (15 min) - PRIORITY!"
echo "    https://apply.workable.com/qodeworld/j/0E7F439D0D/"
echo ""
echo "2️⃣  Set up LinkedIn job alerts (15 min)"
echo "    → Data Engineer Singapore"
echo "    → Lead Data Engineer Remote"
echo "    → QA Manager Data"
echo "    → Data Platform Engineer Australia"
echo "    → Data Quality Engineer"
echo ""
echo "3️⃣  Apply to 10 Easy Apply jobs (1 hour)"
echo "    LinkedIn Jobs → Easy Apply filter ON → Apply!"
echo ""
echo "4️⃣  Connect with 5 recruiters (30 min)"
echo "    See: RECRUITER_OUTREACH_STRATEGY.md for templates"
echo ""
echo "5️⃣  Check target company career pages (30 min)"
echo "    → https://grab.careers/"
echo "    → https://career.seagroup.com/"
echo "    → https://www.atlassian.com/company/careers"
echo ""
echo "🎯 DAILY TARGET: 13 applications + 5 recruiter connections"
echo ""
echo "📚 HELPFUL GUIDES:"
echo "   • DECEMBER_JOB_SEARCH_TRACKER.md - Full 6-week plan"
echo "   • CLICKUP_SETUP_GUIDE.md - How to use ClickUp"
echo "   • MANUAL_JOB_SEARCH_GUIDE.md - Job search strategies"
echo "   • RECRUITER_OUTREACH_STRATEGY.md - Connection templates"
echo ""
echo "🔥 YOU'VE GOT THIS! LET'S FIND YOU AN AMAZING JOB! 💪"
echo ""
echo "========================================================================"
echo "Start with: Open https://apply.workable.com/qodeworld/j/0E7F439D0D/"
echo "========================================================================"
