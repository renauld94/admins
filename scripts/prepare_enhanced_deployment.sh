#!/bin/bash

# Enhanced Portfolio Manual Deployment Script
# Run this script to prepare files for manual upload

echo "🎯 Enhanced Portfolio Deployment Preparation"
echo "============================================="

# Configuration
DEPLOY_DIR="/home/simon/Desktop/Learning Management System Academy/portfolio-deployment-enhanced"
PACKAGE_FILE="/home/simon/Desktop/Learning Management System Academy/portfolio-enhanced-deployment.tar.gz"

echo ""
echo "📋 Current Status:"
echo "  ✅ Enhanced portfolio files created"
echo "  ✅ Professional content improvements applied"
echo "  ✅ SEO optimization completed"
echo "  ✅ Enterprise-focused messaging implemented"
echo ""

echo "📁 Files ready for deployment:"
echo "  📂 Directory: $DEPLOY_DIR"
echo "  📦 Package: $PACKAGE_FILE"
echo ""

echo "🔍 Key Enhanced Features:"
echo "  ✅ Hero badge: 'Enterprise Data Strategy & Clinical Analytics'"
echo "  ✅ Professional subtitle emphasizing strategic business intelligence"
echo "  ✅ Enhanced about section with enterprise language"
echo "  ✅ Refined experience descriptions"
echo "  ✅ Professional project case studies"
echo "  ✅ Enhanced expertise sections"
echo "  ✅ Professional contact section"
echo "  ✅ Updated meta tags and SEO"
echo "  ✅ Page title: 'Senior Data Scientist & Innovation Strategist'"
echo ""

echo "🚀 Manual Deployment Instructions:"
echo ""
echo "1. Access your server console/KVM at 136.243.155.166"
echo "2. Navigate to /var/www/html/"
echo "3. Upload files from: $DEPLOY_DIR"
echo "4. Set permissions: chown -R www-data:www-data /var/www/html/"
echo "5. Set permissions: chmod -R 755 /var/www/html/"
echo "6. Restart web server: systemctl reload nginx"
echo ""

echo "🧪 Verification:"
echo "  🌐 Visit: https://www.simondatalab.de/"
echo "  📋 Check: Title shows 'Senior Data Scientist & Innovation Strategist'"
echo "  🎯 Verify: Badge shows 'Enterprise Data Strategy & Clinical Analytics'"
echo "  📱 Test: All functionality works on desktop and mobile"
echo ""

echo "📊 File Count:"
find "$DEPLOY_DIR" -type f | wc -l | xargs echo "  📄 Total files ready:"

echo ""
echo "🎉 Enhanced portfolio is ready for deployment!"
echo "📖 See ENHANCED_PORTFOLIO_DEPLOYMENT_GUIDE.md for detailed instructions"
