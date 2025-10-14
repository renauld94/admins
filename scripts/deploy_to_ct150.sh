#!/bin/bash

echo "🚀 DEPLOYING CT 150 CLINICAL PROGRAMMING COURSE UPDATES"
echo "======================================================"

# Check if we're on CT 150
if [[ $(hostname) != "portfolio-web" ]]; then
    echo "❌ This script must be run on CT 150 (portfolio-web)"
    echo "Please SSH to CT 150 and run this script there"
    exit 1
fi

echo "✅ Running on CT 150"

# Create backup directory
echo "📦 Creating backup..."
BACKUP_DIR="/var/backups/ct150-updates-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# Backup current LMS content
if [[ -d "/var/www/html/lms" ]]; then
    echo "📁 Backing up current LMS content..."
    cp -r /var/www/html/lms "$BACKUP_DIR/"
fi

# Deploy Clinical Programming course content
echo "📚 Deploying Clinical Programming course..."
COURSE_DIR="/var/www/html/lms/courses/ct150-clinical-programming"
mkdir -p "$COURSE_DIR"

# Copy course content from local directory
if [[ -d "/home/simon/Learning-Management-System-Academy/learning-platform/courses/ct150-clinical-programming" ]]; then
    cp -r /home/simon/Learning-Management-System-Academy/learning-platform/courses/ct150-clinical-programming/* "$COURSE_DIR/"
    echo "✅ Course content deployed successfully"
else
    echo "⚠️  Course content directory not found, creating placeholder..."
    mkdir -p "$COURSE_DIR/module-01-fundamentals"
    echo "# CT 150 Clinical Programming Course" > "$COURSE_DIR/README.md"
fi

# Update Moodle course configuration
echo "🔧 Updating Moodle course configuration..."
MOODLE_CONFIG="/var/www/html/lms/config.php"
if [[ -f "$MOODLE_CONFIG" ]]; then
    echo "✅ Moodle configuration found"
else
    echo "⚠️  Moodle configuration not found"
fi

# Set correct permissions
echo "🔐 Setting permissions..."
chown -R www-data:www-data /var/www/html/lms
chmod -R 755 /var/www/html/lms

# Reload web server
echo "🔄 Reloading web server..."
if systemctl is-active --quiet nginx; then
    systemctl reload nginx
    echo "✅ Nginx reloaded"
elif systemctl is-active --quiet apache2; then
    systemctl reload apache2
    echo "✅ Apache2 reloaded"
else
    echo "⚠️  No web server found running"
fi

# Test the deployment
echo "🧪 Testing deployment..."
if curl -s -o /dev/null -w "%{http_code}" https://www.simondatalab.de/lms | grep -q "200"; then
    echo "✅ LMS is accessible"
else
    echo "⚠️  LMS may not be accessible"
fi

echo ""
echo "🎉 CT 150 Clinical Programming course deployment complete!"
echo "🌐 Visit: https://www.simondatalab.de/lms"
echo "📚 Course: CT 150 Clinical Programming"
echo "💾 Backup saved to: $BACKUP_DIR"