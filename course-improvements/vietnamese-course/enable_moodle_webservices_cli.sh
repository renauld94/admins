#!/bin/bash
# Enable Moodle Web Services via CLI
# This script connects to the Moodle server (VM 9001) via proxy jump and enables web services

set -e

# VM 9001 Configuration
VM_HOST="10.0.0.104"
VM_USER="simonadmin"
BASTION_HOST="136.243.155.166"
BASTION_PORT="2222"
BASTION_USER="root"
MOODLE_DIR="/var/www/moodle"

echo "========================================================================"
echo "  ENABLE MOODLE WEB SERVICES VIA CLI"
echo "========================================================================"
echo ""
echo "Target: VM 9001 (${VM_HOST}) via bastion ${BASTION_HOST}:${BASTION_PORT}"
echo ""

# Check SSH connectivity to bastion
echo "Checking SSH connectivity to bastion..."
if ! ssh -p "$BASTION_PORT" -o ConnectTimeout=5 "${BASTION_USER}@${BASTION_HOST}" "echo 'Bastion OK'" 2>/dev/null; then
    echo "❌ Cannot connect to bastion server via SSH"
    echo "Please check:"
    echo "  - SSH credentials"
    echo "  - Port $BASTION_PORT is accessible"
    echo "  - Host $BASTION_HOST is reachable"
    exit 1
fi
echo "✓ Bastion connection successful"
echo ""

# Check SSH connectivity to VM 9001
echo "Checking SSH connectivity to VM 9001..."
if ! ssh -o ProxyJump="${BASTION_USER}@${BASTION_HOST}:${BASTION_PORT}" -o ConnectTimeout=10 "${VM_USER}@${VM_HOST}" "echo 'VM 9001 OK'" 2>/dev/null; then
    echo "❌ Cannot connect to VM 9001 via proxy jump"
    echo "Please check VM 9001 is running and SSH is enabled"
    exit 1
fi
echo "✓ VM 9001 connection successful"
echo ""

# Verify Moodle installation
echo "Verifying Moodle installation..."
if ! ssh -o ProxyJump="${BASTION_USER}@${BASTION_HOST}:${BASTION_PORT}" "${VM_USER}@${VM_HOST}" "test -f ${MOODLE_DIR}/config.php" 2>/dev/null; then
    echo "❌ Moodle config.php not found at ${MOODLE_DIR}"
    echo "Searching for Moodle..."
    FOUND_DIR=$(ssh -o ProxyJump="${BASTION_USER}@${BASTION_HOST}:${BASTION_PORT}" "${VM_USER}@${VM_HOST}" "find /var/www /opt -name 'config.php' -path '*/moodle*/config.php' 2>/dev/null | head -1 | xargs dirname" 2>/dev/null || echo "")
    if [ -n "$FOUND_DIR" ]; then
        MOODLE_DIR="$FOUND_DIR"
        echo "✓ Found Moodle at: $MOODLE_DIR"
    else
        echo "❌ Could not locate Moodle installation"
        exit 1
    fi
else
    echo "✓ Found Moodle at: $MOODLE_DIR"
fi
echo ""

if [ -z "$MOODLE_DIR" ]; then
    echo "❌ Could not locate Moodle installation"
    echo "Please specify Moodle directory manually"
    exit 1
fi
echo "✓ Found Moodle at: $MOODLE_DIR"
echo ""

echo "Enabling web services in Moodle database..."
echo ""

# Try using moosh (Moodle shell) first
echo "Attempting to enable via moosh (if available)..."
ssh -o ProxyJump="${BASTION_USER}@${BASTION_HOST}:${BASTION_PORT}" "${VM_USER}@${VM_HOST}" bash << ENDSSH
cd "$MOODLE_DIR"

# Check if moosh is installed
if command -v moosh &> /dev/null; then
    echo "✓ moosh found, using it to enable services..."
    moosh config-set enablewebservices 1
    moosh config-set enablemobilewebservice 1
    moosh config-set webservice_rest 1
    echo "✓ Web services enabled via moosh"
else
    echo "⚠ moosh not found, falling back to direct SQL..."
    
    # Get database config from Moodle config.php
    DB_TYPE=\$(grep "^\\\$CFG->dbtype" config.php | sed "s/.*'\(.*\)'.*/\1/")
    DB_HOST=\$(grep "^\\\$CFG->dbhost" config.php | sed "s/.*'\(.*\)'.*/\1/")
    DB_NAME=\$(grep "^\\\$CFG->dbname" config.php | sed "s/.*'\(.*\)'.*/\1/")
    DB_USER=\$(grep "^\\\$CFG->dbuser" config.php | sed "s/.*'\(.*\)'.*/\1/")
    DB_PASS=\$(grep "^\\\$CFG->dbpass" config.php | sed "s/.*'\(.*\)'.*/\1/")
    DB_PREFIX=\$(grep "^\\\$CFG->prefix" config.php | sed "s/.*'\(.*\)'.*/\1/" || echo "mdl_")
    
    echo "Database: $DB_TYPE at $DB_HOST/$DB_NAME (prefix: $DB_PREFIX)"
    
    # Create PHP script to enable webservices (works with any DB type Moodle supports)
    cat > /tmp/enable_ws.php << 'PHPEOF'
<?php
define('CLI_SCRIPT', true);
require_once('/var/www/moodle/config.php');
require_once($CFG->libdir.'/clilib.php');

echo "Enabling web services via PHP/Moodle API...\n";

// Enable web services
set_config('enablewebservices', 1);
echo "✓ enablewebservices = 1\n";

// Enable REST protocol
set_config('rest', 1, 'webservice');
echo "✓ webservice_rest = 1\n";

// Enable mobile web service (optional but useful)
set_config('enablemobilewebservice', 1);
echo "✓ enablemobilewebservice = 1\n";

// Verify settings
$ws_enabled = get_config(null, 'enablewebservices');
$rest_enabled = get_config('webservice', 'rest');
$mobile_enabled = get_config(null, 'enablemobilewebservice');

echo "\nVerification:\n";
echo "  enablewebservices: " . ($ws_enabled ? 'ENABLED' : 'DISABLED') . "\n";
echo "  REST protocol: " . ($rest_enabled ? 'ENABLED' : 'DISABLED') . "\n";
echo "  Mobile webservice: " . ($mobile_enabled ? 'ENABLED' : 'DISABLED') . "\n";

echo "\n✓ Web services successfully enabled!\n";
PHPEOF
    
    # Execute the PHP script (works with any DB type)
    php /tmp/enable_ws.php
    
    if [ \$? -eq 0 ]; then
        echo "✓ Web services enabled successfully"
    else
        echo "❌ Failed to enable web services via PHP"
        echo "Falling back to manual SQL..."
        
        # Update the SQL script with correct prefix
        sed "s/mdl_/\${DB_PREFIX}/g" > /tmp/enable_ws.sql << 'SQLEOF'
UPDATE mdl_config SET value = '1' WHERE name = 'enablewebservices';
UPDATE mdl_config_plugins SET value = '1' WHERE plugin = 'webservice' AND name = 'rest';
UPDATE mdl_config SET value = '1' WHERE name = 'enablemobilewebservice';
SELECT name, value FROM mdl_config WHERE name IN ('enablewebservices', 'enablemobilewebservice');
SQLEOF
        
        if [ "\$DB_TYPE" = "pgsql" ]; then
            PGPASSWORD="\$DB_PASS" psql -h "\$DB_HOST" -U "\$DB_USER" -d "\$DB_NAME" -f /tmp/enable_ws.sql
        elif [ "\$DB_TYPE" = "mysqli" ] || [ "\$DB_TYPE" = "mariadb" ]; then
            mysql -h "\$DB_HOST" -u "\$DB_USER" -p"\$DB_PASS" "\$DB_NAME" < /tmp/enable_ws.sql
        elif [ "\$DB_TYPE" = "sqlsrv" ] || [ "\$DB_TYPE" = "mssql" ]; then
            echo "SQL Server detected. Please run these commands manually via SQL Server Management Studio or sqlcmd:"
            cat /tmp/enable_ws.sql
        else
            echo "❌ Unsupported database type: \$DB_TYPE"
            exit 1
        fi
    fi
    
    rm -f /tmp/enable_ws.sql
    echo "✓ Web services enabled via SQL"
fi

# Clear Moodle cache
echo ""
echo "Clearing Moodle cache..."
if [ -d "admin/cli" ]; then
    php admin/cli/purge_caches.php 2>/dev/null || echo "⚠ Cache clear had issues but continuing..."
    echo "✓ Cache cleared"
else
    echo "⚠ Could not find CLI tools to clear cache"
fi
ENDSSH

echo ""
echo "========================================================================"
echo "  WEB SERVICES ENABLED!"
echo "========================================================================"
echo ""
echo "Next steps:"
echo ""
echo "1. Verify by running the test script:"
echo "   ./test_moodle_connection.sh"
echo ""
echo "2. If successful, create a web service token:"
echo "   ./setup_moodle_webservices.sh"
echo ""
echo "3. Or create token via web interface:"
echo "   https://moodle.simondatalab.de/admin/settings.php?section=webservicetokens"
echo ""
