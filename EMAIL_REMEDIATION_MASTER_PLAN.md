# Email Remediation - Master Implementation Plan

**Date:** November 8, 2025  
**Domain:** simondatalab.de  
**Mail Host:** 136.243.155.166  
**Status:** Ready for Implementation  
**Priority:** HIGH (Email delivery currently failing due to duplicate DNS records)

---

## Overview

Your email system has critical issues preventing successful delivery (especially to Gmail). This plan addresses all issues in logical order.

**Key Problems Found:**
1. ⚠️ TWO SPF TXT records (should be 1) → Gmail bounces
2. ⚠️ TWO DMARC TXT records (should be 1) → Authentication confusion
3. ❌ No TLS certificate on SMTP → Submission port not available
4. ❌ Submission port 587 closed → Users cannot send via authenticated SMTP

---

## Implementation Timeline

| Phase | Task | Estimated Time | Status |
|-------|------|-----------------|--------|
| 1 | Fix DNS records (duplicate cleanup) | 5-15 min | ⏳ TO DO |
| 2 | Wait for DNS propagation | 5-10 min | ⏳ TO DO |
| 3 | Run Postfix automation script | 2-3 min | ⏳ TO DO |
| 4 | Verify changes (local tests) | 5 min | ⏳ TO DO |
| 5 | Send test emails | 5 min | ⏳ TO DO |
| 6 | Monitor maillog & verify delivery | 10 min | ⏳ TO DO |
| **TOTAL** | | **~40 minutes** | |

---

## Phase 1: DNS Record Cleanup (Hetzner Console)

### Task 1.1: Remove Duplicate SPF Records

**Location:** Hetzner Robot DNS Console → simondatalab.de → TXT Records

**Current State:**
```
SPF Record 1: v=spf1 ip4:136.243.155.166 a:mail.simondatalab.de ~all
SPF Record 2: v=spf1 a mx a:mail.simondatalab.de ip4:136.243.155.166 ~all
```

**Action:**
1. Delete BOTH SPF records
2. Add a single new SPF record:
   - Name: `@`
   - Type: `TXT`
   - Value: `v=spf1 ip4:136.243.155.166 a:mail.simondatalab.de ~all`
   - TTL: `3600` (default)

**Why this SPF record:**
- `ip4:136.243.155.166` — Allows mail from server IP
- `a:mail.simondatalab.de` — Allows MX host A record
- `~all` — Soft fail (not hard reject)

---

### Task 1.2: Remove Duplicate DMARC Records

**Location:** Hetzner Robot DNS Console → simondatalab.de → TXT Records

**Current State:**
```
DMARC Record 1: v=DMARC1; p=none; rua=mailto:dmarc@simondatalab.de; ...
DMARC Record 2: v=DMARC1; p=none; rua=mailto:webmaster@simondatalab.de
```

**Action:**
1. Delete BOTH DMARC records
2. Add a single new DMARC record:
   - Name: `_dmarc`
   - Type: `TXT`
   - Value: `v=DMARC1; p=none; rua=mailto:webmaster@simondatalab.de; ruf=mailto:webmaster@simondatalab.de; fo=1; adkim=s; aspf=s; pct=100`
   - TTL: `3600` (default)

**Why this DMARC record:**
- `p=none` — Monitor only (don't reject/quarantine yet)
- `rua=mailto:webmaster@simondatalab.de` — Send aggregate reports here
- `ruf=mailto:webmaster@simondatalab.de` — Send forensic reports here
- `fo=1; adkim=s; aspf=s; pct=100` — Report on all failures, strict alignment

**After you feel confident**, you can upgrade to:
```
v=DMARC1; p=quarantine; rua=mailto:webmaster@simondatalab.de; ...
```

---

### Verification (after DNS changes)

**Wait 5-10 minutes**, then verify in terminal:

```bash
# Should return ONLY ONE SPF record
dig +short TXT simondatalab.de | grep "v=spf1"

# Should return ONLY ONE DMARC record
dig +short TXT _dmarc.simondatalab.de
```

❌ If you still see TWO records, the DNS change did not propagate. Wait another 5 minutes.  
✓ If you see ONE record for each, proceed to Phase 2.

---

## Phase 2: Postfix Configuration (Automation)

### Task 2.1: Run Automation Script (Recommended)

The easiest way to apply Postfix changes is to run the automation script:

```bash
# Step 1: Copy script to mail server
scp email_remediation.sh root@136.243.155.166:/tmp/

# Step 2: SSH to mail server
ssh root@136.243.155.166 -p 2222

# Step 3: Run script
sudo bash /tmp/email_remediation.sh
```

**What the script does:**
1. Checks prerequisites (Postfix, certbot)
2. Obtains/verifies TLS certificate from Let's Encrypt
3. Backs up Postfix config files
4. Updates main.cf with TLS settings
5. Enables submission port (587) in master.cf
6. Verifies Dovecot auth
7. Reloads Postfix
8. Runs basic verification tests
9. Prints success summary

**Expected output:**
```
========================================
Email Remediation Automation
...
>>> PART 7: Summary and Next Steps

✓ Postfix TLS and Submission Configuration Complete!

What was done:
  1. TLS certificate obtained/verified
  2. Postfix configured for STARTTLS on port 25
  3. Submission port 587 enabled with SASL auth
  4. Dovecot auth verified
  5. Postfix reloaded

NEXT STEPS:
1. FIX DNS RECORDS (Hetzner DNS Console) — done in Phase 1
2. WAIT FOR DNS PROPAGATION (5-10 minutes) — being done
3. TEST EMAIL DELIVERY
...
```

**If script fails:**
- Check SSH access to mail server
- Ensure you have root permissions
- See "Troubleshooting" section below

---

### Task 2.2: Manual Configuration (Alternative)

If you prefer to apply changes manually instead of running script:

**See guide:** `EMAIL_REMEDIATION_POSTFIX_CONFIG.md`

Contains step-by-step instructions for:
- Installing/obtaining TLS certificate
- Updating Postfix main.cf
- Updating Postfix master.cf
- Verifying configuration
- Troubleshooting

---

## Phase 3: Verification Tests (Local)

### Task 3.1: Verify DNS Changed

```bash
# Verify SPF (should be 1 line)
dig +short TXT simondatalab.de | grep "v=spf1"

# Verify DMARC (should be 1 line)
dig +short TXT _dmarc.simondatalab.de

# Verify DKIM (should be unchanged)
dig +short TXT default2509._domainkey.simondatalab.de

# Verify MX and PTR
dig +short MX simondatalab.de
dig +short -x 136.243.155.166
```

✓ All should show correct, non-duplicate records.

---

### Task 3.2: Verify Postfix Ports (from local machine)

```bash
# Test port 25
nc -vz mail.simondatalab.de 25

# Expected:
# Connection to mail.simondatalab.de 25 port [tcp/smtp] succeeded!

# Test port 587
nc -vz mail.simondatalab.de 587

# Expected:
# Connection to mail.simondatalab.de 587 port [tcp/submission] succeeded!
```

✓ Both should succeed.

---

### Task 3.3: Verify TLS Certificate

```bash
# Test STARTTLS on port 25
openssl s_client -connect mail.simondatalab.de:25 -starttls smtp
# Type: QUIT

# Test STARTTLS on port 587
openssl s_client -connect mail.simondatalab.de:587 -starttls smtp
# Type: QUIT
```

✓ Both should show valid certificate with `CN=mail.simondatalab.de`

---

## Phase 4: Email Delivery Tests

### Task 4.1: Send Test Email FROM simondatalab.de

**Goal:** Test outbound SMTP and DKIM signing

**Steps:**
1. Go to Hetzner Webmail
2. Log in as: webmaster@simondatalab.de
3. Send email to: your-personal-email@gmail.com
4. Subject: "Test DKIM - simondatalab.de"
5. Body: "Testing email delivery and DKIM signature"

**What to check:**
- Email should arrive in Gmail inbox (not spam)
- If in spam, check email headers for SPF/DKIM/DMARC status

**In Gmail, check headers:**
1. Open email
2. Click dropdown arrow → "Show original"
3. Search for "Authentication-Results"
4. Look for:
   - ✓ `spf=pass`
   - ✓ `dkim=pass`
   - ✓ `dmarc=pass`

---

### Task 4.2: Send Test Email TO simondatalab.de

**Goal:** Test inbound SMTP delivery

**Steps:**
1. From Gmail, send email to: webmaster@simondatalab.de
2. Subject: "Test Inbound - simondatalab.de"
3. Body: "Testing inbound delivery"

**What to check:**
1. Go to Hetzner Webmail
2. Log in as: webmaster@simondatalab.de
3. Email should appear in inbox within 5 seconds

**If bounce received:**
- Check bounce message for error code
- Common errors:
  - 550: User not found (create mailbox in Hetzner)
  - 554: SPF/DKIM/DMARC failure (verify DNS)
  - 451/452: Temporary error (try again later)

---

### Task 4.3: Check Maillog

On mail server:

```bash
ssh root@136.243.155.166 -p 2222
sudo tail -50 /var/log/mail.log
```

Look for:
- ✓ "DKIM-Signature field added" (outgoing emails)
- ✓ "message accepted" (inbound emails)
- ✗ "SPF fail" (check DNS)
- ✗ "Authentication failed" (check SASL)

---

## Phase 5: Monitoring

### Task 5.1: Check DMARC Reports

Starting 24 hours after DNS change, you'll receive DMARC reports at webmaster@simondatalab.de.

**Reports show:**
- SPF pass/fail rates
- DKIM pass/fail rates
- Which sources are sending (or failing to send)

Review these to identify any delivery issues.

---

### Task 5.2: Monitor Certificate Expiry

Let's Encrypt certificates expire after 90 days. Check expiry:

```bash
sudo openssl x509 -enddate -noout -in /etc/letsencrypt/live/mail.simondatalab.de/fullchain.pem
```

Automatic renewal should happen, but you can manually renew:

```bash
sudo certbot renew
sudo systemctl reload postfix
```

---

## Troubleshooting Quick Reference

| Issue | Cause | Fix |
|-------|-------|-----|
| DNS still shows duplicates | Propagation delay | Wait 15 min, try again |
| Port 587 closed | Submission not enabled | Run script or enable manually |
| TLS cert not presented | Path wrong or not readable | Check cert path, fix permissions |
| AUTH LOGIN fails | Wrong password or auth socket missing | Verify Dovecot running, check socket |
| Email bounces SPF fail | SPF record wrong | Check DNS, verify single SPF record |
| Email goes to spam | DMARC fail | Check DMARC record, align SPF/DKIM |
| Postfix won't reload | Config error | Run `postfix check` to see error |

---

## Files Provided

| File | Purpose |
|------|---------|
| `email_remediation.sh` | Automation script (recommended) |
| `EMAIL_REMEDIATION_DNS_GUIDE.md` | Step-by-step DNS edits |
| `EMAIL_REMEDIATION_POSTFIX_CONFIG.md` | Manual Postfix configuration |
| `EMAIL_REMEDIATION_VERIFICATION.md` | Detailed verification tests |
| `EMAIL_REMEDIATION_MASTER_IMPLEMENTATION_PLAN.md` | This file |

---

## Step-by-Step Execution

```
1. Apply DNS changes (Phase 1) — 10 minutes
   ↓
2. Wait for propagation — 5-10 minutes
   ↓
3. Run automation script (Phase 2) — 2-3 minutes
   ↓
4. Run local verification tests (Phase 3) — 5 minutes
   ↓
5. Send test emails (Phase 4) — 5 minutes
   ↓
6. Monitor and review (Phase 5) — ongoing
```

---

## Success Criteria

After completing all phases, you should have:

- ✓ Single SPF record in DNS
- ✓ Single DMARC record in DNS
- ✓ Port 25 open and responding with STARTTLS
- ✓ Port 587 open and responding with STARTTLS + AUTH
- ✓ Valid TLS certificate for mail.simondatalab.de
- ✓ Outbound emails arriving at external addresses
- ✓ Inbound emails arriving in Hetzner mailboxes
- ✓ DKIM signatures showing `pass` in email headers
- ✓ SPF showing `pass` in email headers
- ✓ DMARC showing `pass` in email headers

---

## Emergency Rollback

If something breaks, rollback Postfix changes:

```bash
ssh root@136.243.155.166 -p 2222

# Restore backup
sudo cp /etc/postfix/backups/main.cf.YYYYMMDD-HHMMSS /etc/postfix/main.cf
sudo cp /etc/postfix/backups/master.cf.YYYYMMDD-HHMMSS /etc/postfix/master.cf

# Reload
sudo postfix reload

# Verify
sudo postfix check
```

DNS changes can be rolled back by re-adding the original records to Hetzner console.

---

## Support & Questions

If you encounter issues:

1. Check the "Troubleshooting" section above
2. Review relevant guide file (DNS, Postfix, Verification)
3. Check mail server logs: `sudo tail -f /var/log/mail.log`
4. Re-run verification tests to identify exact failure point

---

## Next Steps

**Ready?** Start with Phase 1 (DNS cleanup in Hetzner console).

**Timeline:** ~40 minutes from start to verified working email.

**Expected Result:** Full email delivery to external providers (Gmail, Outlook, etc.) with DKIM/SPF/DMARC passing.

---

**Created:** November 8, 2025  
**Last Updated:** November 8, 2025  
**Status:** Ready for Implementation

---

## Quick Start Command

```bash
# If using automation script:
scp email_remediation.sh root@136.243.155.166:/tmp/ && \
  ssh root@136.243.155.166 -p 2222 "sudo bash /tmp/email_remediation.sh"

# Then follow Phase 1-5 in order
```
