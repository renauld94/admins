# Jellyfin Live TV Issue - Complete Diagnosis

**Date:** November 6, 2025  
**Status:** ROOT CAUSE IDENTIFIED

## Discovery

✅ **Jellyfin Location Found:**
- Running on **Proxmox host** (pve) at 136.243.155.166
- NOT in VM 200 or any container
- Installed via: `/snap/itrue-jellyfin/153`
- Process ID: 1657963
- Access via: `ssh -p 2222 root@136.243.155.166`

## Root Cause Analysis

### ✅ DNS Resolution: WORKING
```bash
dig +short viamotionhsi.netplus.ch
Result: 78.155.24.242
```
- DNS servers: 1.1.1.1, 8.8.8.8 (correctly configured)
- Hostname resolution works perfectly

### ❌ HTTPS Connectivity: **BLOCKED**
```bash
curl -I https://viamotionhsi.netplus.ch/live/eds/3sathd/browser-HLS8/3sathd.m3u8
Result: Connection timeout after 5 seconds
```

**THE PROBLEM:** Outbound HTTPS (port 443) connections are being blocked or timing out.

## Why This Causes Issues

1. **Live TV Streams Fail:**
   - Jellyfin can resolve hostnames but cannot download M3U8 playlists
   - FFmpeg error: Cannot connect to upstream IPTV servers

2. **Channel Thumbnails Fail (HTTP 500):**
   - Cannot fetch artwork from i.imgur.com, upload.wikimedia.org, etc.
   - All image URLs return timeout → server returns 500 error

3. **Browser Errors:**
   - Client sees 500 errors on all `/Items/.../Images/Primary` requests
   - `POST /LiveStreams/MediaInfo` fails (404) because stream never opens

## Possible Causes

1. **ISP/Network Blocking**
   - Some providers block/throttle HTTPS to certain domains
   - Rate limiting on outbound connections

2. **Cloudflare Tunnel Interference**
   - If Jellyfin is behind Cloudflare tunnel
   - Tunnel may not allow direct outbound from host

3. **Network Configuration**
   - MTU issues
   - Routing table problems
   - IPv6/IPv4 preference issues

4. **Connection Exhaustion**
   - Too many simultaneous outbound connections
   - All sockets in use (check with `ss -s`)

## Solution Attempts

### ✅ Completed:
- Verified DNS configuration (correct)
- Restarted Jellyfin service
- Confirmed firewall OUTPUT policy: ACCEPT

### ⏳ To Try:

#### 1. Test with Different HTTPS Endpoints
```bash
ssh -p 2222 root@136.243.155.166 "curl -I --connect-timeout 5 https://1.1.1.1"
ssh -p 2222 root@136.243.155.166 "curl -I --connect-timeout 5 https://google.com"
ssh -p 2222 root@136.243.155.166 "curl -I --connect-timeout 5 https://i.imgur.com"
```

#### 2. Check MTU Settings
```bash
ssh -p 2222 root@136.243.155.166 "ip link show | grep mtu"
# If MTU > 1500, lower it:
# ip link set dev vmbr0 mtu 1500
```

#### 3. Check for Connection Limits
```bash
ssh -p 2222 root@136.243.155.166 "ss -s"
ssh -p 2222 root@136.243.155.166 "netstat -an | grep ESTABLISHED | wc -l"
```

#### 4. Test with Proxy/VPN
If the ISP/network blocks HTTPS to these domains, use a proxy:
```bash
# Install if needed:
apt install proxychains4

# Configure Jellyfin snap to use proxy
snap set itrue-jellyfin proxy.http=http://proxy:port
snap set itrue-jellyfin proxy.https=http://proxy:port
snap restart itrue-jellyfin
```

#### 5. Use Alternative IPTV Sources
Test with a different IPTV provider that may not be blocked:
```bash
curl -I https://iptv-all.lanesh4d0w.repl.co/india/allcategories
```

#### 6. Cloudflare Tunnel Workaround
If using Cloudflare tunnel, ensure it allows outbound:
```bash
# Check tunnel config
cat /etc/cloudflared/config.yml

# Jellyfin needs direct internet, not just inbound via tunnel
```

## Immediate Workaround

### Option A: Use Local Files Instead of IPTV
Upload video files directly to Jellyfin instead of streaming from external sources.

### Option B: Download M3U8 Playlists Locally
```bash
# Download playlist locally
wget https://viamotionhsi.netplus.ch/.../.m3u8 -O /tmp/channel.m3u8

# Edit Jellyfin IPTV tuner to use file:///tmp/channel.m3u8
```

### Option C: Set Up Local Proxy
On a machine with working HTTPS:
```bash
# Install squid proxy
apt install squid

# Configure Jellyfin to use it
snap set itrue-jellyfin proxy.https=http://proxy-ip:3128
```

## Verification Commands

Run these from local machine to test the fix:

```bash
# Test HTTPS from Proxmox host
ssh -p 2222 root@136.243.155.166 "curl -I --connect-timeout 10 https://viamotionhsi.netplus.ch/live/eds/3sathd/browser-HLS8/3sathd.m3u8"

# Should see HTTP 200 or 302, not timeout

# Check Jellyfin logs
ssh -p 2222 root@136.243.155.166 "journalctl -u snap.itrue-jellyfin* -f"

# Test in browser
# Open https://jellyfin.simondatalab.de
# Try playing a Live TV channel
```

## Next Steps

1. Run diagnostic commands above to identify exact blocking mechanism
2. Implement appropriate workaround (proxy, VPN, or alternative sources)
3. Test Live TV playback after fix
4. Monitor for continued issues

---

**Summary:** DNS is fine, but outbound HTTPS to IPTV providers is blocked/timing out. This is a network-level issue, not a Jellyfin configuration problem.
