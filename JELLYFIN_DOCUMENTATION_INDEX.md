# Jellyfin Documentation Index

**Last Updated:** October 19, 2025  
**Status:** Complete - All Issues Diagnosed & Solutions Provided

---

## 🎯 Current Issue: 500 Internal Server Errors

**Problem:** Browser console showing 500 errors on Primary images and PlaybackInfo  
**Root Cause:** Network connectivity - cannot reach `raw.githubusercontent.com`  
**Impact:** Channel images fail to load, EPG data missing, playback info unavailable  
**Solution Status:** ✅ Fix scripts created and ready to run  

---

## 📚 Documentation Files

### Quick Start & Reference

1. **[JELLYFIN_QUICK_REFERENCE.md](./JELLYFIN_QUICK_REFERENCE.md)**
   - Quick start guide (2 minutes)
   - Common tasks and commands
   - Troubleshooting basics
   - **NEW:** Transcoding troubleshooting section
   - **Status:** Updated with 500 error fixes

2. **[JELLYFIN_TRANSCODING_QUICK_REFERENCE.md](./JELLYFIN_TRANSCODING_QUICK_REFERENCE.md)**
   - Quick reference for transcoding settings
   - Monitoring commands
   - Settings cheat sheet
   - Action checklist
   - **Purpose:** Day-to-day reference

### Detailed Analysis

3. **[JELLYFIN_TRANSCODING_SUMMARY.md](./JELLYFIN_TRANSCODING_SUMMARY.md)** ⭐ **START HERE**
   - Executive summary of current issues
   - Root cause analysis
   - Solution overview
   - Action plan with priorities
   - Expected results
   - **Purpose:** Understand the complete situation

4. **[JELLYFIN_TRANSCODING_ANALYSIS.md](./JELLYFIN_TRANSCODING_ANALYSIS.md)**
   - Comprehensive configuration analysis
   - Hardware acceleration setup review
   - Performance benchmarks
   - Optimization recommendations
   - Testing procedures
   - **Purpose:** Deep technical reference

### Historical Documentation

5. **[JELLYFIN_ENHANCED_CHANNELS_COMPLETE.md](./JELLYFIN_ENHANCED_CHANNELS_COMPLETE.md)**
   - Complete channel setup documentation
   - 311 working channels across 10 categories
   - Channel organization details
   - **Status:** Current and working

6. **[JELLYFIN_SETUP_SUMMARY.md](./JELLYFIN_SETUP_SUMMARY.md)**
   - Initial Jellyfin setup documentation
   - Basic configuration
   - **Status:** Superseded by newer docs

7. **[JELLYFIN_TV_CHANNELS_FIX.md](./JELLYFIN_TV_CHANNELS_FIX.md)**
   - Previous channel configuration fixes
   - Historical reference
   - **Status:** Archived

---

## 🛠️ Scripts & Tools

### Critical Fix Scripts (Run These First)

1. **`scripts/fix_jellyfin_livetv_errors.sh`** ⭐ **RUN FIRST**
   - Fixes network connectivity issues
   - Clears image cache
   - Restarts container with proper DNS
   - Tests connectivity
   - **Usage:** `./scripts/fix_jellyfin_livetv_errors.sh`
   - **Purpose:** Fix 500 Internal Server Errors

2. **`scripts/verify_jellyfin_hw_acceleration.sh`**
   - Verifies Intel VAAPI hardware acceleration
   - Tests GPU passthrough
   - Checks FFmpeg support
   - Runs encoding test
   - **Usage:** `./scripts/verify_jellyfin_hw_acceleration.sh`
   - **Purpose:** Validate hardware acceleration setup

3. **`scripts/optimize_jellyfin_transcoding.sh`**
   - Configuration backup
   - Optimization recommendations
   - Manual adjustment guide
   - Testing procedures
   - **Usage:** `./scripts/optimize_jellyfin_transcoding.sh`
   - **Purpose:** Fine-tune transcoding settings

### Channel Management Scripts

4. **`scripts/fetch-and-test-channels.py`**
   - Fetches latest channels from IPTV-Org
   - Tests each URL for accessibility
   - Creates enhanced M3U file
   - **Usage:** `python3 scripts/fetch-and-test-channels.py`
   - **Purpose:** Update channel list weekly

### Legacy Scripts

5. **`scripts/upgrade_jellyfin_and_fix_livetv.sh`**
   - Previous upgrade script
   - **Status:** Superseded by fix_jellyfin_livetv_errors.sh

6. **`scripts/jellyfin_api_bypass_solution.sh`**
   - Historical API fix attempts
   - **Status:** Archived

---

## 📋 Step-by-Step Action Plan

### Immediate Actions (Do Now)

#### Step 1: Fix Network & 500 Errors

```bash
cd /home/simon/Learning-Management-System-Academy
./scripts/fix_jellyfin_livetv_errors.sh
```

**Expected time:** 5 minutes  
**Expected result:** Container restarted with proper DNS, cache cleared  

#### Step 2: Clear Browser Cache

Press `Ctrl+Shift+R` in browser at:  
<http://136.243.155.166:8096/web/#/livetv.html>

**Expected result:** Fresh page load, no cached 500 errors  

#### Step 3: Verify the Fix

Open browser console (F12) and check for:
- ❌ No Primary image 500 errors
- ❌ No PlaybackInfo 500 errors  
- ✅ Images loading successfully

**If still seeing errors:** See troubleshooting section below

### Validation (Within 1 Hour)

#### Step 4: Verify Hardware Acceleration

```bash
./scripts/verify_jellyfin_hw_acceleration.sh
```

**Expected result:** 6-7 checks should pass  
**If checks fail:** Review script output for specific issues

#### Step 5: Test Playback

1. Open LiveTV: <http://136.243.155.166:8096/web/#/livetv.html>
2. Select a channel
3. Check Dashboard → Activity
4. Look for "hw" in transcode reason

**Expected result:** Video plays smoothly, CPU usage < 20%

### Optimization (This Week)

#### Step 6: Apply Minor Tweaks

```bash
./scripts/optimize_jellyfin_transcoding.sh
```

Then manually in Jellyfin Dashboard:
1. Navigate to: Dashboard → Playback → Transcoding
2. Change "Audio boost" from 2.0 to 1.5
3. Change "Tone mapping desat" from 0 to 0.5
4. (Optional) Test "Subtitle extraction" OFF

**Expected result:** Slightly better audio quality, better HDR rendering

---

## 🔍 Troubleshooting Guide

### Issue: 500 Errors Still Appearing

**Symptoms:**
- Primary image 500 errors in browser console
- PlaybackInfo POST returning 500
- Channel images not loading

**Solutions:**

1. **Verify DNS was updated:**
   ```bash
   ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "docker exec jellyfin-simonadmin cat /etc/resolv.conf"'
   ```
   Should show: `nameserver 8.8.8.8`

2. **Test external connectivity:**
   ```bash
   ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "docker exec jellyfin-simonadmin curl -I https://raw.githubusercontent.com/iptv-org/iptv/master/streams/us.m3u"'
   ```
   Should return: `HTTP/2 200`

3. **Disable external metadata:**
   - Dashboard → Live TV → TV Guide Data Providers
   - Disable automatic refresh
   - Use local M3U playlists only

### Issue: Hardware Acceleration Not Working

**Symptoms:**
- CPU usage > 50% during transcoding
- No "hw" indicator in Dashboard → Activity
- Slow transcode speed

**Solutions:**

1. **Check GPU passthrough:**
   ```bash
   ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "docker exec jellyfin-simonadmin ls -l /dev/dri/renderD128"'
   ```

2. **Verify VAAPI:**
   ```bash
   ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "docker exec jellyfin-simonadmin vainfo"'
   ```

3. **Check Jellyfin logs:**
   ```bash
   ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "docker logs jellyfin-simonadmin | grep -i vaapi"'
   ```

### Issue: Buffering or Stuttering

**Symptoms:**
- Video pauses frequently
- Loading indicator appears
- Transcode speed too slow

**Solutions:**

1. **Increase throttle time:**
   - Dashboard → Playback → Transcoding
   - "Throttle after": 180s → 240s

2. **Use faster preset:**
   - "Encoding preset": Auto → fast

3. **Check network bandwidth:**
   ```bash
   speedtest-cli
   ```

### Issue: Poor Video Quality

**Symptoms:**
- Blocky or pixelated video
- Loss of detail in motion
- Compression artifacts visible

**Solutions:**

1. **Lower CRF values:**
   - H.264 CRF: 23 → 21 (better quality)
   - H.265 CRF: 28 → 25 (better quality)

2. **Use better preset:**
   - "Encoding preset": fast → medium

3. **Verify source quality:**
   - Check source stream bitrate
   - Some channels are naturally low quality

---

## 📊 Monitoring Commands

### Real-Time Monitoring

```bash
# GPU usage during transcoding
ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "watch -n 1 intel_gpu_top"'

# Container resource usage
ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "docker stats jellyfin-simonadmin"'

# Active transcodes
ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "watch -n 2 ls -lh /cache/transcodes/"'

# FFmpeg transcode logs
ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "docker exec jellyfin-simonadmin tail -f /config/log/FFmpeg.Transcode-*.txt"'

# Jellyfin main logs
ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "docker logs -f jellyfin-simonadmin"'
```

### One-Time Checks

```bash
# Check container health
ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "docker ps | grep jellyfin"'

# Count channels
grep -c "^#EXTINF:" alternative_m3u_sources/jellyfin-channels-enhanced.m3u

# Check VAAPI support
ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "docker exec jellyfin-simonadmin /usr/lib/jellyfin-ffmpeg/ffmpeg -hwaccels"'
```

---

## 🔗 Quick Links

### Jellyfin Web Interface

- **Home:** <http://136.243.155.166:8096>
- **Dashboard:** <http://136.243.155.166:8096/web/index.html#!/dashboard.html>
- **LiveTV:** <http://136.243.155.166:8096/web/#/livetv.html>
- **Transcoding Settings:** <http://136.243.155.166:8096/web/index.html#!/encodingsettings.html>
- **Logs:** <http://136.243.155.166:8096/web/index.html#!/log.html>

### External Documentation

- **Jellyfin Docs:** <https://jellyfin.org/docs/>
- **Hardware Acceleration:** <https://jellyfin.org/docs/general/administration/hardware-acceleration/>
- **Intel VAAPI:** <https://jellyfin.org/docs/general/administration/hardware-acceleration/intel/>
- **Troubleshooting:** <https://jellyfin.org/docs/general/administration/troubleshooting/>

---

## 📁 File Locations

### Configuration Files

```
Container: jellyfin-simonadmin
Config: /config/system.xml
Cache: /cache/transcodes/
Logs: /config/log/
```

### Local Files

```
Scripts: /home/simon/Learning-Management-System-Academy/scripts/
Channels: /home/simon/Learning-Management-System-Academy/alternative_m3u_sources/
Docs: /home/simon/Learning-Management-System-Academy/*.md
```

---

## ✅ Configuration Status

### Working Perfectly

- ✅ Hardware Acceleration (Intel VAAPI)
- ✅ Hardware Decoding (All codecs)
- ✅ Hardware Encoding (H264/HEVC)
- ✅ HDR Tone Mapping (VPP + OpenCL)
- ✅ 311 Working Channels
- ✅ 10 Organized Categories
- ✅ Throttling & Segment Management

### Needs Fixing

- 🔴 Network Connectivity (causing 500 errors) - **Fix script ready**
- ⚠️ Audio Boost (2.0 → 1.5) - **Manual adjustment needed**
- ⚠️ Tone Mapping Desat (0.0 → 0.5) - **Manual adjustment needed**

### Optional Testing

- 🟡 Subtitle Extraction (test with OFF)

---

## 🎯 Success Criteria

After running all fixes, you should have:

1. **No 500 errors** in browser console
2. **Channel images loading** successfully
3. **Hardware acceleration working** (CPU < 20%, GPU active)
4. **Smooth playback** without buffering
5. **Good video quality** with proper HDR rendering
6. **All 311 channels accessible** and organized

---

## 📞 Support & Help

### If You Need Help

1. **Check the docs:** Start with JELLYFIN_TRANSCODING_SUMMARY.md
2. **Run diagnostics:** Use the verification script
3. **Check logs:** Use monitoring commands above
4. **Review console:** Browser F12 console for errors

### Backup Before Changes

All scripts create automatic backups:
```
/config/system.xml.backup-YYYYMMDD_HHMMSS
```

To restore:
```bash
ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "docker exec jellyfin-simonadmin cp /config/system.xml.backup-YYYYMMDD_HHMMSS /config/system.xml && docker restart jellyfin-simonadmin"'
```

---

## 🚀 Ready to Start?

**Run this now:**

```bash
cd /home/simon/Learning-Management-System-Academy
./scripts/fix_jellyfin_livetv_errors.sh
```

Then follow the on-screen instructions!

---

**Document Version:** 1.0  
**Last Updated:** October 19, 2025  
**Status:** ✅ Complete - Ready for Action
