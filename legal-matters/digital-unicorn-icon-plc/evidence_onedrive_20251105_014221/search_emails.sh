#!/bin/bash

# Quick Email Search Helper
# Digital Unicorn Contract Dispute Evidence Collection

echo "══════════════════════════════════════════════════════════════"
echo "  EMAIL SEARCH HELPER - DIGITAL UNICORN DISPUTE"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "Your Email Accounts:"
echo "  1. sn.renauld@gmail.com (Active - PRIMARY SOURCE)"
echo "  2. simon.renauld@digitalunicorn.fr (DEACTIVATED)"
echo ""
echo "══════════════════════════════════════════════════════════════"
echo ""

# Create directories
echo "Creating directories for email collection..."
mkdir -p emails/{eml,pdf,screenshots,attachments,logs}
echo "✓ Directories created"
echo ""

# Create search log file
SEARCH_LOG="emails/logs/search_log_$(date +%Y%m%d_%H%M%S).txt"
cat > "$SEARCH_LOG" << EOF
EMAIL SEARCH LOG
================
Date: $(date -u '+%Y-%m-%d %H:%M:%S UTC')
Case: Digital Unicorn vs Simon Renauld - Contract 0925/CONSULT/DU

ACCOUNTS SEARCHED
=================
1. sn.renauld@gmail.com (Personal/Active)
2. simon.renauld@digitalunicorn.fr (Company/Deactivated)

EOF

echo "Search log created: $SEARCH_LOG"
echo ""

# Function to display search query
show_search() {
    local num=$1
    local desc=$2
    local query=$3
    local priority=$4
    
    echo "══════════════════════════════════════════════════════════════"
    echo "SEARCH $num: $desc"
    if [ -n "$priority" ]; then
        echo "PRIORITY: $priority"
    fi
    echo "══════════════════════════════════════════════════════════════"
    echo ""
    echo "Gmail Search Query:"
    echo "─────────────────────────────────────────────────────────────"
    echo "$query"
    echo "─────────────────────────────────────────────────────────────"
    echo ""
    
    # Log to file
    cat >> "$SEARCH_LOG" << EOF

SEARCH $num: $desc
Query: $query
Results: _____ emails found
Key Findings: _____________________

EOF
}

# Display searches
echo ""
echo "🔍 GMAIL SEARCH QUERIES"
echo ""
echo "Open Gmail: https://mail.google.com"
echo "Login to: sn.renauld@gmail.com"
echo ""
echo "Then copy/paste these searches one by one:"
echo ""
read -p "Press ENTER when ready to see searches..."
clear

# Search 1: All DU emails
show_search "1" \
    "ALL DIGITAL UNICORN EMAILS (Sept-Oct 2025)" \
    "from:(@digitalunicorn.fr) OR to:(@digitalunicorn.fr) OR cc:(@digitalunicorn.fr) after:2025/09/01 before:2025/11/01" \
    "BASELINE"

read -p "Results found? Press ENTER for next search..."
clear

# Search 2: Lucas's payment promise (CRITICAL)
show_search "2" \
    "LUCAS'S PAYMENT PROMISE (Oct 10) ⭐ CRITICAL" \
    "from:(lucas@digitalunicorn.fr) after:2025/10/10 before:2025/10/11" \
    "🔥 HIGHEST PRIORITY"

echo "What to look for:"
echo '  • Email around 4:46 PM on October 10'
echo '  • Contains: "We will fast track it this Monday"'
echo '  • From: Lucas Kacem (Founder)'
echo ""
echo "If found: Download immediately!"
echo ""

read -p "Found it? Press ENTER for next search..."
clear

# Search 3: Bounced email (SMOKING GUN)
show_search "3" \
    "BOUNCED EMAIL - ACCOUNT DEACTIVATION (Oct 29) 🔥 SMOKING GUN" \
    "from:(mailer-daemon@googlemail.com) subject:(delivery OR failed OR inactive) after:2025/10/29 before:2025/10/31" \
    "🔥 HIGHEST PRIORITY"

echo "What to look for:"
echo '  • Date: October 29, 2025 around 3:19 PM'
echo '  • Error: "550 5.2.1 email account is inactive"'
echo '  • Account: simon.renauld@digitalunicorn.fr'
echo ""
echo "This proves company prevented your response to termination!"
echo ""

read -p "Found it? Press ENTER for next search..."
clear

# Search 4: Bryan's rejection
show_search "4" \
    "BRYAN'S RETROACTIVE REJECTION (Oct 16)" \
    "from:(hatruong@digitalunicorn.fr) after:2025/10/16 before:2025/10/17" \
    "HIGH"

echo "What to look for:"
echo '  • Date: October 16, 2025 around 2:46 PM'
echo '  • Claims: "only four meetings" and work inadequate'
echo '  • This comes AFTER Lucas promised payment!'
echo ""

read -p "Press ENTER for next search..."
clear

# Search 5: Termination notice
show_search "5" \
    "OFFICIAL TERMINATION NOTICE (Oct 22)" \
    "from:(hi@digitalunicorn.fr) subject:(termination OR \"0925/CONSULT/DU\") after:2025/10/22 before:2025/10/23" \
    "HIGH"

echo "What to look for:"
echo '  • Date: October 22, 2025 around 6:04 PM'
echo '  • From: Mia HR'
echo '  • Subject: "Official Notice of Termination..."'
echo '  • Has attachment: Download the termination document!'
echo ""
echo "This came 6 days AFTER you demanded written notice!"
echo ""

read -p "Press ENTER for next search..."
clear

# Search 6: ICON escalation
show_search "6" \
    "ICON PLC ESCALATION (Oct 16)" \
    "(from:graham.crawley OR to:graham.crawley OR cc:graham.crawley) OR (subject:ICON after:2025/10/16 before:2025/10/17)" \
    "MEDIUM"

echo "What to look for:"
echo '  • Date: October 16, 2025 around 1:29 PM'
echo '  • To: Graham Crawley (ICON PLC)'
echo '  • Your escalation to prime contractor'
echo '  • Third-party witness to dispute'
echo ""

read -p "Press ENTER for next search..."
clear

# Search 7: Payment dispute thread
show_search "7" \
    "COMPLETE PAYMENT DISPUTE THREAD (Oct 9-20)" \
    "subject:(nonpayment OR urgent OR formal OR notice) (from:@digitalunicorn.fr OR to:@digitalunicorn.fr) after:2025/10/09 before:2025/10/21" \
    "HIGH"

echo "This should be a long thread with ~19 messages including:"
echo "  • Your Oct 9 payment demand"
echo "  • Bryan requesting timesheet"
echo "  • Your timesheet submission"
echo "  • Lucas's payment promise"
echo "  • Your follow-ups"
echo "  • Bryan's rejection"
echo ""

read -p "Press ENTER for next search..."
clear

# Search 8: Timesheet submission
show_search "8" \
    "SEPTEMBER TIMESHEET SUBMISSION (Oct 10)" \
    "subject:(timesheet OR september) (to:@digitalunicorn.fr) after:2025/10/10 before:2025/10/11" \
    "MEDIUM"

echo "What to look for:"
echo '  • Your email from Oct 10, 9:35 AM'
echo '  • Attached: September 2025 timesheet (80 hours)'
echo '  • Download the attachment!'
echo ""

read -p "Press ENTER for additional searches..."
clear

# Additional searches
echo ""
echo "══════════════════════════════════════════════════════════════"
echo "ADDITIONAL USEFUL SEARCHES"
echo "══════════════════════════════════════════════════════════════"
echo ""

cat << 'EOF'
9. ALL SEPTEMBER WORK EMAILS:
   subject:(september OR "sept 2025") after:2025/09/01 before:2025/10/01

10. ALL PAYMENT-RELATED:
    subject:(payment OR pay OR compensation OR invoice) 
    (from:@digitalunicorn.fr OR to:@digitalunicorn.fr) 
    after:2025/09/01 before:2025/11/01

11. ALL TERMINATION-RELATED:
    subject:(termination OR terminate OR contract OR notice) 
    (from:@digitalunicorn.fr OR to:@digitalunicorn.fr) 
    after:2025/10/01 before:2025/11/01

12. PANOS PETROPOULOS:
    from:(panos OR petropoulos) after:2025/09/01 before:2025/11/01

13. CLARA VIGNE:
    from:(clara OR vigne) after:2025/09/01 before:2025/11/01

14. J&J PROJECT EMAILS:
    subject:("j&j" OR "johnson" OR "python academy" OR "beacon" OR "summit")
    after:2025/09/01 before:2025/11/01
EOF

echo ""
echo "══════════════════════════════════════════════════════════════"
echo ""
read -p "Press ENTER to see download instructions..."
clear

# Download instructions
cat << 'EOF'
══════════════════════════════════════════════════════════════
HOW TO DOWNLOAD EMAILS FROM GMAIL
══════════════════════════════════════════════════════════════

For each important email:

METHOD 1: Download as .EML (Preserves all headers)
─────────────────────────────────────────────────
1. Open the email in Gmail
2. Click ⋮ (three dots in upper right corner)
3. Click "Download message"
4. File saves as .eml format
5. Move to: emails/eml/ folder
6. Rename with descriptive name (e.g., lucas_payment_promise_20251010.eml)

METHOD 2: Print to PDF (Visual evidence)
────────────────────────────────────────
1. Open the email in Gmail
2. Click printer icon or Ctrl+P
3. Select "Print to PDF"
4. Include: "Show original" to display headers
5. Save to: emails/pdf/ folder
6. Use same filename as .eml

METHOD 3: Screenshot (Context evidence)
───────────────────────────────────────
1. Open email in Gmail
2. Ensure visible: URL bar, timestamp, from/to fields
3. Take screenshot (Print Screen or Shift+Ctrl+Show Windows)
4. Save to: emails/screenshots/ folder

IMPORTANT: Do all three methods for critical emails!

EOF

echo ""
read -p "Press ENTER to check deactivated account..."
clear

# Deactivated account check
cat << 'EOF'
══════════════════════════════════════════════════════════════
CHECKING DEACTIVATED ACCOUNT
══════════════════════════════════════════════════════════════

Your company email: simon.renauld@digitalunicorn.fr
Status: Deactivated on or before October 29, 2025

TRY TO LOGIN NOW:
─────────────────
1. Open new browser tab/window
2. Go to: https://mail.google.com
3. Try to login with: simon.renauld@digitalunicorn.fr
4. Enter your password

POSSIBLE OUTCOMES:
──────────────────

✅ SUCCESS (Account still accessible):
   → DOWNLOAD EVERYTHING IMMEDIATELY
   → Use Google Takeout: https://takeout.google.com
   → Or download emails individually
   → Account may be deleted at any time!

❌ ERROR: "Couldn't find your Google Account"
   → Account completely deleted
   → Document this error (screenshot it!)
   → This is additional evidence

⚠️  ERROR: "Account disabled" or similar
   → Account locked but may be recoverable
   → Document the exact error message
   → Contact Google Workspace admin (if DU gives access)

📸 IMPORTANT: Screenshot any error message you get!
   This proves when account was deactivated.

EOF

echo ""
read -p "Press ENTER for email client check..."
clear

# Email client check
cat << 'EOF'
══════════════════════════════════════════════════════════════
CHECK EMAIL CLIENTS FOR CACHED EMAILS
══════════════════════════════════════════════════════════════

If you used an email client (Thunderbird, Outlook, Evolution),
emails might still be cached locally!

EOF

echo ""
echo "Checking for Thunderbird..."
if [ -d "$HOME/.thunderbird" ]; then
    echo "✓ Thunderbird found!"
    echo "  Location: $HOME/.thunderbird"
    echo "  Check for cached emails in ImapMail folders"
else
    echo "✗ Thunderbird not found"
fi

echo ""
echo "Checking for Evolution..."
if [ -d "$HOME/.local/share/evolution/mail" ]; then
    echo "✓ Evolution found!"
    echo "  Location: $HOME/.local/share/evolution/mail"
else
    echo "✗ Evolution not found"
fi

echo ""
echo "Checking for Outlook files..."
OUTLOOK_FILES=$(find "$HOME" -name "*.pst" -o -name "*.ost" 2>/dev/null)
if [ -n "$OUTLOOK_FILES" ]; then
    echo "✓ Outlook files found:"
    echo "$OUTLOOK_FILES"
else
    echo "✗ No Outlook files found"
fi

echo ""
read -p "Press ENTER for mobile device instructions..."
clear

# Mobile check
cat << 'EOF'
══════════════════════════════════════════════════════════════
CHECK MOBILE DEVICE
══════════════════════════════════════════════════════════════

If you had simon.renauld@digitalunicorn.fr on your phone:

1. Open email app on phone
2. Check if messages still cached locally
3. Try to export/forward important emails to sn.renauld@gmail.com
4. Screenshot critical messages before they sync/delete
5. Check "Sent" folder for your sent messages

Mobile apps often cache emails even after account deletion!

EOF

read -p "Press ENTER for summary..."
clear

# Summary
cat << 'EOF'
══════════════════════════════════════════════════════════════
SUMMARY - NEXT STEPS
══════════════════════════════════════════════════════════════

CRITICAL EMAILS TO FIND (Priority Order):
──────────────────────────────────────────

1. 🔥 Lucas's Payment Promise (Oct 10, 4:46 PM)
   "We will fast track it this Monday"
   → This is binding commitment from Founder

2. 🔥 Bounced Email (Oct 29, 3:19 PM)
   "550 5.2.1 email account is inactive"
   → Proves bad faith - prevented your response

3. ⭐ Bryan's Rejection (Oct 16, 2:46 PM)
   Retroactive rejection after payment promise
   → Shows reversal without valid cause

4. ⭐ Termination Notice (Oct 22, 6:04 PM)
   First written notice - 6 days late
   → Proves Article 11 violation

5. ⭐ Your Timesheet Submission (Oct 10, 9:35 AM)
   September 2025 - 80 hours
   → Shows you fulfilled requirements

6. ⭐ ICON Escalation (Oct 16, 1:29 PM)
   To Graham Crawley
   → Third-party witness

AFTER COLLECTING EMAILS:
────────────────────────
1. Save all to emails/eml/ folder
2. Run: ./collect_gmail_evidence.sh
3. Script will:
   - Extract authentication headers
   - Generate cryptographic hashes
   - Create manifest
   - Verify integrity

SEARCH LOG SAVED TO:
────────────────────
EOF

echo "$SEARCH_LOG"

cat << 'EOF'

Update this log with your findings:
- Number of emails found per search
- Key discoveries
- Any missing emails

══════════════════════════════════════════════════════════════

QUESTIONS? See: EMAIL_SEARCH_GUIDE.md for detailed instructions

══════════════════════════════════════════════════════════════
EOF

echo ""
echo "Ready to start email collection!"
echo ""
echo "Open Gmail now? (y/n)"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Opening Gmail..."
    xdg-open "https://mail.google.com" 2>/dev/null || \
    open "https://mail.google.com" 2>/dev/null || \
    echo "Please open https://mail.google.com manually"
    echo ""
    echo "Login to: sn.renauld@gmail.com"
    echo "Then use the searches shown above!"
else
    echo ""
    echo "No problem! Open Gmail when ready:"
    echo "  https://mail.google.com"
    echo ""
    echo "Re-run this script anytime: ./search_emails.sh"
fi

echo ""
echo "Good luck with evidence collection!"
echo ""
