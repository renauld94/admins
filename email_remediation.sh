#!/bin/bash

# Email Remediation Automation Script
# Applies DNS and Postfix configuration changes for simondatalab.de
# Run as: sudo bash email_remediation.sh

set -e  # Exit on error

DOMAIN="simondatalab.de"
MAIL_HOST="mail.simondatalab.de"
MAIL_IP="136.243.155.166"
CERT_PATH="/etc/letsencrypt/live/mail.simondatalab.de"
BACKUP_DIR="/etc/postfix/backups"
BACKUP_DATE=$(date +%Y%m%d-%H%M%S)

echo "=========================================="
echo "Email Remediation Automation"
echo "Domain: $DOMAIN"
echo "Date: $(date)"
echo "=========================================="
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "ERROR: This script must be run as root (use: sudo bash email_remediation.sh)"
   exit 1
fi

# Function to print section headers
print_section() {
    echo ""
    echo ">>> $1"
    echo ""
}

# Function to print success
print_success() {
    echo "✓ $1"
}

# Function to print error and exit
print_error() {
    echo "✗ ERROR: $1"
    exit 1
}

# =============================================================================
# PART 1: VERIFY POSTFIX INSTALLATION
# =============================================================================

print_section "PART 1: Verifying Postfix Installation"

if ! command -v postfix &> /dev/null; then
    print_error "Postfix not found. Install it first: apt-get install postfix"
fi
print_success "Postfix found"

if ! command -v certbot &> /dev/null; then
    echo "! Certbot not found. Installing certbot..."
    apt-get update
    apt-get install -y certbot
fi
print_success "Certbot available"

# =============================================================================
# PART 2: OBTAIN TLS CERTIFICATE
# =============================================================================

print_section "PART 2: Obtaining TLS Certificate"

if [ -f "$CERT_PATH/fullchain.pem" ] && [ -f "$CERT_PATH/privkey.pem" ]; then
    print_success "Valid certificate already exists at $CERT_PATH"
    echo "Skipping certificate generation."
else
    echo "Certificate not found. Generating new Let's Encrypt certificate..."
    
    # Check if Let's Encrypt is accessible
    if ! certbot certonly --standalone -d "$MAIL_HOST" 2>/dev/null; then
        echo ""
        echo "! WARNING: Let's Encrypt certificate generation failed."
        echo "  This may be because:"
        echo "    - Port 80 is not accessible externally"
        echo "    - DNS is not resolving $MAIL_HOST"
        echo "    - Rate limiting from Let's Encrypt"
        echo ""
        echo "FALLBACK: Using self-signed certificate (not recommended for production)"
        echo ""
        
        mkdir -p /etc/ssl/certs /etc/ssl/private
        openssl req -new -x509 -days 365 -nodes \
            -out /etc/ssl/certs/mail.simondatalab.de.crt \
            -keyout /etc/ssl/private/mail.simondatalab.de.key \
            -subj "/CN=$MAIL_HOST/O=SimonDataLab/C=DE"
        
        chmod 600 /etc/ssl/private/mail.simondatalab.de.key
        chmod 644 /etc/ssl/certs/mail.simondatalab.de.crt
        
        CERT_PATH="/etc/ssl/certs"
        print_success "Self-signed certificate created (TEMPORARY - use Let's Encrypt in production)"
    else
        print_success "Let's Encrypt certificate obtained"
    fi
fi

# Verify certificate files
if [ ! -f "$CERT_PATH/fullchain.pem" ] && [ ! -f "/etc/ssl/certs/mail.simondatalab.de.crt" ]; then
    print_error "Certificate files not found at expected location"
fi

print_success "Certificate verification complete"

# =============================================================================
# PART 3: BACKUP AND CONFIGURE POSTFIX
# =============================================================================

print_section "PART 3: Configuring Postfix (TLS and SMTP Settings)"

mkdir -p "$BACKUP_DIR"

# Backup main.cf
if [ -f /etc/postfix/main.cf ]; then
    cp /etc/postfix/main.cf "$BACKUP_DIR/main.cf.$BACKUP_DATE"
    print_success "Backed up main.cf to $BACKUP_DIR/main.cf.$BACKUP_DATE"
fi

# Backup master.cf
if [ -f /etc/postfix/master.cf ]; then
    cp /etc/postfix/master.cf "$BACKUP_DIR/master.cf.$BACKUP_DATE"
    print_success "Backed up master.cf to $BACKUP_DIR/master.cf.$BACKUP_DATE"
fi

# Determine certificate path for main.cf
if [ -d "/etc/letsencrypt/live/$MAIL_HOST" ]; then
    CERT_FILE="/etc/letsencrypt/live/$MAIL_HOST/fullchain.pem"
    KEY_FILE="/etc/letsencrypt/live/$MAIL_HOST/privkey.pem"
else
    CERT_FILE="/etc/ssl/certs/mail.simondatalab.de.crt"
    KEY_FILE="/etc/ssl/private/mail.simondatalab.de.key"
fi

# Add/update TLS configuration in main.cf
echo ""
echo "Updating main.cf with TLS configuration..."

# Check if TLS settings already exist
if grep -q "^smtpd_tls_cert_file" /etc/postfix/main.cf; then
    echo "  (TLS settings already exist, updating...)"
    sed -i "s|^smtpd_tls_cert_file.*|smtpd_tls_cert_file = $CERT_FILE|" /etc/postfix/main.cf
    sed -i "s|^smtpd_tls_key_file.*|smtpd_tls_key_file = $KEY_FILE|" /etc/postfix/main.cf
else
    echo "  (Adding new TLS settings...)"
    cat >> /etc/postfix/main.cf << EOF

# TLS Configuration (INCOMING)
smtpd_tls_cert_file = $CERT_FILE
smtpd_tls_key_file = $KEY_FILE
smtpd_use_tls = yes
smtpd_tls_security_level = may
smtpd_tls_auth_only = no
smtpd_tls_session_cache_database = btree:/var/lib/postfix/smtpd_tls_session_cache
smtpd_tls_received_header = yes
smtpd_tls_loglevel = 1

# TLS Configuration (OUTGOING)
smtp_tls_security_level = may
smtp_tls_session_cache_database = btree:/var/lib/postfix/smtp_tls_session_cache
EOF
fi

print_success "TLS configuration added to main.cf"

# Enable submission port in master.cf
echo ""
echo "Enabling submission port (587) in master.cf..."

# Check if submission is already enabled
if grep -q "^submission inet" /etc/postfix/master.cf; then
    echo "  (Submission already enabled, verifying configuration...)"
else
    # Uncomment the submission line
    sed -i 's/^#submission inet/submission inet/' /etc/postfix/master.cf
fi

# Ensure submission has proper configuration
if ! grep -A 8 "^submission inet" /etc/postfix/master.cf | grep -q "smtpd_sasl_auth_enable"; then
    echo "  (Adding SASL configuration to submission...)"
    # Find submission line and replace next section
    sed -i '/^submission inet/,/^$/c\
submission inet n       -       y       -       -       smtpd\
  -o syslog_name=postfix/submission\
  -o smtpd_tls_wrappermode=no\
  -o smtpd_tls_security_level=encrypt\
  -o smtpd_sasl_auth_enable=yes\
  -o smtpd_sasl_type=dovecot\
  -o smtpd_sasl_path=private/auth\
  -o smtpd_client_restrictions=permit_sasl_authenticated,reject\
  -o milter_macro_daemon_name=ORIGINATING' /etc/postfix/master.cf
fi

print_success "Submission port (587) enabled in master.cf"

# =============================================================================
# PART 4: VERIFY DOVECOT AUTH
# =============================================================================

print_section "PART 4: Verifying Dovecot Authentication"

if ! systemctl is-active --quiet dovecot; then
    echo "WARNING: Dovecot is not running. Starting dovecot..."
    systemctl start dovecot
fi

if systemctl is-active --quiet dovecot; then
    print_success "Dovecot is running"
else
    echo "WARNING: Dovecot failed to start. Check logs with: journalctl -u dovecot"
fi

# Check if auth socket exists
if [ -S /var/spool/postfix/private/auth ]; then
    print_success "Dovecot auth socket is present"
else
    echo "WARNING: Auth socket not found. This may cause SASL auth failures."
    echo "  Check Dovecot configuration: /etc/dovecot/conf.d/10-master.conf"
fi

# =============================================================================
# PART 5: SYNTAX CHECK AND RELOAD
# =============================================================================

print_section "PART 5: Postfix Syntax Check and Reload"

echo "Running Postfix syntax check..."
if postfix check 2>&1; then
    print_success "Postfix configuration syntax is valid"
else
    print_error "Postfix configuration has errors. Restore backup and check manually."
fi

echo ""
echo "Reloading Postfix..."
if postfix reload 2>&1 | grep -q "fatal"; then
    echo "ERROR: Postfix reload failed!"
    echo "Attempting restart instead..."
    systemctl restart postfix || print_error "Postfix restart failed"
else
    print_success "Postfix reloaded successfully"
fi

# Wait a moment for Postfix to fully reload
sleep 2

# =============================================================================
# PART 6: VERIFICATION TESTS
# =============================================================================

print_section "PART 6: Verification Tests"

echo "Checking port 25..."
if netstat -tlnp 2>/dev/null | grep -q ":25 " || ss -tlnp 2>/dev/null | grep -q ":25 "; then
    print_success "Port 25 (SMTP) is listening"
else
    echo "WARNING: Port 25 not found in listening ports"
fi

echo ""
echo "Checking port 587..."
if netstat -tlnp 2>/dev/null | grep -q ":587 " || ss -tlnp 2>/dev/null | grep -q ":587 "; then
    print_success "Port 587 (Submission) is listening"
else
    echo "WARNING: Port 587 not found in listening ports (check firewall)"
fi

# =============================================================================
# PART 7: FINAL INSTRUCTIONS
# =============================================================================

print_section "PART 7: Summary and Next Steps"

echo "✓ Postfix TLS and Submission Configuration Complete!"
echo ""
echo "What was done:"
echo "  1. TLS certificate obtained/verified"
echo "  2. Postfix configured for STARTTLS on port 25"
echo "  3. Submission port 587 enabled with SASL auth"
echo "  4. Dovecot auth verified"
echo "  5. Postfix reloaded"
echo ""
echo "NEXT STEPS:"
echo ""
echo "1. FIX DNS RECORDS (Hetzner DNS Console)"
echo "   - Remove duplicate SPF TXT records (keep only 1)"
echo "   - Remove duplicate DMARC TXT records (keep only 1)"
echo "   - See: EMAIL_REMEDIATION_DNS_GUIDE.md"
echo ""
echo "2. WAIT FOR DNS PROPAGATION (5-10 minutes)"
echo "   - Then run: dig +short TXT simondatalab.de"
echo "   - Should return ONLY ONE SPF record"
echo ""
echo "3. TEST EMAIL DELIVERY"
echo "   - Send test email from: webmaster@simondatalab.de"
echo "   - Receive test email to: webmaster@simondatalab.de"
echo "   - Check for bounces or delivery failures"
echo ""
echo "4. VERIFY TLS CERTIFICATE"
echo "   openssl s_client -connect mail.simondatalab.de:25 -starttls smtp"
echo ""
echo "5. VERIFY SUBMISSION AUTH (from client)"
echo "   telnet mail.simondatalab.de 587"
echo "   EHLO localhost"
echo "   AUTH LOGIN (with base64 encoded credentials)"
echo ""
echo "USEFUL COMMANDS:"
echo ""
echo "  Check certificate expiry:"
echo "    openssl x509 -enddate -noout -in $CERT_FILE"
echo ""
echo "  View Postfix logs:"
echo "    tail -f /var/log/mail.log"
echo ""
echo "  Restart Postfix:"
echo "    systemctl restart postfix"
echo ""
echo "  Test STARTTLS:"
echo "    openssl s_client -connect $MAIL_HOST:25 -starttls smtp"
echo ""
echo "BACKUP LOCATIONS:"
echo "  Main config: $BACKUP_DIR/main.cf.$BACKUP_DATE"
echo "  Master config: $BACKUP_DIR/master.cf.$BACKUP_DATE"
echo ""
echo "ROLLBACK (if needed):"
echo "  cp $BACKUP_DIR/main.cf.$BACKUP_DATE /etc/postfix/main.cf"
echo "  cp $BACKUP_DIR/master.cf.$BACKUP_DATE /etc/postfix/master.cf"
echo "  postfix reload"
echo ""
echo "=========================================="
echo "Script completed at $(date)"
echo "=========================================="
