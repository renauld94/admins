# Quick Reference: simondatalab.de Mail System

## ✅ System Status (Nov 8, 2025)

| Component | Status | Details |
|-----------|--------|---------|
| **DNS** | ✅ Active | SPF + DMARC single canonical records, verified globally |
| **TLS** | ✅ Active | Let's Encrypt cert (mail.simondatalab.de), expires Feb 6, 2026 |
| **Postfix** | ✅ Active | Port 25 (SMTP), Port 587 (Submission with SASL) |
| **OpenDKIM** | ✅ Active | Signing with selector `mail`, domain `simondatalab.de` |
| **Dovecot IMAP** | ✅ Active | Port 993 (IMAPS), authentication working |
| **Mailboxes** | ✅ Active | `webmaster@simondatalab.de`, `contact@simondatalab.de` |

---

## 📧 Mailbox Accounts

### 1. webmaster@simondatalab.de
- **Purpose:** Admin/system mailbox
- **Status:** ✅ Operational
- **Features:** Receives DMARC/DKIM reports, system alerts
- **Access:** IMAP on port 993 (if needed)

### 2. contact@simondatalab.de
- **Purpose:** Contact form / general inquiries
- **Status:** ✅ Operational
- **Forwarding:** Automatically forwards to `sn.renauld@gmail.com`
- **Local IMAP:** Available for backup/access
- **Credentials:** contact@simondatalab.de / Desjardins1###
- **Access:** IMAP on port 993, SMTP on port 587

---

## 🔐 Connection Details

### IMAP (Receive Mail)
```
Server:      mail.simondatalab.de
Port:        993
Protocol:    IMAPS (SSL/TLS)
Username:    contact@simondatalab.de (for contact mailbox)
Password:    Desjardins1###
```

### SMTP (Send Mail)
```
Server:      mail.simondatalab.de
Port:        587
Protocol:    SMTP with STARTTLS
Username:    contact@simondatalab.de
Password:    Desjardins1###
Auth:        SASL (required)
```

---

## 🔍 DNS Records (Verified)

**SPF:**
```
v=spf1 ip4:136.243.155.166 a:mail.simondatalab.de ~all
```

**DMARC:**
```
v=DMARC1; p=none; rua=mailto:webmaster@simondatalab.de
```

**DKIM Selector:**
```
mail._domainkey.simondatalab.de (Public key configured)
```

---

## ✉️ Email Authentication Results

**Test from:** webmaster@simondatalab.de  
**Received:** Gmail inbox, Nov 8, 2025

```
SPF:    ✅ PASS (IP 136.243.155.166 authorized)
DKIM:   ✅ PASS (Selector: mail, Domain: simondatalab.de)
DMARC:  ✅ PASS (Policy: none, aligned)
```

---

## 🛠️ Common Tasks

### Send Test Email
```bash
ssh -p 2222 root@136.243.155.166
echo "Test" | sendmail -f webmaster@simondatalab.de -v contact@simondatalab.de
```

### Check Mail Queue
```bash
ssh -p 2222 root@136.243.155.166 "postqueue -p"
```

### View Postfix Logs
```bash
ssh -p 2222 root@136.243.155.166 "journalctl -u postfix -n 50"
```

### Verify DKIM Signing
```bash
ssh -p 2222 root@136.243.155.166 "journalctl -u opendkim -n 50"
```

### Test IMAP Connection
```bash
openssl s_client -connect mail.simondatalab.de:993 -quiet
# Type: A001 LOGIN contact@simondatalab.de Desjardins1###
```

---

## 📋 Server Information

**Hostname:** mail.simondatalab.de  
**IP Address:** 136.243.155.166  
**SSH Port:** 2222  
**OS:** Debian 12.11  
**Mail System:** Postfix + Dovecot + OpenDKIM  

**Mail Directories:**
```
/var/mail/simondatalab.de/
├── webmaster/   (webmaster@simondatalab.de)
└── contact/     (contact@simondatalab.de)
```

**Configuration Files:**
```
/etc/postfix/main.cf            (Postfix main config)
/etc/postfix/master.cf          (Postfix service config)
/etc/postfix/virtual            (Email aliases)
/etc/dovecot/dovecot.conf       (Dovecot main config)
/etc/dovecot/virtual-users      (Dovecot password hashes)
/etc/opendkim/              (OpenDKIM configs)
```

---

## 🔐 Security Summary

| Aspect | Status |
|--------|--------|
| **TLS Encryption** | ✅ Let's Encrypt (trusted, auto-renews) |
| **Password Storage** | ✅ SHA512-CRYPT (secure hash, non-reversible) |
| **DKIM Signing** | ✅ All outbound emails signed |
| **SPF Policy** | ✅ Configured (v=spf1) |
| **DMARC Policy** | ✅ Configured (p=none for monitoring) |
| **SASL Auth** | ✅ Required on submission (port 587) |
| **Port Security** | ✅ 25 (SMTP), 587 (submission), 993 (IMAPS) open |

---

## ⚠️ Important Notes

1. **Forwarding:** Emails to `contact@simondatalab.de` are forwarded to Gmail BUT also stored locally for IMAP access.

2. **DMARC Policy:** Currently set to `p=none` (monitoring mode). Upgrade to `p=quarantine` after 48 hours of monitoring if desired.

3. **Certificate Renewal:** Let's Encrypt certificate auto-renews daily. No manual intervention needed.

4. **DMARC Reports:** Aggregate reports are sent to `webmaster@simondatalab.de` (arrive within 24-48 hours).

5. **Backup:** Regularly backup `/var/mail/simondatalab.de/` and `/etc/dovecot/virtual-users`.

---

## 📞 Support / Troubleshooting

**All emails failing?**
→ Check `journalctl -u postfix`

**Can't log in via IMAP?**
→ Verify credentials with `doveadm auth test contact@simondatalab.de <pwd>`

**Forwarding not working?**
→ Check `/etc/postfix/virtual` and run `postmap /etc/postfix/virtual`

**Certificate issues?**
→ Run `certbot status` on the server

**Emails in spam?**
→ Check Gmail Authentication-Results header (SPF/DKIM/DMARC results)

---

**Created:** November 8, 2025  
**System:** simondatalab.de Mail Infrastructure  
**All systems operational and verified. ✅**
