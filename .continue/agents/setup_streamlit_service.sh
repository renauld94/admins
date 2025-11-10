#!/bin/bash
# Setup script for Streamlit service deployment
# Run as: bash setup_streamlit_service.sh

SERVICE_NAME="job-search-streamlit"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
LOCAL_SERVICE="/home/simon/Learning-Management-System-Academy/.continue/agents/${SERVICE_NAME}.service"

echo "🚀 Setting up Streamlit Dashboard Service"
echo "=========================================="

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ This script must be run as root (use: sudo bash setup_streamlit_service.sh)"
   exit 1
fi

# Copy service file to systemd
echo "📋 Copying service file to /etc/systemd/system/..."
cp "$LOCAL_SERVICE" "$SERVICE_FILE"
chmod 644 "$SERVICE_FILE"

# Reload systemd daemon
echo "🔄 Reloading systemd daemon..."
systemctl daemon-reload

# Enable service (auto-start on boot)
echo "✅ Enabling service (auto-start on boot)..."
systemctl enable "$SERVICE_NAME"

# Start service
echo "🚀 Starting service..."
systemctl start "$SERVICE_NAME"

# Check status
echo ""
echo "📊 Service Status:"
systemctl status "$SERVICE_NAME" --no-pager

echo ""
echo "✅ Setup complete!"
echo ""
echo "📍 Access Streamlit dashboard at: http://localhost:8501"
echo ""
echo "Useful commands:"
echo "  systemctl status $SERVICE_NAME        # Check status"
echo "  systemctl start $SERVICE_NAME         # Start service"
echo "  systemctl stop $SERVICE_NAME          # Stop service"
echo "  systemctl restart $SERVICE_NAME       # Restart service"
echo "  journalctl -u $SERVICE_NAME -f        # View live logs"
echo ""
