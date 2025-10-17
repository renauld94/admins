# 📚 Jellyfin Manual Setup Guide

## 🎯 Current Status
✅ **Jellyfin Server**: Running (10.10.7)  
✅ **User Logged In**: simonadmin  
✅ **Web Interface**: Accessible  
❌ **Media Libraries**: Not configured yet  
❌ **Live TV Channels**: Not configured yet  

## 📋 Step-by-Step Manual Configuration

### Step 1: Configure Media Libraries

Since you're already logged in as `simonadmin`, follow these steps:

1. **Click the gear icon** (⚙️) in the top-right corner (Admin Panel)
2. **Navigate to**: Libraries
3. **Click**: "+" (Add Library) button

#### Create Movies Library:
- **Content Type**: Movies
- **Display Name**: Movies
- **Folders**: Click "+" and add `/media/movies`
- **Click**: OK

#### Create TV Shows Library:
- **Content Type**: TV Shows
- **Display Name**: TV Shows
- **Folders**: Click "+" and add `/media/tvshows`
- **Click**: OK

#### Create Music Library:
- **Content Type**: Music
- **Display Name**: Music
- **Folders**: Click "+" and add `/media/music`
- **Click**: OK

#### Create Books Library:
- **Content Type**: Books
- **Display Name**: Books
- **Folders**: Click "+" and add `/media/books`
- **Click**: OK

### Step 2: Configure Live TV with 2000+ Free Channels

1. **Navigate to**: Admin Panel → Live TV
2. **Click**: "+" next to "Tuner Devices"
3. **Select**: "M3U Tuner"

#### Add Each M3U File:
For each file below, create a new M3U Tuner:

**File 1: GitHub Free-TV (100+ channels)**
- Name: `GitHub Free-TV`
- M3U URL: `/home/simon/Learning-Management-System-Academy/enhanced_channels/free_tv_github.m3u8`
- Click: Save

**File 2: iptv-org Global (1000+ channels)**
- Name: `iptv-org Global`
- M3U URL: `/home/simon/Learning-Management-System-Academy/enhanced_channels/iptv_org.m3u`
- Click: Save

**File 3: US Channels (500+ channels)**
- Name: `US Channels`
- M3U URL: `/home/simon/Learning-Management-System-Academy/enhanced_channels/iptv_us.m3u`
- Click: Save

**File 4: UK Channels (200+ channels)**
- Name: `UK Channels`
- M3U URL: `/home/simon/Learning-Management-System-Academy/enhanced_channels/iptv_uk.m3u`
- Click: Save

**File 5: Canada Channels (150+ channels)**
- Name: `Canada Channels`
- M3U URL: `/home/simon/Learning-Management-System-Academy/enhanced_channels/iptv_ca.m3u`
- Click: Save

**File 6: News Channels (100+ channels)**
- Name: `News Channels`
- M3U URL: `/home/simon/Learning-Management-System-Academy/enhanced_channels/iptv_news.m3u`
- Click: Save

**File 7: Sports Channels (200+ channels)**
- Name: `Sports Channels`
- M3U URL: `/home/simon/Learning-Management-System-Academy/enhanced_channels/iptv_sports.m3u`
- Click: Save

**File 8: Movies Channels (150+ channels)**
- Name: `Movies Channels`
- M3U URL: `/home/simon/Learning-Management-System-Academy/enhanced_channels/iptv_movies.m3u`
- Click: Save

**File 9: Music Channels (100+ channels)**
- Name: `Music Channels`
- M3U URL: `/home/simon/Learning-Management-System-Academy/enhanced_channels/iptv_music.m3u`
- Click: Save

**File 10: Curated Free Channels (30+ channels)**
- Name: `Curated Free Channels`
- M3U URL: `/home/simon/Learning-Management-System-Academy/enhanced_channels/curated_free_channels.m3u`
- Click: Save

**File 11: Samsung TV Plus Enhanced (6 channels)**
- Name: `Samsung TV Plus Enhanced`
- M3U URL: `/home/simon/Learning-Management-System-Academy/enhanced_channels/samsung_tv_plus_enhanced.m3u`
- Click: Save

**File 12: Pluto TV (6 channels)**
- Name: `Pluto TV`
- M3U URL: `/home/simon/Learning-Management-System-Academy/enhanced_channels/pluto_tv.m3u`
- Click: Save

### Step 3: Refresh Guide Data

1. **In Live TV section**, click **"Refresh Guide Data"**
2. **Wait** for the guide to populate (may take a few minutes)

### Step 4: Add Media Content

After creating libraries, add actual media files:

#### For Movies:
- Upload movie files to `/media/movies/`
- Use naming: `Movie Name (Year).ext`
- Supported formats: MP4, MKV, AVI, MOV

#### For TV Shows:
- Upload TV show files to `/media/tvshows/`
- Use structure:
  ```
  /media/tvshows/
  ├── Show Name/
  │   ├── Season 01/
  │   │   ├── Show Name - S01E01 - Episode Title.mp4
  │   │   └── Show Name - S01E02 - Episode Title.mp4
  │   └── Season 02/
  │       └── Show Name - S02E01 - Episode Title.mp4
  ```

#### For Music:
- Upload music files to `/media/music/`
- Use structure:
  ```
  /media/music/
  ├── Artist Name/
  │   ├── Album Name/
  │   │   ├── 01 - Song Title.mp3
  │   │   └── 02 - Song Title.mp3
  ```

### Step 5: Refresh Libraries

1. **Go to**: Admin Panel → Libraries
2. **Click**: "Scan All Libraries"
3. **Wait** for scan to complete

## 🎉 Expected Result

After completing these steps, you should see:

### Main Menu:
- **Movies** - Your movie library
- **TV Shows** - Your TV show library  
- **Music** - Your music library
- **Books** - Your book library
- **Live TV** - 2000+ free TV channels

### Live TV Channels:
- **2000+ free channels** from multiple sources
- **Program guide** with show schedules
- **Channel categories**: News, Sports, Movies, Music, Entertainment, Kids, etc.

### Programs/Movies Page:
- **Your movie library content**
- **Live TV movie channels**
- **Full program information**

## 🚀 Quick Test

To test if everything is working:

1. **Go to**: Live TV section
2. **Browse channels** - you should see 2000+ channels
3. **Click on a channel** to test playback
4. **Check Programs/Movies page** - should show content

## 📞 Troubleshooting

If you don't see channels:
1. **Check file paths** are correct
2. **Refresh Guide Data** again
3. **Restart Jellyfin** if needed
4. **Check logs** in Admin Panel → Logs

## 🌐 Access Your Jellyfin

- **URL**: http://136.243.155.166:8096/web/
- **Login**: simonadmin
- **Status**: ✅ Online and ready to configure!


