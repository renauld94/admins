# 📺 Jellyfin Live TV Configuration Guide

## 🎯 Current Status
✅ **M3U Tuner Files Installed:**
- `/config/samsung_tv_plus.m3u` (4 channels)
- `/config/plex_live.m3u` (3 channels)  
- `/config/tubi_tv.m3u` (2 channels)

✅ **EPG Files Installed:**
- `/config/epg_us.xml` (US program guide)
- `/config/epg_uk.xml` (UK program guide)
- `/config/epg_de.xml` (German program guide)
- `/config/epg_fr.xml` (French program guide)

## 🔧 Next Steps - Configure in Jellyfin

### Step 1: Access Jellyfin
1. **Open your browser** and go to: http://136.243.155.166:8096/web/
2. **Log in** as: `simonadmin`

### Step 2: Configure Tuner Devices (TV Channels)
1. **Navigate to:** Admin Panel → Live TV
2. **Click** the `+` button next to "Tuner Devices"
3. **Select:** "M3U Tuner"
4. **Configure each tuner:**

   **Tuner 1: Samsung TV Plus**
   - Name: `Samsung TV Plus`
   - M3U URL: `/config/samsung_tv_plus.m3u`
   - Click "Save"

   **Tuner 2: Plex Live**
   - Name: `Plex Live`
   - M3U URL: `/config/plex_live.m3u`
   - Click "Save"

   **Tuner 3: Tubi TV**
   - Name: `Tubi TV`
   - M3U URL: `/config/tubi_tv.m3u`
   - Click "Save"

### Step 3: Configure TV Guide Data Providers (Program Guide)
1. **Click** the `+` button next to "TV Guide Data Providers"
2. **Select:** "XMLTV"
3. **Configure each EPG provider:**

   **EPG Provider 1: US Guide**
   - Name: `US EPG`
   - XMLTV URL: `/config/epg_us.xml`
   - Click "Save"

   **EPG Provider 2: UK Guide**
   - Name: `UK EPG`
   - XMLTV URL: `/config/epg_uk.xml`
   - Click "Save"

   **EPG Provider 3: German Guide**
   - Name: `German EPG`
   - XMLTV URL: `/config/epg_de.xml`
   - Click "Save"

   **EPG Provider 4: French Guide**
   - Name: `French EPG`
   - XMLTV URL: `/config/epg_fr.xml`
   - Click "Save"

### Step 4: Refresh Guide Data
1. **Click** "Refresh Guide Data" button
2. **Wait** for the guide to populate (may take a few minutes)

### Step 5: Access Live TV
1. **Go to** the main Jellyfin menu
2. **Click** "Live TV"
3. **Browse** and watch your channels!

## 📺 What You'll Get

### TV Channels (9 total):
- **Samsung TV Plus:** News, Entertainment, Sports, Movies
- **Plex Live:** News, Entertainment, Movies
- **Tubi TV:** Movies, TV Shows

### Program Guide Features:
- **Show schedules** for all channels
- **Channel information** and descriptions
- **Program details** and descriptions
- **Multi-language support** (US, UK, German, French)

## 🔧 Troubleshooting

### If Live TV doesn't appear:
1. **Check** that all tuners are configured correctly
2. **Verify** EPG providers are added
3. **Refresh** guide data
4. **Restart** Jellyfin container if needed

### If channels don't work:
1. **Check** M3U file paths are correct
2. **Verify** file permissions
3. **Check** container logs for errors

### If program guide is empty:
1. **Wait** for guide data to refresh
2. **Check** EPG file paths are correct
3. **Verify** XML files are valid

## 🎉 Success!

Once configured, you'll have:
- ✅ **9 free TV channels** to watch
- ✅ **Complete program guide** with schedules
- ✅ **Multi-language support**
- ✅ **Professional Live TV experience**

**🌐 Access:** http://136.243.155.166:8096/web/  
**👤 Login:** simonadmin  
**📺 Live TV:** Available in main menu after configuration
