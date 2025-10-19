# 🎬 Jellyfin TV Channels - Quick Reference

## ⚡ The Problem
- ❌ TV channels not working in Jellyfin
- ❌ No categories/grouping visible
- ❌ M3U file issues or too large

## ✅ The Solution (3 Easy Steps)

### Step 1️⃣ - Access Jellyfin Settings (2 min)
```
URL: http://136.243.155.166:8096
Settings → Live TV → Tuners
```

### Step 2️⃣ - Add New Tuner (2 min)
**Click:** "Add Tuner" → Select "M3U Tuner"

**Fill in:**
- **Name:** `Jellyfin Organized Channels`
- **File/URL:** `/home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-organized-channels.m3u`
- **Enable:** ✅

**Click:** Save

### Step 3️⃣ - View Channels (2 min)
```
Live TV → Guide
Wait 30-60 seconds for channels to populate
```

---

## 📊 What You Get

| Category | Icon | Count |
|----------|------|-------|
| News | 📰 | 11 |
| Sports | ⚽ | 13 |
| Entertainment | 🎭 | 10 |
| Movies | 🎬 | 9 |
| Music | 🎵 | 15 |
| Kids | 👶 | 9 |
| Religious | ✝️ | 12 |
| Documentary | 📚 | 5 |
| General/Intl | 🌍 | 20+ |

**Total: 100+ Working Channels**

---

## 🔧 If It Doesn't Work

### Issue: "Channel not found" / "500 error"
```bash
✅ Solution 1: Use REMOTE URL instead
https://raw.githubusercontent.com/renauld94/Learning-Management-System-Academy/main/alternative_m3u_sources/jellyfin-organized-channels.m3u

✅ Solution 2: Restart Jellyfin
docker restart jellyfin

✅ Solution 3: Clear cache and refresh
- Live TV → Settings → Clear Guide Data
- Wait 5 minutes
- Refresh Guide
```

### Issue: Channels appear but won't play
```bash
✅ This is normal - some channels:
  - Are geo-blocked (region-restricted)
  - Have dead streams
  - Require authentication

Try other channels in the list instead.
```

### Issue: Channels loading very slowly
```bash
✅ Don't add too many M3U files at once
✅ Keep to one organized file initially
✅ Add more tuners gradually after testing
```

---

## 📋 Alternative Setup Options

### Option 1: IPTV-Org Categories (More Channels)
Add these as separate tuners for 1000+ channels total:

```
Category          | URL
------------------+-----------------------------------------------
News              | https://iptv-org.github.io/iptv/categories/news.m3u
Sports            | https://iptv-org.github.io/iptv/categories/sports.m3u
Entertainment     | https://iptv-org.github.io/iptv/categories/entertainment.m3u
Movies            | https://iptv-org.github.io/iptv/categories/movies.m3u
Music             | https://iptv-org.github.io/iptv/categories/music.m3u
Kids              | https://iptv-org.github.io/iptv/categories/kids.m3u
Documentary      | https://iptv-org.github.io/iptv/categories/documentary.m3u
Religious        | https://iptv-org.github.io/iptv/categories/religious.m3u
Lifestyle        | https://iptv-org.github.io/iptv/categories/lifestyle.m3u
Shop             | https://iptv-org.github.io/iptv/categories/shop.m3u
```

### Option 2: Country-Specific (US Only Example)
```
URL: https://iptv-org.github.io/iptv/countries/us.m3u
(1000+ US channels)
```

---

## 🛠️ Useful Commands

### Test M3U File Validity
```bash
head -1 /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-organized-channels.m3u
# Should show: #EXTM3U
```

### Count Channels
```bash
grep "^#EXTINF:" /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-organized-channels.m3u | wc -l
# Should show: ~100
```

### List Categories
```bash
grep -o 'group-title="[^"]*"' /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-organized-channels.m3u | sort | uniq
# Shows all available categories
```

### Check Jellyfin Logs
```bash
docker logs jellyfin | grep -i "livetv\|tuner" | tail -20
```

### Restart Jellyfin
```bash
docker restart jellyfin
# Wait 30 seconds for startup
```

### Clear Jellyfin Cache
```bash
docker exec jellyfin rm -rf /cache/livetv/*
docker restart jellyfin
```

---

## 🎯 Recommended Setup

**For Most Users:**
- 1 tuner: Use `jellyfin-organized-channels.m3u`
- 100+ quality channels
- 9 well-organized categories
- No complexity, just works

**For Sports/News Focus:**
- 2-3 tuners:
  - Organized file (default)
  - IPTV-Org News category
  - IPTV-Org Sports category

**For Maximum Variety:**
- 8-10 tuners:
  - One per IPTV-Org category
  - 1000+ channels
  - Complete global coverage

---

## 📞 Support Files

| File | Purpose |
|------|---------|
| `jellyfin-organized-channels.m3u` | Pre-organized 100+ channels |
| `JELLYFIN_TV_CHANNELS_FIX.md` | Detailed setup guide |
| `jellyfin-iptv-setup.sh` | Helper script for troubleshooting |
| `manual_iptv_org_setup_guide.md` | Manual IPTV-Org setup |

---

## 🎬 Example Workflows

### Workflow 1: Quick Start (5 min)
```
1. Go to Jellyfin Settings → Live TV
2. Add tuner using: jellyfin-organized-channels.m3u
3. Wait 1 minute
4. View channels in Live TV → Guide
5. Done! ✅
```

### Workflow 2: Full Setup (15 min)
```
1. Add main organized file (Step 1)
2. Add IPTV-Org News category (Step 2)
3. Add IPTV-Org Sports category (Step 3)
4. Wait 2 minutes
5. Refresh guide data
6. Browse multiple category tuners ✅
```

### Workflow 3: Troubleshooting (30 min)
```
1. Run diagnostic script
2. Check logs
3. Clear cache
4. Restart Jellyfin
5. Test with different tuner
6. Check network connectivity
7. Verify URLs work manually
8. Adjust settings and retry ✅
```

---

## 📱 Testing Individual Channels

### Manual Test (Linux)
```bash
# Test if stream is accessible
curl -I "https://example.com/stream.m3u8"

# Try to download first segment
timeout 10 curl "https://example.com/stream.m3u8" | head -100
```

### Using Helper Script
```bash
# Make script executable
chmod +x ~/Learning-Management-System-Academy/scripts/jellyfin-iptv-setup.sh

# Run interactive menu
~/Learning-Management-System-Academy/scripts/jellyfin-iptv-setup.sh

# Or use commands:
./jellyfin-iptv-setup.sh validate
./jellyfin-iptv-setup.sh show
./jellyfin-iptv-setup.sh diagnostic
```

---

## ✨ Tips & Tricks

1. **Faster Loading:** Keep guide refresh to 1 hour (3600 sec)
2. **Better Organization:** Add one tuner per category
3. **Geo-Blocking:** Some streams only work in specific regions
4. **Dead Streams:** Check if URL works before adding
5. **Performance:** Don't add 1000+ channels on slow internet
6. **Favorites:** Mark favorite channels to see subset in guide
7. **Custom M3U:** Create your own by selecting best working URLs
8. **Backup:** Save working M3U configs before experimenting

---

## 📊 Status Check

✅ M3U File: Ready
✅ 100+ Channels: Verified  
✅ 9 Categories: Organized
✅ Quick Setup: 5 minutes
✅ Helper Script: Available
✅ Troubleshooting Guide: Included

**You're all set! Start with Step 1 above.** 🚀

---

**Last Updated:** October 19, 2025  
**Version:** 1.0  
**Status:** ✅ Tested & Ready  
