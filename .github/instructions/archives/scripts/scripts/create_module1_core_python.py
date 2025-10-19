import os
import requests
from requests.adapters import HTTPAdapter
from urllib3.poolmanager import PoolManager
import ssl

# === CONFIGURATION ===
MOODLE_URL = os.getenv("MOODLE_URL", "https://moddle-datalabsimon.duckdns.org/webservice/rest/server.php")
MOODLE_TOKEN = os.getenv("MOODLE_TOKEN", "")
MODULE_NAME = "Module 1 - Core Python"
COURSE_CATEGORY_ID = 1  # Change if needed

# === PATHS ===
REFERENCE_DIRS = [
    "/home/simon/Desktop/Python_Academy/Python Academy Courses/Module 1 - Core Python",
    "/home/simon/Desktop/learning-platform/moodle_upload_staging/Module 1 - Core Python"
]

class HostNameIgnoringAdapter(HTTPAdapter):
    def init_poolmanager(self, *args, **kwargs):
        context = ssl.create_default_context()
        context.check_hostname = False
        context.verify_mode = ssl.CERT_NONE
        kwargs['ssl_context'] = context
        return super().init_poolmanager(*args, **kwargs)

session = requests.Session()
session.mount('https://', HostNameIgnoringAdapter())

if not MOODLE_TOKEN:
    raise RuntimeError("MOODLE_TOKEN environment variable is required; do not hardcode tokens.")

def get_files_from_dirs(dirs):
    files = []
    for d in dirs:
        for root, _, filenames in os.walk(d):
            for f in filenames:
                files.append(os.path.join(root, f))
    return files

def create_course():
    params = {
        'wstoken': MOODLE_TOKEN,
        'wsfunction': 'core_course_create_courses',
        'moodlewsrestformat': 'json',
        'courses[0][fullname]': MODULE_NAME,
        'courses[0][shortname]': 'core-python',
        'courses[0][categoryid]': COURSE_CATEGORY_ID,
        'courses[0][summary]': 'Core Python module auto-created via API',
        'courses[0][format]': 'topics',
    }
    r = session.post(MOODLE_URL, params=params)  # <--- use session here
    r.raise_for_status()
    return r.json()

def upload_file(course_id, filepath):
    filename = os.path.basename(filepath)
    with open(filepath, 'rb') as f:
        files = {'file': (filename, f)}
        params = {
            'wstoken': MOODLE_TOKEN,
            'wsfunction': 'core_files_upload',
            'moodlewsrestformat': 'json',
            'contextid': course_id,  # You may need to get the correct contextid
            'component': 'course',
            'filearea': 'summary',
            'filepath': '/',
            'filename': filename,
        }
        r = session.post(MOODLE_URL, params=params, files=files)  # <--- use session here
        r.raise_for_status()
        return r.json()

if __name__ == "__main__":
    print("Creating course...")
    course_resp = create_course()
    print("Course created:", course_resp)
    course_id = course_resp[0]['id']

    print("Uploading files...")
    files = get_files_from_dirs(REFERENCE_DIRS)
    for f in files:
        print(f"Uploading {f}...")
        try:
            upload_file(course_id, f)
        except Exception as e:
            print(f"Failed to upload {f}: {e}")
    print("Done.")