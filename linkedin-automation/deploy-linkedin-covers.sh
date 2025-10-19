#!/bin/bash
# Deploy LinkedIn Covers to Portfolio

SOURCE_DIR="/home/simon/Learning-Management-System-Academy/linkedin-automation"
PORTFOLIO_DIR="/home/simon/Learning-Management-System-Academy/portfolio-deployment-enhanced"

echo "Deploying LinkedIn Premium Cover Carousel..."
echo "=============================================="
echo ""

# Create linkedin assets directory
mkdir -p "$PORTFOLIO_DIR/assets/linkedin-covers"

# Copy images
echo "Copying cover images..."
cp -v "$SOURCE_DIR/linkedin-covers/"*.png "$PORTFOLIO_DIR/assets/linkedin-covers/"

# Copy HTML viewer
echo "Copying carousel viewer..."
cp -v "$SOURCE_DIR/linkedin-cover-carousel.html" "$PORTFOLIO_DIR/linkedin-covers.html"

# Copy README
echo "Copying documentation..."
cp -v "$SOURCE_DIR/README-LINKEDIN-COVERS.md" "$PORTFOLIO_DIR/assets/linkedin-covers/"

echo ""
echo "LinkedIn covers deployed successfully!"
echo "View at: https://www.simondatalab.de/linkedin-covers.html"
echo ""
echo "Files ready for LinkedIn Premium:"
ls -1 "$PORTFOLIO_DIR/assets/linkedin-covers/"*.png | while read file; do
    basename "$file"
    identify "$file" | awk '{print "  Size: " $3 " | Format: " $2}'
done

echo ""
echo "Ready to upload to LinkedIn Premium Cover!"
