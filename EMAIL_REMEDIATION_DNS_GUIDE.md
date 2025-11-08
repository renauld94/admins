# Email Remediation: DNS Configuration Guide

**Date:** November 8, 2025  
**Goal:** Fix duplicate SPF/DMARC records and optimize email authentication  
**Affected Domain:** simondatalab.de

---

## Summary of DNS Changes Required

### Issues Found
1. ⚠️ **TWO SPF TXT records exist** (should be only ONE)
   - Record 1: `v=spf1 ip4:136.243.155.166 a:mail.simondatalab.de ~all`
   - Record 2: `v=spf1 a mx a:mail.simondatalab.de ip4:136.243.155.166 ~all`
   - **Impact:** SPF validation fails or behaves unpredictably; Gmail may reject mail.

2. ⚠️ **TWO DMARC TXT records exist** (should be only ONE)
   - Record 1: `v=DMARC1; p=none; rua=mailto:dmarc@simondatalab.de; ruf=mailto:dmarc@simondatalab.de; fo=1; adkim=s; aspf=s; pct=100`
   - Record 2: `v=DMARC1; p=none; rua=mailto:webmaster@simondatalab.de`
   - **Impact:** Receivers confused about policy; reporting errors.

3. ✅ **DKIM:** Correct (single record, selector `default2509`, key published)
4. ✅ **PTR:** Correct (136.243.155.166 → mail.simondatalab.de)
5. ✅ **MX:** Correct (mail.simondatalab.de)

---

## DNS Edits: Step-by-Step (Hetzner Console)

### Step 1: Remove Duplicate SPF Records

**Via Hetzner DNS Console:**

1. Log in to **Hetzner Robot** → **DNS** → **simondatalab.de**
2. Find the **TXT** record section
3. **DELETE** both existing SPF records (both lines starting with `v=spf1`)
4. **ADD** a single new SPF record:
   ```
   Name: @
   Type: TXT
   Value: v=spf1 ip4:136.243.155.166 a:mail.simondatalab.de ~all
   TTL: 3600 (or default)
   ```
   
   **Alternative (if you want to include MX explicitly):**
   ```
   Name: @
   Type: TXT
   Value: v=spf1 a mx ip4:136.243.155.166 ~all
   TTL: 3600
   ```

5. **Save changes**

---

### Step 2: Remove Duplicate DMARC Records

**Via Hetzner DNS Console:**

1. Go to **DNS** → **simondatalab.de** → **TXT records**
2. Find records starting with `_dmarc.simondatalab.de`
3. **DELETE** both existing DMARC records
4. **ADD** a single new DMARC record:
   ```
   Name: _dmarc
   Type: TXT
   Value: v=DMARC1; p=none; rua=mailto:webmaster@simondatalab.de; ruf=mailto:webmaster@simondatalab.de; fo=1; adkim=s; aspf=s; pct=100
   TTL: 3600 (or default)
   ```

5. **Save changes**

---

## Verification: Confirm DNS Changes

After making changes, **wait 5-10 minutes** for DNS propagation, then run these commands:

```bash
# Check SPF (should return only ONE record)
dig +short TXT simondatalab.de | grep "v=spf1"

# Expected output (single line):
# "v=spf1 ip4:136.243.155.166 a:mail.simondatalab.de ~all"

# Check DMARC (should return only ONE record)
dig +short TXT _dmarc.simondatalab.de

# Expected output (single line):
# "v=DMARC1; p=none; rua=mailto:webmaster@simondatalab.de; ..."

# Check DKIM selector (should remain unchanged)
dig +short TXT default2509._domainkey.simondatalab.de

# Check MX, PTR (should remain unchanged)
dig +short MX simondatalab.de
dig +short -x 136.243.155.166
```

---

## Alternative: Via Cloudflare (if you use Cloudflare DNS)

If your domain is registered with or delegated to **Cloudflare**:

1. Log in to **Cloudflare Dashboard** → **Websites** → **simondatalab.de**
2. Go to **DNS** → **Records**
3. Find and **DELETE** duplicate SPF TXT records
4. **ADD** single SPF record:
   - Type: TXT
   - Name: @ (or simondatalab.de)
   - Content: `v=spf1 ip4:136.243.155.166 a:mail.simondatalab.de ~all`
   - TTL: Auto (or 3600)
   - Proxy: DNS only (gray cloud icon)

5. Find and **DELETE** duplicate DMARC TXT records
6. **ADD** single DMARC record:
   - Type: TXT
   - Name: _dmarc
   - Content: `v=DMARC1; p=none; rua=mailto:webmaster@simondatalab.de; ruf=mailto:webmaster@simondatalab.de; fo=1; adkim=s; aspf=s; pct=100`
   - TTL: Auto (or 3600)
   - Proxy: DNS only (gray cloud icon)

7. **Save and wait 5-10 minutes** for propagation.

---

## Timeline & Expected Results

| Step | Action | Timing | Expected Outcome |
|------|--------|--------|------------------|
| 1 | Delete duplicate SPF/DMARC | Immediate | Records removed from DNS |
| 2 | Add single SPF/DMARC | Immediate | New records in DNS console |
| 3 | Wait for propagation | 5-10 min | dig shows single SPF/DMARC |
| 4 | Test mail delivery | After step 3 | Gmail, Outlook, etc. accept mail |

---

## Testing DNS Changes

After DNS updates and propagation, you can:

1. **Run SPF check:**
   ```bash
   dig +short TXT simondatalab.de
   ```

2. **Use MXToolbox SPF checker:**
   Visit: https://mxtoolbox.com/spf.aspx  
   Enter: simondatalab.de

3. **Send a test email** from another account to webmaster@simondatalab.de:
   - Should arrive without bounce (or with specific bounce if mailbox issue, not SPF)

4. **Check DMARC aggregation reports:**
   - After 24 hours, reports will start arriving at webmaster@simondatalab.de
   - These show DKIM/SPF pass/fail rates from external senders

---

## Notes

- **TTL:** Hetzner defaults are usually 3600 (1 hour). You can keep these.
- **Propagation:** Global DNS propagation can take 5-30 min depending on ISP and cached records.
- **Safe to change:** Removing duplicates is always safe; you're just consolidating into one correct record.
- **No downtime:** Email delivery continues even during DNS updates (MX and SMTP don't change).

---

## Next Steps

1. ✅ Apply DNS changes (SPF/DMARC cleanup)
2. ✅ Wait 5-10 min for propagation
3. ✅ Verify with dig (see Verification section above)
4. ⏳ Configure Postfix for TLS and submission port 587 (separate guide)
5. ⏳ Re-test mail delivery

---

**Created:** November 8, 2025  
**Status:** Ready for implementation
