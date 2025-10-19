#!/bin/bash

# Deploy portfolio dropdown fixes to live website
# Author: Simon Renauld
# Date: October 16, 2025

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SOURCE_DIR="/home/simon/Learning-Management-System-Academy/portfolio-deployment-enhanced"
TARGET_DIR="/var/www/html/simondatalab"
BACKUP_DIR="/home/simon/Learning-Management-System-Academy/backups/portfolio-$(date +%Y%m%d_%H%M%S)"

echo -e "${BLUE}🚀 Deploying Portfolio Dropdown Fixes${NC}"
echo -e "${YELLOW}📅 $(date)${NC}"
echo ""

# Check if source files exist
if [ ! -f "$SOURCE_DIR/index.html" ]; then
    echo -e "${RED}❌ Error: Source index.html not found!${NC}"
    exit 1
fi

if [ ! -f "$SOURCE_DIR/styles.css" ]; then
    echo -e "${RED}❌ Error: Source styles.css not found!${NC}"
    exit 1
fi

# Create backup directory
echo -e "${YELLOW}📦 Creating backup...${NC}"
mkdir -p "$BACKUP_DIR"

# Backup current files if they exist
if [ -d "$TARGET_DIR" ]; then
    cp -r "$TARGET_DIR" "$BACKUP_DIR/"
    echo -e "${GREEN}✅ Backup created at: $BACKUP_DIR${NC}"
else
    echo -e "${YELLOW}⚠️  Target directory doesn't exist, creating it...${NC}"
    sudo mkdir -p "$TARGET_DIR"
fi

# Copy files with proper permissions
echo -e "${YELLOW}📋 Deploying files...${NC}"

# Copy main HTML file
echo -e "   📄 Deploying index.html"
sudo cp "$SOURCE_DIR/index.html" "$TARGET_DIR/"

# Copy CSS file
echo -e "   🎨 Deploying styles.css"
sudo cp "$SOURCE_DIR/styles.css" "$TARGET_DIR/"

# Copy JavaScript file
echo -e "   ⚡ Deploying app.js"
sudo cp "$SOURCE_DIR/app.js" "$TARGET_DIR/"

# Copy test file for verification
echo -e "   🧪 Deploying test file"
sudo cp "$SOURCE_DIR/test-dropdown-fix.html" "$TARGET_DIR/"

# Copy other essential files
if [ -f "$SOURCE_DIR/favicon.svg" ]; then
    echo -e "   🔖 Deploying favicon.svg"
    sudo cp "$SOURCE_DIR/favicon.svg" "$TARGET_DIR/"
fi

# Copy assets directory if it exists
if [ -d "$SOURCE_DIR/assets" ]; then
    echo -e "   📁 Deploying assets directory"
    sudo cp -r "$SOURCE_DIR/assets" "$TARGET_DIR/"
fi

# Copy geospatial-viz directory if it exists
if [ -d "$SOURCE_DIR/geospatial-viz" ]; then
    echo -e "   🌍 Deploying geospatial-viz directory"
    sudo cp -r "$SOURCE_DIR/geospatial-viz" "$TARGET_DIR/"
fi

# Set proper permissions
echo -e "${YELLOW}🔐 Setting permissions...${NC}"
sudo chown -R www-data:www-data "$TARGET_DIR"
sudo chmod -R 755 "$TARGET_DIR"
sudo find "$TARGET_DIR" -type f -exec chmod 644 {} \;

# Restart web server to clear cache
echo -e "${YELLOW}🔄 Restarting web server...${NC}"
sudo systemctl reload apache2

echo ""
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${BLUE}📍 Changes deployed to: https://www.simondatalab.de/${NC}"
echo -e "${BLUE}🧪 Test page available at: https://www.simondatalab.de/test-dropdown-fix.html${NC}"
echo ""
echo -e "${YELLOW}🔧 What was fixed:${NC}"
echo -e "   ✅ Mobile admin dropdown now responsive"
echo -e "   ✅ Improved color contrast and visibility" 
echo -e "   ✅ Better touch targets for mobile"
echo -e "   ✅ Smooth animations and transitions"
echo -e "   ✅ Proper JavaScript event handling"
echo ""
echo -e "${GREEN}✨ The mobile admin dropdown should now work perfectly!${NC}"