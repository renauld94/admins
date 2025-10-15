# 🔧 Cloudflare Tunnel - Manual Fix Required

**Date**: October 15, 2025  
**Issue**: Cloudflared tunnel service is stopped on Proxmox host  
**Impact**: https://jellyfin.simondatalab.de returns 530 error  
**Workaround**: Use direct HTTP access: http://136.243.155.166:8096

---

## ✅ DNS Configuration (CORRECT!)

Your DNS is properly configured:

```
Type: CNAME
Name: jellyfin.simondatalab.de
Content: a10f0734-57e8-439f-8d1d-ef7a1cf54da0.cfargotunnel.com
Proxy: ✅ Proxied
Status: ✅ Correct
```

---

## ❌ Problem: Cloudflared Service is Stopped

The cloudflared tunnel connector is **installed but not running** on the Proxmox host (136.243.155.166).

**Service Status:**
```
cloudflared.service - inactive (dead)
Last stopped: Oct 14 11:38:06
Reason: Connection timeout to Cloudflare edge
```

---

## 🔧 Manual Fix

### SSH into Proxmox Host

```bash
ssh -p 2222 root@136.243.155.166
```

### Start Cloudflared Service

```bash
# Start the service
systemctl start cloudflared

# Enable it to start on boot
systemctl enable cloudflared

# Check status
systemctl status cloudflared

# View logs
journalctl -u cloudflared -f
```

### Verify Tunnel is Connected

```bash
# Should show "Registered tunnel connection"
journalctl -u cloudflared -n 50 | grep -i "registered\|connected"
```

---

## ✅ Test After Starting

Wait 30-60 seconds after starting cloudflared, then test:

```bash
# From your local machine
curl -I https://jellyfin.simondatalab.de

# Should return HTTP/2 302 (redirect) instead of 530
```

Or open in browser:
- https://jellyfin.simondatalab.de

---

## 🎯 Alternative: Use Direct HTTP Access (Working Now!)

While fixing the tunnel, you can use Jellyfin via direct HTTP:

**Direct Access:** http://136.243.155.166:8096/web/  
**Status:** ✅ WORKING  
**Login:** simonadmin

This works perfectly for:
- Configuring IPTV tuners
- Watching channels
- All Jellyfin functionality

The only difference is HTTP instead of HTTPS (and a different URL).

---

## 📊 Current Status Summary

| Component | Status | Access |
|-----------|--------|--------|
| **Jellyfin Container** | ✅ Running | VM 200 (10.0.0.103:8096) |
| **IPTV Playlists** | ✅ Installed | 12 files, 12,242+ channels |
| **Direct HTTP** | ✅ Working | http://136.243.155.166:8096 |
| **DNS Record** | ✅ Correct | jellyfin.simondatalab.de |
| **Tunnel Route** | ✅ Configured | Route #10 in Cloudflare |
| **Cloudflared Service** | ❌ Stopped | Needs manual start on Proxmox |
| **HTTPS Access** | ❌ 530 Error | Will work after starting cloudflared |

---

## 🔍 Why Did Cloudflared Stop?

From the logs:
```
Oct 14 11:37:39: ERR DialContext error: dial tcp 104.16.133.229:7844: i/o timeout
Oct 14 11:38:06: INF Initiating graceful shutdown due to signal terminated
```

**Possible causes:**
1. Network connectivity issue to Cloudflare edge
2. Manual stop/restart of service
3. System update or reboot
4. Configuration issue

**Solution:** Simply restart the service

---

## 📝 Commands Summary

```bash
# SSH to Proxmox
ssh -p 2222 root@136.243.155.166

# Start cloudflared
systemctl start cloudflared

# Enable on boot
systemctl enable cloudflared

# Check status
systemctl status cloudflared

# View live logs
journalctl -u cloudflared -f

# Exit when you see "Registered tunnel connection"
# Press Ctrl+C to exit logs

# Test from your machine
curl -I https://jellyfin.simondatalab.de
```

---

## ✅ When Tunnel is Working

You'll see in logs:
```
INF Registered tunnel connection
INF Connection established
```

And the test will show:
```bash
$ curl -I https://jellyfin.simondatalab.de
HTTP/2 302
location: /web/
```

---

## 🎬 For Now: Use Jellyfin via HTTP!

Don't wait! Start using Jellyfin now via:

**URL:** http://136.243.155.166:8096/web/  
**Login:** simonadmin

1. Configure M3U tuners with the installed playlists
2. Start watching IPTV channels
3. Fix the tunnel later when convenient

The tunnel is just for HTTPS access from outside - all functionality works via direct HTTP!

---

**Location of cloudflared:** Proxmox host (136.243.155.166)  
**Service name:** cloudflared.service  
**Tunnel ID:** a10f0734-57e8-439f-8d1d-ef7a1cf54da0  
**Fix required:** Manual start of cloudflared service
