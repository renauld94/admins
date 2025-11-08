# Email Remediation: Post-Implementation Verification & Testing

**Date:** November 8, 2025  
**Goal:** Verify that all email remediation changes are working correctly  
**Domain:** simondatalab.de  
**Mail Host:** 136.243.155.166 (mail.simondatalab.de)

---

## Phase 1: DNS Verification (after DNS records updated)

### 1.1 Verify SPF Record (Single Only)

```bash
dig +short TXT simondatalab.de | grep "v=spf1"
```

**Expected Output:**
```
"v=spf1 ip4:136.243.155.166 a:mail.simondatalab.de ~all"
```

⚠️ **CRITICAL:** Should be exactly ONE line. If you see TWO lines, the DNS change did not complete. Wait another 5 minutes and re-run.

---

### 1.2 Verify DMARC Record (Single Only)

```bash
dig +short TXT _dmarc.simondatalab.de
```

**Expected Output:**
```
"v=DMARC1; p=none; rua=mailto:webmaster@simondatalab.de; ..."
```

⚠️ **CRITICAL:** Should be exactly ONE line. If you see TWO lines, the DNS change did not complete.

---

### 1.3 Verify DKIM Record (should be unchanged)

```bash
dig +short TXT default2509._domainkey.simondatalab.de
```

**Expected Output:**
```
"v=DKIM1; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A..."
```

✓ Should be present and unchanged.

---

### 1.4 Verify MX and PTR Records

```bash
# MX record
dig +short MX simondatalab.de

# Expected:
# 10 mail.simondatalab.de.

# PTR record (reverse DNS)
dig +short -x 136.243.155.166

# Expected:
# mail.simondatalab.de.
```

✓ Both should be correct.

---

### 1.5 Use Online SPF/DMARC Checker (Optional)

Visit: https://mxtoolbox.com/  
- Enter: simondatalab.de
- Check "SPF Record" and "DMARC Record"
- Should show single, valid records

---

## Phase 2: Postfix Configuration Verification (on mail server)

### 2.1 Verify Postfix Syntax

SSH to mail server:

```bash
ssh root@136.243.155.166 -p 2222
# or
ssh -J root@136.243.155.166:2222 root@136.243.155.166

# Then run:
sudo postfix check
```

**Expected Output:**
```
(empty or warnings only, no errors)
```

---

### 2.2 Verify Listening Ports

```bash
sudo ss -tlnp | grep postfix
# or
sudo netstat -tlnp | grep postfix
```

**Expected Output:**
```
tcp        0      0 0.0.0.0:25              0.0.0.0:*               LISTEN      2048/master
tcp        0      0 0.0.0.0:587             0.0.0.0:*               LISTEN      2048/master
tcp6       0      0 :::25                   :::*                    LISTEN      2048/master
tcp6       0      0 :::587                  :::*                    LISTEN      2048/master
```

✓ Both ports 25 and 587 should be listening.

---

### 2.3 Verify TLS Certificate

```bash
# Check certificate file exists
sudo ls -la /etc/letsencrypt/live/mail.simondatalab.de/

# Or if using self-signed:
sudo ls -la /etc/ssl/certs/mail.simondatalab.de.crt
sudo ls -la /etc/ssl/private/mail.simondatalab.de.key
```

**Expected Output:**
```
-rw-r--r-- 1 root root .... fullchain.pem
-rw-r--r-- 1 root root .... privkey.pem
```

---

### 2.4 Verify TLS Configuration in Postfix

```bash
sudo grep "smtpd_tls" /etc/postfix/main.cf
```

**Expected Output:**
```
smtpd_tls_cert_file = /etc/letsencrypt/live/mail.simondatalab.de/fullchain.pem
smtpd_tls_key_file = /etc/letsencrypt/live/mail.simondatalab.de/privkey.pem
smtpd_use_tls = yes
smtpd_tls_security_level = may
...
```

---

### 2.5 Verify Submission Configuration

```bash
sudo grep -A 8 "^submission inet" /etc/postfix/master.cf
```

**Expected Output:**
```
submission inet n       -       y       -       -       smtpd
  -o syslog_name=postfix/submission
  -o smtpd_tls_wrappermode=no
  -o smtpd_tls_security_level=encrypt
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_sasl_type=dovecot
  -o smtpd_sasl_path=private/auth
  ...
```

---

### 2.6 Verify Dovecot Auth

```bash
sudo systemctl status dovecot
sudo ls -la /var/spool/postfix/private/auth
```

**Expected Output:**
```
Active: active (running)

srw-rw---- 1 dovecot postfix ... /var/spool/postfix/private/auth
```

✓ Both should show Dovecot is running and auth socket exists.

---

## Phase 3: Remote SMTP Connectivity Tests

### 3.1 Test Port 25 (SMTP)

From external machine or local:

```bash
# TCP connection test
nc -vz mail.simondatalab.de 25

# Expected:
# Connection to mail.simondatalab.de 25 port [tcp/smtp] succeeded!
```

---

### 3.2 Test STARTTLS on Port 25

```bash
openssl s_client -connect mail.simondatalab.de:25 -starttls smtp
```

At the OPENSSL prompt, type:

```
QUIT
```

**Expected Output:**
```
Trying...
Connected to mail.simondatalab.de
...
Verify return code: 0 (ok)
Subject: C = DE, O = SimonDataLab, CN = mail.simondatalab.de
Issuer: ...
-----BEGIN CERTIFICATE-----
...
-----END CERTIFICATE-----

250 2.0.0 Ok
221 2.0.0 Bye
```

✓ Should show valid certificate with CN=mail.simondatalab.de

---

### 3.3 Test Port 587 (Submission)

```bash
# TCP connection test
nc -vz mail.simondatalab.de 587

# Expected:
# Connection to mail.simondatalab.de 587 port [tcp/submission] succeeded!
```

---

### 3.4 Test STARTTLS on Port 587

```bash
openssl s_client -connect mail.simondatalab.de:587 -starttls smtp
```

At the OPENSSL prompt, type:

```
QUIT
```

**Expected Output:**
Same as port 25, but should also show AUTH capabilities:

```
250-AUTH LOGIN PLAIN CRAM-MD5
```

---

### 3.5 Full SMTP/AUTH Test

From local machine:

```bash
# 1. Create base64 encoded auth string
AUTH_STRING=$(echo -n "webmaster@simondatalab.de:PASSWORD" | base64)

# 2. Connect to submission port
telnet mail.simondatalab.de 587

# 3. Type these commands (one at a time):
EHLO localhost
STARTTLS
# Wait for "220" response
EHLO localhost
AUTH LOGIN $AUTH_STRING
# Should respond: 235 2.7.0 Authentication successful

MAIL FROM:<webmaster@simondatalab.de>
RCPT TO:<external@gmail.com>
DATA
Subject: Test

This is a test email from webmaster@simondatalab.de
.
QUIT
```

**Expected Responses:**
```
220 mail.simondatalab.de ESMTP Postfix (Debian/GNU)
250-mail.simondatalab.de
...
235 2.7.0 Authentication successful
250 2.1.0 Ok
250 2.1.5 Ok
354 End data with <CR><LF>.<CR><LF>
250 2.0.0 Ok: queued
221 2.0.0 Bye
```

✓ If all responses are 2xx codes, authentication and submission are working.

---

## Phase 4: Email Delivery Tests

### 4.1 Send Test Email FROM simondatalab.de

**What:** Send email from webmaster@simondatalab.de to external address  
**Why:** Test outbound SMTP and DKIM signing

**Steps:**
1. Log in to Hetzner Webmail for webmaster@simondatalab.de
2. Send email to: your-personal-email@gmail.com (or other external)
3. Subject: "Test from simondatalab.de - DKIM check"
4. Body: "Testing email delivery and DKIM signature"

**Verification:**
- Check if email arrives in Gmail inbox or spam
- If in spam, open the email in Gmail
- Click the dropdown arrow next to "Report phishing"
- Select "Show original"
- Look for `dkim=pass` in the authentication results

**Expected:**
```
spf=pass (google.com: domain of webmaster@simondatalab.de designates 136.243.155.166 as permitted sender) smtp.mailfrom=webmaster@simondatalab.de;
dkim=pass header.d=simondatalab.de header.s=default2509 header.b=...;
dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=simondatalab.de
```

✓ All three (SPF, DKIM, DMARC) should show `pass`.

---

### 4.2 Send Test Email TO simondatalab.de

**What:** Send email to webmaster@simondatalab.de from external (Gmail)  
**Why:** Test inbound SMTP and mailbox delivery

**Steps:**
1. From Gmail, send email to: webmaster@simondatalab.de
2. Subject: "Test to simondatalab.de"
3. Body: "Testing inbound delivery"

**Verification:**
1. Log in to Hetzner Webmail
2. Check webmaster@simondatalab.de inbox for the email
3. Should arrive within seconds

**If bounce received:**
- Check bounce message for error code (550, 554, etc.)
- Common errors:
  - 550: User not found (check mailbox exists in Hetzner)
  - 554: SPF/DKIM/DMARC failure (verify DNS records)
  - 451/452: Temporary error (try again in 5 minutes)

---

### 4.3 Check Maillog for Errors

On mail server:

```bash
sudo tail -100 /var/log/mail.log | grep -i "dkim\|spf\|dmarc\|authentication\|submission"
```

**Look for:**
- ✓ "DKIM-Signature field added" (outgoing)
- ✓ "Authentication successful" (submission)
- ✗ "SPF fail" or "DKIM fail" (DNS issues)
- ✗ "Authentication failed" (SASL issue)

---

## Phase 5: Monitoring & Long-term Checks

### 5.1 Certificate Expiry

Check certificate expiration date:

```bash
sudo openssl x509 -enddate -noout -in /etc/letsencrypt/live/mail.simondatalab.de/fullchain.pem

# Expected:
# notAfter=Nov  7 14:23:45 2026 GMT
```

⚠️ If expiring within 30 days, renew:

```bash
sudo certbot renew --dry-run  # Test renewal
sudo certbot renew            # Perform renewal
sudo systemctl reload postfix # Reload with new cert
```

---

### 5.2 Monitor DMARC Reports

DMARC aggregate reports will arrive at webmaster@simondatalab.de daily/weekly.

Example report names:
```
dmarc-report@...
aggregate report@...
```

**What to look for:**
- High SPF pass rate
- High DKIM pass rate
- Low DMARC fail rate
- Identify sources of failures (if any)

---

### 5.3 Regular Email Tests

**Weekly:**
- Send test email from simondatalab.de to external account
- Send test email to simondatalab.de from external account
- Verify both arrive and show authentication headers passing

**Monthly:**
- Review maillog for errors
- Check certificate expiry
- Test submission port (587) with client app

---

## Troubleshooting Common Issues

### Issue: SPF/DMARC Still Show Duplicates

**Cause:** DNS cache not yet cleared  
**Fix:** Wait 15+ minutes, then:

```bash
# Flush local DNS cache (Linux)
sudo systemctl restart systemd-resolved

# Then retry:
dig +short TXT simondatalab.de
```

---

### Issue: TLS Certificate Not Presented

**Error:** `openssl s_client` shows "no peer certificate available"  
**Cause:** Certificate path wrong or file not readable  
**Fix:**

```bash
# Check certificate exists and is readable
sudo ls -la /etc/letsencrypt/live/mail.simondatalab.de/
sudo openssl x509 -text -noout -in /path/to/cert.pem

# Check Postfix can read it
sudo -u postfix cat /etc/letsencrypt/live/mail.simondatalab.de/fullchain.pem > /dev/null

# Reload Postfix
sudo postfix reload
```

---

### Issue: Port 587 Not Accepting Connections

**Cause:** Submission not enabled or firewall blocking  
**Fix:**

```bash
# Check submission is uncommented
grep "^submission inet" /etc/postfix/master.cf

# If not found, enable:
sudo sed -i 's/^#submission inet/submission inet/' /etc/postfix/master.cf
sudo postfix reload

# Check firewall
sudo ufw status
sudo ufw allow 587/tcp
```

---

### Issue: AUTH LOGIN Fails

**Error:** `535 5.7.8 Error: authentication failed`  
**Cause:** Wrong password or Dovecot auth socket not working  
**Fix:**

```bash
# Verify Dovecot is running
sudo systemctl status dovecot

# Check auth socket
sudo ls -la /var/spool/postfix/private/auth

# Check mailbox exists in Dovecot
sudo doveadm user webmaster@simondatalab.de

# If mailbox not found, check Dovecot config:
sudo nano /etc/dovecot/conf.d/10-auth.conf
```

---

### Issue: Emails Bouncing with SPF Fail

**Error:** "550 5.7.23 SPF fail"  
**Cause:** SPF record missing or incorrect  
**Fix:**

```bash
# Check SPF record
dig +short TXT simondatalab.de | grep spf1

# Should include: ip4:136.243.155.166

# If missing, add to DNS console:
# Value: v=spf1 ip4:136.243.155.166 a:mail.simondatalab.de ~all
```

---

## Success Checklist

After implementing all changes, verify:

- [ ] SPF record: Single, correct record in DNS
- [ ] DMARC record: Single, correct record in DNS
- [ ] DKIM record: Present and unchanged
- [ ] MX record: Points to mail.simondatalab.de
- [ ] PTR record: 136.243.155.166 → mail.simondatalab.de
- [ ] Postfix port 25: Listening and responding
- [ ] Postfix port 587: Listening and responding
- [ ] TLS certificate: Valid, correctly configured
- [ ] STARTTLS: Working on both ports
- [ ] AUTH LOGIN: Working with valid credentials
- [ ] Outbound email: Arrives at external addresses
- [ ] Inbound email: Arrives in Hetzner mailboxes
- [ ] DKIM signature: Shows `dkim=pass` in email headers
- [ ] SPF: Shows `spf=pass` in email headers
- [ ] DMARC: Shows `dmarc=pass` in email headers
- [ ] Maillog: No critical errors

---

## Emergency Rollback

If something breaks:

```bash
# Restore Postfix config from backup
sudo cp /etc/postfix/backups/main.cf.20251108-HHMMSS /etc/postfix/main.cf
sudo cp /etc/postfix/backups/master.cf.20251108-HHMMSS /etc/postfix/master.cf

# Reload Postfix
sudo postfix reload

# Verify syntax
sudo postfix check

# Restart if needed
sudo systemctl restart postfix
```

---

**Next:** Run test suite from Phase 1-4 and report results.  
**Created:** November 8, 2025
