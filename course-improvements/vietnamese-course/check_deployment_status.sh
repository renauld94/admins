#!/bin/bash
echo "========================================="
echo "VIETNAMESE COURSE DEPLOYMENT STATUS"
echo "========================================="
echo ""
echo "📅 Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

echo "1. MOODLE COURSE STATUS"
echo "----------------------------------------"
echo "   Course URL: https://moodle.simondatalab.de/course/view.php?id=10"
echo "   Last Modified: $(curl -sI 'https://moodle.simondatalab.de/course/view.php?id=10' 2>/dev/null | grep -i 'last-modified' | cut -d' ' -f2-)"
echo ""

echo "2. COURSE STRUCTURE (Live on Moodle)"
echo "----------------------------------------"
curl -sL "https://moodle.simondatalab.de/course/view.php?id=10" | \
python3 -c "
import sys, re
html = sys.stdin.read()
sections = re.findall(r'data-sectionname=\"([^\"]+)\"', html)
for i, section in enumerate(sections, 1):
    print(f'   [{i}] {section}')
" 2>/dev/null || echo "   Unable to fetch course structure"
echo ""

echo "3. LOCAL GENERATED CONTENT"
echo "----------------------------------------"
if [ -d "generated/professional" ]; then
    echo "   Generated files:"
    ls -lht generated/professional/*.html 2>/dev/null | head -5 | while read -r line; do
        echo "   $line"
    done
else
    echo "   ❌ No generated content found"
fi
echo ""

echo "4. DEPLOYMENT STATUS"
echo "----------------------------------------"
# Check if webservices are configured
if [ -f ~/.moodle_token ]; then
    echo "   ✅ Moodle token: Configured"
else
    echo "   ❌ Moodle token: Not configured"
fi

# Check if course has content
SECTIONS=$(curl -sL "https://moodle.simondatalab.de/course/view.php?id=10" 2>/dev/null | grep -c 'data-sectionname=')
if [ "$SECTIONS" -gt 3 ]; then
    echo "   ✅ Course sections: $SECTIONS sections found"
else
    echo "   ⚠️  Course sections: $SECTIONS sections (may need updates)"
fi
echo ""

echo "5. RECENT UPDATES CHECK"
echo "----------------------------------------"
# Check specific lesson page
PAGE_TITLE=$(curl -sL "https://moodle.simondatalab.de/mod/page/view.php?id=188" 2>/dev/null | grep -o '<title>[^<]*</title>' | sed 's/<[^>]*>//g')
if [ -n "$PAGE_TITLE" ]; then
    echo "   ✅ Sample page accessible: $PAGE_TITLE"
else
    echo "   ❌ Sample page not accessible"
fi
echo ""

echo "6. NEXT STEPS"
echo "----------------------------------------"
if [ ! -f ~/.moodle_token ]; then
    echo "   1. Configure webservice token (see WEBSERVICES_SETUP_STATUS.md)"
    echo "   2. Run: ./setup_moodle_webservices.sh"
fi
echo "   3. Generate fresh content: python3 course_content_generator.py --generate-all"
echo "   4. Deploy to Moodle: python3 moodle_deployer.py --deploy-all"
echo ""
echo "========================================="
