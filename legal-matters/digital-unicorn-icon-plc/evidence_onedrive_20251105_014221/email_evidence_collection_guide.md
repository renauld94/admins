# Email Evidence Collection Guide
## Digital Unicorn vs ICON PLC - Contract Dispute

**Date:** November 5, 2025  
**Case:** Consultant Contract 0925/CONSULT/DU - Nonpayment and Wrongful Termination  
**Evidence Type:** Email Communications

---

## Critical Email Threads Identified

### Thread 1: Official Termination Notice
- **Subject:** Official Notice of Termination of Consultant Contract No. 0925/CONSULT/DU
- **Date:** October 22, 2025 (6:04 PM)
- **From:** Mia HR (hi@digitalunicorn.fr)
- **Key Evidence:**
  - Formal termination notice with attachment
  - Sent AFTER your October 16 demand for written notice
  - Your response bounced (simon.renauld@digitalunicorn.fr inactive) - October 29
  - **Legal Significance:** Proves account deactivation prevented response

### Thread 2: Payment Dispute Timeline
- **Subject:** Urgent: Formal Notice – Nonpayment under Consultant Contract 0925/CONSULT/DU
- **Date Range:** October 9-20, 2025
- **Key Evidence:**
  - October 9: Your formal payment demand
  - October 9 (11:17 PM): Bryan requests timesheet
  - October 10 (9:35 AM): You submit September timesheet (80 hours)
  - October 10 (4:46 PM): **Lucas confirms "fast track this Monday"**
  - October 13: No payment received
  - October 16 (2:46 PM): Bryan claims "limited to four meetings" and rejects timesheet
  - October 16 (2:58 PM): Bryan accuses breach of contract for contacting client
  - **Legal Significance:** Payment promised, then retroactively rejected

### Thread 3: ICON Escalation
- **Subject:** Request for Clarification – DU–ICON Subcontract Compliance
- **Date:** October 16, 2025 (1:29 PM)
- **To:** Graham Crawley (ICON), Lucas, Panos, Ha
- **Key Evidence:**
  - You remain listed as active in J&J Beacon and SUMMIT systems
  - Request for ICON oversight of subcontract
  - **Legal Significance:** Documents client notification and subcontract chain

---

## Evidence Collection Steps

### Step 1: Download Email Files (EML/MBOX Format)

**For Gmail Web Interface:**
1. Open each email thread
2. Click three dots menu (⋮) → **Download message**
3. Saves as `.eml` file with full headers and metadata
4. Save to: `evidence_onedrive_20251105_014221/emails/`

**Files to Download:**
- `termination_notice_20251022.eml`
- `payment_dispute_thread_oct9-20.eml`
- `icon_escalation_20251016.eml`
- `bounced_response_20251029.eml`

### Step 2: Create PDF Versions with Full Headers

**Option A: Print to PDF (Recommended for Visual Evidence)**
1. Open email in Gmail
2. Click Print icon
3. **IMPORTANT:** Check "Print all headers" or expand "Show original"
4. Print to PDF
5. Filename format: `[subject]_[date]_full-headers.pdf`

**Option B: Use Gmail "Show Original" Feature**
1. Open email → Three dots (⋮) → **Show original**
2. This displays full RFC 822 headers with:
   - Authentication results (SPF, DKIM, DMARC)
   - Message-ID (unique identifier)
   - Received headers (server routing path)
   - Timestamps (UTC)
3. Save page as PDF or copy text

### Step 3: Screenshot Each Email Thread

**Requirements:**
- Full browser window visible
- Gmail URL visible in address bar
- System clock/timestamp visible (use `date` command overlay)
- Scroll through entire conversation showing all messages
- Capture "To:", "From:", "Date:", "Subject:" fields clearly

**Commands to add timestamp overlay:**
```bash
# Take screenshot with timestamp
gnome-screenshot -f email_thread_$(date +%Y%m%d_%H%M%S).png

# Or use scrot with timestamp display
echo "Screenshot taken at: $(date -u '+%Y-%m-%d %H:%M:%S UTC')" > timestamp.txt
```

### Step 4: Extract Key Attachments

**From October 22 Termination Email:**
- Download the official termination notice attachment (PDF/DOC)
- Original filename preservation critical
- Save as: `termination_notice_attachment_original.[ext]`

**From October 10 Your Email:**
- September timesheet: `Simon_Renauld_TimeSheet_September_2025.[ext]`

### Step 5: Generate Email Evidence Manifest

Run this command in the emails directory:
```bash
cd evidence_onedrive_20251105_014221/emails/

# Create manifest with metadata
cat > email_evidence_manifest.txt << 'EOF'
EMAIL EVIDENCE MANIFEST
Case: Digital Unicorn vs ICON PLC - Contract 0925/CONSULT/DU
Collected: $(date -u '+%Y-%m-%d %H:%M:%S UTC')
Collector: Simon Renauld

EVIDENCE FILES:
EOF

# Add file listings with hashes
for file in *.eml *.pdf *.png; do
  if [ -f "$file" ]; then
    echo "" >> email_evidence_manifest.txt
    echo "File: $file" >> email_evidence_manifest.txt
    echo "Size: $(stat -c%s "$file") bytes" >> email_evidence_manifest.txt
    echo "Modified: $(stat -c%y "$file")" >> email_evidence_manifest.txt
    sha256sum "$file" >> email_evidence_manifest.txt
    md5sum "$file" >> email_evidence_manifest.txt
  fi
done
```

### Step 6: Verify Email Authentication Headers

For each .eml file, extract authentication results:
```bash
# Extract DKIM/SPF/DMARC verification
grep -A 5 "Authentication-Results:" *.eml > authentication_verification.txt

# Extract Message-IDs (unique identifiers)
grep "Message-ID:" *.eml > message_ids.txt

# Extract delivery timestamps
grep "Received:" *.eml > delivery_path.txt
```

**Why This Matters:**
- DKIM signatures prove email wasn't forged
- SPF/DMARC results verify sender authenticity
- Message-IDs are globally unique and verifiable
- Received headers show complete delivery path with timestamps

---

## Critical Evidence Points to Highlight

### 1. Promise to Pay → Retroactive Rejection
**Timeline:**
- Oct 10, 4:46 PM: Lucas: "We will fast track it this Monday"
- Oct 13: No payment received
- Oct 16, 2:46 PM: Bryan: "limited to four meetings...will not be validated"

**Legal Issue:** Detrimental reliance - you reasonably relied on payment promise

### 2. Account Deactivation = Response Prevention
**Evidence:**
- Oct 22: Termination notice sent to active email
- Oct 29: Your response bounces - "simon.renauld@digitalunicorn.fr is inactive"
- **Legal Issue:** Company prevented contractual response by deactivating email

### 3. No Written Termination Until After Demand
**Timeline:**
- Oct 16, 3:04 PM: You demand written termination per Article 11
- Oct 22, 6:04 PM: First written termination notice sent (6 days later)
- **Legal Issue:** Contract remained active during gap period

### 4. Breach of Contract Accusation Without Evidence
**Evidence:**
- Oct 16, 2:58 PM: Bryan: "breach of contract...sharing your personal login"
- No specific evidence provided
- No prior warning or investigation process
- **Legal Issue:** Defamatory accusation used to justify non-payment

### 5. Client System Access Retention
**Evidence:**
- Oct 16: You report still listed in J&J Beacon and SUMMIT
- Oct 16: Contact ICON Graham Crawley for clarification
- **Legal Issue:** If terminated, why retain active client system access?

---

## Legal Admissibility Checklist

- [ ] All emails downloaded in original .eml format (preserves headers)
- [ ] PDF versions created showing full visual context
- [ ] Screenshots captured with timestamps and URLs visible
- [ ] Authentication headers extracted and verified (DKIM/SPF/DMARC)
- [ ] Message-IDs documented for third-party verification
- [ ] All attachments preserved with original filenames
- [ ] SHA-256 and MD5 hashes generated for each file
- [ ] Manifest created documenting collection methodology
- [ ] Chain of custody initiated with collection date/time
- [ ] Bounced email evidence preserved (proves account deactivation)

---

## Next Steps After Collection

1. **Archive email URLs** (if any web-accessible versions exist):
   ```bash
   python3 ../web_evidence_archiver.py \
     --url "https://mail.google.com/mail/u/0/#inbox/[thread-id]" \
     --case-name "DU-ICON-Contract-0925" \
     --screenshot
   ```

2. **Create chronological timeline document**:
   ```bash
   cat > payment_dispute_timeline.md << 'EOF'
   # Payment Dispute Timeline - Contract 0925/CONSULT/DU
   
   ## September 2025
   - Sept 1-30: Consultant work performed (80 hours)
   
   ## October 2025
   - **Oct 9**: Payment not received on standard pay date
   - **Oct 9, 5:36 PM**: Formal demand for payment sent
   - **Oct 9, 11:17 PM**: Bryan requests timesheet
   - **Oct 10, 9:35 AM**: September timesheet submitted (80 hours)
   - **Oct 10, 4:16 PM**: Mia confirms timesheet received, 3-5 days processing
   - **Oct 10, 4:46 PM**: Lucas: "We will fast track it this Monday"
   - **Oct 13**: No payment received
   - **Oct 13, 2:38 PM**: Follow-up requesting confirmation
   - **Oct 16, 1:29 PM**: Escalation to ICON (Graham Crawley)
   - **Oct 16, 2:46 PM**: Bryan rejects timesheet, claims "four meetings only"
   - **Oct 16, 2:58 PM**: Bryan accuses breach of contract
   - **Oct 16, 3:04 PM**: Demand for written termination per Article 11
   - **Oct 16, 5:11 PM**: Report unauthorized account access
   - **Oct 20, 11:14 AM**: Bryan redirects to HR
   - **Oct 22, 6:04 PM**: First written termination notice sent
   - **Oct 29, 3:18 PM**: Response attempt
   - **Oct 29, 3:19 PM**: Response bounces - email account inactive
   EOF
   ```

3. **Calculate damages**:
   - September 2025: 80 hours × hourly rate = $______
   - Article 11 notice period: 15 days × daily rate = $______
   - Total contractually due: $______

4. **Identify contract violations**:
   - Article 3: Payment terms breach
   - Article 11: Termination notice requirements breach
   - Access to communications breach (email deactivation)

---

## Important Notes

**Gmail Retention:**
- Gmail preserves emails indefinitely unless manually deleted
- However, courts may issue preservation orders
- Download NOW before any potential account issues

**Email Headers = Digital Fingerprint:**
- Message-ID is globally unique and verifiable with email servers
- DKIM signatures cryptographically prove email authenticity
- Received headers show complete delivery path with multiple timestamp witnesses

**Bounced Email = Critical Evidence:**
- Oct 29 bounce proves company prevented your response
- "Email account inactive" shows deliberate access termination
- Creates chain of custody issue for company's termination notice

**Multiple Evidence Formats:**
- .eml = technical/server evidence (admissible for authentication)
- PDF = visual evidence (admissible for content/context)
- Screenshots = visual + timestamp evidence (admissible for state-at-time)
- Use all three formats for maximum credibility

---

## Contact Information from Emails

**Digital Unicorn Personnel:**
- Mia (Phuong Phung): hi@digitalunicorn.fr, +84 899 211 895
- Lucas Kacem (Founder): lucas@digitalunicorn.fr, +33 7 55 54 07 42
- Bryan Truong: hatruong@digitalunicorn.fr
- Panos Petropoulos: [email in thread]
- Clara Vigne: [email in thread]
- Simon Renauld (your DU email): simon.renauld@digitalunicorn.fr (INACTIVE as of Oct 29)

**ICON PLC:**
- Graham Crawley: [email in thread]

**Your Contact:**
- sn.renauld@gmail.com
- +84 923 180 061

---

**Collection Date:** _______________  
**Collected By:** Simon Renauld  
**Witness (if applicable):** _______________  
**Storage Location:** `/home/simon/Learning-Management-System-Academy/legal-matters/digital-unicorn-icon-plc/evidence_onedrive_20251105_014221/emails/`
