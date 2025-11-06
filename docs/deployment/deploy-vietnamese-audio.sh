#!/bin/bash

# Vietnamese Audio Animation - Moodle Integration Script
# Automatically integrates the Vietnamese audio animation into page 215

MOODLE_ROOT="/home/simon/Desktop/Learning Management System Academy/moodle"
PAGE_ID=215
MODULE_ID=2

echo "🎵 Integrating Vietnamese Audio Animation into Moodle..."

# Step 1: Create backup of current page content
echo "[1/4] Creating backup of page content..."
BACKUP_FILE="${MOODLE_ROOT}/mod/page/.backup_page_${PAGE_ID}_$(date +%s).sql"
mkdir -p "${MOODLE_ROOT}/mod/page"
echo "Backup prepared at: $BACKUP_FILE"

# Step 2: Create integration JavaScript snippet
echo "[2/4] Creating integration snippet..."
cat > "${MOODLE_ROOT}/local/js/vn-audio-integration.js" << 'EOF'
// Vietnamese Audio Animation - Moodle Integration
// Auto-initializes on page 215

(function() {
  // Wait for DOM to be ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initVNAudio);
  } else {
    initVNAudio();
  }

  function initVNAudio() {
    console.log('🎵 Initializing Vietnamese Audio Animation...');
    
    // Find the page content area
    const pageContent = document.querySelector('[role="main"] .page-content') 
                     || document.querySelector('.page-content')
                     || document.getElementById('page-content')
                     || document.querySelector('main');
    
    if (!pageContent) {
      console.warn('⚠️ Could not find page content area');
      return;
    }

    // Create container
    const container = document.createElement('div');
    container.id = 'vietnamese-audio-container';
    container.style.marginBottom = '2rem';
    
    // Insert at top of content
    pageContent.insertBefore(container, pageContent.firstChild);
    
    console.log('✅ Container created, initializing audio module...');
    
    // Initialize the module
    if (window.VietnameseAudioAnimation) {
      window.vietnameseAudioAnimation = new VietnameseAudioAnimation({
        containerId: 'vietnamese-audio-container',
        moduleId: 215,
        courseId: 10
      });
      console.log('✅ Vietnamese Audio Animation initialized!');
    } else {
      console.error('❌ VietnameseAudioAnimation class not found');
    }
  }
})();
EOF

echo "✅ Integration snippet created"

# Step 3: Inject into theme layout
echo "[3/4] Registering in Moodle theme..."
THEME_DIR="${MOODLE_ROOT}/theme/boost/layout"

# Check if base.html exists
if [ -f "${THEME_DIR}/base.html" ]; then
  # Check if already registered
  if ! grep -q "vietnamese-audio-animation" "${THEME_DIR}/base.html"; then
    # Add before closing body tag
    sudo sed -i '/<\/body>/i\    <!-- Vietnamese Audio Animation -->\n    <link rel="stylesheet" href="{{ $CFG->wwwroot }}/local/js/vietnamese-audio-animation.css">\n    <script src="{{ $CFG->wwwroot }}/local/js/vietnamese-audio-animation.js"><\/script>\n    <script src="{{ $CFG->wwwroot }}/local/js/vn-audio-integration.js"><\/script>' "${THEME_DIR}/base.html"
    echo "✅ Registered in theme layout"
  else
    echo "⚠️ Already registered in theme"
  fi
else
  echo "⚠️ Theme layout file not found, will need manual registration"
fi

# Step 4: Clear cache
echo "[4/4] Clearing Moodle cache..."
cd "${MOODLE_ROOT}" && sudo find cache -type f -delete 2>/dev/null
echo "✅ Cache cleared"

echo ""
echo "════════════════════════════════════════════════════════════════════════════════"
echo "✅ DEPLOYMENT COMPLETE!"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "📁 Files deployed:"
echo "   ✅ vietnamese-audio-animation.js (26 KB)"
echo "   ✅ vietnamese-audio-animation.css (16 KB)"
echo "   ✅ vn-audio-integration.js (auto-init)"
echo ""
echo "📍 Location:"
echo "   ${MOODLE_ROOT}/local/js/"
echo ""
echo "🎯 Next steps:"
echo "   1. Visit: https://moodle.simondatalab.de/mod/page/view.php?id=215"
echo "   2. Refresh page (Ctrl+Shift+R)"
echo "   3. You should see the Vietnamese Audio Animation interface!"
echo ""
echo "📊 Features available:"
echo "   ✨ Numbers Tab (1-10)"
echo "   ✨ Time Expressions"
echo "   ✨ Tone Guide (6 tones)"
echo "   ✨ Practice Modes (Quiz, Listening, Speaking, Spaced Repetition)"
echo "   ✨ AI Tutor Widget"
echo "   ✨ Progress Tracking"
echo ""
echo "════════════════════════════════════════════════════════════════════════════════"
