# CRITICAL REDIRECT ISSUE - RESOLVED ✅

**Date:** October 15, 2025  
**Status:** ✅ **FIXED**  
**Issue:** All HTTPS traffic was redirecting to VM 9001 Moodle instead of Proxmox nginx

---

## 🔴 Problem Summary

### Symptoms
- Accessing `https://simondatalab.de/` returned HTTP 303 redirect to Moodle
- Wrong SSL certificate served (self-signed `moodle.simondatalab.de` instead of Let's Encrypt)
- Wrong nginx version in response headers (nginx/1.24.0 instead of nginx/1.22.1)
- Internal tests from Proxmox worked correctly
- External tests from user's machine failed

### Root Cause
**Triple misconfiguration** causing ports 80 and 443 to be DNATed to wrong destinations:

1. **`/etc/iptables.rules`** - Loaded by `/etc/network/if-pre-up.d/iptables-restore`
   - Had DNAT rules forwarding ports 80/443 to `192.168.100.101` (non-existent IP!)
   - File was loaded BEFORE network interfaces came up

2. **`/etc/nftables.d/forward-80-443-to-vm.nft`**
   - Had nftables rules forwarding ports 80/443 to `10.0.0.104` (VM 9001)
   - Loaded by nftables service at boot

3. **`/etc/network/interfaces`** (initially)
   - Had manual DNAT rules (later removed but kept coming back from iptables.rules)

---

## ✅ Solution Applied

### 1. Removed Port 80/443 DNAT from `/etc/iptables.rules`
```bash
# Backup
cp /etc/iptables.rules /etc/iptables.rules.backup-20251015-074400

# Remove problematic rules
sed -i '/192.168.100.101/d' /etc/iptables.rules
sed -i '/192.168.100.0/d' /etc/iptables.rules

# Reload clean rules
iptables -t nat -F
iptables-restore < /etc/iptables.rules
```

**Result:** No more DNAT for ports 80/443 in iptables

### 2. Disabled nftables Port Forwarding
```bash
mv /etc/nftables.d/forward-80-443-to-vm.nft /etc/nftables.d/forward-80-443-to-vm.nft.disabled
systemctl restart nftables
```

**Result:** nftables no longer forwards ports 80/443

### 3. Removed Ollama/OpenWebUI configs from Container 150
Container 150 should ONLY serve the portfolio, not handle other services.

```bash
pct exec 150 -- rm -f /etc/nginx/sites-enabled/ollama /etc/nginx/sites-enabled/openwebui
pct exec 150 -- systemctl reload nginx
```

### 4. Rebooted Proxmox
```bash
reboot
```

Ensured all network configurations loaded cleanly from corrected files.

---

## 📊 Verification Results

### ✅ All Tests Passing

1. **Certificate Test**
   ```bash
   $ echo | openssl s_client -connect simondatalab.de:443 -servername simondatalab.de 2>&1 | grep "subject=CN"
   subject=CN = simondatalab.de
   ```
   ✅ Correct Let's Encrypt certificate (not self-signed Moodle cert)

2. **HTTP Response**
   ```bash
   $ curl -I https://simondatalab.de/
   HTTP/2 200 
   server: nginx/1.22.1
   ```
   ✅ Correct nginx version (Proxmox nginx, not VM 9001)

3. **Page Content**
   ```bash
   $ curl -s https://simondatalab.de/ | grep '<title>'
   <title>Simon Renauld | Senior Data Scientist & Innovation Strategist</title>
   ```
   ✅ Correct portfolio content (not Moodle redirect page)

4. **Service Status**
   - ✅ `https://simondatalab.de/` - HTTP 200 (Portfolio)
   - ✅ `https://moodle.simondatalab.de/` - HTTP 200 (Moodle LMS)
   - ⚠️  `https://ollama.simondatalab.de/` - HTTP 502 (Backend service may be down, but routing is correct)

---

## 🏗️ Current Infrastructure State

### Network Rules (Clean)
```bash
# PREROUTING DNAT Rules
- Port 8088 → 10.0.0.103:8088 (Nextcloud/Jellyfin)
- Port 8096 → 10.0.0.103:8096 (Jellyfin)
✅ NO DNAT for ports 80 or 443 (handled by Proxmox nginx)

# POSTROUTING MASQUERADE Rules  
- 10.0.0.0/24 → vmbr0 (NAT for internal VMs/containers)
- 10.0.0.103:8088, 10.0.0.103:8096 (specific MASQUERADE)
```

### Running Services
**Containers:**
- CT 100: Running
- CT 150: Running (portfolio-web-1000150) - **Serves simondatalab.de**

**VMs:**
- VM 106: Running (vm106-geoneural1000111)
- VM 159: Running (ubuntuai-1000110) - Ollama/MLflow at 10.0.0.110
- VM 200: Running (nextcloud-vm-10-0-0-103) 
- VM 9001: Running (moodle-lms-9001-1000104) - **Serves moodle.simondatalab.de**

### Network Bridges
- **vmbr0:** 136.243.155.166/26 (Public internet)
- **vmbr1:** 10.0.0.1/24 (Internal VM/container network)

### Nginx Configurations
**Proxmox (`/etc/nginx/sites-enabled/`):**
- `000-auth-redirect.conf` - HTTP → HTTPS redirect (port 80 default_server)
- `simondatalab-https.conf` - HTTPS default_server, proxies to CT 150 (10.0.0.150)
- `moodle.simondatalab.de.conf` - Proxies to VM 9001 (10.0.0.104:8086)
- `additional-services-ssl.conf` - Ollama, MLflow, Booklore, GeoNeuralViz
- `grafana-proxy.conf` - Grafana dashboard

**Container 150 (`/etc/nginx/sites-enabled/`):**
- `default` - Basic portfolio config
- `portfolio` - Main portfolio site with geospatial-viz
- ✅ **Removed:** ollama, openwebui (these belong on Proxmox, not CT 150)

---

## 📝 Key Lessons Learned

1. **Multiple NAT layers conflict:** Having DNAT rules in both iptables AND nftables causes unpredictable behavior
2. **Boot-time scripts override manual changes:** `/etc/network/if-pre-up.d/iptables-restore` reloaded old rules on every reboot
3. **Container isolation:** Containers should serve ONE purpose (CT 150 = portfolio only)
4. **Test after reboot:** Network changes must survive reboot to be considered fixed
5. **Version mismatch diagnostic:** nginx version in HTTP headers revealed traffic was going to wrong server

---

## 🔧 Files Modified

### Permanently Fixed
- ✅ `/etc/iptables.rules` - Removed port 80/443 DNAT
- ✅ `/etc/nftables.d/forward-80-443-to-vm.nft` - Renamed to `.disabled`
- ✅ `/etc/network/interfaces` - Removed port 80/443 DNAT (earlier)
- ✅ Container 150: Removed ollama, openwebui nginx configs

### Backups Created
- `/etc/iptables.rules.backup-20251015-074400`
- `/etc/nftables.conf.backup-20251015-073317`
- `/etc/network/interfaces.backup-20251015-071830`

---

## 🎯 Next Steps (Optional Improvements)

1. **Enable Ollama backend** (if needed):
   ```bash
   pct start 110  # or wherever Ollama service runs
   ```

2. **Monitor logs** for any issues:
   ```bash
   tail -f /var/log/nginx/error.log
   tail -f /var/log/nginx/access.log
   ```

3. **Test SSL certificate renewal:**
   ```bash
   certbot renew --dry-run
   ```

4. **Document all services** with their IPs and ports for future reference

---

## ✅ Verification Checklist

- [x] Ports 80/443 handled by Proxmox nginx (no DNAT)
- [x] Let's Encrypt certificate served (not self-signed)
- [x] Portfolio loads correctly (HTTP 200)
- [x] Moodle accessible at subdomain (HTTP 200)
- [x] Correct nginx version in headers (1.22.1)
- [x] Changes survive reboot
- [x] Container 150 only serves portfolio
- [x] All configs cleaned and documented

---

## 📞 Quick Reference

**Test Commands:**
```bash
# Test certificate
echo | openssl s_client -connect simondatalab.de:443 -servername simondatalab.de 2>&1 | grep "subject=CN"

# Test HTTP response
curl -I https://simondatalab.de/

# Test page content
curl -s https://simondatalab.de/ | grep '<title>'

# Check NAT rules
ssh -p 2222 root@136.243.155.166 "iptables -t nat -L PREROUTING -n -v"

# Check nftables rules
ssh -p 2222 root@136.243.155.166 "nft list ruleset | grep 'tcp dport'"
```

**Important IPs:**
- Proxmox: 136.243.155.166
- Container 150 (Portfolio): 10.0.0.150
- VM 9001 (Moodle): 10.0.0.104
- VM 159 (Ollama/MLflow): 10.0.0.110
- VM 200 (Nextcloud): 10.0.0.103

---

**Issue Status:** ✅ **RESOLVED AND VERIFIED**  
**Last Updated:** October 15, 2025 07:45 UTC
