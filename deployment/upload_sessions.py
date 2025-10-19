import os
import requests

MOODLE_URL = "http://136.243.155.166:8081"
TOKEN = "c53409a866e3765b250d1cd7cafc7be2"  # Replace with your token
COURSE_ID = 2  # Replace with your course id
SECTION_NUM = 2  # Section number (not id), e.g., 2 for section id=2

SESSIONS_PATH = "/home/simon/Learning Management System Academy/learning-platform/jnj/module-02-core-python"

# --- Helper functions ---
def upload_file(filepath):
    url = f"{MOODLE_URL}/webservice/upload.php"
    params = {'token': TOKEN}
    files = {'file': open(filepath, 'rb')}
    response = requests.post(url, params=params, files=files)
    try:
        data = response.json()
        print("Upload response:", data)
        if isinstance(data, list) and data:
            return data[0]['filepath'], data[0]['filename']
        elif isinstance(data, dict) and 'error' in data:
            raise Exception(f"Upload error: {data['error']}")
        else:
            raise Exception("Unexpected upload response format.")
    except Exception as e:
        print("Upload failed:", e)
        raise

def create_label(label_text, name):
    url = f"{MOODLE_URL}/webservice/rest/server.php"
    params = {
        'wstoken': TOKEN,
        'wsfunction': 'mod_label_add_label',
        'moodlewsrestformat': 'json',
        'courseid': COURSE_ID,
        'sectionnum': SECTION_NUM,
        'name': name,
        'intro': label_text,
        'introformat': 1
    }
    response = requests.post(url, data=params)
    print(response.json())

def upload_and_link(session, session_dir, filename, label):
    filepath = os.path.join(session_dir, filename)
    if os.path.exists(filepath):
        print(f"Uploading {filepath}...")
        fileurl, fname = upload_file(filepath)
        file_link = f"{MOODLE_URL}/pluginfile.php/{fileurl}/{fname}"
        label_html = f'<a href="{file_link}">{label}</a>'
        create_label(label_html, f"{session}: {label}")

# --- Main logic ---
def main():
    for session in sorted(os.listdir(SESSIONS_PATH)):
        session_dir = os.path.join(SESSIONS_PATH, session)
        if os.path.isdir(session_dir) and session.startswith("session-"):
            print(f"\nProcessing {session}...")
            # 1. Upload HTML as Page/Label
            htmls = [f for f in os.listdir(session_dir) if f.endswith("-moodle-compatible.html")]
            if htmls:
                html_path = os.path.join(session_dir, htmls[0])
                with open(html_path, 'r', encoding='utf-8') as f:
                    html_content = f.read()
                create_label(html_content, f"{session} Overview")
            # 2. Upload assignment.ipynb as Exercise
            upload_and_link(session, session_dir, "assignment.ipynb", "Exercise (Notebook)")
            # 3. Upload slides.pptx as Presentation
            upload_and_link(session, session_dir, "slides.pptx", "Presentation Slides")
            # 4. Upload gamma.ipynb and gamma.md as Extra Material
            upload_and_link(session, session_dir, "gamma.ipynb", "Extra Exercise (gamma.ipynb)")
            upload_and_link(session, session_dir, "gamma.md", "Extra Material (gamma.md)")
            # 5. Upload video_script.md or video_script.ipynb as Video Script
            if os.path.exists(os.path.join(session_dir, "video_script.md")):
                upload_and_link(session, session_dir, "video_script.md", "Video Script (Markdown)")
            elif os.path.exists(os.path.join(session_dir, "video_script.ipynb")):
                upload_and_link(session, session_dir, "video_script.ipynb", "Video Script (Notebook)")

if __name__ == "__main__":
    main()
