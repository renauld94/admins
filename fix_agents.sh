#!/bin/bash
set -euo pipefail

base="/home/simon/Learning-Management-System-Academy/.continue/agents"
services=(
  "agent-geo_intel.service"
  "agent-data_science.service"
  "agent-systemops.service"
  "agent-portfolio.service"
  "smart-agent.service"
  "agent-core_dev.service"
  "agent-web_lms.service"
)

# Available agent scripts
declare -A agent_map=(
  ["geo_intel"]="$base/geodashboard_autonomous_agent.py"
  ["data_science"]="$base/workspace_analyzer_agent.py"
  ["systemops"]="$base/infrastructure_monitor_agent.py"
  ["portfolio"]="$base/epic_cinematic_agent.py"
  ["smart"]="$base/smart_agent.py"
  ["core_dev"]="$base/code_generation_specialist.py"
  ["web_lms"]="$base/documentation_generator.py"
)

echo "Starting agent service repairs..."

for svc in "${services[@]}"; do
  echo ""
  echo "=== Processing $svc ==="
  
  # Extract the key name from service name (e.g., "agent-geo_intel.service" -> "geo_intel")
  key="${svc#agent-}"
  key="${key%.service}"
  
  # Get the candidate script from map
  script="${agent_map[$key]:-}"
  
  if [ -z "$script" ]; then
    echo "No script mapping found for $key; removing service."
    sudo systemctl disable "$svc" --now 2>/dev/null || true
    sudo rm -f "/etc/systemd/system/$svc"
    continue
  fi
  
  if [ ! -f "$script" ]; then
    echo "Script not found: $script; removing service."
    sudo systemctl disable "$svc" --now 2>/dev/null || true
    sudo rm -f "/etc/systemd/system/$svc"
    continue
  fi
  
  echo "Script found: $script"
  unitfile="/etc/systemd/system/$svc"
  
  if [ -f "$unitfile" ]; then
    # Update ExecStart to point to the correct script
    sudo sed -i.bak "s|^ExecStart=.*|ExecStart=/usr/bin/env python3 $script|" "$unitfile"
    echo "Updated $unitfile"
    
    # Reload, enable and restart
    sudo systemctl daemon-reload
    sudo systemctl enable "$svc" --now 2>/dev/null || true
    sleep 1
    status=$(sudo systemctl status "$svc" --no-pager 2>&1 | head -n 3 || true)
    echo "Status: $status"
  fi
done

echo ""
echo "=== Final Status ==="
sudo systemctl daemon-reload
for svc in "${services[@]}"; do
  if sudo systemctl is-enabled "$svc" >/dev/null 2>&1; then
    state=$(sudo systemctl is-active "$svc" 2>/dev/null || echo "unknown")
    echo "$svc: enabled ($state)"
  else
    echo "$svc: disabled/removed"
  fi
done

echo ""
echo "Agent repair complete!"
