#!/bin/bash
# Setup LinkedIn Credentials for Lead Generation
# This will prompt for your LinkedIn credentials securely

echo "🔐 LinkedIn Credentials Setup"
echo "=============================="
echo ""
echo "Your credentials will be stored in .env file (git-ignored)"
echo ""

# Check if .env exists
if [ -f .env ]; then
    echo "⚠️  .env file already exists. Backing up to .env.backup"
    cp .env .env.backup
fi

# Prompt for email
read -p "LinkedIn Email: " LINKEDIN_EMAIL

# Prompt for password (hidden)
read -s -p "LinkedIn Password: " LINKEDIN_PASSWORD
echo ""

# Write to .env
cat >> .env << EOF

# LinkedIn Credentials (added $(date))
LINKEDIN_EMAIL=$LINKEDIN_EMAIL
LINKEDIN_PASSWORD=$LINKEDIN_PASSWORD
EOF

echo ""
echo "✅ Credentials saved to .env"
echo ""
echo "🚀 Ready to run lead search!"
echo ""
echo "Next steps:"
echo "  1. Quick search (Vietnam, Canada, Singapore):"
echo "     python3 batch_lead_search.py --quick --locations Vietnam Canada Singapore --auto-import"
echo ""
echo "  2. Full search (all locations):"
echo "     python3 batch_lead_search.py --auto-import"
echo ""
echo "  3. Interactive search:"
echo "     ./search-leads.sh"
echo ""
