# 📺 Organized Channel Playlists - Setup Guide

## ✅ Organization Complete!

Your 11,337 channels have been organized into manageable playlists by country.

## 📊 Available Playlists

### **Country-Based Playlists (WORKING)**
- ✅ **US_channels.m3u** - 1,484 US channels
- ✅ **UK_channels.m3u** - 213 UK channels  
- ✅ **DE_channels.m3u** - 273 German channels
- ✅ **FR_channels.m3u** - 196 French channels
- ✅ **ES_channels.m3u** - 291 Spanish channels
- ✅ **IT_channels.m3u** - 366 Italian channels
- ✅ **CA_channels.m3u** - 174 Canadian channels
- ✅ **AU_channels.m3u** - 65 Australian channels

**Total Organized Channels: 3,062 channels**

### **Category Playlists (Empty)**
⚠️ News, Sports, Movies, Kids, Music, Entertainment, Documentary, and Lifestyle playlists are empty because the source iptv-org playlist doesn't include proper category tags.

---

## 🎯 Recommended Setup

Add these playlists to Jellyfin for the best experience (~2,500 channels):

1. **US_channels.m3u** (1,484 channels) - Most content
2. **UK_channels.m3u** (213 channels) - BBC, Sky, etc.
3. **CA_channels.m3u** (174 channels) - CBC, CTV, etc.
4. **DE_channels.m3u** (273 channels) - German content
5. **FR_channels.m3u** (196 channels) - French content

---

## 📝 How to Add to Jellyfin

### **Step 1: Remove Old Large Tuner**

1. Open: http://136.243.155.166:8096/web/
2. Login as: **simonadmin**
3. Go to: **Dashboard** → **Live TV** → **Tuner Devices**
4. Find the tuner with **11,337 channels** (iptv_org_international.m3u)
5. Click **Delete** (⚠️ This will remove the overwhelming channel list)

### **Step 2: Add Organized Tuners**

For each playlist you want to add:

1. Click **"+"** (Add Tuner Device)
2. Select: **M3U Tuner**
3. **File or URL**: `/config/data/playlists/clean/US_channels.m3u`
4. **Simultaneous stream limit**: `0` (unlimited)
5. **Fallback max stream bitrate**: `30` Mbps
6. Click **Save**

Repeat for each country you want:
- `/config/data/playlists/clean/UK_channels.m3u`
- `/config/data/playlists/clean/CA_channels.m3u`
- `/config/data/playlists/clean/DE_channels.m3u`
- etc.

### **Step 3: Verify Channels**

1. Go to: http://136.243.155.166:8096/web/#/livetv.html
2. You should now see your organized channels by country
3. Much easier to browse than 11,000+ channels!

---

## 🎬 About EPG (Program Guide)

**Current Status**: ❌ No EPG data available

The organized playlists **work perfectly for Live TV streaming**, but you won't see:
- Movie listings
- TV show schedules  
- Sports event times
- What's currently playing

### **To Get EPG Data (Optional):**

**Option 1: Schedules Direct (BEST - $25/year)**
- Free 7-day trial: https://www.schedulesdirect.org/
- Most comprehensive EPG for US/CA/UK
- Setup: Dashboard → Live TV → TV Guide Data Providers → Add "Schedules Direct"

**Option 2: Use Live TV Without EPG (FREE)**
- Your channels work perfectly for live streaming
- Just browse by country and channel name
- No program information, but all streams work

---

## 📊 Channel Statistics

| Playlist | Channels | File Size | Status |
|----------|----------|-----------|--------|
| US | 1,484 | 403 KB | ✅ Ready |
| IT | 366 | 90 KB | ✅ Ready |
| ES | 291 | 79 KB | ✅ Ready |
| DE | 273 | 78 KB | ✅ Ready |
| UK | 213 | 52 KB | ✅ Ready |
| FR | 196 | 62 KB | ✅ Ready |
| CA | 174 | 40 KB | ✅ Ready |
| AU | 65 | 14 KB | ✅ Ready |

---

## 🔧 Troubleshooting

**Playlist file not found?**
- Check path: `/config/data/playlists/clean/`
- Make sure you're using the **exact** path shown above

**Channels not loading?**
- Some channels may be geo-blocked (use ProtonVPN)
- Some streams may be offline (normal for free IPTV)
- Wait 30 seconds for playlist to process

**Want to re-organize?**
- Run: `/home/simon/Learning-Management-System-Academy/scripts/quick_organize_channels.sh`
- This will recreate all playlists from scratch

---

## 📺 Enjoy Your Organized Channels!

You've gone from **11,337 overwhelming channels** to **~3,000 organized channels by country**. Much easier to browse and find content!

**Live TV**: http://136.243.155.166:8096/web/#/livetv.html
