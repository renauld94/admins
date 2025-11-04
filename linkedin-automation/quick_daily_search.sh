#!/bin/bash

# Quick Daily Search Script
# Run this every morning: ./quick_daily_search.sh

DATE=$(date +%Y%m%d)
LEAD_FILE="manual_leads_${DATE}.json"

echo "================================================"
echo "📊 DAILY LEAD & JOB SEARCH - $(date +%Y-%m-%d)"
echo "================================================"
echo ""

# Check current CRM status
echo "Current CRM Status:"
python3 crm_database.py dashboard
echo ""

# Determine today's search theme
DAY_OF_WEEK=$(date +%u)  # 1=Monday, 7=Sunday

case $DAY_OF_WEEK in
  1)
    THEME="Canada Data Quality Roles"
    QUERY1="Data Quality Engineer Canada Remote"
    QUERY2="QA Engineer Data Toronto Vancouver"
    QUERY3="Senior Data Engineer Quality Canada"
    ;;
  2)
    THEME="Singapore/Asia QA Roles"
    QUERY1="QA Engineer Singapore Data Platform"
    QUERY2="Test Engineer Ho Chi Minh City Python"
    QUERY3="Quality Assurance Bangkok ETL"
    ;;
  3)
    THEME="Leadership Roles (Head of Data)"
    QUERY1="Head of Data Quality Remote"
    QUERY2="Director Data Engineering Canada Europe"
    QUERY3="VP Data Startup Series A Series B"
    ;;
  4)
    THEME="Healthcare & Compliance Roles"
    QUERY1="Data Engineer Healthcare HIPAA"
    QUERY2="QA Engineer Medical Device Pharma"
    QUERY3="Data Governance Healthcare Analytics"
    ;;
  5)
    THEME="E-Commerce & Marketplace Roles"
    QUERY1="Data Engineer E-commerce Marketplace"
    QUERY2="Analytics Engineer Shopify Amazon"
    QUERY3="Data Quality Retail Tech"
    ;;
  6|7)
    THEME="Weekend: Review & Plan"
    echo "Weekend - No searches scheduled. Review your week:"
    echo "- Total leads added this week?"
    echo "- Applications submitted?"
    echo "- Follow-ups needed?"
    exit 0
    ;;
esac

echo "Today's Theme: $THEME"
echo ""
echo "LinkedIn Searches to Run:"
echo "  1. $QUERY1"
echo "  2. $QUERY2"
echo "  3. $QUERY3"
echo ""
echo "Target Companies (check career pages):"

case $DAY_OF_WEEK in
  1)
    echo "  - Shopify: https://www.shopify.com/careers"
    echo "  - Wealthsimple: https://www.wealthsimple.com/en-ca/careers"
    echo "  - Lightspeed: https://www.lightspeedhq.com/careers/"
    ;;
  2)
    echo "  - Grab: https://grab.careers/"
    echo "  - Sea Group (Shopee): https://career.seagroup.com/"
    echo "  - VNG Corporation: https://career.vng.com.vn/"
    ;;
  3)
    echo "  - AngelList: https://wellfound.com/jobs (Series A-C startups)"
    echo "  - YC Companies: https://www.ycombinator.com/companies"
    ;;
  4)
    echo "  - TELUS Health: https://www.telus.com/en/careers"
    echo "  - Veeva Systems: https://www.veeva.com/careers/"
    echo "  - Epic Systems: https://careers.epic.com/"
    ;;
  5)
    echo "  - Shopify: https://www.shopify.com/careers"
    echo "  - Lazada: https://www.lazada.com/careers/"
    echo "  - Instacart: https://instacart.careers/"
    ;;
esac

echo ""
echo "================================================"
echo "⏱️  QUICK 30-MINUTE WORKFLOW"
echo "================================================"
echo ""
echo "Step 1 (10 min): LinkedIn Search"
echo "  - Open LinkedIn, paste each query above"
echo "  - Filter: 'Past Week' + 'Remote' or target location"
echo "  - Open 10 promising profiles in tabs"
echo ""
echo "Step 2 (10 min): Qualify Leads"
echo "  - For each profile: Check fit score (6-10)"
echo "  - Skip if: Inactive >6mo, wrong tech stack, clearly junior"
echo "  - Save 5 best leads"
echo ""
echo "Step 3 (10 min): Data Entry + Import"
echo "  - Copy template from manual_lead_template.json"
echo "  - Fill in: name, title, company, linkedin_url, fit_score, notes"
echo "  - Save as: $LEAD_FILE"
echo "  - Import: python3 crm_database.py import-leads $LEAD_FILE"
echo ""
echo "================================================"
echo "🎯 TODAY'S GOAL: 5 new leads in CRM"
echo "================================================"
echo ""
echo "Create $LEAD_FILE when ready, then run:"
echo "  python3 crm_database.py import-leads $LEAD_FILE"
echo ""
echo "After import, verify with:"
echo "  python3 crm_database.py dashboard"
echo ""

# Check if lead file already exists
if [ -f "$LEAD_FILE" ]; then
    echo "✅ Found $LEAD_FILE - Ready to import!"
    read -p "Import now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        python3 crm_database.py import-leads "$LEAD_FILE"
        echo ""
        echo "Updated CRM Status:"
        python3 crm_database.py dashboard
    fi
else
    echo "📝 $LEAD_FILE not found yet. Create it after your searches!"
fi

echo ""
echo "Good luck! 🚀"
