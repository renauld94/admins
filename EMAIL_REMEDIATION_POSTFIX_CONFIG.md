# Email Remediation: Postfix TLS & Submission Port Configuration

**Date:** November 8, 2025  
**Goal:** Enable TLS certificate on SMTP and configure submission port 587  
**Mail Server:** 136.243.155.166 (mail.simondatalab.de)  
**OS:** Debian (with Postfix)

---

## Summary of Postfix Changes Required

### Current State (from diagnostics)
- ✅ Port 25 (SMTP): Open and working
- ❌ Port 587 (Submission): Closed (connection refused)
- ❌ STARTTLS: No peer certificate presented

### Target State
- ✅ Port 25: Keep as-is (server-to-server delivery)
- ✅ Port 587: Enable with SASL auth for client submission
- ✅ STARTTLS: Present valid TLS certificate signed by Let's Encrypt

---

## Prerequisites

You need SSH access to the mail server:
```bash
ssh root@136.243.155.166 -p 2222
```

Or (if using jump host):
```bash
ssh -J root@136.243.155.166:2222 root@136.243.155.166
```

---

## Step 1: Obtain TLS Certificate

### Option A: Using Let's Encrypt (Recommended)

If Let's Encrypt is already installed:
```bash
sudo certbot certonly --standalone -d mail.simondatalab.de
```

If certbot is not installed:
```bash
sudo apt-get update && sudo apt-get install -y certbot
sudo certbot certonly --standalone -d mail.simondatalab.de
```

**Expected result:** Certificate at:
- `/etc/letsencrypt/live/mail.simondatalab.de/fullchain.pem`
- `/etc/letsencrypt/live/mail.simondatalab.de/privkey.pem`

### Option B: Using Self-Signed Certificate (Temporary Testing Only)

```bash
sudo openssl req -new -x509 -days 365 -nodes \
  -out /etc/ssl/certs/mail.simondatalab.de.crt \
  -keyout /etc/ssl/private/mail.simondatalab.de.key \
  -subj "/CN=mail.simondatalab.de/O=SimonDataLab/C=DE"

sudo chmod 600 /etc/ssl/private/mail.simondatalab.de.key
sudo chmod 644 /etc/ssl/certs/mail.simondatalab.de.crt
```

⚠️ **Note:** Self-signed certs are not trusted by external mail servers; use Let's Encrypt in production.

---

## Step 2: Configure Postfix for TLS

SSH into the mail server and edit Postfix main configuration:

```bash
sudo cp /etc/postfix/main.cf /etc/postfix/main.cf.backup-20251108
sudo nano /etc/postfix/main.cf
```

**Add or update these lines** (use Option A or B based on your certificate choice):

### If using Let's Encrypt (Option A):

```plaintext
# TLS Configuration (INCOMING)
smtpd_tls_cert_file = /etc/letsencrypt/live/mail.simondatalab.de/fullchain.pem
smtpd_tls_key_file = /etc/letsencrypt/live/mail.simondatalab.de/privkey.pem
smtpd_use_tls = yes
smtpd_tls_security_level = may
smtpd_tls_auth_only = no
smtpd_tls_session_cache_database = btree:/var/lib/postfix/smtpd_tls_session_cache
smtpd_tls_received_header = yes
smtpd_tls_loglevel = 1

# TLS Configuration (OUTGOING)
smtp_tls_security_level = may
smtp_tls_session_cache_database = btree:/var/lib/postfix/smtp_tls_session_cache
```

### If using self-signed (Option B):

```plaintext
smtpd_tls_cert_file = /etc/ssl/certs/mail.simondatalab.de.crt
smtpd_tls_key_file = /etc/ssl/private/mail.simondatalab.de.key
smtpd_use_tls = yes
smtpd_tls_security_level = may
smtpd_tls_auth_only = no
smtpd_tls_session_cache_database = btree:/var/lib/postfix/smtpd_tls_session_cache
smtpd_tls_received_header = yes
smtpd_tls_loglevel = 1

smtp_tls_security_level = may
smtp_tls_session_cache_database = btree:/var/lib/postfix/smtp_tls_session_cache
```

**Save and close** (nano: Ctrl+O, Enter, Ctrl+X)

---

## Step 3: Enable Submission Port 587

Edit Postfix master configuration:

```bash
sudo nano /etc/postfix/master.cf
```

**Find the line starting with `#submission inet`** (should be around line 13-15) and uncomment it:

**Before:**
```plaintext
#submission inet n       -       y       -       -       smtpd
```

**After:**
```plaintext
submission inet n       -       y       -       -       smtpd
  -o syslog_name=postfix/submission
  -o smtpd_tls_wrappermode=no
  -o smtpd_tls_security_level=encrypt
  -o smtpd_sasl_auth_enable=yes
  -o smtpd_sasl_type=dovecot
  -o smtpd_sasl_path=private/auth
  -o smtpd_client_restrictions=permit_sasl_authenticated,reject
  -o milter_macro_daemon_name=ORIGINATING
```

**Save and close**

---

## Step 4: Verify SASL Authentication Setup

Check if Dovecot auth is configured and working:

```bash
# Check if Dovecot is running
sudo systemctl status dovecot

# Check if auth socket exists
ls -la /var/spool/postfix/private/auth
```

If auth socket doesn't exist, configure Dovecot:

```bash
sudo nano /etc/dovecot/conf.d/10-master.conf
```

**Ensure this section exists:**

```plaintext
service auth {
  unix_listener auth-postfix {
    mode = 0666
    user = postfix
    group = postfix
  }
}
```

**Save and restart Dovecot:**

```bash
sudo systemctl restart dovecot
```

---

## Step 5: Reload Postfix

```bash
sudo postfix reload
```

**Or if reload fails:**

```bash
sudo systemctl restart postfix
```

---

## Step 6: Verify Configuration

Check if Postfix loaded correctly:

```bash
# Test syntax
sudo postfix check

# Should return: (empty or "warning:" lines are ok, no "error:" lines)

# Check if ports are listening
sudo netstat -tlnp | grep postfix
# or
sudo ss -tlnp | grep postfix

# Expected:
# tcp        0      0 0.0.0.0:25              0.0.0.0:*               LISTEN
# tcp        0      0 0.0.0.0:587             0.0.0.0:*               LISTEN
# tcp6       0      0 :::25                   :::*                    LISTEN
# tcp6       0      0 :::587                  :::*                    LISTEN
```

---

## Step 7: Test TLS and Submission

### Test STARTTLS on port 25:

```bash
openssl s_client -connect mail.simondatalab.de:25 -starttls smtp
# At prompt, type: QUIT
# Should see valid certificate info (CN=mail.simondatalab.de)
```

### Test submission port 587:

```bash
openssl s_client -connect mail.simondatalab.de:587 -starttls smtp
# At prompt, type: QUIT
# Should see valid certificate and list of AUTH mechanisms
```

### Full SMTP/AUTH test (with credentials):

```bash
# Generate base64 auth string (username:password)
echo -n "webmaster@simondatalab.de:PASSWORD" | base64

# Then connect:
telnet mail.simondatalab.de 587

# Type commands:
EHLO example.com
AUTH LOGIN <base64_string_from_above>
# Should respond: 235 2.7.0 Authentication successful

QUIT
```

---

## Step 8: Firewall (if applicable)

Ensure port 587 is open on your firewall:

```bash
# Check current rules
sudo iptables -L -n | grep 587

# If port 587 is not allowed, add rule:
sudo iptables -A INPUT -p tcp --dport 587 -j ACCEPT
sudo iptables-save > /etc/iptables/rules.v4

# Or with ufw:
sudo ufw allow 587/tcp
```

---

## Troubleshooting

### Certificate Not Found Error

**Error:** `postfix/master: fatal: parameter smtpd_tls_cert_file: /path/to/cert: No such file`

**Fix:** Ensure certificate path is correct and readable:

```bash
sudo ls -la /etc/letsencrypt/live/mail.simondatalab.de/
sudo postfix check
```

### Port 587 Not Listening

**Error:** netstat shows no port 587 listening

**Fix:** Ensure `submission inet` is uncommented in master.cf and reload:

```bash
sudo grep "^submission" /etc/postfix/master.cf
sudo postfix reload
sudo ss -tlnp | grep 587
```

### SASL Auth Fails

**Error:** `SASL authentication failed`

**Fix:** Verify Dovecot is running and auth socket exists:

```bash
sudo systemctl restart dovecot
sudo ls -la /var/spool/postfix/private/auth
sudo postfix reload
```

### TLS Negotiation Fails

**Error:** `TLS Handshake failure`

**Fix:** Check Postfix logs:

```bash
sudo tail -f /var/log/mail.log
# Send a test message, watch for TLS errors
```

---

## Verification Checklist

After changes:

- [ ] Postfix syntax check passed (no errors)
- [ ] Port 25 listening (netstat)
- [ ] Port 587 listening (netstat)
- [ ] STARTTLS connects on port 25
- [ ] STARTTLS connects on port 587
- [ ] Certificate is valid (CN=mail.simondatalab.de)
- [ ] AUTH LOGIN works with valid credentials
- [ ] Test email via port 25 sends successfully
- [ ] Test email via port 587 (authenticated) sends successfully

---

## Rollback (if needed)

If something breaks:

```bash
# Restore backup
sudo cp /etc/postfix/main.cf.backup-20251108 /etc/postfix/main.cf
sudo postfix reload

# Comment out submission in master.cf (restore original)
sudo sed -i 's/^submission inet/# submission inet/' /etc/postfix/master.cf
sudo postfix reload
```

---

## Next Steps

1. ✅ Apply DNS changes (SPF/DMARC cleanup)
2. ✅ Configure Postfix TLS and port 587 (this guide)
3. ⏳ Run post-remediation verification tests
4. ⏳ Send test emails and verify delivery

---

**Created:** November 8, 2025  
**Status:** Ready for implementation
