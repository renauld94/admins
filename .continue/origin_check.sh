#!/bin/bash
set -e

echo "--- uname -a ---"
uname -a || true

echo "\n--- sysctl ip_forward ---"
sysctl net.ipv4.ip_forward || cat /proc/sys/net/ipv4/ip_forward || true

echo "\n--- iptables NAT table (iptables -t nat -L -n -v) ---"
sudo iptables -t nat -L -n -v || true

echo "\n--- iptables filter table (iptables -L -n -v) ---"
sudo iptables -L -n -v || true

echo "\n--- iptables-save (nat) ---"
sudo iptables-save -t nat || true

echo "\n--- nft list ruleset (if nft present) ---"
if command -v nft >/dev/null 2>&1; then sudo nft list ruleset || true; else echo "nft not installed"; fi

echo "\n--- ufw status verbose ---"
if command -v ufw >/dev/null 2>&1; then sudo ufw status verbose || true; else echo "ufw not installed"; fi

echo "\n--- docker ps (brief) ---"
if command -v docker >/dev/null 2>&1; then sudo docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}" || true; else echo "docker not installed"; fi

echo "\n--- listeners ss -ltnp for common ports ---"
ss -ltnp | egrep ':3000|:3001|:3002|:11434|:80|:443|:5000|:3000' || true

echo "\n--- processes: node, cloudflared, socat, ollama ---"
ps aux | egrep "node|cloudflared|socat|ollama" | egrep -v egrep || true

echo "\n--- nginx sites-enabled listing ---"
ls -l /etc/nginx/sites-enabled || true

echo "\n--- tail nginx access log (last 80 lines) ---"
sudo tail -n 80 /var/log/nginx/access.log || true

echo "\n--- tail nginx error log (last 80 lines) ---"
sudo tail -n 80 /var/log/nginx/error.log || true
