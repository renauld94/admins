# Jellyfin Live TV Connectivity Fix

**Date:** November 6, 2025  
**Issue:** Live TV channels cannot be played, image thumbnails fail with HTTP 500 errors

## Root Cause Analysis

Based on log analysis:
- **Primary Issue:** DNS resolution failures inside Jellyfin container (CT 200)
- **Evidence:** 
  - FFmpeg log shows: `Failed to resolve hostname viamotionhsi.netplus.ch: Temporary failure in name resolution`
  - Server log shows hundreds of `HttpClient.Timeout` errors fetching images from i.imgur.com, upload.wikimedia.org, etc.
  - Socket errors: `Resource temporarily unavailable (i.ibb.co:443)`

## Symptoms
- ❌ Live TV channels fail to play
- ❌ Channel thumbnails show HTTP 500 errors
- ❌ Browser console shows: `Failed to execute 'scrollTo' on 'Element': The provided value 'null' is not a valid enum value`
- ❌ POST to `/LiveStreams/MediaInfo` returns 404

## Fix Instructions

### Option 1: Run on Proxmox Host (Recommended)

```bash
# Copy script to Proxmox host
scp scripts/fix-jellyfin-connectivity.sh root@136.243.155.166:/tmp/

# SSH to Proxmox host
ssh root@136.243.155.166

# Run the fix script
bash /tmp/fix-jellyfin-connectivity.sh
```

### Option 2: Run Inside Container

```bash
# SSH to Proxmox host
ssh root@136.243.155.166

# Enter the container
pct enter 200

# Copy/paste the script or download it
wget https://raw.githubusercontent.com/.../fix-jellyfin-connectivity.sh

# Run it inside container
bash fix-jellyfin-connectivity.sh --inside-container
```

### Option 3: Manual Fix (if script fails)

```bash
# SSH to Proxmox host
ssh root@136.243.155.166

# Backup current DNS config
pct exec 200 -- cp /etc/resolv.conf /etc/resolv.conf.backup

# Update DNS to Cloudflare + Google
pct exec 200 -- bash -c 'cat > /etc/resolv.conf << EOF
nameserver 1.1.1.1
nameserver 1.0.0.1
nameserver 8.8.8.8
nameserver 8.8.4.4
options timeout:2 attempts:3 rotate
EOF'

# Test DNS
pct exec 200 -- dig +short viamotionhsi.netplus.ch

# Test HTTPS connectivity
pct exec 200 -- curl -I https://viamotionhsi.netplus.ch/live/eds/3sathd/browser-HLS8/3sathd.m3u8

# Restart Jellyfin
pct exec 200 -- systemctl restart jellyfin

# Check status
pct exec 200 -- systemctl status jellyfin
```

## What the Fix Does

1. **Updates DNS Configuration**
   - Sets primary DNS to Cloudflare (1.1.1.1, 1.0.0.1)
   - Sets backup DNS to Google (8.8.8.8, 8.8.4.4)
   - Adds timeout and retry options

2. **Tests Connectivity**
   - Verifies DNS resolution for IPTV sources
   - Tests HTTPS connectivity to upstream providers
   - Checks Jellyfin service status

3. **Restarts Jellyfin**
   - Applies new DNS configuration
   - Clears connection pool
   - Re-initializes network stack

## Additional Fixes (Optional)

### Fix ScrollTo JavaScript Error

Deploy the scroll behavior fix to prevent UI crashes:

1. Open Jellyfin Admin Dashboard
2. Go to: **Dashboard → Branding → Custom CSS**
3. Add this to Custom JavaScript:
   ```javascript
   // Fix scrollBehavior null error
   (function() {
       const orig = Element.prototype.scrollTo;
       Element.prototype.scrollTo = function(opts) {
           if (typeof opts === 'object' && opts !== null) {
               if (opts.behavior === null || opts.behavior === undefined) {
                   opts.behavior = 'smooth';
               }
           }
           return orig.call(this, opts);
       };
   })();
   ```

### Disable Remote Image Fetching (Temporary)

To reduce log spam while fixing network:

1. Dashboard → Libraries → Metadata
2. Uncheck: TheMovieDB, FanArt, OMDb
3. This stops thumbnail fetch attempts until connectivity is restored

## Verification Steps

After running the fix:

1. **Clear Browser Cache**
   - Press `Ctrl+Shift+R` (hard refresh)
   - Or clear cache in DevTools

2. **Test DNS Inside Container**
   ```bash
   pct exec 200 -- dig +short viamotionhsi.netplus.ch
   # Should return: 78.155.24.242
   ```

3. **Check Jellyfin Logs**
   ```bash
   pct exec 200 -- journalctl -u jellyfin -f
   # Should see successful stream opens, no DNS errors
   ```

4. **Test Live TV Channel**
   - Open Jellyfin web UI
   - Navigate to Live TV
   - Try playing a channel (e.g., 3sat HD)
   - Should play without errors

## Troubleshooting

### DNS Still Fails

Check if systemd-resolved is overwriting `/etc/resolv.conf`:

```bash
pct exec 200 -- systemctl status systemd-resolved

# If running, configure it properly:
pct exec 200 -- bash -c 'cat > /etc/systemd/resolved.conf << EOF
[Resolve]
DNS=1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4
FallbackDNS=
EOF'

pct exec 200 -- systemctl restart systemd-resolved
```

### Firewall Blocking Outbound HTTPS

Check iptables on Proxmox host:

```bash
# List firewall rules
iptables -L -n -v

# If outbound 443 is blocked, add rule:
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
iptables -A FORWARD -p tcp --dport 443 -j ACCEPT

# Save rules (Debian/Ubuntu)
netfilter-persistent save
```

### Cloudflare Tunnel Interference

If using Cloudflare Tunnel for Jellyfin:

```bash
# Check tunnel status
cloudflared tunnel list
cloudflared tunnel info <tunnel-id>

# Verify tunnel doesn't block outbound from container
# Container needs direct internet access, not just inbound via tunnel
```

### Container Network Configuration

Check container network settings:

```bash
# View container config
pct config 200

# Should have network config like:
# net0: name=eth0,bridge=vmbr0,firewall=1,ip=dhcp,type=veth

# Test from container
pct exec 200 -- ip addr show
pct exec 200 -- ip route show
pct exec 200 -- ping -c 3 1.1.1.1
```

## Expected Results

After fix is applied:

✅ DNS resolution works for all IPTV sources  
✅ Jellyfin can fetch thumbnails without timeouts  
✅ Live TV channels play without errors  
✅ FFmpeg successfully opens HLS streams  
✅ Browser console shows no 500 errors  
✅ ScrollTo errors eliminated (if custom JS added)

## Files Modified

- `/etc/resolv.conf` (inside container)
- Jellyfin service restarted

## Rollback

If the fix causes issues:

```bash
# Restore original DNS config
pct exec 200 -- cp /etc/resolv.conf.backup /etc/resolv.conf

# Restart Jellyfin
pct exec 200 -- systemctl restart jellyfin
```

## Related Issues

- Server Log: `/tmp/log_20251106.log` - 20,001 lines of HTTP timeouts
- FFmpeg Log: `/tmp/ffmpeg.log` - DNS resolution failure
- Browser Console: ScrollTo behavior null error
- Live TV Guide: Cannot load channel artwork

## Prevention

To prevent this issue in the future:

1. **Lock DNS Configuration**
   ```bash
   pct exec 200 -- chattr +i /etc/resolv.conf
   ```

2. **Monitor DNS Health**
   Add monitoring for DNS resolution inside container

3. **Document Network Setup**
   Keep clear documentation of container network configuration

---

**Status:** Ready to apply  
**Impact:** Fixes all Live TV and image loading issues  
**Risk:** Low (changes only DNS config, fully reversible)
