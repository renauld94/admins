#!/bin/bash
# Quick launcher for ADA package

echo "🚀 Opening ADA Package..."
echo ""

# Open main README
echo "📖 Opening README in editor..."
code ADA_README.md

# Open action checklist
echo "✅ Opening Action Checklist..."
code ADA_ACTION_CHECKLIST.md

# Open thank-you email
echo "📧 Opening Thank-You Email (SEND TODAY)..."
code ada_thank_you_email.txt

# Open dashboard in browser
echo "📊 Opening Dashboard Mockup in browser..."
xdg-open ada_metrics_dashboard_mockup.html &

echo ""
echo "✅ All files opened!"
echo ""
echo "NEXT STEPS:"
echo "1. Read ADA_ACTION_CHECKLIST.md"
echo "2. Customize ada_thank_you_email.txt"
echo "3. Send email to Frank TODAY"
echo ""
echo "Good luck! 🎯"
