# ⚡ Jellyfin Enhanced Channels - Quick Reference

## 🎬 What You Have Now

```
✅ 311 verified working channels
✅ 10 organized categories
✅ All channels tested for accessibility
✅ Jellyfin tuner configured and active
✅ Ready to use immediately
```

---

## 🚀 Quick Start (2 Minutes)

### Step 1: Open Jellyfin
```
URL: http://136.243.155.166:8096
```

### Step 2: Go to Live TV
```
Path: Live TV → Guide
```

### Step 3: Wait & Browse
```
Time: 30-60 seconds for channels to populate
Enjoy: 311 channels in 10 categories
```

---

## 📊 Your Channels

### By Category
```
41 - ✝️  Religious      30 - 👶  Kids
36 - 🎵  Music         29 - 🎭  Entertainment
34 - 🛍️  Shop          29 - 📚  Documentary
34 - 📰  News          26 - 🌿  Lifestyle
30 - 🎬  Movies        22 - ⚽  Sports
```

### How to Find Specific Channels

**Search by Category:**
```bash
grep '📰 News' /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-channels-enhanced.m3u
```

**Search by Name:**
```bash
grep 'CNN' /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-channels-enhanced.m3u
```

**List All Categories:**
```bash
grep -o 'group-title="[^"]*"' /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-channels-enhanced.m3u | sort | uniq
```

---

## 🔧 Common Tasks

### Refresh Channels
```bash
# Option 1: Via Jellyfin UI
Settings → Live TV → Guide → Refresh Guide

# Option 2: Via command line
docker restart jellyfin-simonadmin
```

### Check Jellyfin Status
```bash
docker ps | grep jellyfin
```

### View Logs
```bash
docker logs jellyfin-simonadmin | tail -50
```

### Update Channels (Find New Ones)
```bash
python3 /home/simon/Learning-Management-System-Academy/scripts/fetch-and-test-channels.py
```

---

## ⚠️ Troubleshooting

### Channels Not Appearing?
1. **Wait longer** - First load takes 30-60 seconds
2. **Refresh guide** - Go to Settings → Live TV → Guide → Refresh
3. **Restart Jellyfin** - `docker restart jellyfin-simonadmin`

### Channel Won't Play?
1. **Normal** - Some streams are geo-blocked or dead
2. **Solution** - Try another channel from same category
3. **Check logs** - `docker logs jellyfin-simonadmin`

### Jellyfin Unhealthy?
```bash
docker restart jellyfin-simonadmin
# Wait 2-3 minutes for startup
```

---

## 📁 Files & Locations

| File | Location | Size |
|------|----------|------|
| Enhanced M3U | `/alternative_m3u_sources/jellyfin-channels-enhanced.m3u` | 69 KB |
| Fetch Script | `/scripts/fetch-and-test-channels.py` | 10 KB |
| Full Guide | `/JELLYFIN_ENHANCED_CHANNELS_COMPLETE.md` | 10 KB |

---

## 🎯 Pro Tips

1. **Organize Favorites** - Mark favorite channels in Jellyfin
2. **Create Collections** - Group channels by preference
3. **Schedule Recordings** - Record your favorite shows
4. **Mobile Access** - Use Jellyfin mobile app to watch
5. **Remote Access** - Configure port forwarding for external access

---

## 🔄 Maintenance

### Weekly Update
```bash
python3 /home/simon/Learning-Management-System-Academy/scripts/fetch-and-test-channels.py
```

This automatically:
- Fetches latest channels from IPTV-Org
- Tests each URL
- Creates new M3U file
- Shows statistics

### Monthly Backup
```bash
cp alternative_m3u_sources/jellyfin-channels-enhanced.m3u \
   alternative_m3u_sources/jellyfin-channels-enhanced-backup-$(date +%Y%m%d).m3u
```

---

## 📞 Support

### Quick Commands
```bash
# Count total channels
grep -c "^#EXTINF:" /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-channels-enhanced.m3u

# Verify M3U format
head -5 /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-channels-enhanced.m3u

# Check file size
du -h /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-channels-enhanced.m3u
```

### Contact Jellyfin Support
```
Jellyfin Project: https://jellyfin.org
Documentation: https://docs.jellyfin.org
Community: https://jellyfin.org/community
```

---

## ✨ Statistics

```
Sources:         10 IPTV-Org categories
Total Fetched:   500 channels
Total Tested:    500 channels
Success Rate:    62% (311 working)
Categories:      10
File Size:       69 KB
Load Time:       ~30 seconds
```

---

## 🎊 Summary

You're all set! You now have:

- 311 free, tested TV channels
- Organized into 10 categories
- Configured in Jellyfin
- Ready to use immediately

**Just open Jellyfin and start watching!** 🎬

---

## 🎬 Transcoding & Performance

### 500 Internal Server Errors?

If you see errors in browser console like:
```
Failed to load resource: the server responded with a status of 500 (Internal Server Error)
POST .../PlaybackInfo 500 (Internal Server Error)
```

**Quick Fix:**
```bash
./scripts/fix_jellyfin_livetv_errors.sh
```

### Verify Hardware Acceleration
```bash
./scripts/verify_jellyfin_hw_acceleration.sh
```

### Optimize Transcoding Settings
```bash
./scripts/optimize_jellyfin_transcoding.sh
```

### Check GPU Usage During Playback
```bash
ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "watch -n 1 intel_gpu_top"'
```

### Monitor CPU Usage
```bash
ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "docker stats jellyfin-simonadmin"'
```

**See also:**
- `JELLYFIN_TRANSCODING_SUMMARY.md` - Issue analysis & solutions
- `JELLYFIN_TRANSCODING_QUICK_REFERENCE.md` - Detailed reference
- `JELLYFIN_TRANSCODING_ANALYSIS.md` - Complete analysis

---

**Last Updated:** October 19, 2025  
**Version:** 1.1  
**Status:** ✅ Ready to Use
