#!/bin/bash
# Deploy All Vietnamese Course Content - EPIC Edition
# 
# This script:
# 1. Reviews content for duplicates
# 2. Generates all 8 weeks of professional content
# 3. Tests generated content
# 4. Prepares for Moodle deployment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "========================================================================"
echo "  VIETNAMESE COURSE - EPIC CONTENT DEPLOYMENT"
echo "========================================================================"
echo ""

# Check dependencies
echo "[1/5] Checking dependencies..."
command -v python3 >/dev/null 2>&1 || { echo "✗ python3 not found"; exit 1; }
echo "  ✓ Python 3 found"

# Check Vietnamese Tutor Agent
echo ""
echo "[2/5] Checking Vietnamese Tutor Agent..."
if curl -s http://localhost:5001/health >/dev/null 2>&1; then
    echo "  ✓ Vietnamese Tutor Agent is running"
else
    echo "  ✗ Vietnamese Tutor Agent is not running"
    echo "  Start it with: sudo systemctl start vietnamese-tutor-agent"
    exit 1
fi

# Review for duplicates
echo ""
echo "[3/5] Reviewing content for duplicates..."
python3 course_content_generator.py --review-duplicates

# Generate all content
echo ""
echo "[4/5] Generating all course content..."
echo "  This will take 20-40 minutes depending on AI model speed..."
echo "  Progress will be shown for each week."
echo ""
python3 course_content_generator.py --generate-all

# Test generated content
echo ""
echo "[5/5] Testing generated content..."
python3 course_content_generator.py --test-content

echo ""
echo "========================================================================"
echo "  DEPLOYMENT COMPLETE!"
echo "========================================================================"
echo ""
echo "Generated files location:"
echo "  $(pwd)/generated/professional/"
echo ""
echo "Next steps:"
echo "  1. Review content: firefox generated/professional/index.html"
echo "  2. Import quizzes to Moodle: Site admin > Question bank > Import"
echo "  3. Upload HTML lessons to course pages"
echo "  4. Distribute flashcards to students"
echo ""
echo "To deploy to Moodle automatically, run:"
echo "  python3 moodle_uploader.py --upload-all"
echo ""
