#!/bin/bash
# Install all agent systemd services and targets

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEMD_DIR="$SCRIPT_DIR/../systemd"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

echo "🚀 Installing Agent Systemd Services..."
echo "========================================"

# Create user systemd directory if it doesn't exist
mkdir -p "$SYSTEMD_USER_DIR"

# Copy all service files
echo "📦 Copying service files..."
cp -v "$SYSTEMD_DIR"/*.service "$SYSTEMD_USER_DIR/"
cp -v "$SYSTEMD_DIR"/*.target "$SYSTEMD_USER_DIR/"
cp -v "$SYSTEMD_DIR"/*.timer "$SYSTEMD_USER_DIR/" 2>/dev/null || true

# Reload systemd
echo "🔄 Reloading systemd..."
systemctl --user daemon-reload

# Enable agents.target
echo "✅ Enabling agents.target..."
systemctl --user enable agents.target

echo ""
echo "✅ Installation complete!"
echo ""
echo "📊 Available commands:"
echo "  Start all agents:   systemctl --user start agents.target"
echo "  Stop all agents:    systemctl --user stop agents.target"
echo "  Check status:       systemctl --user list-units '*agent*.service'"
echo ""
echo "🎯 Monitor agents:"
echo "  Terminal dashboard: $SCRIPT_DIR/unified_agent_monitor.sh"
echo "  Web dashboard:      firefox $SCRIPT_DIR/../unified_agent_dashboard.html"
echo ""
