import requests
import os

MOODLE_URL = "http://moodle.simondatalab.de/webservice/rest/server.php"
TOKEN = "759f14c0bb0b2c6b2a0393dbf04b90ac"  # Replace with your token if different
COURSE_ID = 2  # Your course ID

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
    response = requests.post(MOODLE_URL, params)
    print("Status code:", response.status_code)
    print("Raw response:", response.text)
    try:
        print(response.json())
    except Exception as e:
        print("JSON decode error:", e)

if __name__ == "__main__":
    # Example: create a page from your Welcome Introduction HTML
    file_path = "/home/simon/Desktop/learning-platform/moodle_upload_staging/Module 1 - Core Python/1-Welcome-Introduction.html"
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()
    create_page("Module 1 - Welcome & Introduction", content)