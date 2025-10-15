# 🖼️ Fix Missing IPTV Channel Thumbnails

## 📋 Problem

Your Jellyfin console shows these errors:
```
Primary?fillHeight=344&fillWidth=344&quality=96&tag=543b6ca4c9f21c87d81daf7a932499c0:1
Failed to load resource: the server responded with a status of 500 (Internal Server Error)
```

**Cause**: IPTV streams from iptv-org don't include channel logo/thumbnail metadata in their M3U playlists.

**Impact**: Channels work fine, but no logos/thumbnails display in Jellyfin's Live TV interface.

---

## ✅ Solutions

### Solution 1: Add Channel Logos (RECOMMENDED)

Run this automated script to add logos to your playlists:

```bash
cd /home/simon/Learning-Management-System-Academy/scripts
./fix_missing_thumbnails.sh
```

**What it does:**
1. ✅ Downloads all playlists from Jellyfin
2. ✅ Adds `tvg-logo` tags with logo URLs
3. ✅ Uses real logos for popular channels (CNN, BBC, ESPN, etc.)
4. ✅ Uses placeholder images for less common channels
5. ✅ Uploads updated playlists back to Jellyfin
6. ✅ Restarts Jellyfin to load new logos

**Time**: 2-3 minutes  
**Result**: Channel logos appear in Live TV!

---

### Solution 2: Disable Image Download Errors (Quick Fix)

If you don't care about logos, just disable the error messages:

1. **Access**: http://136.243.155.166:8096/web/
2. **Login**: simonadmin
3. **Go to**: Admin Dashboard → Live TV
4. **Click**: TV Guide Data Providers tab
5. **Uncheck**: "Download images" or "Automatically download images"
6. **Save**

**Result**: No more 500 errors in console (but still no logos).

---

## 🎨 Channel Logos Included

The script adds logos for these popular channels:

### News
- CNN, BBC, Fox News, NBC, ABC, CBS
- MSNBC, CNBC, Sky News, Euronews
- Bloomberg, France 24, Al Jazeera

### Entertainment
- MTV, HBO, Discovery Channel
- Disney Channel, Nickelodeon
- Cartoon Network, TLC

### Documentaries
- National Geographic, History Channel
- Animal Planet, Discovery

### Sports
- ESPN (and variants)

### Other
- Food Network, and many more...

---

## 📊 Logo Sources

The script uses logos from:

1. **Wikimedia Commons**: High-quality official logos
2. **iptv-org repository**: Community-maintained channel logos
3. **Placeholder.com**: Generic placeholders for unknown channels

---

## 🔄 Alternative: Manual Logo Addition

If you want to manually add logos to specific channels:

### Step 1: Edit M3U File

Find a channel entry like this:
```
#EXTINF:-1,CNN
http://stream-url-here
```

Change it to:
```
#EXTINF:-1 tvg-logo="https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/CNN.svg/200px-CNN.svg.png",CNN
http://stream-url-here
```

### Step 2: Upload to Jellyfin

```bash
# Edit playlist on VM
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103

# Edit file
docker exec -it jellyfin-simonadmin nano /config/data/playlists/your_playlist.m3u

# Restart Jellyfin
docker restart jellyfin-simonadmin
```

---

## 🧪 Testing

After running the fix script:

1. **Wait 30 seconds** for Jellyfin to restart
2. **Clear browser cache**: Ctrl+Shift+R (or Ctrl+F5)
3. **Access**: http://136.243.155.166:8096/web/#/livetv.html
4. **Check**: Channel logos should appear

---

## 📝 Created Scripts

### `fix_missing_thumbnails.sh` ⭐ RECOMMENDED
- **Purpose**: Complete automated solution
- **Features**: Downloads playlists, adds logos, uploads back
- **Time**: 2-3 minutes
- **Skill level**: Beginner (fully automated)

### `add_channel_logos.sh`
- **Purpose**: Bash-based logo adder
- **Features**: Uses curl and Python to fetch logos
- **Time**: 3-5 minutes
- **Skill level**: Intermediate

### `add_logos.py`
- **Purpose**: Standalone Python script for logo addition
- **Features**: Can be run on any M3U files
- **Usage**: Copy to directory with M3U files and run
- **Skill level**: Advanced

---

## 🎯 Expected Results

### Before Fix:
```
Live TV Interface:
┌─────────────────┐
│                 │  <- No logo
│   Channel Name  │
└─────────────────┘
```

### After Fix:
```
Live TV Interface:
┌─────────────────┐
│  [CNN LOGO]     │  <- Logo appears!
│   CNN           │
└─────────────────┘
```

---

## ⚠️ Important Notes

### Backup
- Original playlists are backed up to `/config/data/playlists/backup_before_logos/`
- You can restore them if needed

### Logo Quality
- **Popular channels**: Get real, high-quality logos
- **Less common channels**: Get placeholder images
- **Unknown channels**: May still show no logo

### Performance
- Adding logos doesn't affect streaming performance
- Logos are loaded separately from streams
- Small file size impact (~100KB per logo)

---

## 🔧 Troubleshooting

### Issue: Script fails to download playlists

**Fix**:
```bash
# Check SSH connection
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker ps'

# Check playlists exist
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker exec jellyfin-simonadmin ls -la /config/data/playlists/'
```

### Issue: Logos still not appearing

**Fix**:
```bash
# Clear Jellyfin cache
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 << 'ENDSSH'
    docker exec jellyfin-simonadmin rm -rf /config/cache/*
    docker restart jellyfin-simonadmin
ENDSSH

# Clear browser cache
# Press Ctrl+Shift+R in browser
```

### Issue: Some logos are broken/missing

**Solution**: This is normal! Not all channels have logos available. The script adds logos for popular channels. Less common channels may still show no logo or placeholder.

---

## 📚 Additional Resources

### Find More Logos

If you want to add logos for specific channels:

1. **Wikimedia Commons**: https://commons.wikimedia.org/
2. **iptv-org logos**: https://github.com/iptv-org/iptv
3. **Custom URLs**: Any public image URL (PNG, JPG, SVG)

### M3U Logo Format

```
#EXTINF:-1 tvg-id="channel.id" tvg-name="Channel Name" tvg-logo="https://url-to-logo.png" group-title="Category",Channel Display Name
http://stream-url
```

---

## 🚀 Quick Start

**Just run this:**

```bash
cd /home/simon/Learning-Management-System-Academy/scripts
./fix_missing_thumbnails.sh
```

**Wait 3 minutes, then refresh Jellyfin. Done!** 🎉

---

## ✅ Success Checklist

After running the script:

- [ ] Script completed without errors
- [ ] Jellyfin restarted successfully
- [ ] Waited 30 seconds for restart
- [ ] Cleared browser cache (Ctrl+Shift+R)
- [ ] Accessed Live TV page
- [ ] Logos visible for major channels (CNN, BBC, ESPN)
- [ ] No more 500 errors in browser console (or much fewer)

---

**🎯 Bottom Line**: The 500 errors are because IPTV channels don't have logos. Running `fix_missing_thumbnails.sh` adds logos automatically. Takes 3 minutes, fixes the problem! 🚀
