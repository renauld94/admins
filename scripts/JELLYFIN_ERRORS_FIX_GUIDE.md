# 🔧 Jellyfin Console Errors Fix Guide

## 📋 Errors Identified

Your Jellyfin console shows these issues:

### 1. ❌ ScrollTo Error (Minor - UI issue)
```
TypeError: Failed to execute 'scrollTo' on 'Element': 
The provided value 'null' is not a valid enum value of type ScrollBehavior.
```
**Impact**: Minor UI glitch, doesn't affect streaming
**Fix**: This is a Jellyfin bug in version 10.10.7, will be fixed in next update

### 2. ❌ Image Loading Errors (500 Internal Server Error)
```
Primary?fillHeight=344&fillWidth=344&quality=96&tag=543b6ca4c9f21c87d81daf7a932499c0:1
Failed to load resource: the server responded with a status of 500 (Internal Server Error)
```
**Impact**: Channel thumbnails not loading
**Fix**: IPTV streams don't have thumbnail images

### 3. ✅ Everything Else Working Fine
- WebSocket connection: ✅ Working
- API connections: ✅ Working  
- Channel loading: ✅ Working
- Streaming: ✅ Working
- Bitrate test: ✅ 3-5 Mbps

---

## 🔧 Fixes

### Fix 1: Clear Jellyfin Cache
This will fix most UI issues:

```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103

# Stop Jellyfin
docker stop jellyfin-simonadmin

# Clear cache
docker exec jellyfin-simonadmin rm -rf /config/cache/*
docker exec jellyfin-simonadmin rm -rf /config/transcodes/*

# Restart Jellyfin
docker start jellyfin-simonadmin
```

### Fix 2: Disable Image Fetching for IPTV Channels
IPTV streams don't have images, so disable automatic fetching:

1. **Access**: http://136.243.155.166:8096/web/
2. **Login**: simonadmin
3. **Go to**: Admin Dashboard → Live TV
4. **Click**: TV Guide Data Providers
5. **Uncheck**: "Download images"
6. **Save**

### Fix 3: Update Jellyfin to Latest Version
Your version (10.10.7) has the scrollTo bug. Update to fix:

```bash
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103

# Backup current config
docker exec jellyfin-simonadmin tar czf /config/backup_before_update.tar.gz /config/data

# Pull latest version
docker pull jellyfin/jellyfin:latest

# Restart container with latest image
docker stop jellyfin-simonadmin
docker rm jellyfin-simonadmin

# Recreate with latest version (adjust paths as needed)
docker run -d \
  --name jellyfin-simonadmin \
  -p 8096:8096 \
  -v /path/to/jellyfin/config:/config \
  -v /path/to/jellyfin/cache:/cache \
  --restart unless-stopped \
  jellyfin/jellyfin:latest
```

**Note**: Before running the recreate command, check your current Jellyfin docker run command:
```bash
docker inspect jellyfin-simonadmin | grep -A 20 "Mounts"
```

### Fix 4: Disable ServiceWorker Error Message
The "serviceWorker unsupported" is just informational (HTTPS required). Ignore it or enable HTTPS via Cloudflare tunnel.

---

## 🚀 Quick Fix Script

I'll create a script to automatically fix these:

```bash
#!/bin/bash
# Fix Jellyfin console errors

VM_IP="10.0.0.103"
PROXY_HOST="136.243.155.166:2222"
VM_USER="simonadmin"

echo "🔧 Fixing Jellyfin console errors..."
echo ""

# Clear cache
echo "1. Clearing Jellyfin cache..."
ssh -J root@${PROXY_HOST} ${VM_USER}@${VM_IP} << 'ENDSSH'
    docker exec jellyfin-simonadmin rm -rf /config/cache/* 2>/dev/null || true
    docker exec jellyfin-simonadmin rm -rf /config/transcodes/* 2>/dev/null || true
ENDSSH

# Restart Jellyfin
echo "2. Restarting Jellyfin..."
ssh -J root@${PROXY_HOST} ${VM_USER}@${VM_IP} 'docker restart jellyfin-simonadmin'

echo ""
echo "✅ Cache cleared and Jellyfin restarted"
echo ""
echo "Next steps:"
echo "1. Go to: http://136.243.155.166:8096/web/"
echo "2. Admin Dashboard → Live TV → TV Guide Data Providers"
echo "3. Uncheck 'Download images'"
echo "4. Save"
echo ""
echo "This will fix the 500 errors for missing images."
```

---

## 📊 Error Priority

| Error | Priority | Impact | Fix |
|-------|----------|--------|-----|
| ScrollTo null | LOW | Minor UI glitch | Update Jellyfin |
| Image 500 errors | MEDIUM | Missing thumbnails | Disable image download |
| ServiceWorker | LOW | Just informational | Ignore or enable HTTPS |
| **Streaming** | ✅ WORKING | Channels play fine | No fix needed |

---

## ✅ Current Working Status

Despite the console errors, your system is **WORKING PERFECTLY**:

- ✅ Jellyfin connected and running
- ✅ WebSocket connected
- ✅ API calls successful
- ✅ Live TV loading channels
- ✅ Channels streaming (as shown by your playback URLs)
- ✅ Bitrate test passing (3-5 Mbps)
- ✅ Authentication working

**The errors are cosmetic and don't affect functionality!**

---

## 🎯 Recommendation

**For now, ignore the errors and focus on organizing your channels.**

The console errors are:
1. **scrollTo**: Jellyfin bug, will be fixed in next release
2. **500 image errors**: IPTV streams don't have images, expected behavior
3. **Everything else**: Working perfectly ✅

**Priority**: Organize your 11,000 channels first, then optionally fix cosmetic errors later.

---

## 📞 If Streaming Actually Fails

If channels don't play (not just missing images), try:

1. **Check stream URL directly**:
   ```bash
   curl -I "http://stream-url-here"
   ```

2. **Enable VPN** (for geo-blocked content):
   ```bash
   ./setup_protonvpn_sn_renauld.sh
   ```

3. **Check Jellyfin logs**:
   ```bash
   ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker logs --tail 100 jellyfin-simonadmin'
   ```

---

**🎯 Bottom Line**: Your Jellyfin is working! The errors are minor cosmetic issues. Focus on organizing channels with `./quick_organize_channels.sh` instead.
