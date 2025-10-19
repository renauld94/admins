# Jellyfin Live TV Channels - Complete Fix & Setup Guide

## 📋 Table of Contents
1. [Quick Fix (5 minutes)](#quick-fix)
2. [Detailed Setup (15 minutes)](#detailed-setup)
3. [Troubleshooting](#troubleshooting)
4. [Recommended Configurations](#recommendations)
5. [Advanced Options](#advanced-options)

---

## 🚀 Quick Fix

### Problem Summary
- TV channels are not appearing in Jellyfin
- No categories/grouping of channels
- M3U file may be too large or improperly formatted

### Step 1: Use the Organized Channel File
Replace your current M3U with the pre-organized one:

**File Location:** `/alternative_m3u_sources/jellyfin-organized-channels.m3u`

This file includes:
- ✅ **100+ channels** properly categorized
- ✅ **9 categories** with emojis for easy navigation:
  - 📰 News Channels
  - ⚽ Sports
  - 🎭 Entertainment
  - 🎬 Movies
  - 🎵 Music
  - 👶 Kids
  - ✝️ Religious
  - 📚 Documentary
  - 🌍 General/International

### Step 2: Add to Jellyfin
1. Go to **Jellyfin Web UI** → `http://136.243.155.166:8096`
2. Click **Settings** (gear icon, top right)
3. Navigate to **Live TV** → **Tuners**
4. Click **"Add Tuner"** or **"Add TV Provider"**
5. Select **"M3U Tuner"** or **"IPTV"**
6. **Option A - Remote URL (Recommended):**
   ```
   Name: Jellyfin Organized Channels
   File or URL: https://raw.githubusercontent.com/renauld94/Learning-Management-System-Academy/save/proxmox-dashboard-20251015T162458/alternative_m3u_sources/jellyfin-organized-channels.m3u
   ```
   
   **Option B - Local File:**
   ```
   Name: Jellyfin Organized Channels (Local)
   File Path: /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/jellyfin-organized-channels.m3u
   ```

7. Enable the tuner ✅
8. Click **Save**

### Step 3: Verify & Refresh
1. Go to **Live TV** → **Guide**
2. Wait 30-60 seconds for channels to populate
3. You should see **9 category groups** with 100+ channels
4. If not showing, try **Refresh Guide** option

---

## 📖 Detailed Setup

### Complete Channel Organization Strategy

#### Option 1: Single Organized M3U (Recommended)
**Use:** `jellyfin-organized-channels.m3u`
- **Pros:** Clean, categorized, fast loading, tested channels
- **Cons:** Limited to 100 channels (can be expanded)
- **Best for:** Casual users, quick setup

#### Option 2: Multiple Category M3U Files
Create separate files for different categories:

```
News Channels: news-channels.m3u
Sports Channels: sports-channels.m3u
Entertainment: entertainment-channels.m3u
Movies: movies-channels.m3u
Kids: kids-channels.m3u
```

**Setup in Jellyfin:**
1. Add 5 different tuners (one per file)
2. Each tuner = one category
3. Better organization, easier management

#### Option 3: Full IPTV-Org Integration
Use the official IPTV-Org project:

```
Global Channels: https://iptv-org.github.io/iptv/index.m3u
US Only: https://iptv-org.github.io/iptv/countries/us.m3u
News: https://iptv-org.github.io/iptv/categories/news.m3u
Sports: https://iptv-org.github.io/iptv/categories/sports.m3u
Entertainment: https://iptv-org.github.io/iptv/categories/entertainment.m3u
Movies: https://iptv-org.github.io/iptv/categories/movies.m3u
Music: https://iptv-org.github.io/iptv/categories/music.m3u
Kids: https://iptv-org.github.io/iptv/categories/kids.m3u
Religious: https://iptv-org.github.io/iptv/categories/religious.m3u
Documentary: https://iptv-org.github.io/iptv/categories/documentary.m3u
```

**Setup:** Add each as a separate tuner (10 tuners total)

---

## 🔧 Troubleshooting

### Issue 1: "No channels found" or "500 error"

**Solution A:** Use Remote URL instead of Local File
```
❌ Wrong: file:///path/to/file.m3u
✅ Right: https://raw.githubusercontent.com/.../file.m3u
```

**Solution B:** Check M3U File Syntax
```bash
# Verify file is valid M3U format
head -20 /path/to/file.m3u

# Should start with:
#EXTM3U
#EXTINF:-1 tvg-id="..." tvg-logo="..." group-title="...",Channel Name
URL_HERE
```

**Solution C:** Restart Jellyfin Service
```bash
# Docker restart
docker restart jellyfin

# Or systemd
sudo systemctl restart jellyfin
```

### Issue 2: Channels appear but no playback

**Causes:**
- ❌ Stream URL is dead/geo-blocked
- ❌ Network connectivity issue
- ❌ Firewall blocking streaming ports

**Solutions:**
1. Test URL manually: `curl -I "stream_url"`
2. Check if URL requires authentication
3. Add HTTP headers if needed:
   ```m3u
   #EXTVLCOPT:http-user-agent=Mozilla/5.0
   #EXTVLCOPT:http-referrer=https://example.com
   ```

### Issue 3: Very slow guide loading

**Problem:** Too many channels (1000+)

**Solutions:**
- Use smaller category files instead of full list
- Keep only working channels
- Split into multiple tuners

### Issue 4: Categories not showing properly

**Solution:** Check group-title formatting
```
✅ Correct: group-title="📰 News"
❌ Wrong: group_title="News" or group-title="News"
```

### Issue 5: Duplicate channels

**Solution:** Don't add same M3U twice
- Check existing tuners in Live TV settings
- Remove duplicates before adding new ones

---

## ⭐ Recommendations

### 1. **Optimal Setup** (Recommended)
- **3 Tuners:**
  - `Channel Package 1` (Local organized file)
  - `Channel Package 2` (IPTV-Org Global)
  - `Channel Package 3` (IPTV-Org Categories)

### 2. **Minimal Setup** (Quick Start)
- **1 Tuner:**
  - Use: `jellyfin-organized-channels.m3u`
  - 100 tested, working channels
  - 9 categories

### 3. **Maximum Variety** (Advanced)
- **10+ Tuners:**
  - One per category from IPTV-Org
  - Complete global coverage
  - Best for TV enthusiasts

### 4. **Performance Tuning**

**Docker Compose Settings:**
```yaml
jellyfin:
  environment:
    - TZ=UTC
    - JELLYFIN_CACHE_ENTRIES=1000
    - JELLYFIN_LIVETV_GUIDE_REFRESH_INTERVAL=3600
```

**Jellyfin Settings:**
- Live TV → Guide
  - Refresh interval: 3600 seconds (1 hour)
  - Only load guide for active channels
  - Enable channel favorites to show subset

---

## 📊 Channel Categories Explained

### 📰 News (11 channels)
- Global news, regional news
- Examples: Al Jazeera, BBC, ABC News

### ⚽ Sports (13 channels)
- Live sports, sports news
- Examples: Abu Dhabi Sports, ESPN, Eurosport

### 🎭 Entertainment (10 channels)
- TV dramas, variety shows
- Examples: ATV, Adom TV, 1+1 International

### 🎬 Movies (9 channels)
- Movie channels, cinema
- Examples: &flix, &pictures, Afriwood Blockbuster

### 🎵 Music (15 channels)
- Music videos, music channels
- Examples: 4 Fun, 9XM, Afrobeats

### 👶 Kids (9 channels)
- Children's programming
- Examples: ABC Kids, 3ABN Kids, Aghapy Kids

### ✝️ Religious (12 channels)
- Religious content, spiritual programs
- Examples: 3ABN, Aastha TV, Al Quran TV

### 📚 Documentary (5 channels)
- Documentary content, educational
- Examples: Al Jazeera Documentary, Adventure Earth

### 🌍 General (20+ channels)
- International general channels
- Examples: ABC Australia, Al Iraqia, Abu Dhabi TV

---

## 🛠️ Advanced Options

### Custom M3U Creation

**Template:**
```m3u
#EXTM3U url-tvg="https://example.com/guide.xml"

#EXTINF:-1 tvg-id="channel.id" tvg-name="Channel Name" tvg-logo="https://example.com/logo.png" group-title="📺 Category", Channel Name
#EXTVLCOPT:http-user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36
stream_url_here
```

### M3U Validation Script
```bash
#!/bin/bash
# Check M3U file validity
FILE="$1"

echo "Checking M3U file: $FILE"
echo "---"

# Count entries
ENTRIES=$(grep -c "^#EXTINF:" "$FILE")
echo "Total entries: $ENTRIES"

# Check for syntax errors
echo "Checking syntax..."
grep -o 'group-title="[^"]*"' "$FILE" | sort | uniq -c | sort -nr

echo "---"
echo "Sample entries (first 5):"
head -20 "$FILE" | tail -10
```

### Docker Configuration
```yaml
version: '3.8'
services:
  jellyfin:
    image: jellyfin/jellyfin:latest
    container_name: jellyfin
    ports:
      - "8096:8096"  # Web UI
      - "8088:8088"  # Discovery
      - "1900:1900/udp"  # SSDP
      - "7359:7359/udp"  # UPnP
    volumes:
      - /home/simon/jellyfin-data/config:/config
      - /home/simon/jellyfin-data/cache:/cache
      - /home/simon/Learning-Management-System-Academy/alternative_m3u_sources:/media/iptv:ro
    environment:
      - TZ=UTC
      - JELLYFIN_PublishedServerUrl=http://136.243.155.166:8096
    restart: unless-stopped
```

### Manual Channel Refresh
```bash
# SSH into Jellyfin container
docker exec -it jellyfin bash

# Clear cache
rm -rf /cache/livetv/*

# Restart service (inside container)
# Or just restart container from host
```

---

## 📞 Support & Troubleshooting

### Check Jellyfin Logs
```bash
docker logs jellyfin | grep -i "livetv\|tuner\|channel"
```

### Test Channel URLs
```bash
# Test if stream URL is accessible
curl -I "https://stream.url/playlist.m3u8"

# Should return 200 OK
```

### Verify Network Connectivity
```bash
# From Jellyfin container
docker exec jellyfin ping google.com

# Or test specific URL
docker exec jellyfin wget -O /tmp/test.m3u "https://raw.githubusercontent.com/..."
```

---

## 📝 Summary

| Task | Time | Difficulty |
|------|------|------------|
| Quick Fix (Single tuner) | 5 min | ⭐ Easy |
| Multiple Categories | 15 min | ⭐⭐ Moderate |
| Full IPTV-Org Setup | 30 min | ⭐⭐ Moderate |
| Custom M3U Creation | 30+ min | ⭐⭐⭐ Advanced |
| Troubleshooting Issues | 15-60 min | ⭐⭐⭐ Advanced |

---

## 🎯 Next Steps

1. ✅ **Try the quick fix** with `jellyfin-organized-channels.m3u`
2. ✅ **Test a few channels** to ensure playback works
3. ✅ **If satisfied**, add additional category tuners
4. ✅ **If issues persist**, use troubleshooting guide above

---

## 📚 Resources

- [IPTV-Org GitHub](https://github.com/iptv-org/iptv)
- [Jellyfin Documentation](https://docs.jellyfin.org/)
- [M3U Format Specification](https://en.wikipedia.org/wiki/M3U)
- [VLC OPT Options](https://www.videolan.org/developers/vlc/modules/stream_filter/httpcookies.c)

---

**Last Updated:** October 19, 2025
**Status:** ✅ Tested & Ready
