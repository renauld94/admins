import os
import sys
import requests

# Configuration via environment variables (no hardcoded secrets)
# Required: MOODLE_URL, MOODLE_TOKEN, COURSE_ID, SECTION_NUM, SESSIONS_PATH
MOODLE_URL = os.environ.get("MOODLE_URL")
TOKEN = os.environ.get("MOODLE_TOKEN")

def _int_env(name: str, default: int | None = None) -> int:
    val = os.environ.get(name)
    if val is None:
        if default is None:
            raise ValueError(f"Missing required environment variable: {name}")
        return default
    try:
        return int(val)
    except ValueError:
        raise ValueError(f"Environment variable {name} must be an integer, got: {val}")

COURSE_ID = _int_env("COURSE_ID", None)
SECTION_NUM = _int_env("SECTION_NUM", None)

SESSIONS_PATH = os.environ.get(
    "SESSIONS_PATH",
    "/home/simon/Learning Management System Academy/learning-platform/jnj/module-02-core-python",
)

if not MOODLE_URL or not TOKEN:
    print("Error: MOODLE_URL and MOODLE_TOKEN must be set in the environment.", file=sys.stderr)
    sys.exit(1)

# --- Helper functions ---
def upload_file(filepath):
    url = f"{MOODLE_URL}/webservice/upload.php"
    params = {"token": TOKEN}
    with open(filepath, "rb") as fh:
        files = {"file": fh}
        response = requests.post(url, params=params, files=files, timeout=60)
    response.raise_for_status()
    try:
        data = response.json()
        print("Upload response:", data)
        if isinstance(data, list) and data:
            return data[0]["filepath"], data[0]["filename"]
        elif isinstance(data, dict) and "error" in data:
            raise RuntimeError(f"Upload error: {data['error']}")
        else:
            raise RuntimeError("Unexpected upload response format.")
    except Exception as e:
        print("Upload failed:", e)
        raise

def create_label(label_text, name):
    url = f"{MOODLE_URL}/webservice/rest/server.php"
    params = {
        "wstoken": TOKEN,
        "wsfunction": "mod_label_add_label",
        "moodlewsrestformat": "json",
        "courseid": COURSE_ID,
        "sectionnum": SECTION_NUM,
        "name": name,
        "intro": label_text,
        "introformat": 1,
    }
    response = requests.post(url, data=params, timeout=60)
    response.raise_for_status()
    try:
        print(response.json())
    except Exception:
        print(response.text)

def upload_and_link(session, session_dir, filename, label):
    filepath = os.path.join(session_dir, filename)
    if os.path.exists(filepath):
        print(f"Uploading {filepath}...")
        fileurl, fname = upload_file(filepath)
        file_link = f"{MOODLE_URL}/pluginfile.php/{fileurl}/{fname}"
        label_html = f'<a href="{file_link}">{label}</a>'
        create_label(label_html, f"{session}: {label}")
    else:
        print(f"Skip missing file: {filepath}")

# --- Main logic ---
def main():
    if not os.path.isdir(SESSIONS_PATH):
        print(f"Error: SESSIONS_PATH does not exist or is not a directory: {SESSIONS_PATH}", file=sys.stderr)
        sys.exit(1)
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