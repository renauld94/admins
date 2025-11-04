#!/bin/bash
#
# Universal CRM - Complete Setup and First Run
# Sets up database, finds leads, imports to CRM, shows dashboard
#

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo "=================================================================="
echo "🚀 UNIVERSAL CRM - COMPLETE SETUP"
echo "=================================================================="
echo ""
echo "This will:"
echo "  1. Setup PostgreSQL database"
echo "  2. Find your first LinkedIn leads"
echo "  3. Import them to CRM"
echo "  4. Show your dashboard"
echo ""
read -p "Continue? (y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "Aborted."
    exit 0
fi

# Step 1: Setup database
echo ""
echo "=================================================================="
echo "STEP 1: Setting up PostgreSQL database..."
echo "=================================================================="
./setup-crm-database.sh

# Step 2: Configure LinkedIn credentials
echo ""
echo "=================================================================="
echo "STEP 2: Configure LinkedIn credentials"
echo "=================================================================="
echo ""
echo "Edit .env file to add your LinkedIn email and password:"
echo ""

if ! grep -q "LINKEDIN_EMAIL=.*@" .env 2>/dev/null; then
    echo "⚠️  LinkedIn credentials not configured yet"
    echo ""
    read -p "Enter LinkedIn email: " LINKEDIN_EMAIL
    read -sp "Enter LinkedIn password: " LINKEDIN_PASSWORD
    echo ""
    
    # Update .env
    sed -i "s/^LINKEDIN_EMAIL=.*/LINKEDIN_EMAIL=$LINKEDIN_EMAIL/" .env
    sed -i "s/^LINKEDIN_PASSWORD=.*/LINKEDIN_PASSWORD=$LINKEDIN_PASSWORD/" .env
    
    echo "✓ Credentials saved to .env"
else
    echo "✓ LinkedIn credentials already configured"
fi

# Step 3: Install Playwright
echo ""
echo "=================================================================="
echo "STEP 3: Installing browser for automation..."
echo "=================================================================="
python3 -m playwright install chromium

# Step 4: Find leads
echo ""
echo "=================================================================="
echo "STEP 4: Find your first leads"
echo "=================================================================="
echo ""
echo "Target locations:"
echo "  1. Vietnam (your primary market)"
echo "  2. Canada"
echo "  3. Singapore"
echo ""
echo "Running QUICK search (top 4 roles, ~15 minutes)..."
echo ""
read -p "Start lead search now? (y/n): " DO_SEARCH

if [ "$DO_SEARCH" = "y" ]; then
    python3 batch_lead_search.py --quick --locations Vietnam Canada Singapore
    
    # Step 5: Show dashboard
    echo ""
    echo "=================================================================="
    echo "STEP 5: Your CRM Dashboard"
    echo "=================================================================="
    python3 crm_database.py dashboard
else
    echo "Skipped lead search. Run later with:"
    echo "  ./search-leads.sh"
fi

# Final summary
echo ""
echo "=================================================================="
echo "✅ UNIVERSAL CRM SETUP COMPLETE!"
echo "=================================================================="
echo ""
echo "What you have now:"
echo ""
echo "  ✓ PostgreSQL database (universal_crm)"
echo "  ✓ Complete schema (organizations, people, leads, jobs, projects)"
echo "  ✓ LinkedIn credentials configured"
echo "  ✓ Browser automation ready"

if [ "$DO_SEARCH" = "y" ]; then
    echo "  ✓ First batch of leads imported"
fi

echo ""
echo "Next steps:"
echo ""
echo "1. View your leads in database:"
echo "   psql universal_crm -c 'SELECT * FROM active_leads_view LIMIT 10;'"
echo ""
echo "2. Generate outreach messages:"
echo "   python3 lead_generation_engine.py pipeline"
echo "   python3 lead_generation_engine.py outreach <lead_id> inmail"
echo ""
echo "3. Find more leads:"
echo "   ./search-leads.sh"
echo ""
echo "4. View dashboard anytime:"
echo "   python3 crm_database.py dashboard"
echo ""
echo "5. Access database directly:"
echo "   psql universal_crm"
echo ""
echo "6. Read complete guide:"
echo "   cat CRM_DATABASE_GUIDE.md"
echo ""
echo "Database connects:"
echo "  📊 LinkedIn leads → CRM"
echo "  💼 Job applications → CRM"
echo "  🎓 Moodle enrollments → CRM"
echo "  🏢 Consulting projects → CRM"
echo "  🖥️  Infrastructure VMs → CRM"
echo "  💬 All interactions → CRM"
echo ""
echo "Everything is interconnected! 🎯"
echo ""
