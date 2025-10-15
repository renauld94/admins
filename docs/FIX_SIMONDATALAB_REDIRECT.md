# Fix simondatalab.de → moodle.simondatalab.de Redirect Conflict

## Problem
- **Issue**: `http://simondatalab.de/` and `http://www.simondatalab.de/` are redirecting to `http://moodle.simondatalab.de/`
- **Expected**: simondatalab.de should show the portfolio website from CT 150
- **Actual**: Traffic is being redirected to the Moodle LMS on VM 9001

## Infrastructure Overview
- **Proxmox Host**: 136.243.155.166 (root@pve)
- **Portfolio Website**: Container 150 (portfolio-web-1000150) at 10.0.0.150:80
- **Moodle LMS**: Virtual Machine 9001 (moodle-lms-9001-1000104) at 10.0.0.104:80
- **Cloudflare Tunnel**: Routes traffic from public domains to internal IPs

## Root Cause Analysis

The redirect conflict can be caused by one or more of these issues:

### 1. **Cloudflare Tunnel Misconfiguration** (Most Likely)
Your Cloudflare Tunnel dashboard shows:
```
1. simondatalab.de → http://10.0.0.150:80 ✓ 
2. www.simondatalab.de → http://10.0.0.150:80 ✓
3. moodle.simondatalab.de → http://10.0.0.104:80 ✓
```

However, local config might differ or there might be a catch-all rule.

### 2. **Reverse Proxy on Proxmox Host**
- Nginx or Caddy on the Proxmox host might have a `default_server` or catch-all configuration
- This could intercept traffic before it reaches the Cloudflare Tunnel

### 3. **iptables NAT Rules**
- DNAT/REDIRECT rules might be routing port 80 traffic incorrectly
- These would override Cloudflare Tunnel routing

### 4. **Web Server Configuration on CT 150**
- Nginx/Apache on CT 150 might not be configured correctly
- Missing server_name or wrong document root

## Diagnostic Steps

### Option 1: Quick Diagnostic (Copy-Paste Ready)

SSH to Proxmox host and run:
```bash
bash /home/simon/Learning-Management-System-Academy/scripts/quick_diagnostic.sh
```

Or copy/paste this one-liner:
```bash
curl -sI http://localhost/ && curl -sI -H "Host: simondatalab.de" http://localhost/ && curl -sI -H "Host: www.simondatalab.de" http://localhost/ && iptables -t nat -L PREROUTING -n -v | grep "dpt:80"
```

### Option 2: Full Diagnostic

Run the comprehensive diagnostic:
```bash
/home/simon/Learning-Management-System-Academy/scripts/diagnose_redirect_conflict.sh > /tmp/diagnostic.log 2>&1
cat /tmp/diagnostic.log
```

## Fix Steps

### Step 1: Connect to Proxmox Host

Since SSH from your local machine is timing out, use one of these methods:

**Method A - Direct SSH (if connection works):**
```bash
ssh root@136.243.155.166
```

**Method B - Proxmox Web Console:**
1. Open https://136.243.155.166:8006
2. Login with root credentials
3. Click "Shell" in the top-right

### Step 2: Run Fix Script on Proxmox Host

```bash
# Download or create the fix script
cd /tmp

# Run the fix script
bash /root/fix_proxmox_redirect_conflict.sh
```

### Step 3: Check Cloudflare Tunnel Configuration

**On Proxmox host**, check the cloudflared config:
```bash
cat /etc/cloudflared/config.yml
# or
cat /root/.cloudflared/config.yml
```

Look for ingress rules. Should look like:
```yaml
ingress:
  - hostname: simondatalab.de
    service: http://10.0.0.150:80
  - hostname: www.simondatalab.de
    service: http://10.0.0.150:80
  - hostname: moodle.simondatalab.de
    service: http://10.0.0.104:80
  - service: http_status:404
```

If the config is wrong, edit it and restart:
```bash
nano /etc/cloudflared/config.yml
systemctl restart cloudflared
```

### Step 4: Check/Remove Conflicting Reverse Proxy

**Check for Nginx:**
```bash
systemctl status nginx
nginx -T | grep -A 10 "server_name"
nginx -T | grep "proxy_pass"
```

**Check for Caddy:**
```bash
systemctl status caddy
cat /etc/caddy/Caddyfile
```

**If found, disable or reconfigure:**
```bash
# For Nginx
systemctl stop nginx
systemctl disable nginx

# For Caddy
systemctl stop caddy
systemctl disable caddy
```

### Step 5: Check iptables NAT Rules

```bash
# View all NAT rules
iptables -t nat -L -n -v --line-numbers

# Look for DNAT/REDIRECT on port 80
iptables -t nat -L PREROUTING -n -v --line-numbers | grep "dpt:80"
```

If you find problematic rules, remove them:
```bash
# Example: Remove rule #3 from PREROUTING chain
iptables -t nat -D PREROUTING 3

# Save changes
iptables-save > /etc/iptables/rules.v4
```

### Step 6: Fix CT 150 Configuration

Connect to CT 150:
```bash
# From Proxmox host
ssh root@10.0.0.150

# Or use pct exec
pct exec 150 -- bash
```

Run the CT 150 fix script:
```bash
bash /tmp/fix_simondatalab_redirect.sh
```

### Step 7: Test the Fix

**From Proxmox host:**
```bash
# Test direct access to backends
curl -sI http://10.0.0.150/
curl -sI http://10.0.0.104/

# Test with Host headers
curl -sI -H "Host: simondatalab.de" http://localhost/
curl -sI -H "Host: www.simondatalab.de" http://localhost/
curl -sI -H "Host: moodle.simondatalab.de" http://localhost/
```

**From your browser:**
- https://www.simondatalab.de/ (should show portfolio)
- https://moodle.simondatalab.de/ (should show moodle)

### Step 8: Purge Cloudflare Cache

If still seeing old content:
1. Go to Cloudflare Dashboard
2. Select simondatalab.de domain
3. Go to Caching → Configuration
4. Click "Purge Everything"

## Scripts Created

All scripts are in: `/home/simon/Learning-Management-System-Academy/scripts/`

| Script | Purpose | Run On |
|--------|---------|--------|
| `quick_diagnostic.sh` | Fast diagnostic (copy-paste ready) | Proxmox Host |
| `diagnose_redirect_conflict.sh` | Comprehensive diagnostic | Proxmox Host |
| `fix_proxmox_redirect_conflict.sh` | Fix redirect on Proxmox host | Proxmox Host |
| `fix_simondatalab_redirect.sh` | Fix nginx/apache on CT 150 | CT 150 |
| `fix_ct150_simple.sh` | Simple fix for CT 150 | CT 150 |

## Quick Fix Commands

```bash
# On Proxmox Host (136.243.155.166)
# 1. Check what's listening on port 80
netstat -tuln | grep ":80 "

# 2. Check iptables
iptables -t nat -L -n -v | grep "dpt:80"

# 3. Check cloudflared
systemctl status cloudflared
cat /etc/cloudflared/config.yml

# 4. Test backends
curl -sI http://10.0.0.150/
curl -sI http://10.0.0.104/

# 5. Test with Host headers
curl -sI -H "Host: www.simondatalab.de" http://localhost/
```

## Troubleshooting

### SSH Connection Times Out
- Use Proxmox Web Console instead (https://136.243.155.166:8006)
- Check if you're on a network that blocks port 22
- Try from a different network or use VPN

### Changes Don't Take Effect
1. Restart cloudflared: `systemctl restart cloudflared`
2. Purge Cloudflare cache
3. Clear browser cache (Ctrl+Shift+Del)
4. Try incognito/private browsing mode

### Still Redirects to Moodle
1. Check Cloudflare Dashboard tunnel routes (most likely cause)
2. Disable nginx/caddy on Proxmox host
3. Check for catch-all rules in web servers
4. Verify CT 150 is running: `pct status 150`

## Contact Information

If you need manual assistance, provide:
1. Output of `quick_diagnostic.sh`
2. Output of `cat /etc/cloudflared/config.yml`
3. Output of `iptables -t nat -L -n -v`
4. Screenshots of Cloudflare Tunnel configuration

## Success Criteria

✅ `https://www.simondatalab.de/` shows portfolio website
✅ `https://simondatalab.de/` shows portfolio website  
✅ `https://moodle.simondatalab.de/` shows Moodle LMS
✅ No redirect loops
✅ HTTPS works correctly
✅ Cache headers are correct

---

**Last Updated**: October 14, 2025
**Status**: Ready for execution
