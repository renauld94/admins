#!/bin/bash
# filepath: /home/simon/Desktop/learning-platform/create_core_python_course.sh

# --- CONFIGURATION ---
MOODLE_CONTAINER="moodle"      # Change if your Moodle web container is named differently
COURSE_FULLNAME="Module 1 - Core Python"
COURSE_SHORTNAME="Core Python"
COURSE_CATEGORYID=1            # Main category; change if needed

# --- CREATE COURSE VIA MOODLE CLI ---
docker exec -u www-data $MOODLE_CONTAINER php admin/cli/create_course.php \
  --fullname="$COURSE_FULLNAME" \
  --shortname="$COURSE_SHORTNAME" \
  --categoryid=$COURSE_CATEGORYID

echo "Course '$COURSE_FULLNAME' created in Moodle."

# --- INSTRUCTIONS FOR CONTENT IMPORT ---
echo ""
echo "To import your Jupyter Notebooks and content:"
echo "1. Go to your Moodle web UI at http://localhost:8081/course/view.php?id=3"
echo "2. Add sections and upload your .ipynb files as 'File' resources or use 'Page' for formatted text."
echo "3. Use the course outline provided earlier for structure."
echo ""
echo "For advanced CLI automation (sections, files), consider installing Moosh: https://moosh-online.com/"
