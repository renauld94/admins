import requests
import os
import sys

# Use environment variables only; do not hardcode secrets in archived scripts
MOODLE_URL = os.getenv("MOODLE_URL", "http://localhost:8081/webservice/rest/server.php")
TOKEN = os.getenv("MOODLE_TOKEN", "")
COURSE_ID = int(os.getenv("COURSE_ID", "0") or 0)

def create_page(title, content):
    params = {
        'wstoken': TOKEN,
        'wsfunction': 'mod_page_add_instance',
        'moodlewsrestformat': 'json',
        'page[course]': COURSE_ID,
        'page[name]': title,
        'page[intro]': content,
        'page[introformat]': 1,
        'page[content]': content,
        'page[contentformat]': 1,
    }
    response = requests.post(MOODLE_URL, params=params, timeout=30)
    print("Status code:", response.status_code)
    print("Raw response:", response.text)
    try:
        print(response.json())
    except Exception as e:
        print("JSON decode error:", e)

if __name__ == "__main__":
    if not TOKEN or not COURSE_ID:
        print("Error: set MOODLE_TOKEN and COURSE_ID in the environment first.", file=sys.stderr)
        sys.exit(1)
    # Example: create a page from your Welcome Introduction HTML
    file_path = os.getenv("PAGE_HTML_PATH", "/home/simon/Desktop/learning-platform/moodle_upload_staging/Module 1 - Core Python/1-Welcome-Introduction.html")
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    create_page("Module 1 - Welcome & Introduction", content)