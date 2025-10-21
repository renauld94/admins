#!/usr/bin/env bash
# Collect diagnostics for Jellyfin on VM 200 (Proxmox guest)
# Usage: run on the Proxmox host or inside the VM as appropriate. Outputs to /tmp/jellyfin-diagnostics-<timestamp>.tar.gz

set -euo pipefail

TS=$(date +%Y%m%dT%H%M%S)
OUTDIR=/tmp/jellyfin-diagnostics-${TS}
ARCHIVE=/tmp/jellyfin-diagnostics-${TS}.tar.gz
mkdir -p "$OUTDIR"

echo "Collecting diagnostics into $OUTDIR"

# Basic system info
uname -a > "$OUTDIR/01_uname.txt" 2>&1 || true
cat /etc/os-release > "$OUTDIR/02_os-release.txt" 2>&1 || true
ip a > "$OUTDIR/03_ip_a.txt" 2>&1 || true
ss -tunelp > "$OUTDIR/04_ss.txt" 2>&1 || true
route -n > "$OUTDIR/05_route.txt" 2>&1 || true

# Docker / container checks
if command -v docker >/dev/null 2>&1; then
  docker ps -a > "$OUTDIR/10_docker_ps.txt" 2>&1 || true
  docker inspect jellyfin-simonadmin > "$OUTDIR/11_docker_inspect_jellyfin.json" 2>&1 || true
  docker logs --since 10m jellyfin-simonadmin > "$OUTDIR/12_docker_logs_last_10m.txt" 2>&1 || true
  docker stats --no-stream --format "{{.Name}} {{.CPUPerc}} {{.MemUsage}} {{.NetIO}}" > "$OUTDIR/13_docker_stats.txt" 2>&1 || true
else
  echo "docker not found" > "$OUTDIR/10_docker_ps.txt"
fi

# System journal (last 500 lines)
if command -v journalctl >/dev/null 2>&1; then
  journalctl -n 500 > "$OUTDIR/20_journalctl_last_500.txt" 2>&1 || true
fi

# Jellyfin specific files (common container paths)
# Attempt to copy config/cache if accessible
for p in "/var/lib/jellyfin" "/config" "/var/lib/docker/volumes"; do
  if [ -d "$p" ]; then
    mkdir -p "$OUTDIR/30_jellyfin_files"
    cp -a --no-preserve=ownership "$p" "$OUTDIR/30_jellyfin_files/" 2>/dev/null || true
  fi
done

# Network tests - DNS and external connectivity
if command -v ping >/dev/null 2>&1; then
  ping -c 3 8.8.8.8 > "$OUTDIR/40_ping_gw.txt" 2>&1 || true
fi
if command -v dig >/dev/null 2>&1; then
  dig +short google.com > "$OUTDIR/41_dns_google.txt" 2>&1 || true
else
  if command -v host >/dev/null 2>&1; then
    host google.com > "$OUTDIR/41_dns_google.txt" 2>&1 || true
  fi
fi

# curl test to Jellyfin local web UI
if command -v curl >/dev/null 2>&1; then
  curl -s -I http://127.0.0.1:8096 > "$OUTDIR/50_curl_local_jellyfin.txt" 2>&1 || true
  curl -s -I http://136.243.155.166:8096 > "$OUTDIR/51_curl_public_jellyfin.txt" 2>&1 || true
fi

# Collect /var/log if present (last 200 lines of jellyfin logs)
if [ -f "/var/log/jellyfin/jellyfin.log" ]; then
  tail -n 200 /var/log/jellyfin/jellyfin.log > "$OUTDIR/60_jellyfin_log_tail.txt" 2>&1 || true
fi

# Packaging
tar -czf "$ARCHIVE" -C /tmp "jellyfin-diagnostics-${TS}" || true
chmod 600 "$ARCHIVE" || true

echo "Diagnostics collected: $ARCHIVE"

# Print short summary
ls -l "$ARCHIVE"

exit 0
