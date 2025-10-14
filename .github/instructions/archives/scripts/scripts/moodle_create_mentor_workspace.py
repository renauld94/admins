import requests

MOODLE_URL = "http://localhost:8081/webservice/rest/server.php"
TOKEN = "5dac2adefe029ebd8ed2fb52379c8d02"
ADMIN_USER_ID = 2  # Directly use the known admin user ID

# 1. Create the course
course_params = {
    'wstoken': TOKEN,
    'wsfunction': 'core_course_create_courses',
    'moodlewsrestformat': 'json',
    'courses[0][fullname]': 'Mentor Workspace',
    'courses[0][shortname]': 'mentorws',
    'courses[0][categoryid]': 1
}
course_resp = requests.post(MOODLE_URL, params=course_params)
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
enrol_resp = requests.post(MOODLE_URL, params=enrol_params)
enrol_resp.raise_for_status()
print("Mentor Workspace created and admin enrolled as teacher.")