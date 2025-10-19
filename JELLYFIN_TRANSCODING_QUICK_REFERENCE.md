# Jellyfin Transcoding Quick Reference

**Date:** October 19, 2025  
**Server:** <http://136.243.155.166:8096>

---

## 🎯 Your Configuration Status

### ✅ What's Already Perfect

- **Intel VAAPI Hardware Acceleration:** Fully enabled
- **Hardware Decoding:** All formats enabled (H264, HEVC, VP9, AV1)
- **Hardware Encoding:** Low-power encoders enabled
- **HDR Support:** Both VPP and OpenCL tone mapping configured
- **Throttling & Segment Management:** Optimally configured

### ⚠️ What Needs Attention

1. **Network Connectivity Issues** (CRITICAL)
   - Cannot reach `raw.githubusercontent.com`
   - Causing 500 errors on channel images
   - Causing PlaybackInfo failures

2. **Audio Boost Too High**
   - Current: 2.0
   - Recommended: 1.5
   - Issue: May cause audio clipping

3. **Tone Mapping Desaturation Low**
   - Current: 0.0
   - Recommended: 0.5
   - Issue: May cause blown-out highlights in HDR

4. **Subtitle Extraction Enabled**
   - May contribute to PlaybackInfo 500 errors
   - Test with this disabled

---

## 🚀 Quick Fix Commands

### Fix Network & Image Issues

```bash
# Run the complete network fix
./scripts/fix_jellyfin_livetv_errors.sh
```

### Verify Hardware Acceleration

```bash
# Check if Intel GPU is working properly
./scripts/verify_jellyfin_hw_acceleration.sh
```

### Apply Transcoding Optimizations

```bash
# Get optimization guide
./scripts/optimize_jellyfin_transcoding.sh
```

---

## 📊 Monitoring Commands

### Watch GPU Usage

```bash
ssh -p 2222 root@136.243.155.166 \
  'ssh simonadmin@10.0.0.103 "watch -n 1 intel_gpu_top"'
```

### Watch Container Stats

```bash
ssh -p 2222 root@136.243.155.166 \
  'ssh simonadmin@10.0.0.103 "docker stats jellyfin-simonadmin"'
```

### Watch Transcode Logs

```bash
ssh -p 2222 root@136.243.155.166 \
  'ssh simonadmin@10.0.0.103 "docker exec jellyfin-simonadmin tail -f /config/log/FFmpeg.Transcode-*.txt"'
```

### Check Active Transcodes

```bash
ssh -p 2222 root@136.243.155.166 \
  'ssh simonadmin@10.0.0.103 "docker exec jellyfin-simonadmin ls -lh /cache/transcodes/"'
```

---

## 🎬 Manual Settings to Adjust

Access: **Dashboard → Playback → Transcoding**

### Priority 1: Audio Settings

- **Audio boost when downmixing:** Change `2` → `1.5`

### Priority 2: HDR Settings

- **Tone mapping desat:** Change `0` → `0.5`

### Priority 3: Test Subtitle Extraction

- **Allow subtitle extraction on the fly:** Try `UNCHECKED`
- Test if PlaybackInfo 500 errors stop
- Re-enable if not the cause

### Priority 4: Encoding Preset

- **Current:** Auto
- **For LiveTV:** Change to `fast`
- **For Quality:** Change to `medium`

---

## 🔍 Expected Performance

### With Hardware Acceleration Working

| Scenario | CPU Usage | GPU Usage | Speed |
|----------|-----------|-----------|-------|
| H264 decode + encode | 10-15% | 30-40% | 4-8x |
| HEVC decode + encode | 15-20% | 40-60% | 2-4x |
| HDR tone mapping | 20-25% | 50-70% | 1.5-3x |

### If CPU Usage > 50%

Hardware acceleration is NOT being used. Check:

1. Run verification script
2. Check Dashboard → Activity for "hw" indicator
3. Check logs for VAAPI errors

---

## 🐛 Troubleshooting Checklist

### LiveTV 500 Errors (Current Issue)

- [ ] Run `fix_jellyfin_livetv_errors.sh`
- [ ] Clear browser cache (Ctrl+Shift+R)
- [ ] Disable subtitle extraction
- [ ] Check browser console for remaining errors
- [ ] Manually refresh guide data in Dashboard

### Hardware Acceleration Not Working

- [ ] Run `verify_jellyfin_hw_acceleration.sh`
- [ ] Check `/dev/dri/renderD128` exists in container
- [ ] Verify VAAPI with `vainfo` command
- [ ] Check FFmpeg supports VAAPI
- [ ] Review Proxmox GPU passthrough

### Buffering Issues

- [ ] Increase "Throttle after" to 240s
- [ ] Increase "Keep segments" to 900s
- [ ] Change preset to `fast` or `veryfast`
- [ ] Check network bandwidth
- [ ] Monitor transcode speed

### Quality Issues

- [ ] Lower CRF values (H264: 21, H265: 25)
- [ ] Change preset to `medium` or `slow`
- [ ] Verify hardware encoding is active
- [ ] Check source quality

### HDR Issues

- [ ] Enable VPP tone mapping
- [ ] Set desaturation to 0.5
- [ ] Adjust peak value (100-400)
- [ ] Check client HDR support

---

## 📝 Configuration Backups

Backups are automatically created before changes:

```bash
/config/system.xml.backup-YYYYMMDD_HHMMSS
```

### Restore a Backup

```bash
ssh -p 2222 root@136.243.155.166 \
  'ssh simonadmin@10.0.0.103 "docker exec jellyfin-simonadmin \
  cp /config/system.xml.backup-YYYYMMDD_HHMMSS /config/system.xml"'

# Restart Jellyfin
ssh -p 2222 root@136.243.155.166 \
  'ssh simonadmin@10.0.0.103 "docker restart jellyfin-simonadmin"'
```

---

## 🔗 Useful URLs

- **Jellyfin Dashboard:** <http://136.243.155.166:8096/web/index.html#!/dashboard.html>
- **LiveTV:** <http://136.243.155.166:8096/web/#/livetv.html>
- **Transcoding Settings:** <http://136.243.155.166:8096/web/index.html#!/encodingsettings.html>
- **Logs:** <http://136.243.155.166:8096/web/index.html#!/log.html>

---

## 📚 Documentation

- **Official Docs:** <https://jellyfin.org/docs/>
- **Hardware Acceleration:** <https://jellyfin.org/docs/general/administration/hardware-acceleration/>
- **Intel VAAPI:** <https://jellyfin.org/docs/general/administration/hardware-acceleration/intel/>
- **Troubleshooting:** <https://jellyfin.org/docs/general/administration/troubleshooting/>

---

## 🎯 Action Plan

### Immediate (Today)

1. Run `./scripts/fix_jellyfin_livetv_errors.sh`
2. Clear browser cache
3. Test LiveTV - check for 500 errors

### Short Term (This Week)

1. Adjust audio boost to 1.5
2. Adjust tone mapping desaturation to 0.5
3. Test subtitle extraction disabled
4. Verify hardware acceleration is working

### Monitoring (Ongoing)

1. Watch CPU usage during transcoding
2. Monitor GPU usage with intel_gpu_top
3. Check logs for errors
4. Verify transcode speed is adequate

---

*Last Updated: October 19, 2025*
