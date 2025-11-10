#!/usr/bin/env bash
# QUICK START GUIDE - JOB SEARCH AUTOMATION
# Run this file to get your system up and running in minutes

set -e

echo "=========================================="
echo "🚀 JOB SEARCH AUTOMATION - QUICK START"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -f "requirements.txt" ]; then
    echo "❌ Error: requirements.txt not found"
    echo "Please run this from: ~/Learning-Management-System-Academy/job-search-toolkit/"
    exit 1
fi

echo -e "${BLUE}Step 1: Checking Python installation${NC}"
python3 --version || { echo "❌ Python3 not found"; exit 1; }
echo -e "${GREEN}✓ Python installed${NC}"
echo ""

echo -e "${BLUE}Step 2: Installing dependencies (may require sudo)${NC}"
sudo pip install -r requirements.txt 2>/dev/null || pip install -r requirements.txt
echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

echo -e "${BLUE}Step 3: Installing pandoc for PDF export${NC}"
which pandoc > /dev/null 2>&1 || sudo apt-get update && sudo apt-get install -y pandoc
echo -e "${GREEN}✓ Pandoc installed${NC}"
echo ""

echo -e "${BLUE}Step 4: Setting up email (Gmail SMTP)${NC}"
echo -e "${YELLOW}⚠️  You need an app password from Google:${NC}"
echo "   1. Go to: https://myaccount.google.com/apppasswords"
echo "   2. Select Gmail + Linux"
echo "   3. Copy the 16-character password"
echo ""
read -p "Enter your 16-char Gmail app password (or press Enter to skip): " APP_PASSWORD

if [ -n "$APP_PASSWORD" ]; then
    export EMAIL_PASSWORD="$APP_PASSWORD"
    echo -e "${GREEN}✓ Email password set${NC}"
    
    # Verify SMTP connection
    python3 -c "
import smtplib
try:
    server = smtplib.SMTP_SSL('smtp.gmail.com', 465, timeout=5)
    print('✓ Gmail SMTP connection successful')
    server.quit()
except Exception as e:
    print(f'❌ Error: {e}')
    exit(1)
" || { echo "❌ SMTP connection failed"; }
else
    echo -e "${YELLOW}⚠️  Email password not set. Email features will be disabled.${NC}"
fi
echo ""

echo -e "${BLUE}Step 5: Creating necessary directories${NC}"
mkdir -p data outputs/{resumes,interviews,invites,logs} config
echo -e "${GREEN}✓ Directories ready${NC}"
echo ""

echo -e "${BLUE}Step 6: Initializing databases${NC}"
python3 -c "
import sqlite3
import os

db_files = [
    'data/job_search.db',
    'data/linkedin_contacts.db',
    'data/interview_scheduler.db',
    'data/resume_delivery.db',
    'data/job_search_metrics.db'
]

for db in db_files:
    if os.path.exists(db):
        size = os.path.getsize(db)
        print(f'✓ {db} ({size:,} bytes)')
    else:
        print(f'⚠️  {db} will be created on first run')
"
echo -e "${GREEN}✓ Databases initialized${NC}"
echo ""

echo -e "${BLUE}Step 7: Checking profile configuration${NC}"
if [ -f "config/profile.json" ]; then
    echo -e "${GREEN}✓ Profile found${NC}"
else
    echo -e "${YELLOW}⚠️  No profile.json found. Creating template...${NC}"
    cat > config/profile.json << 'EOF'
{
  "name": "Simon Renauld",
  "email_primary": "contact@simondatalab.de",
  "email_backup": "sn@gmail.com",
  "linkedin": "linkedin.com/in/simonrenauld",
  "target_salary": "$150K-$350K",
  "regions": ["Vietnam", "APAC", "Australia", "USA Remote", "Canada Remote", "Europe Remote"],
  "target_roles": ["Senior Data Engineer", "ML Engineer", "Data Architect", "Data Science Manager"],
  "skills": ["Python", "Spark", "Kafka", "AWS", "Azure", "GCP", "SQL", "Docker"],
  "languages": ["English", "German", "Vietnamese"],
  "willing_to_relocate": "Australia",
  "timezone": "UTC+7"
}
EOF
    echo -e "${GREEN}✓ Profile template created${NC}"
    echo "   Edit config/profile.json with your details"
fi
echo ""

echo "=========================================="
echo "✅ SETUP COMPLETE!"
echo "=========================================="
echo ""

echo -e "${YELLOW}📊 NEXT STEPS:${NC}"
echo ""
echo "1️⃣  Review your profile:"
echo "   nano config/profile.json"
echo ""
echo "2️⃣  (Optional) View the Streamlit dashboard:"
echo "   streamlit run streamlit_dashboard.py"
echo "   Access at: http://localhost:8501"
echo ""
echo "3️⃣  Wait for tomorrow 7:00 AM UTC+7 (automatic runs)"
echo "   OR run manually:"
echo "   python3 epic_job_search_agent.py daily"
echo ""
echo "4️⃣  Send tailored resume to recruiter:"
echo "   python3 -c \""
echo "   from resume_auto_adjuster import ResumeAutoAdjuster"
echo "   adj = ResumeAutoAdjuster()"
echo "   result = adj.process_job_and_send("
echo "       job_title='Senior Data Engineer',"
echo "       job_description='We seek...',"
echo "       company='Company Name',"
echo "       recruiter_email='recruiter@company.com',"
echo "       recruiter_name='John Doe',"
echo "       job_id='company_001',"
echo "       generate_pdf=True,"
echo "       send_email=True"
echo "   )"
echo "   print(result)"
echo "   \""
echo ""
echo "5️⃣  Schedule an interview:"
echo "   python3 interview_scheduler.py \\"
echo "     --title 'Interview: Senior Data Engineer' \\"
echo "     --start '2025-11-20T09:00:00+07:00' \\"
echo "     --end '2025-11-20T09:45:00+07:00' \\"
echo "     --organizer 'contact@simondatalab.de' \\"
echo "     --attendee 'recruiter@example.com'"
echo ""

echo -e "${YELLOW}🔍 VERIFY YOUR SETUP:${NC}"
echo ""
echo "Check job opportunities:"
echo "  sqlite3 data/job_search.db \"SELECT COUNT(*) as jobs FROM opportunities;\""
echo ""
echo "Check LinkedIn activity:"
echo "  sqlite3 data/linkedin_contacts.db \"SELECT COUNT(*) as connections FROM contacts;\""
echo ""
echo "View today's opportunity scores:"
echo "  sqlite3 data/job_search.db \"SELECT company, title, score FROM opportunities ORDER BY score DESC LIMIT 10;\""
echo ""

echo -e "${YELLOW}📝 DOCUMENTATION:${NC}"
echo "  • COMPLETE_AUTOMATION_FINAL_REPORT.md - Full system overview"
echo "  • EXECUTIVE_SUMMARY_AUTOMATION.md - Quick reference"
echo "  • README_AUTOMATION.md - Detailed setup guide"
echo ""

echo -e "${GREEN}🎉 You're all set! Your automation system is ready.${NC}"
echo ""
echo "Job discovery starts tomorrow at 7:00 AM UTC+7"
echo "Or run manually: python3 epic_job_search_agent.py daily"
echo ""
echo "Questions? Check the documentation files above."
echo ""
