#!/bin/bash

cat << 'GUIDE'

╔═══════════════════════════════════════════════════════════════════╗
║        FREE CLOUDFLARE SOLUTIONS (No Enterprise Plan Needed)     ║
╚═══════════════════════════════════════════════════════════════════╝

PROBLEM: WAF Custom Rules require Enterprise plan ($$$)
SOLUTION: Use FREE alternatives below

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ OPTION 1: BYPASS CLOUDFLARE FOR WEBSERVICE (RECOMMENDED)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Create a separate subdomain that bypasses Cloudflare proxy:

STEPS:
1. Go to: https://dash.cloudflare.com
2. Select: simondatalab.de
3. Click: DNS > Records
4. Add A Record:
   ┌────────────────────────────────────────┐
   │ Type:    A                             │
   │ Name:    moodle-api                    │
   │ IPv4:    136.243.155.166               │
   │ Proxy:   DNS only (gray cloud ☁️)      │
   │ TTL:     Auto                          │
   └────────────────────────────────────────┘

5. Save

RESULT:
• moodle.simondatalab.de → goes through Cloudflare (blocked)
• moodle-api.simondatalab.de:8086 → direct to server (works!)

USAGE IN YOUR CODE:
Update moodle_deployer.py:
  MOODLE_URL = 'http://moodle-api.simondatalab.de:8086'

TEST:
  curl -X POST "http://moodle-api.simondatalab.de:8086/webservice/rest/server.php" \
    -d "wstoken=$(cat ~/.moodle_token)" \
    -d "wsfunction=core_webservice_get_site_info" \
    -d "moodlewsrestformat=json"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ OPTION 2: DISABLE CLOUDFLARE PROXY FOR MAIN DOMAIN
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

If you don't need Cloudflare DDoS protection:

1. Go to: DNS > Records
2. Find: moodle.simondatalab.de
3. Click: orange cloud icon → turns gray
4. Save

⚠️ WARNING: This removes ALL Cloudflare protections for this domain

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ OPTION 3: USE SSH TUNNEL (NO CLOUDFLARE CHANGES)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Run a local proxy that tunnels through SSH to VM 9001:

STEPS:
1. Start proxy:
   python3 moodle_api_proxy.py &

2. Update moodle_deployer.py:
   MOODLE_URL = 'http://127.0.0.1:9999'

3. Deploy:
   python3 moodle_deployer.py

PROS: No Cloudflare changes, no DNS changes
CONS: Only works from your local machine

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ OPTION 4: DIRECT IP ACCESS (QUICK TEST)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Access Moodle directly via IP (bypasses Cloudflare):

USAGE:
  MOODLE_URL = 'http://136.243.155.166:8086'

IMPORTANT: Add Host header in your requests:
  headers = {'Host': 'moodle.simondatalab.de'}

TEST:
  curl -X POST "http://136.243.155.166:8086/webservice/rest/server.php" \
    -H "Host: moodle.simondatalab.de" \
    -d "wstoken=$(cat ~/.moodle_token)" \
    -d "wsfunction=core_webservice_get_site_info" \
    -d "moodlewsrestformat=json"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🏆 RECOMMENDED: OPTION 1 (API Subdomain)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Why Option 1 is best:
✅ Free (no Enterprise plan needed)
✅ Keeps Cloudflare protection on main site
✅ Works from anywhere (not just localhost)
✅ Proper DNS (no IP hardcoding)
✅ No code changes after initial setup
✅ Professional (clean subdomain: moodle-api.simondatalab.de)

5-minute setup, permanent solution!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

GUIDE
