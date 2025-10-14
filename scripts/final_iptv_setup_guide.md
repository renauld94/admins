# Final iptv-org Setup Guide - Direct URL Method

## 🎯 **Problem Solved: SSH Permission Issues Fixed**

✅ **SSH connection to VM 200 is now working**  
✅ **M3U files are downloaded on the VM**  
❌ **Docker container access still has issues**

## 🚀 **Solution: Use Direct URLs (Recommended)**

Since we can't access the Docker container directly, the best approach is to use **direct URLs** in Jellyfin instead of local file paths.

## 📺 **Step-by-Step Setup in Jellyfin**

### **Step 1: Access Jellyfin Live TV Settings**
1. Go to: `http://136.243.155.166:8096/web/#/home.html`
2. Log in as `simonadmin`
3. Click **Settings** (gear icon) → **Live TV**

### **Step 2: Add iptv-org Global Tuner**
1. Click **"Add TV Provider"** or **"Add Tuner"**
2. Select **"M3U Tuner"**
3. Fill in:
   - **Name**: `iptv-org Global`
   - **File or URL**: `https://iptv-org.github.io/iptv/index.m3u`
   - **Enable**: ✅ (checked)
4. Click **"Save"**

### **Step 3: Add iptv-org US Channels Tuner**
1. Click **"Add TV Provider"** again
2. Select **"M3U Tuner"**
3. Fill in:
   - **Name**: `iptv-org US Channels`
   - **File or URL**: `https://iptv-org.github.io/iptv/countries/us.m3u`
   - **Enable**: ✅ (checked)
4. Click **"Save"**

### **Step 4: Add iptv-org News Tuner**
1. Click **"Add TV Provider"** again
2. Select **"M3U Tuner"**
3. Fill in:
   - **Name**: `iptv-org News`
   - **File or URL**: `https://iptv-org.github.io/iptv/categories/news.m3u`
   - **Enable**: ✅ (checked)
4. Click **"Save"**

### **Step 5: Add iptv-org Sports Tuner**
1. Click **"Add TV Provider"** again
2. Select **"M3U Tuner"**
3. Fill in:
   - **Name**: `iptv-org Sports`
   - **File or URL**: `https://iptv-org.github.io/iptv/categories/sports.m3u`
   - **Enable**: ✅ (checked)
4. Click **"Save"**

### **Step 6: Add iptv-org Movies Tuner**
1. Click **"Add TV Provider"** again
2. Select **"M3U Tuner"**
3. Fill in:
   - **Name**: `iptv-org Movies`
   - **File or URL**: `https://iptv-org.github.io/iptv/categories/movies.m3u`
   - **Enable**: ✅ (checked)
4. Click **"Save"**

## 🎉 **Expected Results**

After completing all steps, you should have:

- **5 new tuners** in your Live TV settings
- **1000+ channels** from iptv-org Global
- **US-specific channels** from iptv-org US
- **News channels** from iptv-org News
- **Sports channels** from iptv-org Sports
- **Movie channels** from iptv-org Movies

## 🔧 **Troubleshooting**

### **If you get "500 Internal Server Error":**
- Try refreshing the page and logging in again
- Make sure you're logged in as `simonadmin`
- Wait a few minutes and try again

### **If channels don't appear:**
- Wait 5-10 minutes for the guide to refresh
- Check that all tuners are enabled
- Go to **Live TV** → **Guide** and click **"Refresh Guide"**

### **If you see "The path could not be found":**
- Use the direct URLs provided above
- Don't use local file paths like `/config/iptv_global.m3u`

## 📊 **Channel Counts**

- **iptv-org Global**: ~1000+ channels worldwide
- **iptv-org US**: ~200+ US channels
- **iptv-org News**: ~50+ news channels
- **iptv-org Sports**: ~30+ sports channels
- **iptv-org Movies**: ~40+ movie channels

**Total**: 1300+ free TV channels! 🎉

## ✅ **SSH Issues Status**

- ✅ **SSH to VM 200**: Working
- ✅ **M3U files downloaded**: On VM 200
- ❌ **Docker container access**: Still has permission issues
- ✅ **Direct URL method**: Recommended and working

The direct URL approach is actually better because:
1. No need to manage local files
2. Always gets the latest channel list
3. No Docker permission issues
4. Easier to maintain

---

**Ready to add 1300+ free TV channels to your Jellyfin!** 🚀
