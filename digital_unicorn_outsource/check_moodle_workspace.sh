#!/bin/bash

# Check Moodle Workspace CLI Tool
# Usage: ./check_moodle_workspace.sh <username> <password> <course_id>

MOODLE_URL="http://136.243.155.166:8086"
USERNAME="$1"
PASSWORD="$2"
COURSE_ID="${3:-2}"  # Default to course id=2

if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
    echo "Usage: $0 <username> <password> [course_id]"
    echo "Example: $0 myuser mypass 2"
    exit 1
fi

echo "🔐 Logging into Moodle..."
# Login and save cookies
curl -s -c moodle_cookies.txt \
     -d "username=$USERNAME&password=$PASSWORD&anchor=" \
     "$MOODLE_URL/login/index.php" > /dev/null

# Check if login was successful
if ! grep -q "MoodleSession" moodle_cookies.txt; then
    echo "❌ Login failed. Please check your credentials."
    rm -f moodle_cookies.txt
    exit 1
fi

echo "✅ Login successful"

# Access the course
echo "📚 Accessing course (ID: $COURSE_ID)..."
COURSE_CONTENT=$(curl -s -b moodle_cookies.txt "$MOODLE_URL/course/view.php?id=$COURSE_ID")

# Check if access was successful
if echo "$COURSE_CONTENT" | grep -q "Access denied\|Login\|redirect"; then
    echo "❌ Cannot access course. Possible reasons:"
    echo "   - Course doesn't exist"
    echo "   - Insufficient permissions"
    echo "   - Course is hidden"
    echo "   - Authentication issue"
    echo ""
    echo "🔍 Available courses (from course index):"
    INDEX_CONTENT=$(curl -s -b moodle_cookies.txt "$MOODLE_URL/course/index.php")
    echo "$INDEX_CONTENT" | grep -o 'course/view.php?id=[0-9]*' | sort | uniq | sed 's|course/view.php?id=|   Course ID: |'
    rm -f moodle_cookies.txt
    exit 1
fi

# Check for redirect page
if echo "$COURSE_CONTENT" | grep -q "<title>Redirect</title>"; then
    echo "⚠️  Course page shows redirect. This might indicate:"
    echo "   - Course is not yet set up"
    echo "   - Course requires additional setup"
    echo "   - Permission issue"
    echo ""
    echo "💡 Try accessing the course through your browser first"
    rm -f moodle_cookies.txt
    exit 1
fi

echo "✅ Course accessed successfully"
echo ""

# Extract course information
COURSE_TITLE=$(echo "$COURSE_CONTENT" | grep -o '<title>[^<]*</title>' | sed 's/<title>//;s/<\/title>//' | head -1)

if [ -z "$COURSE_TITLE" ] || [ "$COURSE_TITLE" = "Moodle" ]; then
    COURSE_TITLE="Course $COURSE_ID (Title not found)"
fi

echo "📖 Course Title: $COURSE_TITLE"
echo ""

# Count activities/resources
ACTIVITY_COUNT=$(echo "$COURSE_CONTENT" | grep -c "activityinstance\|modtype_")
echo "📊 Activities/Resources found: $ACTIVITY_COUNT"

# List course sections
echo ""
echo "📚 Course Sections:"
echo "$COURSE_CONTENT" | grep -o '<h3[^>]*>[^<]*</h3>' | sed 's/<[^>]*>//g' | head -10

# List some activities (basic parsing)
echo ""
echo "📋 Recent Activities:"
echo "$COURSE_CONTENT" | grep -A 1 -B 1 "activityinstance" | grep -v "activityinstance" | head -10

# Check for uploaded files
echo ""
echo "📁 File Resources:"
echo "$COURSE_CONTENT" | grep -o 'resource.*href="[^"]*"' | sed 's/.*href="//;s/".*//' | head -5

# Check for assignments/quizzes
echo ""
echo "📝 Assignments/Activities:"
echo "$COURSE_CONTENT" | grep -o '<a[^>]*href="[^"]*mod/[^"]*"[^>]*>[^<]*</a>' | sed 's/<[^>]*>//g' | head -5

echo ""
echo "✅ Workspace check complete!"
echo "💡 Tip: Use course ID parameter to check different courses"

# Optional: List all available courses
echo ""
echo "📋 All Available Courses:"
INDEX_CONTENT=$(curl -s -b moodle_cookies.txt "$MOODLE_URL/course/index.php")
if echo "$INDEX_CONTENT" | grep -q "course/view.php"; then
    echo "$INDEX_CONTENT" | grep -A 1 -B 1 "course/view.php?id=" | grep -v "course/view.php" | sed 's/^[ \t]*//' | head -20
else
    echo "   Could not retrieve course list"
fi
