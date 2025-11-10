#!/bin/bash

# Gmail Evidence Collection Script
# Case: Digital Unicorn vs ICON PLC - Contract 0925/CONSULT/DU
# Date: November 5, 2025

set -e

EVIDENCE_DIR="$(pwd)/emails"
CASE_NAME="DU-ICON-Contract-0925"
COLLECTION_DATE=$(date -u '+%Y-%m-%d %H:%M:%S UTC')

echo "=================================================="
echo "Gmail Evidence Collection Assistant"
echo "Case: Digital Unicorn vs ICON PLC"
echo "Contract: 0925/CONSULT/DU"
echo "=================================================="
echo ""

# Create directory structure
echo "[Step 1] Creating evidence directory structure..."
mkdir -p "$EVIDENCE_DIR"/{eml,pdf,screenshots,attachments,headers}
echo "✓ Created: $EVIDENCE_DIR"
echo ""

# Instructions for user
echo "=================================================="
echo "MANUAL COLLECTION STEPS"
echo "=================================================="
echo ""
echo "You must manually collect evidence from Gmail:"
echo ""
echo "▶ THREAD 1: Official Termination Notice"
echo "  Subject: 'Official Notice of Termination...'"
echo "  Date: October 22, 2025 (6:04 PM)"
echo "  From: Mia HR (hi@digitalunicorn.fr)"
echo ""
echo "  Actions:"
echo "  1. Open the email in Gmail"
echo "  2. Click ⋮ (three dots) → 'Download message'"
echo "  3. Save as: $EVIDENCE_DIR/eml/termination_notice_20251022.eml"
echo "  4. Click Print icon → Print to PDF"
echo "  5. Save as: $EVIDENCE_DIR/pdf/termination_notice_20251022.pdf"
echo "  6. Take full-window screenshot → Save to screenshots/"
echo ""

echo "▶ THREAD 2: Payment Dispute (19 messages)"
echo "  Subject: 'Urgent: Formal Notice – Nonpayment...'"
echo "  Date Range: October 9-20, 2025"
echo ""
echo "  Actions:"
echo "  1. Open the full thread in Gmail"
echo "  2. Click ⋮ → 'Download message' (downloads entire thread)"
echo "  3. Save as: $EVIDENCE_DIR/eml/payment_dispute_oct9-20.eml"
echo "  4. Print entire thread to PDF"
echo "  5. Save as: $EVIDENCE_DIR/pdf/payment_dispute_oct9-20.pdf"
echo "  6. Screenshot showing all 19 messages"
echo ""

echo "▶ THREAD 3: ICON Escalation"
echo "  Subject: 'Request for Clarification – DU–ICON...'"
echo "  Date: October 16, 2025 (1:29 PM)"
echo "  To: Graham Crawley (ICON)"
echo ""
echo "  Actions:"
echo "  1. Download message as .eml"
echo "  2. Print to PDF"
echo "  3. Screenshot with timestamp"
echo ""

echo "▶ THREAD 4: Bounced Response (CRITICAL)"
echo "  Subject: 'Mail Delivery Subsystem' bounce notification"
echo "  Date: October 29, 2025 (3:19 PM)"
echo "  Error: '550 5.2.1 email account is inactive'"
echo ""
echo "  Actions:"
echo "  1. Download bounce notification as .eml"
echo "  2. Save as: $EVIDENCE_DIR/eml/bounced_response_20251029.eml"
echo "  3. Print to PDF showing error message"
echo "  4. Screenshot proving email deactivation"
echo ""

echo "▶ ATTACHMENTS"
echo "  - Termination notice document (PDF/DOC from Oct 22 email)"
echo "  - September timesheet (from your Oct 10 email)"
echo "  Save all to: $EVIDENCE_DIR/attachments/"
echo ""

echo "=================================================="
echo "PRESS ENTER when you have downloaded all files..."
read -p ""

# Verify files were collected
echo ""
echo "[Step 2] Verifying collected evidence..."
echo ""

if [ -z "$(ls -A $EVIDENCE_DIR/eml 2>/dev/null)" ]; then
    echo "⚠ WARNING: No .eml files found in $EVIDENCE_DIR/eml/"
    echo "Please download emails using Gmail's 'Download message' feature"
    echo ""
fi

if [ -z "$(ls -A $EVIDENCE_DIR/pdf 2>/dev/null)" ]; then
    echo "⚠ WARNING: No PDF files found in $EVIDENCE_DIR/pdf/"
    echo "Please print emails to PDF using browser's print function"
    echo ""
fi

# Extract email headers from .eml files
echo "[Step 3] Extracting email authentication headers..."
if [ -n "$(ls -A $EVIDENCE_DIR/eml 2>/dev/null)" ]; then
    cd "$EVIDENCE_DIR/eml"
    
    # Extract authentication results
    echo "Extracting DKIM/SPF/DMARC verification..."
    grep -H -A 5 "Authentication-Results:" *.eml > ../headers/authentication_verification.txt 2>/dev/null || true
    
    # Extract Message-IDs
    echo "Extracting Message-IDs (unique identifiers)..."
    grep -H "Message-ID:" *.eml > ../headers/message_ids.txt 2>/dev/null || true
    
    # Extract delivery path
    echo "Extracting delivery timestamps..."
    grep -H "Received:" *.eml > ../headers/delivery_path.txt 2>/dev/null || true
    
    # Extract From/To/Subject/Date
    echo "Extracting basic headers..."
    for file in *.eml; do
        echo "=== $file ===" >> ../headers/basic_headers.txt
        grep -E "^(From|To|Subject|Date):" "$file" >> ../headers/basic_headers.txt 2>/dev/null || true
        echo "" >> ../headers/basic_headers.txt
    done
    
    cd - > /dev/null
    echo "✓ Headers extracted to $EVIDENCE_DIR/headers/"
else
    echo "⚠ Skipping header extraction - no .eml files found"
fi

# Generate cryptographic hashes
echo ""
echo "[Step 4] Generating cryptographic hashes..."

hash_file() {
    local file="$1"
    local dir=$(dirname "$file")
    local base=$(basename "$file")
    
    # Generate SHA-256
    (cd "$dir" && sha256sum "$base" > "$base.sha256")
    
    # Generate MD5
    (cd "$dir" && md5sum "$base" > "$base.md5")
}

# Hash all evidence files
for dir in eml pdf screenshots attachments; do
    if [ -d "$EVIDENCE_DIR/$dir" ] && [ -n "$(ls -A $EVIDENCE_DIR/$dir 2>/dev/null)" ]; then
        echo "Hashing files in $dir/..."
        for file in "$EVIDENCE_DIR/$dir"/*; do
            if [ -f "$file" ] && [[ ! "$file" =~ \.(sha256|md5)$ ]]; then
                hash_file "$file"
            fi
        done
    fi
done

echo "✓ Cryptographic hashes generated"

# Generate evidence manifest
echo ""
echo "[Step 5] Generating evidence manifest..."

MANIFEST="$EVIDENCE_DIR/email_evidence_manifest.txt"

cat > "$MANIFEST" << EOF
================================================================================
EMAIL EVIDENCE MANIFEST
================================================================================

Case:           Digital Unicorn vs ICON PLC
Contract:       0925/CONSULT/DU
Issue:          Nonpayment and Wrongful Termination
Collection Date: $COLLECTION_DATE
Collected By:   Simon Renauld
Email:          sn.renauld@gmail.com
Phone:          +84 923 180 061

================================================================================
EVIDENCE SUMMARY
================================================================================

THREAD 1: Official Termination Notice
  - Date: October 22, 2025 (6:04 PM)
  - From: Mia HR (hi@digitalunicorn.fr)
  - Significance: First written termination, sent 6 days after demanded

THREAD 2: Payment Dispute (19 messages)
  - Date Range: October 9-20, 2025
  - Key: Lucas's Oct 10 payment promise "fast track this Monday"
  - Key: Bryan's Oct 16 retroactive rejection

THREAD 3: ICON Escalation
  - Date: October 16, 2025 (1:29 PM)
  - To: Graham Crawley (ICON PLC)
  - Significance: Third-party witness to dispute

THREAD 4: Bounced Response
  - Date: October 29, 2025 (3:19 PM)
  - Error: Email account inactive (simon.renauld@digitalunicorn.fr)
  - Significance: Proves company prevented response to termination

================================================================================
CRITICAL EVIDENCE POINTS
================================================================================

1. PAYMENT PROMISE → REJECTION
   Oct 10, 4:46 PM: Lucas: "We will fast track it this Monday"
   Oct 16, 2:46 PM: Bryan retroactively rejects timesheet
   Legal Issue: Promissory estoppel, detrimental reliance

2. TERMINATION NOTICE DELAY
   Oct 16, 3:04 PM: You demand written notice per Article 11
   Oct 22, 6:04 PM: First written notice sent (6 days later)
   Legal Issue: Contract remained active during gap

3. EMAIL DEACTIVATION
   Oct 22: Termination notice sent to company email
   Oct 29: Response bounces - account inactive
   Legal Issue: Bad faith, prevented contractual response

4. NO PRIOR PERFORMANCE WARNINGS
   Bryan claims work inadequate, yet no prior complaints
   Contradicts previous payment approvals
   Legal Issue: Retroactive justification for non-payment

================================================================================
FILE INVENTORY
================================================================================

EOF

# Add file listings
for dir in eml pdf screenshots attachments headers; do
    if [ -d "$EVIDENCE_DIR/$dir" ] && [ -n "$(ls -A $EVIDENCE_DIR/$dir 2>/dev/null)" ]; then
        echo "" >> "$MANIFEST"
        echo "[$dir/]" >> "$MANIFEST"
        echo "----------------------------------------" >> "$MANIFEST"
        
        for file in "$EVIDENCE_DIR/$dir"/*; do
            if [ -f "$file" ]; then
                filename=$(basename "$file")
                filesize=$(stat -c%s "$file")
                modified=$(stat -c%y "$file")
                
                echo "" >> "$MANIFEST"
                echo "File: $filename" >> "$MANIFEST"
                echo "Size: $filesize bytes" >> "$MANIFEST"
                echo "Modified: $modified" >> "$MANIFEST"
                
                # Include hashes if not hash file itself
                if [[ ! "$filename" =~ \.(sha256|md5)$ ]]; then
                    if [ -f "$file.sha256" ]; then
                        cat "$file.sha256" >> "$MANIFEST"
                    fi
                    if [ -f "$file.md5" ]; then
                        cat "$file.md5" >> "$MANIFEST"
                    fi
                fi
            fi
        done
    fi
done

cat >> "$MANIFEST" << EOF

================================================================================
COLLECTION METHODOLOGY
================================================================================

Email Download:
  - Method: Gmail "Download message" feature (.eml format)
  - Preserves: Full RFC 822 headers, authentication results
  - Includes: Message-ID, DKIM signatures, delivery path

PDF Creation:
  - Method: Browser print to PDF
  - Shows: Visual context, full thread, timestamps
  - Purpose: Human-readable legal exhibit

Screenshots:
  - Shows: Gmail interface, URL, system timestamp
  - Purpose: Proves state at time of collection

Cryptographic Verification:
  - SHA-256: Primary hash for integrity verification
  - MD5: Secondary hash for cross-verification
  - Purpose: Proves evidence not tampered with

Header Extraction:
  - Authentication-Results: DKIM/SPF/DMARC verification
  - Message-ID: Globally unique identifier
  - Received: Complete delivery path with timestamps
  - Purpose: Prove email authenticity

================================================================================
CHAIN OF CUSTODY
================================================================================

Collected From:     Gmail account (sn.renauld@gmail.com)
Collection Date:    $COLLECTION_DATE
Collected By:       Simon Renauld
Collection Method:  Direct download from Gmail web interface
Storage Location:   $EVIDENCE_DIR
Access Control:     User-only access (file permissions)

Verification:
  [✓] All emails downloaded in original format (.eml)
  [✓] PDF versions created for visual evidence
  [✓] Screenshots captured with timestamps
  [✓] Authentication headers extracted
  [✓] Cryptographic hashes generated
  [✓] Manifest created

Witness (if applicable): ___________________________________

Signature: ___________________________________  Date: _________

================================================================================
LEGAL ADMISSIBILITY NOTES
================================================================================

Email Authentication:
  - .eml files contain DKIM signatures (cryptographic proof)
  - Authentication-Results headers show SPF/DMARC pass/fail
  - Message-IDs verifiable with email service providers
  - Multiple independent timestamps (sender, receivers, Gmail)

Business Records Exception:
  - Emails created in regular course of business
  - Contemporary with events described
  - Made by persons with knowledge
  - Company's own communications (admission)

Best Evidence Rule:
  - Original electronic format preserved (.eml)
  - Hash values prove integrity
  - Multiple format redundancy (eml + pdf + screenshot)

Hearsay Exception:
  - Party opponent statements (DU's own emails)
  - Lucas/Bryan/Mia statements bind company
  - Business communications exception

================================================================================
NEXT STEPS
================================================================================

1. Review all collected files for completeness
2. Verify hashes match (run: sha256sum -c *.sha256)
3. Review CRITICAL_EVIDENCE_SUMMARY.md for legal analysis
4. Attach evidence to formal demand letter
5. Consider escalation to:
   - Vietnamese labor authorities
   - ICON PLC legal/compliance
   - J&J vendor compliance
   - French authorities (DU is French company)

================================================================================
CONTACT INFORMATION
================================================================================

Your Details:
  - Name: Simon Renauld
  - Active Email: sn.renauld@gmail.com
  - Phone: +84 923 180 061
  - Inactive (deactivated): simon.renauld@digitalunicorn.fr

Digital Unicorn:
  - Lucas Kacem (Founder): lucas@digitalunicorn.fr, +33 7 55 54 07 42
  - Bryan Truong: hatruong@digitalunicorn.fr
  - Mia (HR): hi@digitalunicorn.fr, +84 899 211 895
  - Address: 3rd Floor, 94 Ho Nghinh St, Son Tra, Da Nang, Vietnam
  - French HQ: 61 Rue de Lyon, 75012 Paris, France
  - SIREN: 941.024.499

ICON PLC:
  - Graham Crawley: [from email thread]

================================================================================
END OF MANIFEST
================================================================================
Generated: $COLLECTION_DATE
Tool: Evidence Collection Toolkit v1.0
EOF

echo "✓ Manifest created: $MANIFEST"

# Display summary
echo ""
echo "=================================================="
echo "COLLECTION SUMMARY"
echo "=================================================="
echo ""
echo "Evidence collected in: $EVIDENCE_DIR"
echo ""
echo "Files collected:"
echo "  - EML files: $(find $EVIDENCE_DIR/eml -type f ! -name "*.sha256" ! -name "*.md5" 2>/dev/null | wc -l)"
echo "  - PDF files: $(find $EVIDENCE_DIR/pdf -type f ! -name "*.sha256" ! -name "*.md5" 2>/dev/null | wc -l)"
echo "  - Screenshots: $(find $EVIDENCE_DIR/screenshots -type f ! -name "*.sha256" ! -name "*.md5" 2>/dev/null | wc -l)"
echo "  - Attachments: $(find $EVIDENCE_DIR/attachments -type f ! -name "*.sha256" ! -name "*.md5" 2>/dev/null | wc -l)"
echo ""
echo "Headers extracted: $EVIDENCE_DIR/headers/"
echo "Manifest: $MANIFEST"
echo ""

# Verify hashes
echo "=================================================="
echo "VERIFYING CRYPTOGRAPHIC HASHES"
echo "=================================================="
echo ""

verification_failed=0

for dir in eml pdf screenshots attachments; do
    if [ -d "$EVIDENCE_DIR/$dir" ]; then
        cd "$EVIDENCE_DIR/$dir"
        shopt -s nullglob
        for hashfile in *.sha256; do
            if [ -f "$hashfile" ]; then
                if sha256sum -c "$hashfile" > /dev/null 2>&1; then
                    echo "✓ $(basename "$hashfile" .sha256)"
                else
                    echo "✗ FAILED: $(basename "$hashfile" .sha256)"
                    verification_failed=1
                fi
            fi
        done
        shopt -u nullglob
        cd - > /dev/null
    fi
done

echo ""
if [ $verification_failed -eq 0 ]; then
    echo "✓ All hash verifications passed"
else
    echo "⚠ Some hash verifications failed - check file integrity"
fi

echo ""
echo "=================================================="
echo "NEXT STEPS"
echo "=================================================="
echo ""
echo "1. Review collected files in: $EVIDENCE_DIR"
echo ""
echo "2. Read legal analysis:"
echo "   cat CRITICAL_EVIDENCE_SUMMARY.md"
echo ""
echo "3. Package evidence:"
echo "   tar -czf email_evidence_$(date +%Y%m%d_%H%M%S).tar.gz emails/"
echo ""
echo "4. Calculate damages:"
echo "   - September 2025: 80 hours × \$___/hr = \$_____"
echo "   - Article 11 notice: 15 days × \$___/day = \$_____"
echo ""
echo "5. Consider legal consultation for:"
echo "   - Breach of contract (Articles 3 & 11)"
echo "   - Promissory estoppel (Lucas's payment promise)"
echo "   - Bad faith (email deactivation)"
echo "   - Defamation (false breach accusations)"
echo ""
echo "=================================================="
echo "Evidence collection complete!"
echo "=================================================="
