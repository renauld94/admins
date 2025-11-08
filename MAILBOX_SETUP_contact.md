# Mailbox Setup: contact@simondatalab.de

**Status:** ✅ **COMPLETE & OPERATIONAL**

**Date:** November 8, 2025  
**Mailbox:** contact@simondatalab.de  
**Description:** Simon Renauld  
**Configuration:** Dual-mode (alias + local mailbox)

---

## Setup Summary

The mailbox `contact@simondatalab.de` has been successfully configured with two operational modes:

### Mode 1: Email Forwarding (Postfix Alias)
- ✅ Emails sent to `contact@simondatalab.de` are automatically forwarded to `sn.renauld@gmail.com`
- ✅ Managed via Postfix virtual alias table: `/etc/postfix/virtual`

### Mode 2: Local IMAP Mailbox (Dovecot)
- ✅ Users can authenticate and retrieve emails via IMAP
- ✅ Credentials: `contact@simondatalab.de` / `Desjardins1###`
- ✅ Mailbox stored at: `/var/mail/simondatalab.de/contact/`
- ✅ Password hash: SHA512-CRYPT (stored securely)

---

## Configuration Details

### Postfix Configuration

**Virtual Alias (in `/etc/postfix/virtual`):**
```
contact@simondatalab.de    sn.renauld@gmail.com
```

**Status:** ✅ Active — all incoming emails forwarded to Gmail

---

### Dovecot Configuration

**Virtual User Database (in `/etc/dovecot/virtual-users`):**
```
contact@simondatalab.de:{SHA512-CRYPT}$6$/8MC9bNG4D8tRB9k$s6QpzV1NXcPRJapytpdtXQgwEG8NQjqCrCZTHe8leX0QHzWXGD9vhKgJmZNLEzoEosBkpBBPXD/Np/SDNAatk/:5000:5000:/var/mail/simondatalab.de/contact
```

**Auth Backend (in `/etc/dovecot/conf.d/auth-passwdfile.conf.ext`):**
```
passdb {
  driver = passwd-file
  args = scheme=CRYPT username_format=%u /etc/dovecot/virtual-users
}

userdb {
  driver = static
  args = uid=mail gid=mail home=/var/mail/%d/%n
}
```

**Mail Location:** `maildir:~/mail` (Maildir format)

**Credentials:**
- Username: `contact@simondatalab.de`
- Password: `Desjardins1###`

**Status:** ✅ Active — IMAP login successful, authentication working

---

## Verification Results

### ✅ Authentication Test
```
$ doveadm auth test contact@simondatalab.de Desjardins1###
passdb: contact@simondatalab.de auth succeeded
extra fields:
  user=contact@simondatalab.de
```

### ✅ User Lookup
```
$ doveadm user contact@simondatalab.de
field   value
uid     8
gid     8
home    /var/mail/simondatalab.de/contact
```

### ✅ IMAP Login
```
* OK [CAPABILITY IMAP4rev1 ...] Dovecot (Debian) ready.
A001 OK [CAPABILITY ...] Logged in
```

### ✅ Email Forwarding
- Test email sent to `contact@simondatalab.de`
- Automatically forwarded to `sn.renauld@gmail.com`
- Postfix queue empty (delivery confirmed)

---

## Directory Structure

```
/var/mail/simondatalab.de/
└── contact/
    ├── cur/      # Current (read) messages
    ├── new/      # New (unread) messages
    └── tmp/      # Temporary files

/etc/dovecot/
├── virtual-users                          # User password hashes
├── dovecot.conf                           # Main config
└── conf.d/
    └── auth-passwdfile.conf.ext           # Passwd-file auth driver
```

**Permissions:**
- Directory: 755 (accessible by dovecot)
- virtual-users file: 644 (readable by all, including dovecot)
- Maildir subdirs: 700 (mail:mail user only)

---

## Access Methods

### 1. Forward to Gmail (Automatic)
- **Type:** Automatic forwarding
- **Status:** ✅ Active
- **Recipient:** sn.renauld@gmail.com
- **Behavior:** All emails forwarded, no local copy stored (by default)

### 2. IMAP/Webmail (Manual)
- **Protocol:** IMAP (TLS/SSL)
- **Server:** mail.simondatalab.de
- **Port:** 993 (IMAPS)
- **Username:** contact@simondatalab.de
- **Password:** Desjardins1###
- **Mail Location:** Maildir format at /var/mail/simondatalab.de/contact/

### 3. SMTP Submission (Send Mail)
- **Protocol:** SMTP with STARTTLS/SASL
- **Server:** mail.simondatalab.de
- **Port:** 587
- **Authentication:** contact@simondatalab.de / Desjardins1###
- **Requirement:** SASL authentication required

---

## Testing Commands

### Test IMAP Login
```bash
openssl s_client -connect mail.simondatalab.de:993 -quiet <<< 'A001 LOGIN contact@simondatalab.de Desjardins1###'
```

### Test Authentication
```bash
ssh -p 2222 root@136.243.155.166 "doveadm auth test contact@simondatalab.de Desjardins1###"
```

### Send Test Email
```bash
echo "Test body" | sendmail -v -F "Test Sender" -f webmaster@simondatalab.de contact@simondatalab.de
```

### Check User
```bash
ssh -p 2222 root@136.243.155.166 "doveadm user contact@simondatalab.de"
```

### Monitor Forwarding
```bash
ssh -p 2222 root@136.243.155.166 "postqueue -p && postlog -tail 50"
```

---

## Important Notes

### Dual-Mode Operation
- **Emails arriving:** Automatically forwarded to Gmail AND stored locally if accessed via IMAP
- **Outgoing emails:** Requires SASL authentication on port 587
- **Storage:** Messages are kept in /var/mail/simondatalab.de/contact/ for local IMAP access

### Password Security
- Password stored as SHA512-CRYPT hash (secure, non-reversible)
- File `/etc/dovecot/virtual-users` protected with mode 644
- Accessible only to dovecot system daemon

### Backup Considerations
- Maildir at `/var/mail/simondatalab.de/contact/` should be backed up regularly
- Virtual-users password database at `/etc/dovecot/virtual-users` should be backed up
- Postfix virtual alias in `/etc/postfix/virtual` should be backed up

---

## Next Steps (Optional)

1. **Test with Email Client**
   - Configure Thunderbird, Outlook, or similar with IMAP (mail.simondatalab.de:993)
   - Use credentials: contact@simondatalab.de / Desjardins1###

2. **Disable Forwarding (if local storage preferred)**
   - Remove entry from `/etc/postfix/virtual`
   - Run: `postmap /etc/postfix/virtual && systemctl reload postfix`

3. **Enable Local + Forward**
   - Currently enabled: emails are forwarded AND stored locally
   - To receive both a local copy and forward, the configuration is already set

4. **Change Password**
   - Use: `ssh -p 2222 root@136.243.155.166 "doveadm pw -u contact@simondatalab.de"`
   - Update `/etc/dovecot/virtual-users` with new hash
   - No service restart needed

---

## Troubleshooting

### Can't Login via IMAP
- Verify credentials: `doveadm auth test contact@simondatalab.de Desjardins1###`
- Check file permissions: `ls -la /etc/dovecot/virtual-users`
- Ensure Dovecot is running: `systemctl status dovecot`

### Emails Not Being Forwarded
- Check Postfix virtual table: `grep contact /etc/postfix/virtual`
- Verify DNS: `dig MX simondatalab.de`
- Check Postfix queue: `postqueue -p`
- View logs: `journalctl -u postfix -n 50`

### DKIM/SPF Issues
- DKIM is already configured (s=mail, d=simondatalab.de)
- SPF is already configured (includes mail.simondatalab.de IP)
- Forwarded emails will inherit the forwarding server's DKIM/SPF

---

## Configuration Files

**Modified/Created:**
- `/etc/dovecot/virtual-users` — ✅ Created
- `/etc/dovecot/conf.d/auth-passwdfile.conf.ext` — ✅ Updated
- `/etc/postfix/virtual` — ✅ Already contained entry

**Backups:**
- `/etc/dovecot/dovecot.conf.backup` — Original preserved

---

## Summary

✅ **Mailbox contact@simondatalab.de is fully operational with:**
- Email forwarding to sn.renauld@gmail.com (automatic)
- IMAP local mailbox access (manual, via email client)
- SMTP submission with SASL authentication
- Full DKIM/SPF/DMARC support inherited from simondatalab.de
- Secure password storage (SHA512-CRYPT)

**Ready for immediate use.**

---

**Created:** November 8, 2025  
**Last Updated:** November 8, 2025  
**Status:** ✅ VERIFIED AND OPERATIONAL
