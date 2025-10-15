# Manual iptv-org Channels Setup Guide

## Overview
This guide will help you manually add 5 different iptv-org channel categories to your Jellyfin Live TV setup.

## Channel Categories to Add

1. **iptv-org Global**: 1000+ global channels
2. **iptv-org US Channels**: US-specific channels  
3. **iptv-org News**: News channels worldwide
4. **iptv-org Sports**: Sports channels
5. **iptv-org Movies**: Movie channels

## Step-by-Step Instructions

### Step 1: Access Jellyfin Live TV Settings
1. Open your browser and go to: `http://136.243.155.166:8096/web/#/home.html`
2. Log in as `simonadmin` if not already logged in
3. Click on the **Settings** gear icon (top right)
4. Go to **Live TV** in the left sidebar

### Step 2: Add iptv-org Global Tuner
1. Click **"Add TV Provider"** or **"Add Tuner"**
2. Select **"M3U Tuner"** as the type
3. Fill in the details:
   - **Name**: `iptv-org Global`
   - **File or URL**: `https://iptv-org.github.io/iptv/index.m3u`
   - **Enable**: ✅ (checked)
4. Click **"Save"**

### Step 3: Add iptv-org US Channels Tuner
1. Click **"Add TV Provider"** or **"Add Tuner"** again
2. Select **"M3U Tuner"** as the type
3. Fill in the details:
   - **Name**: `iptv-org US Channels`
   - **File or URL**: `https://iptv-org.github.io/iptv/countries/us.m3u`
   - **Enable**: ✅ (checked)
4. Click **"Save"**

### Step 4: Add iptv-org News Tuner
1. Click **"Add TV Provider"** or **"Add Tuner"** again
2. Select **"M3U Tuner"** as the type
3. Fill in the details:
   - **Name**: `iptv-org News`
   - **File or URL**: `https://iptv-org.github.io/iptv/categories/news.m3u`
   - **Enable**: ✅ (checked)
4. Click **"Save"**

### Step 5: Add iptv-org Sports Tuner
1. Click **"Add TV Provider"** or **"Add Tuner"** again
2. Select **"M3U Tuner"** as the type
3. Fill in the details:
   - **Name**: `iptv-org Sports`
   - **File or URL**: `https://iptv-org.github.io/iptv/categories/sports.m3u`
   - **Enable**: ✅ (checked)
4. Click **"Save"**

### Step 6: Add iptv-org Movies Tuner
1. Click **"Add TV Provider"** or **"Add Tuner"** again
2. Select **"M3U Tuner"** as the type
3. Fill in the details:
   - **Name**: `iptv-org Movies`
   - **File or URL**: `https://iptv-org.github.io/iptv/categories/movies.m3u`
   - **Enable**: ✅ (checked)
4. Click **"Save"**

### Step 7: Refresh the Guide
1. After adding all tuners, go to **Live TV** → **Guide**
2. Click **"Refresh Guide"** or wait for automatic refresh
3. The guide should populate with channels from all 5 tuners

## Expected Results

After completing all steps, you should have:

- **5 new tuners** in your Live TV settings
- **1000+ channels** from iptv-org Global
- **US-specific channels** from iptv-org US
- **News channels** from iptv-org News
- **Sports channels** from iptv-org Sports
- **Movie channels** from iptv-org Movies

## Troubleshooting

### If you get "500 Internal Server Error":
- Try using the direct URLs instead of local file paths
- Make sure you're logged in as `simonadmin`
- Restart Jellyfin if needed

### If channels don't appear:
- Wait 5-10 minutes for the guide to refresh
- Check that all tuners are enabled
- Verify the URLs are accessible

### If you see "The path could not be found":
- Use the direct URLs provided above
- Don't use local file paths

## Alternative: Use Existing Working Tuners

If the above doesn't work, you can also try adding these URLs to your existing working tuners by editing them and changing the URL to one of the iptv-org URLs.

## Verification

To verify everything is working:
1. Go to **Live TV** → **Guide**
2. You should see channels from all categories
3. Try playing a channel to test functionality

---

**Note**: These are all free, legal IPTV channels from the iptv-org project. The channels are publicly available and don't require any subscription.

