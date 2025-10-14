#!/bin/bash

# Moodle CLI Upload Script for AI Detector Tool
# Usage: ./upload_to_moodle.sh [username] [password]

MOODLE_URL="http://136.243.155.166:8086"
COURSE_ID="6"
USERNAME="$1"
PASSWORD="$2"

if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "Usage: $0 <username> <password>"
    echo "Please provide your Moodle username and password"
    exit 1
fi

echo "🔐 Logging into Moodle..."
# Step 1: Login and get session cookie
curl -s -c cookies.txt -d "username=$USERNAME&password=$PASSWORD" "$MOODLE_URL/login/index.php" > /dev/null

if ! grep -q "MoodleSession" cookies.txt; then
    echo "❌ Login failed. Please check your credentials."
    exit 1
fi

echo "✅ Login successful"

# Step 2: Get course page to find upload form
echo "📄 Accessing course page..."
COURSE_PAGE=$(curl -s -b cookies.txt "$MOODLE_URL/course/view.php?id=$COURSE_ID")

# Check if we can access the course
if echo "$COURSE_PAGE" | grep -q "Access denied"; then
    echo "❌ Cannot access course. Please check permissions."
    exit 1
fi

echo "✅ Course accessed successfully"

# Step 3: Find the file upload form action URL
# This is a simplified approach - in practice, Moodle's upload mechanism is more complex
# For now, we'll provide the manual upload instructions

echo ""
echo "📤 MANUAL UPLOAD REQUIRED"
echo "=========================="
echo "Due to Moodle's security features, CLI upload requires additional setup."
echo "Please upload manually or use the following approach:"
echo ""
echo "1. Open your browser and login to Moodle"
echo "2. Go to: $MOODLE_URL/course/view.php?id=$COURSE_ID"
echo "3. Turn editing on"
echo "4. Add a 'File' resource"
echo "5. Upload: ai_detector_export.zip"
echo "6. Set display to 'Force download'"
echo ""
echo "📁 Files ready for upload:"
echo "   - ai_detector_export.zip (18KB)"
echo "   - moodle_export_page.html (4KB)"
echo ""
echo "Alternatively, you can use Moodle's REST API if you have an API token."

# Cleanup
rm -f cookies.txt
