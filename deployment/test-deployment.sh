#!/bin/bash

# Test deployment and create summary report
# Author: Simon Renauld
# Date: October 16, 2025

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Testing Deployed Dropdown Fixes${NC}"
echo -e "${YELLOW}📅 $(date)${NC}"
echo ""

# Test website accessibility
echo -e "${YELLOW}🌐 Testing website accessibility...${NC}"
if curl -s -H "Host: simondatalab.de" http://localhost/ > /dev/null; then
    echo -e "${GREEN}✅ Website is accessible${NC}"
else
    echo -e "${RED}❌ Website not accessible${NC}"
    exit 1
fi

# Check if files were deployed correctly
echo -e "${YELLOW}📁 Checking deployed files...${NC}"

TARGET_DIR="/var/www/html/simondatalab"
FILES=("index.html" "styles.css" "app.js" "test-dropdown-fix.html")

for file in "${FILES[@]}"; do
    if [ -f "$TARGET_DIR/$file" ]; then
        echo -e "   ${GREEN}✅ $file${NC}"
    else
        echo -e "   ${RED}❌ $file missing${NC}"
    fi
done

# Check if mobile dropdown code is present
echo -e "${YELLOW}🔍 Verifying dropdown fixes in code...${NC}"

# Check for mobile dropdown toggle in HTML
if grep -q "mobile-dropdown-toggle.*onclick.*toggleMobileDropdown" "$TARGET_DIR/index.html"; then
    echo -e "   ${GREEN}✅ Mobile dropdown JavaScript binding found${NC}"
else
    echo -e "   ${RED}❌ Mobile dropdown JavaScript binding missing${NC}"
fi

# Check for updated CSS classes
if grep -q "mobile-dropdown.open .mobile-dropdown-menu" "$TARGET_DIR/styles.css"; then
    echo -e "   ${GREEN}✅ Mobile dropdown CSS animations found${NC}"
else
    echo -e "   ${RED}❌ Mobile dropdown CSS animations missing${NC}"
fi

# Check for proper color styling
if grep -q "background.*rgba(248, 250, 252" "$TARGET_DIR/styles.css"; then
    echo -e "   ${GREEN}✅ Improved dropdown colors found${NC}"
else
    echo -e "   ${RED}❌ Improved dropdown colors missing${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Deployment Test Complete!${NC}"
echo ""
echo -e "${BLUE}📍 Live Website: https://www.simondatalab.de/${NC}"
echo -e "${BLUE}🧪 Test Page: https://www.simondatalab.de/test-dropdown-fix.html${NC}"
echo ""
echo -e "${YELLOW}📱 Mobile Testing Instructions:${NC}"
echo -e "   1. Open website on mobile device"
echo -e "   2. Tap hamburger menu (☰) to open mobile navigation"
echo -e "   3. Tap 'Admin Tools' to test dropdown"
echo -e "   4. Verify smooth animations and readable colors"
echo -e "   5. Test touch interaction on dropdown items"
echo ""
echo -e "${GREEN}✨ The dropdown fixes are now live and ready for testing!${NC}"