#!/bin/bash

# Cloudflare WAF Fix for Moodle Webservices
# This script shows you how to fix the 403 Forbidden error from Cloudflare

cat << 'EOF'
🔧 CLOUDFLARE WAF FIX FOR MOODLE WEBSERVICES
============================================

PROBLEM:
Your Moodle webservice API at https://moodle.simondatalab.de/webservice/rest/server.php
is returning HTTP 403 Forbidden because Cloudflare WAF is blocking POST requests.

The token and Moodle configuration are CORRECT. The issue is Cloudflare security.

SOLUTION 1: Whitelist Webservice Path in Cloudflare (RECOMMENDED)
------------------------------------------------------------------
1. Log into Cloudflare Dashboard: https://dash.cloudflare.com
2. Select your domain: simondatalab.de
3. Go to: Security > WAF > Custom Rules
4. Click "Create Rule"
5. Configure the rule:
   - Rule name: "Allow Moodle Webservices"
   - Field: URI Path
   - Operator: starts with
   - Value: /webservice/
   - Then: Skip > All remaining custom rules
   - AND Skip > WAF Managed Rulesets
6. Click "Deploy"

This will allow POST requests to /webservice/* paths while keeping WAF active for the rest of your site.

SOLUTION 2: Bypass Cloudflare for Webservice Subdomain
-------------------------------------------------------
1. In Cloudflare DNS, create an A record:
   - Name: moodle-api
   - Type: A  
   - IPv4 address: 136.243.155.166
   - Proxy status: DNS only (gray cloud, NOT orange)
   - TTL: Auto

2. Update your moodle_deployer.py to use:
   MOODLE_URL = 'http://moodle-api.simondatalab.de:8086'

SOLUTION 3: Use SSH Tunnel (CURRENT WORKAROUND)
-----------------------------------------------
The moodle_api_proxy.py script in this directory creates a local proxy
that forwards API calls through SSH, completely bypassing Cloudflare.

To use:
  python3 moodle_api_proxy.py &
  
Then update moodle_deployer.py:
  MOODLE_URL = 'http://127.0.0.1:9999'

TESTING:
-------
After applying Solution 1 or 2, test with:

  curl -X POST "https://moodle.simondatalab.de/webservice/rest/server.php" \\
    -d "wstoken=$(cat ~/.moodle_token)" \\
    -d "wsfunction=core_webservice_get_site_info" \\
    -d "moodlewsrestformat=json"

You should see JSON response with site info, not a 403 error.

EOF
