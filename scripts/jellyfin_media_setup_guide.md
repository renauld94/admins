# 📚 Jellyfin Media Library Setup Guide

## 🎯 Problem Identified
You're not seeing any content at: http://136.243.155.166:8096/web/#/list.html?type=Programs&IsMovie=true&serverId=50bf6986207b499e9ee3e129aee803ca

**Reason**: No media libraries are configured yet in Jellyfin.

## ✅ Solution: Manual Library Setup

### Step 1: Access Jellyfin Admin Panel
1. **Go to**: http://136.243.155.166:8096/web/
2. **Login as**: `simonadmin`
3. **Click**: Admin Panel (gear icon)

### Step 2: Create Media Libraries
1. **Navigate to**: Libraries
2. **Click**: "+" (Add Library)
3. **Create these libraries**:

#### Movies Library
- **Content Type**: Movies
- **Display Name**: Movies
- **Folders**: Add folder `/media/movies`
- **Click**: OK

#### TV Shows Library
- **Content Type**: TV Shows
- **Display Name**: TV Shows
- **Folders**: Add folder `/media/tvshows`
- **Click**: OK

#### Music Library
- **Content Type**: Music
- **Display Name**: Music
- **Folders**: Add folder `/media/music`
- **Click**: OK

### Step 3: Add Media Content
After creating libraries, you need to add actual media files:

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

### Step 4: Refresh Libraries
1. **Go to**: Admin Panel → Libraries
2. **Click**: "Scan All Libraries"
3. **Wait** for scan to complete

### Step 5: Access Your Content
1. **Return to**: Main Jellyfin page
2. **Click**: Movies, TV Shows, or Music
3. **Browse** your content!

## 🎯 Quick Test
To test if libraries are working:

1. **Create a test file**:
   ```bash
   # SSH into your VM and create a test movie
   echo "Test Movie Content" > /media/movies/test_movie.txt
   ```

2. **Refresh libraries** in Jellyfin admin panel

3. **Check** if the test file appears in your Movies library

## 🔧 Alternative: Use Existing Content
If you have media files elsewhere, you can:

1. **Copy files** to the media directories
2. **Use symbolic links** to point to existing content
3. **Mount external drives** to the media directories

## 📋 Summary
The empty Programs page is because:
- ✅ Jellyfin is running correctly
- ❌ No media libraries are configured
- ❌ No media content is available

**Fix**: Follow the steps above to create libraries and add content!

## 🌐 Access Your Jellyfin
- **URL**: http://136.243.155.166:8096/web/
- **Login**: simonadmin
- **Admin Panel**: Click gear icon → Libraries


