#!/usr/bin/env bash
# UFW hardening script (dry-run friendly)
# Usage: sudo ./deploy/ufw-harden.sh --apply (or run without --apply to print commands)
# It will:
#  - allow SSH (22) from anywhere
#  - allow HTTP/HTTPS (80/443) only from Cloudflare IP ranges (provided inline)
#  - deny direct access to 3000/3001/3002 from external networks (allow from 127.0.0.1 only)
# IMPORTANT: Verify the IP list and test in a maintenance window. Misconfiguration can lock you out.

set -euo pipefail
APPLY=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) APPLY=true; shift;;
    *) echo "Unknown arg: $1"; exit 1;;
  esac
done

# Minimal Cloudflare IPv4/IPv6 list (short snapshot) - update from https://www.cloudflare.com/ips-v4 and ips-v6
CF_IPV4=(
"103.21.244.0/22"
"103.22.200.0/22"
"103.31.4.0/22"
"141.101.64.0/18"
"108.162.192.0/18"
"190.93.240.0/20"
"188.114.96.0/20"
"197.234.240.0/22"
"198.41.128.0/17"
"162.158.0.0/15"
"104.16.0.0/12"
"172.64.0.0/13"
"131.0.72.0/22"
)
CF_IPV6=(
"2400:cb00::/32"
"2606:4700::/32"
"2803:f800::/32"
"2405:b500::/32"
"2405:8100::/32"
"2a06:98c0::/29"
"2c0f:f248::/32"
)

echo "This script will output UFW commands to restrict access. Run with --apply to execute them."

echo "Allow SSH (22) from anywhere"
cmds=("ufw allow 22/tcp")

echo "Allow HTTP/HTTPS only from Cloudflare ranges"
for ip in "${CF_IPV4[@]}"; do
  cmds+=("ufw allow from ${ip} to any port 80,443 proto tcp")
done
for ip in "${CF_IPV6[@]}"; do
  cmds+=("ufw allow from ${ip} to any port 80,443 proto tcp")
done

# Deny direct access to MCP ports from external
cmds+=("ufw deny in to any port 3000 proto tcp")
cmds+=("ufw deny in to any port 3001 proto tcp")
cmds+=("ufw deny in to any port 3002 proto tcp")
# Allow local access from localhost (not necessary for UFW, but explicit)
cmds+=("ufw allow in on lo to any")

# Print or apply
for c in "${cmds[@]}"; do
  echo "+ $c"
  if $APPLY; then
    sudo sh -c "$c"
  fi
done

echo "Done. If you applied rules, check 'sudo ufw status numbered' and test connectivity from a Cloudflare IP or via the tunnel." 
