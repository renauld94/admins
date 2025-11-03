#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SERVICES=(
  agent-core_dev.service
  agent-data_science.service
  agent-geo_intel.service
  agent-web_lms.service
  agent-systemops.service
  agent-legal_advisor.service
  agent-portfolio.service
)

usage() {
  cat <<EOF
Usage: $0 <start|stop|restart|status|logs>

Commands:
  start     Start all agent services (user systemd)
  stop      Stop all agent services
  restart   Restart all agent services
  status    Show systemd status for all agents
  logs      Tail the per-agent log files under ~/.local/state/agents/
EOF
}

cmd=${1:-status}
case "$cmd" in
  start)
    for s in "${SERVICES[@]}"; do
      echo "Starting $s"
      systemctl --user start "$s" || true
    done
    ;;
  stop)
    for s in "${SERVICES[@]}"; do
      echo "Stopping $s"
      systemctl --user stop "$s" || true
    done
    ;;
  restart)
    for s in "${SERVICES[@]}"; do
      echo "Restarting $s"
      systemctl --user restart "$s" || true
    done
    ;;
  status)
    systemctl --user status "${SERVICES[@]}" --no-pager
    ;;
  logs)
    mkdir -p "$HOME/.local/state/agents"
    tail -n 300 "$HOME/.local/state/agents"/*.log 2>/dev/null || echo "No logs found under $HOME/.local/state/agents"
    ;;
  *)
    usage
    exit 2
    ;;
esac
