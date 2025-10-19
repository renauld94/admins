#!/bin/bash

###############################################################################
# Jellyfin Hardware Acceleration Verification Script
# Verifies Intel VAAPI is properly configured and working
###############################################################################

set -e

REMOTE_HOST="136.243.155.166"
REMOTE_USER="simonadmin"
PROXMOX_IP="10.0.0.103"
CONTAINER_NAME="jellyfin-simonadmin"

echo "🔍 Jellyfin Hardware Acceleration Verification"
echo "==============================================="
echo ""

# 1. Check if render device is accessible
echo "1️⃣ Checking Intel GPU render device..."
ssh -p 2222 root@${REMOTE_HOST} \
  "ssh ${REMOTE_USER}@${PROXMOX_IP} 'docker exec ${CONTAINER_NAME} ls -l /dev/dri/renderD128 2>/dev/null'" && {
    echo "✅ /dev/dri/renderD128 is accessible"
} || {
    echo "❌ /dev/dri/renderD128 NOT accessible"
    echo "   Fix: Ensure GPU passthrough is configured in container"
    exit 1
}
echo ""

# 2. Check VAAPI driver info
echo "2️⃣ Checking VAAPI driver capabilities..."
ssh -p 2222 root@${REMOTE_HOST} \
  "ssh ${REMOTE_USER}@${PROXMOX_IP} 'docker exec ${CONTAINER_NAME} vainfo --display drm --device /dev/dri/renderD128 2>/dev/null'" && {
    echo "✅ VAAPI driver is working"
} || {
    echo "⚠️ VAAPI driver may not be properly installed"
    echo "   This may require intel-media-driver package"
}
echo ""

# 3. Check FFmpeg hardware acceleration support
echo "3️⃣ Checking FFmpeg hardware acceleration support..."
HW_ACCELS=$(ssh -p 2222 root@${REMOTE_HOST} \
  "ssh ${REMOTE_USER}@${PROXMOX_IP} 'docker exec ${CONTAINER_NAME} /usr/lib/jellyfin-ffmpeg/ffmpeg -hwaccels 2>/dev/null'")

if echo "$HW_ACCELS" | grep -q "vaapi"; then
    echo "✅ FFmpeg has VAAPI support"
else
    echo "❌ FFmpeg does NOT have VAAPI support"
    exit 1
fi
echo ""

# 4. Check FFmpeg VAAPI encoders
echo "4️⃣ Checking available VAAPI encoders..."
ENCODERS=$(ssh -p 2222 root@${REMOTE_HOST} \
  "ssh ${REMOTE_USER}@${PROXMOX_IP} 'docker exec ${CONTAINER_NAME} /usr/lib/jellyfin-ffmpeg/ffmpeg -encoders 2>/dev/null | grep vaapi'")

echo "Available VAAPI encoders:"
echo "$ENCODERS" | while read -r line; do
    echo "   $line"
done
echo ""

# 5. Check FFmpeg VAAPI decoders
echo "5️⃣ Checking available VAAPI decoders..."
DECODERS=$(ssh -p 2222 root@${REMOTE_HOST} \
  "ssh ${REMOTE_USER}@${PROXMOX_IP} 'docker exec ${CONTAINER_NAME} /usr/lib/jellyfin-ffmpeg/ffmpeg -decoders 2>/dev/null | grep vaapi'")

echo "Available VAAPI decoders:"
echo "$DECODERS" | while read -r line; do
    echo "   $line"
done
echo ""

# 6. Check for Intel GPU in system
echo "6️⃣ Checking for Intel GPU..."
ssh -p 2222 root@${REMOTE_HOST} \
  "ssh ${REMOTE_USER}@${PROXMOX_IP} 'docker exec ${CONTAINER_NAME} cat /proc/cpuinfo 2>/dev/null | grep -i intel'" >/dev/null && {
    echo "✅ Intel CPU detected"
} || {
    echo "⚠️ Intel CPU not clearly identified"
}
echo ""

# 7. Test hardware encoding (quick test)
echo "7️⃣ Testing hardware encoding capability..."
TEST_RESULT=$(ssh -p 2222 root@${REMOTE_HOST} \
  "ssh ${REMOTE_USER}@${PROXMOX_IP} 'docker exec ${CONTAINER_NAME} /usr/lib/jellyfin-ffmpeg/ffmpeg \
    -init_hw_device vaapi=va:/dev/dri/renderD128 \
    -f lavfi -i testsrc=duration=1:size=1280x720:rate=30 \
    -vf hwupload,scale_vaapi=w=1280:h=720 \
    -c:v h264_vaapi \
    -f null - 2>&1'" || echo "FAILED")

if echo "$TEST_RESULT" | grep -q "error\|Error\|ERROR"; then
    echo "❌ Hardware encoding test FAILED"
    echo "   Error details:"
    echo "$TEST_RESULT" | grep -i error | head -5
else
    echo "✅ Hardware encoding test PASSED"
fi
echo ""

# 8. Check current transcode directory
echo "8️⃣ Checking transcode cache..."
TRANSCODES=$(ssh -p 2222 root@${REMOTE_HOST} \
  "ssh ${REMOTE_USER}@${PROXMOX_IP} 'docker exec ${CONTAINER_NAME} ls -lh /cache/transcodes/ 2>/dev/null | wc -l'" || echo "0")

echo "   Active transcodes: $TRANSCODES files"
echo ""

# 9. Check Jellyfin logs for hardware acceleration usage
echo "9️⃣ Checking recent logs for hardware acceleration usage..."
HW_USAGE=$(ssh -p 2222 root@${REMOTE_HOST} \
  "ssh ${REMOTE_USER}@${PROXMOX_IP} 'docker logs ${CONTAINER_NAME} 2>&1 | grep -i \"vaapi\|hwaccel\" | tail -5'" || echo "No recent hardware acceleration logs found")

if [ "$HW_USAGE" = "No recent hardware acceleration logs found" ]; then
    echo "   ⚠️ No recent hardware acceleration activity detected"
    echo "   This is normal if no transcoding has occurred recently"
else
    echo "   Recent hardware acceleration activity:"
    echo "$HW_USAGE" | while read -r line; do
        echo "   $line"
    done
fi
echo ""

# 10. Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 VERIFICATION SUMMARY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Count checks
CHECKS_PASSED=0
CHECKS_TOTAL=7

# Rerun critical checks silently
ssh -p 2222 root@${REMOTE_HOST} "ssh ${REMOTE_USER}@${PROXMOX_IP} 'docker exec ${CONTAINER_NAME} ls -l /dev/dri/renderD128 2>/dev/null'" >/dev/null 2>&1 && ((CHECKS_PASSED++))
ssh -p 2222 root@${REMOTE_HOST} "ssh ${REMOTE_USER}@${PROXMOX_IP} 'docker exec ${CONTAINER_NAME} vainfo --display drm --device /dev/dri/renderD128 2>/dev/null'" >/dev/null 2>&1 && ((CHECKS_PASSED++))
echo "$HW_ACCELS" | grep -q "vaapi" && ((CHECKS_PASSED++))
[ -n "$ENCODERS" ] && ((CHECKS_PASSED++))
[ -n "$DECODERS" ] && ((CHECKS_PASSED++))
! echo "$TEST_RESULT" | grep -q "error\|Error\|ERROR" && ((CHECKS_PASSED++))
ssh -p 2222 root@${REMOTE_HOST} "ssh ${REMOTE_USER}@${PROXMOX_IP} 'docker exec ${CONTAINER_NAME} cat /proc/cpuinfo 2>/dev/null | grep -i intel'" >/dev/null 2>&1 && ((CHECKS_PASSED++))

echo "Checks Passed: ${CHECKS_PASSED}/${CHECKS_TOTAL}"
echo ""

if [ $CHECKS_PASSED -ge 6 ]; then
    echo "✅ Hardware acceleration is PROPERLY CONFIGURED"
    echo ""
    echo "Your Jellyfin instance is ready for hardware-accelerated transcoding!"
    echo ""
    echo "Next steps:"
    echo "  1. Start a video that requires transcoding"
    echo "  2. Check Dashboard → Activity to verify HW transcoding"
    echo "  3. Monitor CPU usage (should be low, ~10-20%)"
    echo "  4. Monitor GPU usage with: intel_gpu_top"
elif [ $CHECKS_PASSED -ge 4 ]; then
    echo "⚠️ Hardware acceleration is PARTIALLY WORKING"
    echo ""
    echo "Some checks failed. Review the output above."
    echo "Hardware acceleration may still work but with limitations."
else
    echo "❌ Hardware acceleration is NOT PROPERLY CONFIGURED"
    echo ""
    echo "Please review the failed checks above and fix issues."
    echo ""
    echo "Common fixes:"
    echo "  - Ensure GPU passthrough in Docker: --device /dev/dri:/dev/dri"
    echo "  - Install intel-media-driver in container"
    echo "  - Check Proxmox GPU passthrough configuration"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 11. Quick reference commands
cat << 'EOF'
📝 Quick Reference Commands:

Monitor GPU usage during transcoding:
  ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "watch -n 1 intel_gpu_top"'

Check active transcodes:
  ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "docker exec jellyfin-simonadmin ls -lh /cache/transcodes/"'

View FFmpeg transcode logs:
  ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "docker exec jellyfin-simonadmin tail -f /config/log/FFmpeg.Transcode-*.txt"'

Check Jellyfin logs for errors:
  ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "docker logs -f jellyfin-simonadmin"'

Test VAAPI manually:
  ssh -p 2222 root@136.243.155.166 'ssh simonadmin@10.0.0.103 "docker exec jellyfin-simonadmin vainfo"'

EOF
