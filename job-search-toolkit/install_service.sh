#!/bin/bash
###############################################################################
# EPIC Job Search Service Installer for VM 159
# Installs continuous daemon as systemd service for auto-start
###############################################################################

set -e

TOOLKIT_DIR="/home/simon/Learning-Management-System-Academy/job-search-toolkit"
SERVICE_NAME="epic-job-search"
SERVICE_FILE="${TOOLKIT_DIR}/${SERVICE_NAME}.service"
SYSTEM_SERVICE="/etc/systemd/system/${SERVICE_NAME}.service"

echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║  EPIC Job Search Service Installer - VM 159                           ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root (use: sudo bash install_service.sh)"
    exit 1
fi

echo "📋 INSTALLATION STEPS:"
echo ""

# Step 1: Verify service file exists
echo "1️⃣  Checking service file..."
if [ ! -f "$SERVICE_FILE" ]; then
    echo "❌ Service file not found: $SERVICE_FILE"
    exit 1
fi
echo "   ✅ Service file found"
echo ""

# Step 2: Make daemon executable
echo "2️⃣  Making daemon executable..."
chmod +x "${TOOLKIT_DIR}/daemon_continuous.py"
echo "   ✅ daemon_continuous.py is executable"
echo ""

# Step 3: Create log directory with proper permissions
echo "3️⃣  Setting up log directories..."
mkdir -p "${TOOLKIT_DIR}/outputs/logs"
mkdir -p "${TOOLKIT_DIR}/outputs/reports"
mkdir -p "${TOOLKIT_DIR}/data"
chown -R simon:simon "${TOOLKIT_DIR}/outputs"
chown -R simon:simon "${TOOLKIT_DIR}/data"
chmod 755 "${TOOLKIT_DIR}/outputs/logs"
echo "   ✅ Log directories created and permissions set"
echo ""

# Step 4: Copy service file to systemd directory
echo "4️⃣  Installing systemd service..."
cp "$SERVICE_FILE" "$SYSTEM_SERVICE"
chmod 644 "$SYSTEM_SERVICE"
echo "   ✅ Service installed to: $SYSTEM_SERVICE"
echo ""

# Step 5: Reload systemd daemon
echo "5️⃣  Reloading systemd daemon..."
systemctl daemon-reload
echo "   ✅ Systemd daemon reloaded"
echo ""

# Step 6: Enable service for auto-start
echo "6️⃣  Enabling service for auto-start..."
systemctl enable "${SERVICE_NAME}.service"
echo "   ✅ Service enabled for auto-start"
echo ""

# Step 7: Start the service
echo "7️⃣  Starting the service..."
systemctl start "${SERVICE_NAME}.service"
sleep 2

if systemctl is-active --quiet "${SERVICE_NAME}.service"; then
    echo "   ✅ Service started successfully"
else
    echo "   ⚠️  Warning: Service may not have started properly"
    echo "   Check status with: sudo systemctl status epic-job-search"
fi
echo ""

echo "╔════════════════════════════════════════════════════════════════════════╗"
echo "║  ✅ INSTALLATION COMPLETE                                             ║"
echo "╚════════════════════════════════════════════════════════════════════════╝"
echo ""

echo "📊 SERVICE STATUS:"
systemctl status "${SERVICE_NAME}.service" --no-pager || true
echo ""

echo "📚 USEFUL COMMANDS:"
echo ""
echo "   View service status:"
echo "   $ sudo systemctl status epic-job-search"
echo ""
echo "   View live logs:"
echo "   $ sudo tail -f ${TOOLKIT_DIR}/outputs/logs/daemon_service.log"
echo ""
echo "   Stop the service:"
echo "   $ sudo systemctl stop epic-job-search"
echo ""
echo "   Start the service:"
echo "   $ sudo systemctl start epic-job-search"
echo ""
echo "   Restart the service:"
echo "   $ sudo systemctl restart epic-job-search"
echo ""
echo "   View service configuration:"
echo "   $ cat $SYSTEM_SERVICE"
echo ""
echo "   View system journal for errors:"
echo "   $ sudo journalctl -u epic-job-search -f"
echo ""

echo "🎯 WHAT'S RUNNING:"
echo ""
echo "The daemon will continuously:"
echo "   🔍 Discover jobs from Indeed, LinkedIn, RemoteOK, Glassdoor"
echo "   🎯 Score and rank by relevance to your profile"
echo "   👥 Identify recruiters across all target regions"
echo "   🔗 Send slow-rate LinkedIn connections and messages"
echo "   📊 Track metrics and generate reports"
echo "   ⏰ Run 24/7 with rate limiting to avoid detection"
echo ""

echo "🌍 TARGET REGIONS:"
echo "   ✈️  APAC: Vietnam (HCM, Da Nang), Singapore, Australia, Japan"
echo "   🇺🇸 Americas: USA (CA, NY, WA, Austin, Boston), Canada"
echo "   🇪🇺 Europe: UK, Germany, Netherlands, France, Switzerland"
echo ""

echo "💾 LOGS & OUTPUTS:"
echo "   Daemon Log: ${TOOLKIT_DIR}/outputs/logs/daemon_service.log"
echo "   Errors Log: ${TOOLKIT_DIR}/outputs/logs/daemon_service_error.log"
echo "   Reports:   ${TOOLKIT_DIR}/outputs/reports/"
echo ""

echo "✅ Your continuous job search is now running 24/7 on VM 159!"
