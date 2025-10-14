#!/bin/bash
# Diagnostic script for HTTP 526 / Cloudflare -> Origin SSL problems
# Run this on the origin server (or via SSH) to collect useful information for debugging

set -euo pipefail

HOSTNAME="moodle.simondatalab.de"
ORIGIN_IP="136.243.155.166"
ORIGIN_INTERNAL="10.0.0.104"

echo "== Quick info"
date
uname -a
echo "Target hostname: $HOSTNAME"
echo "Origin public IP: $ORIGIN_IP"
echo "Origin internal IP (if applicable): $ORIGIN_INTERNAL"
echo

echo "== 1) DNS and cloud tests (run from where you normally test - local workstation)"
echo "# Resolve records"
dig +short A $HOSTNAME || true
echo

echo "# Test HTTPS as seen by Cloudflare (connect to origin IP but send host header)"
echo "curl --resolve $HOSTNAME:443:$ORIGIN_IP -v --max-time 10 https://$HOSTNAME/ || true"
echo

echo "# Test handshake and show cert chain (openssl)"
echo "openssl s_client -connect $ORIGIN_IP:443 -servername $HOSTNAME -showcerts </dev/null || true"
echo

echo "== 2) Check which process is listening on 443/80"
ss -tlnp | egrep ':443|:80' || ss -tlnp || true
echo

echo "== 3) If using nginx or apache, show service status and active config snippets"
if command -v nginx >/dev/null 2>&1; then
  echo "-- nginx present:"
  systemctl status nginx --no-pager || true
  echo "--- nginx -T (full config) ---"
  nginx -T 2>/dev/null || true
fi

if command -v apache2ctl >/dev/null 2>&1 || command -v httpd >/dev/null 2>&1; then
  echo "-- apache present:"
  systemctl status apache2 --no-pager || systemctl status httpd --no-pager || true
  echo "--- apache SSL vhost files (grep for ServerName $HOSTNAME) ---"
  grep -R --line-number --colour=never "ServerName $HOSTNAME" /etc/apache2 /etc/httpd || true
  echo
fi

echo "== 4) Check certificate files and expiry (if cert files are present in common paths)"
CERT_PATHS=("/etc/letsencrypt/live/$HOSTNAME/fullchain.pem" "/etc/ssl/certs/$HOSTNAME.crt" "/etc/nginx/ssl/$HOSTNAME.crt")
for p in "${CERT_PATHS[@]}"; do
  if [ -f "$p" ]; then
    echo "Found cert: $p"
    openssl x509 -in "$p" -noout -dates || true
  fi
done

echo "== 5) Check iptables / nftables / NAT (list rules)"
if command -v iptables >/dev/null 2>&1; then
  echo "-- iptables (nat table)"
  iptables -t nat -L -n -v || true
  echo "-- iptables (filter table)"
  iptables -L -n -v || true
fi

if command -v nft >/dev/null 2>&1; then
  echo "-- nftables rules"
  nft list ruleset || true
fi

echo "== 6) Check port forwarding on host (if behind NAT / Proxmox)"
echo "List all DNAT rules (iptables-save)"
iptables-save | grep -i dnat || true
echo

echo "== 7) Check Cloudflare reachability (from origin): ensure you can connect to Cloudflare edge"
echo "Try fetching Cloudflare IP that connects to you (this is a sanity check)"
curl -sS https://www.cloudflare.com/ || true

echo "== 8) Tail recent webserver logs (last 200 lines)"
if [ -d /var/log/nginx ]; then
  echo "-- /var/log/nginx/error.log (last 200 lines)"
  tail -n 200 /var/log/nginx/error.log || true
fi
if [ -d /var/log/apache2 ]; then
  echo "-- /var/log/apache2/error.log (last 200 lines)"
  tail -n 200 /var/log/apache2/error.log || true
fi

echo "== 9) If using a reverse proxy container (docker), list containers and ports"
if command -v docker >/dev/null 2>&1; then
  docker ps --format 'table {{.ID}}\t{{.Image}}\t{{.Names}}\t{{.Ports}}' || true
fi

echo "== 10) Quick remediation steps to try now (manual):"
echo " - If Cloudflare SSL mode is 'Flexible', set to 'Full' (or 'Full (strict)' if origin cert valid)"
echo " - Ensure webserver is listening on 443 and serving the correct cert for $HOSTNAME"
echo " - If using Let's Encrypt, renew certs: 'certbot renew --dry-run' and then restart webserver"
echo " - Check NAT on Proxmox host and port forwarding from public IP -> VM internal IP"
echo

echo "== End of diagnostics"

echo "If you want, save the full output to a file and paste it here for analysis:"
echo "  sudo bash diagnostic_moodle_ssl.sh | tee /tmp/moodle-ssl-diagnostic-$(date +%s).log"

exit 0
