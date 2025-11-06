#!/bin/bash
# Enable Moodle Web Services via Proxmox qm command
# This script uses Proxmox to execute commands on VM 9001

set -e

BASTION_HOST="136.243.155.166"
BASTION_PORT="2222"
BASTION_USER="root"
VM_ID="9001"
MOODLE_DIR="/var/www/html/moodle"

echo "========================================================================"
echo "  ENABLE MOODLE WEB SERVICES VIA PROXMOX"
echo "========================================================================"
echo ""
echo "Target: VM $VM_ID via Proxmox at ${BASTION_HOST}:${BASTION_PORT}"
echo ""

# Check Proxmox connectivity
echo "Checking Proxmox connectivity..."
if ! ssh -p "$BASTION_PORT" -o ConnectTimeout=5 "${BASTION_USER}@${BASTION_HOST}" "echo 'Proxmox OK'" 2>/dev/null; then
    echo "❌ Cannot connect to Proxmox server"
    exit 1
fi
echo "✓ Proxmox connection successful"
echo ""

# Check VM status
echo "Checking VM $VM_ID status..."
VM_STATUS=$(ssh -p "$BASTION_PORT" "${BASTION_USER}@${BASTION_HOST}" "qm status $VM_ID" 2>/dev/null | awk '{print $2}' || echo "unknown")
if [ "$VM_STATUS" != "running" ]; then
    echo "❌ VM $VM_ID is not running (status: $VM_STATUS)"
    echo "Start it with: ssh -p $BASTION_PORT $BASTION_USER@$BASTION_HOST qm start $VM_ID"
    exit 1
fi
echo "✓ VM $VM_ID is running"
echo ""

# Create the enable script
echo "Creating webservices enable script..."
cat > /tmp/enable_ws.sh << 'SCRIPT_EOF'
#!/bin/bash
cd /var/www/html/moodle

echo "Getting database configuration..."
DB_TYPE=$(grep "^\$CFG->dbtype" config.php | sed "s/.*'\(.*\)'.*/\1/")
DB_HOST=$(grep "^\$CFG->dbhost" config.php | sed "s/.*'\(.*\)'.*/\1/")
DB_NAME=$(grep "^\$CFG->dbname" config.php | sed "s/.*'\(.*\)'.*/\1/")
DB_USER=$(grep "^\$CFG->dbuser" config.php | sed "s/.*'\(.*\)'.*/\1/")
DB_PASS=$(grep "^\$CFG->dbpass" config.php | sed "s/.*'\(.*\)'.*/\1/")
DB_PREFIX=$(grep "^\$CFG->prefix" config.php | sed "s/.*'\(.*\)'.*/\1/" || echo "mdl_")

echo "Database: $DB_TYPE at $DB_HOST/$DB_NAME (prefix: $DB_PREFIX)"
echo ""

# Create SQL file
cat > /tmp/enable_webservices.sql << SQLEOF
UPDATE ${DB_PREFIX}config SET value = '1' WHERE name = 'enablewebservices';
UPDATE ${DB_PREFIX}config_plugins SET value = '1' WHERE plugin = 'webservice' AND name = 'rest';  
UPDATE ${DB_PREFIX}config SET value = '1' WHERE name = 'enablemobilewebservice';
SELECT name, value FROM ${DB_PREFIX}config WHERE name IN ('enablewebservices', 'enablemobilewebservice');
SQLEOF

echo "Enabling web services in database..."
if [ "$DB_TYPE" = "mysqli" ] || [ "$DB_TYPE" = "mariadb" ]; then
    mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" < /tmp/enable_webservices.sql
    echo "✓ Web services enabled via MySQL"
elif [ "$DB_TYPE" = "pgsql" ]; then
    PGPASSWORD="$DB_PASS" psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -f /tmp/enable_webservices.sql
    echo "✓ Web services enabled via PostgreSQL"
else
    echo "❌ Unsupported database type: $DB_TYPE"
    exit 1
fi

# Clear cache
echo ""
echo "Clearing Moodle cache..."
if [ -f "admin/cli/purge_caches.php" ]; then
    php admin/cli/purge_caches.php 2>/dev/null || true
    echo "✓ Cache cleared"
fi

rm -f /tmp/enable_webservices.sql
echo ""
echo "✓ Web services successfully enabled!"
SCRIPT_EOF

# Copy script to Proxmox
echo "Copying script to Proxmox..."
scp -P "$BASTION_PORT" /tmp/enable_ws.sh "${BASTION_USER}@${BASTION_HOST}:/tmp/" >/dev/null 2>&1
echo "✓ Script uploaded"
echo ""

# Execute via qm guest exec
echo "Executing on VM $VM_ID..."
echo "========================================================================"
ssh -p "$BASTION_PORT" "${BASTION_USER}@${BASTION_HOST}" bash << 'PROXMOX_EOF'
# Copy script into VM
echo "Uploading script to VM..."
pct push 9001 /tmp/enable_ws.sh /tmp/enable_ws.sh 2>/dev/null || \
    scp /tmp/enable_ws.sh root@10.0.0.104:/tmp/ 2>/dev/null || \
    echo "Note: Using alternative method to access VM..."

# Try to execute
echo "Executing script in VM..."
pct exec 9001 -- bash /tmp/enable_ws.sh 2>/dev/null || \
    ssh root@10.0.0.104 "bash /tmp/enable_ws.sh" 2>/dev/null || \
    echo "
===================================================================
MANUAL EXECUTION REQUIRED
===================================================================

The script could not be executed automatically.
Please run these commands manually:

1. Access VM console:
   qm terminal 9001

2. Run these commands:
   cd /var/www/html/moodle
   
   # Get database info from config.php
   DB_PREFIX=\$(grep '^\$CFG->prefix' config.php | sed \"s/.*'\\(.*\\)'.*/\\1/\" || echo \"mdl_\")
   
   # For MySQL/MariaDB:
   mysql -u root -p moodle << SQL
   UPDATE \${DB_PREFIX}config SET value = '1' WHERE name = 'enablewebservices';
   UPDATE \${DB_PREFIX}config_plugins SET value = '1' WHERE plugin = 'webservice' AND name = 'rest';
   UPDATE \${DB_PREFIX}config SET value = '1' WHERE name = 'enablemobilewebservice';
   SELECT name, value FROM \${DB_PREFIX}config WHERE name IN ('enablewebservices', 'enablemobilewebservice');
   SQL
   
   # Clear cache
   php admin/cli/purge_caches.php

3. Test with:
   ./test_moodle_connection.sh
===================================================================
"

PROXMOX_EOF

# Cleanup
rm -f /tmp/enable_ws.sh

echo ""
echo "========================================================================"
echo "  COMPLETED!"
echo "========================================================================"
echo ""
echo "Next steps:"
echo ""
echo "1. Test the connection:"
echo "   ./test_moodle_connection.sh"
echo ""
echo "2. If successful, create a web service token:"
echo "   ./setup_moodle_webservices.sh"
echo ""
