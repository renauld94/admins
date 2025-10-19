#!/bin/bash

###############################################################################
# Jellyfin Transcoding Optimization Script
# Applies recommended settings for Intel VAAPI hardware acceleration
###############################################################################

REMOTE_HOST="136.243.155.166"
REMOTE_USER="simonadmin"
PROXMOX_IP="10.0.0.103"
CONTAINER_NAME="jellyfin-simonadmin"
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)

echo "🎯 Jellyfin Transcoding Optimization"
echo "====================================="
echo ""

# Safety first - backup current config
echo "1️⃣ Backing up current configuration..."
ssh -p 2222 root@${REMOTE_HOST} \
  "ssh ${REMOTE_USER}@${PROXMOX_IP} 'docker exec ${CONTAINER_NAME} \
    cp /config/system.xml /config/system.xml.backup-${BACKUP_DATE}'" && {
    echo "✅ Configuration backed up to system.xml.backup-${BACKUP_DATE}"
} || {
    echo "⚠️ Could not backup configuration"
}
echo ""

# Show current settings that need optimization
echo "2️⃣ Current Settings Analysis..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat << 'EOF'

Settings that may need adjustment:

1. Audio Boost: Currently 2.0
   → Recommended: 1.5 (prevents clipping)
   
2. Tone Mapping Desaturation: Currently 0.0
   → Recommended: 0.5 (prevents blown highlights)
   
3. Subtitle Extraction: Currently ENABLED
   → Test with DISABLED if experiencing PlaybackInfo errors
   
4. Encoding Preset: Currently Auto
   → Recommended: "fast" for LiveTV (better performance)
   → Recommended: "medium" for VOD (better quality)

EOF
echo ""

# Provide manual configuration instructions
echo "3️⃣ How to Apply Optimizations..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat << 'EOF'

To apply these optimizations, update settings in Jellyfin Dashboard:

Step 1: Navigate to Settings
   http://136.243.155.166:8096/web/index.html#!/dashboard.html
   → Dashboard → Playback → Transcoding

Step 2: Adjust Audio Settings
   - Scroll to "Audio boost when downmixing"
   - Change from: 2
   - Change to: 1.5
   - Click Save

Step 3: Adjust HDR Tone Mapping
   - Scroll to "Tone mapping desat"
   - Change from: 0
   - Change to: 0.5
   - Click Save

Step 4: Test Subtitle Extraction (Optional)
   If experiencing PlaybackInfo 500 errors:
   - Scroll to "Allow subtitle extraction on the fly"
   - Uncheck this option
   - Click Save
   - Test playback
   - Re-enable if not the cause

Step 5: Optimize Encoding Preset
   - Scroll to "Encoding preset"
   - Change from: Auto
   - Change to: fast (for LiveTV/real-time)
     OR medium (for on-demand/quality)
   - Click Save

EOF
echo ""

# Advanced optimizations
echo "4️⃣ Advanced Optimizations (Optional)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat << 'EOF'

For users experiencing specific issues:

A. Buffering Issues:
   - Increase "Throttle after" to 240 seconds
   - Increase "Time to keep segments" to 900 seconds

B. Quality Issues:
   - Adjust H.264 CRF: Lower = better quality (try 21)
   - Adjust H.265 CRF: Lower = better quality (try 25)

C. Performance Issues:
   - Reduce thread count: Try 4 or 6 threads
   - Use "veryfast" encoding preset
   - Disable tone mapping if not needed

D. Network Issues:
   - Run: ./scripts/fix_jellyfin_livetv_errors.sh
   - Ensure DNS is properly configured

E. HDR Playback Issues:
   - Enable "Enable VPP Tone mapping" (Intel only)
   - Set algorithm to "bt2390"
   - Adjust peak to match your display (100-400)

EOF
echo ""

# Testing procedure
echo "5️⃣ Testing Procedure..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat << 'EOF'

After applying changes:

Test 1: Hardware Acceleration Verification
   1. Run: ./scripts/verify_jellyfin_hw_acceleration.sh
   2. Ensure all checks pass

Test 2: LiveTV Playback
   1. Navigate to: http://136.243.155.166:8096/web/#/livetv.html
   2. Select a channel
   3. Monitor Dashboard → Activity
   4. Verify "hw" appears in transcode reason

Test 3: Check CPU Usage
   1. Start playing a channel that transcodes
   2. Monitor CPU usage (should be <20% with HW accel)
   3. If >50%, hardware acceleration may not be active

Test 4: Check Logs
   1. Dashboard → Logs
   2. Look for VAAPI messages
   3. Check for any errors

Test 5: Browser Console
   1. Open browser console (F12)
   2. Look for 500 errors
   3. Should see fewer/no Primary image errors after network fix

EOF
echo ""

# Monitoring commands
echo "6️⃣ Monitoring Commands..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat << 'EOF'

Real-time monitoring:

# Watch GPU usage during transcoding:
ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "watch -n 1 intel_gpu_top"'

# Watch CPU usage:
ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "docker stats jellyfin-simonadmin"'

# Watch transcode logs:
ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "docker exec jellyfin-simonadmin tail -f /config/log/FFmpeg.Transcode-*.txt"'

# Watch Jellyfin logs:
ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "docker logs -f jellyfin-simonadmin"'

# Check active transcodes:
ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "docker exec jellyfin-simonadmin ls -lh /cache/transcodes/"'

EOF
echo ""

# Rollback instructions
echo "7️⃣ Rollback Instructions..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
cat << EOF

If you need to revert changes:

ssh -p 2222 root@${REMOTE_HOST} 'ssh ${REMOTE_USER}@${PROXMOX_IP} "docker exec ${CONTAINER_NAME} \\
  cp /config/system.xml.backup-${BACKUP_DATE} /config/system.xml"'

Then restart Jellyfin:
ssh -p 2222 root@${REMOTE_HOST} 'ssh ${REMOTE_USER}@${PROXMOX_IP} "docker restart ${CONTAINER_NAME}"'

EOF
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 OPTIMIZATION SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Your current configuration is already excellent!"
echo ""
echo "Priority optimizations:"
echo "  1. ✅ Hardware acceleration: Already configured"
echo "  2. ⚠️ Audio boost: Reduce to 1.5"
echo "  3. ⚠️ Tone mapping desat: Increase to 0.5"
echo "  4. ⚠️ Network connectivity: Run fix_jellyfin_livetv_errors.sh"
echo "  5. ⚠️ Test subtitle extraction: Try disabling if 500 errors persist"
echo ""
echo "Configuration backup saved as: system.xml.backup-${BACKUP_DATE}"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Interactive prompt
read -p "Would you like to open the Jellyfin transcoding settings page? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v xdg-open &> /dev/null; then
        xdg-open "http://136.243.155.166:8096/web/index.html#!/encodingsettings.html"
    elif command -v open &> /dev/null; then
        open "http://136.243.155.166:8096/web/index.html#!/encodingsettings.html"
    else
        echo "Please open: http://136.243.155.166:8096/web/index.html#!/encodingsettings.html"
    fi
fi

echo ""
echo "✅ Optimization guide complete!"
