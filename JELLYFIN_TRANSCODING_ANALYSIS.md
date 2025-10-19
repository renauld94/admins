# Jellyfin Transcoding Configuration Analysis
**Date:** October 19, 2025  
**Server:** http://136.243.155.166:8096  
**Container:** jellyfin-simonadmin

---

## Current Configuration Summary

### ✅ Hardware Acceleration Status
- **Type:** Intel VAAPI (Video Acceleration API)
- **Device:** `/dev/dri/renderD128`
- **Status:** Properly configured for Intel GPU acceleration

### Enabled Hardware Decoding
- ✅ H264
- ✅ HEVC (H.265)
- ✅ MPEG2
- ✅ VC1
- ✅ VP8
- ✅ VP9
- ✅ AV1
- ✅ HEVC 10bit
- ✅ VP9 10bit
- ✅ HEVC RExt 8/10bit
- ✅ HEVC RExt 12bit

### Enabled Hardware Encoding
- ✅ Hardware encoding enabled
- ✅ Intel Low-Power H.264 encoder
- ✅ Intel Low-Power HEVC encoder
- ✅ HEVC format encoding allowed
- ✅ AV1 format encoding allowed

### HDR/Tone Mapping Configuration
- **VPP Tone Mapping:** Enabled (Intel driver-based)
  - Brightness gain: 16
  - Contrast gain: 1.0
- **OpenCL Tone Mapping:** Enabled
  - Algorithm: BT.2390
  - Mode: Auto
  - Range: Auto
  - Desaturation: 0
  - Peak: 100

---

## Performance Settings

| Setting | Value | Impact |
|---------|-------|--------|
| Thread Count | Auto | ✅ Optimal |
| Encoding Preset | Auto | ✅ Balanced |
| H.265 CRF | 28 | ✅ Good quality/size ratio |
| H.264 CRF | 23 | ✅ Standard quality |
| Max Muxing Queue | 2048 | ✅ Good for complex streams |
| Audio Boost | 2 | ⚠️ High (may cause clipping) |
| VBR Audio | Enabled | ✅ Better quality |

---

## Streaming Optimization

| Feature | Status | Recommendation |
|---------|--------|----------------|
| Throttle Transcodes | Enabled | ✅ Good for resource management |
| Delete Segments | Enabled | ✅ Saves disk space |
| Throttle After | 180s | ✅ Good buffer |
| Keep Segments | 720s (12 min) | ✅ Adequate |
| Subtitle Extraction | Enabled | ⚠️ May cause 500 errors |
| Deinterlacing | YADIF | ✅ Good quality |

---

## Issues Related to Your 500 Errors

### 🔴 Critical Issues

1. **Subtitle Extraction Conflicts**
   ```
   "Allow subtitle extraction on the fly" is ENABLED
   ```
   - This can cause transcoding delays
   - May trigger PlaybackInfo 500 errors
   - **Recommendation:** Test with this DISABLED if you see playback issues

2. **Network Connectivity for Metadata**
   ```
   Error: Resource temporarily unavailable (raw.githubusercontent.com:443)
   ```
   - Cannot fetch channel metadata
   - Cannot download EPG data
   - Cannot cache channel images
   - **Fix:** Applied in fix_jellyfin_livetv_errors.sh

### ⚠️ Potential Issues

3. **Audio Boost Setting (2)**
   - Very high for downmixing
   - May cause audio clipping
   - Standard is 1.0-1.5
   - **Recommendation:** Reduce to 1.5

4. **Tone Mapping Desaturation (0)**
   - Default is 0.5
   - May cause blown-out highlights
   - **Recommendation:** Try 0.5 for HDR content

---

## Hardware Verification Script

```bash
#!/bin/bash
# Verify Intel VAAPI hardware acceleration is working

echo "🔍 Checking Intel GPU Hardware Acceleration"
echo "============================================="

# Check if render device exists
ssh -p 2222 root@136.243.155.166 \
  "ssh simonadmin@10.0.0.103 'docker exec jellyfin-simonadmin ls -l /dev/dri/renderD128'" && \
  echo "✅ Render device accessible" || \
  echo "❌ Render device NOT accessible"

# Check VAAPI capabilities
ssh -p 2222 root@136.243.155.166 \
  "ssh simonadmin@10.0.0.103 'docker exec jellyfin-simonadmin vainfo --display drm --device /dev/dri/renderD128'" && \
  echo "✅ VAAPI working" || \
  echo "⚠️ VAAPI may not be working"

# Check FFmpeg hardware acceleration support
ssh -p 2222 root@136.243.155.166 \
  "ssh simonadmin@10.0.0.103 'docker exec jellyfin-simonadmin /usr/lib/jellyfin-ffmpeg/ffmpeg -hwaccels'" | grep vaapi && \
  echo "✅ FFmpeg VAAPI support detected" || \
  echo "❌ FFmpeg VAAPI support missing"

# Check Intel GPU usage during transcoding
echo ""
echo "📊 To monitor GPU usage during transcoding:"
echo "ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 \"docker exec jellyfin-simonadmin intel_gpu_top\"'"
```

---

## Optimization Recommendations

### 🎯 Immediate Actions

1. **Fix Network Connectivity** (Priority 1)
   ```bash
   ./scripts/fix_jellyfin_livetv_errors.sh
   ```

2. **Adjust Audio Boost** (Priority 2)
   - Change from `2` to `1.5`
   - Prevents audio clipping

3. **Test Subtitle Extraction OFF** (Priority 3)
   - Temporarily disable "Allow subtitle extraction on the fly"
   - See if PlaybackInfo 500 errors stop

### 🔧 Performance Tuning

4. **Encoding Preset Optimization**
   - Current: `Auto`
   - For better quality: `slow` or `medium`
   - For better performance: `fast` or `veryfast`
   - **Recommendation:** Try `fast` for LiveTV

5. **Tone Mapping Adjustments for HDR**
   - Desaturation: Change `0` → `0.5`
   - This prevents blown-out colors in highlights

6. **Segment Management**
   - Current settings are good for most use cases
   - If experiencing buffering: Increase "Throttle after" to 240s

### 📊 Monitoring

7. **Enable Debug Logging**
   - Dashboard → Logs
   - Enable FFmpeg debug logging
   - Monitor during playback issues

8. **Check Transcode Activity**
   - Dashboard → Activity
   - Watch for:
     - Hardware acceleration being used
     - Transcoding failures
     - Quality selection issues

---

## Testing Procedure

### Test 1: Verify Hardware Acceleration

```bash
# 1. Start a LiveTV stream that requires transcoding
# 2. Check Jellyfin Dashboard → Activity
# 3. Look for "hw" or "VAAPI" in transcode reason
# 4. Monitor CPU usage (should be low if HW accel working)
```

### Test 2: Check Image Loading

```bash
# Clear browser cache
# Navigate to: http://136.243.155.166:8096/web/#/livetv.html
# Open browser console (F12)
# Look for:
#   - Primary image 500 errors (should be fixed after network fix)
#   - Image loading times
#   - Any remaining errors
```

### Test 3: PlaybackInfo Endpoint

```bash
# Test direct API endpoint
curl -H "X-Emby-Token: 415b13e6a3044c938ce15f72a0bb1a47" \
  "http://136.243.155.166:8096/Items/0cb14b76758ea52791c428255e4750c8/PlaybackInfo" \
  -v
```

---

## Performance Benchmarks

### Expected CPU Usage with Hardware Acceleration

| Scenario | CPU Usage | GPU Usage |
|----------|-----------|-----------|
| No transcoding | <5% | 0% |
| H264 HW decode | 5-10% | 10-20% |
| HEVC HW decode + encode | 10-15% | 30-50% |
| HDR tone mapping | 15-25% | 40-70% |
| Software fallback | 60-100% | 0% |

### Expected Transcoding Speed

- **H264 → H264:** 4x-8x realtime
- **HEVC → H264:** 2x-4x realtime
- **HDR → SDR (tone map):** 1.5x-3x realtime

---

## Troubleshooting Commands

```bash
# Check if hardware acceleration is actually being used
ssh -p 2222 root@136.243.155.166 \
  "ssh simonadmin@10.0.0.103 'docker exec jellyfin-simonadmin \
  cat /config/log/log_*.txt | grep -i \"vaapi\|hwaccel\"'"

# Monitor active transcoding sessions
ssh -p 2222 root@136.243.155.166 \
  "ssh simonadmin@10.0.0.103 'docker exec jellyfin-simonadmin \
  ls -lh /cache/transcodes/'"

# Check FFmpeg transcode logs
ssh -p 2222 root@136.243.155.166 \
  "ssh simonadmin@10.0.0.103 'docker exec jellyfin-simonadmin \
  tail -100 /config/log/FFmpeg.Transcode-*.txt'"
```

---

## Configuration Backup

Your current transcoding configuration is excellent and well-optimized. Before making changes:

```bash
# Backup Jellyfin config
ssh -p 2222 root@136.243.155.166 \
  "ssh simonadmin@10.0.0.103 'docker exec jellyfin-simonadmin \
  cp /config/system.xml /config/system.xml.backup-$(date +%Y%m%d)'"
```

---

## Quick Reference

### Best Settings for Your Intel GPU

| Setting | Optimal Value | Current | Status |
|---------|--------------|---------|--------|
| Hardware Encoding | Enabled | ✅ Enabled | ✅ |
| Low-Power Encoders | Enabled | ✅ Enabled | ✅ |
| Tone Mapping | BT.2390 | ✅ BT.2390 | ✅ |
| Encoding Preset | fast/medium | Auto | ⚠️ |
| Audio Boost | 1.5 | 2.0 | ⚠️ |
| Tone Map Desat | 0.5 | 0.0 | ⚠️ |
| Subtitle Extract | OFF | ON | ⚠️ |

---

## Next Steps

1. ✅ Run network connectivity fix
2. ⚠️ Adjust audio boost to 1.5
3. ⚠️ Change tone mapping desaturation to 0.5
4. ⚠️ Test with subtitle extraction OFF
5. ✅ Monitor logs for remaining errors
6. ✅ Verify hardware acceleration is being used

---

## Support & Documentation

- **Jellyfin Hardware Acceleration:** https://jellyfin.org/docs/general/administration/hardware-acceleration/
- **Intel VAAPI Guide:** https://jellyfin.org/docs/general/administration/hardware-acceleration/intel/
- **FFmpeg VAAPI:** https://trac.ffmpeg.org/wiki/Hardware/VAAPI

---

*Generated: October 19, 2025*
