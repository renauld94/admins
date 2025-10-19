import os
import requests
import sys

MOODLE_URL = os.getenv("MOODLE_URL", "http://localhost:8081/webservice/rest/server.php")
TOKEN = os.getenv("MOODLE_TOKEN", "")
ADMIN_USER_ID = int(os.getenv("MOODLE_ADMIN_USER_ID", "2"))  # default to 2 if not provided

if not TOKEN:
    raise RuntimeError("MOODLE_TOKEN environment variable is required; do not hardcode tokens.")
if not MOODLE_URL:
    print("Error: MOODLE_URL environment variable is required.", file=sys.stderr)
    sys.exit(1)

# 1. Create the course
course_params = {
    'wstoken': TOKEN,
    'wsfunction': 'core_course_create_courses',
    'moodlewsrestformat': 'json',
    'courses[0][fullname]': 'Mentor Workspace',
    'courses[0][shortname]': 'mentorws',
    'courses[0][categoryid]': 1
}
course_resp = requests.post(MOODLE_URL, params=course_params, timeout=30)
course_resp.raise_for_status()
course_data = course_resp.json()
if 'exception' in course_data:
    raise Exception(course_data)
course_id = course_data[0]['id']

# 2. Enrol admin as a teacher (roleid 3 is usually 'editingteacher')
enrol_params = {
    'wstoken': TOKEN,
    'wsfunction': 'enrol_manual_enrol_users',
    'moodlewsrestformat': 'json',
    'enrolments[0][roleid]': 3,
    'enrolments[0][userid]': ADMIN_USER_ID,
    'enrolments[0][courseid]': course_id
}
enrol_resp = requests.post(MOODLE_URL, params=enrol_params, timeout=30)
enrol_resp.raise_for_status()
print("Mentor Workspace created and admin enrolled as teacher.")