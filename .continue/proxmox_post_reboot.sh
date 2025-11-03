#!/bin/bash
set -e

echo "--- uname -a ---"
uname -a || true

echo "\n--- date ---"
date || true

echo "\n--- /proc/sys/net/ipv4/ip_forward ---"
cat /proc/sys/net/ipv4/ip_forward || true

echo "\n--- ip route ---"
ip route || true

echo "\n--- iptables -t nat -L -n -v ---"
iptables -t nat -L -n -v || true

echo "\n--- iptables -L -n -v ---"
iptables -L -n -v || true

echo "\n--- iptables-save -t nat (head) ---"
iptables-save -t nat | sed -n '1,200p' || true

echo "\n--- nft ruleset ---"
if command -v nft >/dev/null 2>&1; then nft list ruleset || echo "nft ok but list failed"; else echo "nft not installed"; fi

echo "\n--- ss listeners (common ports) ---"
ss -ltnp | egrep ':80|:443|:3000|:3001|:3002|:11434' || true

echo "\n--- docker ps (brief) ---"
docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}' || true

echo "\n--- nginx status ---"
systemctl status nginx --no-pager || true

echo "\n--- nginx sites-enabled ---"
ls -l /etc/nginx/sites-enabled || true

echo "\n--- tail nginx access log (last 200 lines) ---"
tail -n 200 /var/log/nginx/access.log || true

echo "\n--- tail nginx error log (last 200 lines) ---"
tail -n 200 /var/log/nginx/error.log || true
