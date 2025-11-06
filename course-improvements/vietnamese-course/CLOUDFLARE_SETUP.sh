#!/bin/bash

# CLOUDFLARE WAF RULE - Copy-paste configuration
# This will allow Moodle webservices to work through Cloudflare

cat << 'EOF'

═══════════════════════════════════════════════════════════════════
   CLOUDFLARE WAF CUSTOM RULE FOR MOODLE WEBSERVICES
═══════════════════════════════════════════════════════════════════

ISSUE: 
Cloudflare WAF is blocking POST requests to your Moodle webservice API.
Token and Moodle configs are 100% correct - only Cloudflare is blocking.

SOLUTION:
Create a Cloudflare WAF custom rule to whitelist /webservice/ path

─────────────────────────────────────────────────────────────────

STEP 1: Log into Cloudflare
→ https://dash.cloudflare.com

STEP 2: Select your domain
→ Click on "simondatalab.de"

STEP 3: Navigate to WAF
→ Security > WAF > Custom rules

STEP 4: Create Rule
→ Click "Create rule" button

STEP 5: Configure the rule with these EXACT settings:

┌─────────────────────────────────────────────────────────────────┐
│ Rule name:                                                       │
│   Allow Moodle Webservices                                      │
│                                                                  │
│ If incoming requests match:                                     │
│   Field:    URI Path                                            │
│   Operator: starts with                                         │
│   Value:    /webservice/                                        │
│                                                                  │
│ Then take action:                                               │
│   Action:   Skip                                                │
│             ☑ All remaining custom rules                        │
│             ☑ WAF Managed Rulesets                              │
│             ☐ Rate Limiting Rules (leave unchecked)             │
│             ☐ Super Bot Fight Mode (leave unchecked)            │
│                                                                  │
│ Deploy rule                                                     │
└─────────────────────────────────────────────────────────────────┘

STEP 6: Test after deployment (wait 10 seconds)

  curl -X POST "https://moodle.simondatalab.de/webservice/rest/server.php" \
    -d "wstoken=$(cat ~/.moodle_token)" \
    -d "wsfunction=core_webservice_get_site_info" \
    -d "moodlewsrestformat=json" | jq

You should see JSON with site info, NOT 403 error!

─────────────────────────────────────────────────────────────────

ALTERNATIVE: Expression Builder (Advanced)

If you prefer using Expression Builder instead of the UI:

  (http.request.uri.path contains "/webservice/")

Then: Skip > All remaining custom rules + WAF Managed Rulesets

─────────────────────────────────────────────────────────────────

WHAT THIS DOES:
• Allows POST requests to /webservice/* paths
• Bypasses Cloudflare WAF for API endpoints only
• Keeps WAF active for rest of your site
• No security impact - Moodle has its own token authentication

─────────────────────────────────────────────────────────────────

TROUBLESHOOTING:

If still getting 403:
1. Wait 30 seconds for Cloudflare to propagate rule
2. Clear browser cache / try incognito
3. Check rule is "Deployed" not "Draft"
4. Verify domain is simondatalab.de not www.simondatalab.de

If getting redirect to /admin/registration:
→ This means Cloudflare rule is working!
→ Issue is now Moodle forcing HTTPS (which is correct)
→ Just use HTTPS in your API calls

═══════════════════════════════════════════════════════════════════

After completing this, update your moodle_deployer.py:

  MOODLE_URL = 'https://moodle.simondatalab.de'  # Use HTTPS!
  
And test:

  python3 test_moodle_connection.sh

EOF

# Also test if curl/wget are available
echo ""
echo "Testing curl availability..."
if command -v curl &> /dev/null; then
    echo "✅ curl is available"
else
    echo "❌ curl not found - install with: sudo apt install curl"
fi

if command -v jq &> /dev/null; then
    echo "✅ jq is available (for pretty JSON)"
else
    echo "⚠️  jq not found - install with: sudo apt install jq (optional)"
fi
