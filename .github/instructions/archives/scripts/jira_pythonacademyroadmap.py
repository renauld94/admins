# === IMPORTS ===
import os
import json
import requests
from dotenv import load_dotenv

# === LOAD ENVIRONMENT VARIABLES ===
# Clear any existing environment variables and reload
for key in ['JIRA_BASE_URL', 'JIRA_EMAIL', 'JIRA_API_TOKEN', 'PROJECT_KEY']:
    if key in os.environ:
        del os.environ[key]

load_dotenv(override=True)

JIRA_BASE_URL = os.getenv("JIRA_BASE_URL")
JIRA_EMAIL = os.getenv("JIRA_EMAIL")
JIRA_API_TOKEN = os.getenv("JIRA_API_TOKEN")
PROJECT_KEY = os.getenv("PROJECT_KEY")

AUTH = (JIRA_EMAIL, JIRA_API_TOKEN)
HEADERS = {
    "Accept": "application/json",
    "Content-Type": "application/json"
}

# === STRUCTURE ===
MODULES = [
    {
        "name": "Core Python",
        "sessions": [
            "Python Overview",
            "Practical Setup",
            "Objects and Types",
            "Assignments & OOP Overview",
            "Code Libraries",
            "Data Structures: Lists, Tuples, Dicts",
            "Conditions, Loops, Try/Except",
            "Functions & Lambdas",
            "DateTime & Regex",
            "Classes, Decorators",
            "Virtual Environments",
            "Practice Exercises"
        ]
    },
    {
        "name": "PySpark",
        "sessions": [
            "Introduction to PySpark",
            "DataFrame Basics",
            "New Columns & Aggregations",
            "Joins, Provenance, Pandas API",
            "Practice & Advanced"
        ]
    },
    {
        "name": "Databricks",
        "sessions": ["UI, Jobs, Clusters"]
    },
    {
        "name": "Bridge: Pandas to PySpark",
        "sessions": ["Mapping Guide", "Side-by-side Examples"]
    },
    {
        "name": "Debugging & Optimization",
        "sessions": ["Error Handling", "Performance Tuning", "SQL Integration"]
    }
]

LABELS = ["academy", "python", "pyspark"]

# === FUNCTIONS ===
def get_project_info(project_key):
    """Get information about a specific project"""
    url = f"{JIRA_BASE_URL}/rest/api/3/project/{project_key}"
    response = requests.get(url, headers=HEADERS, auth=AUTH)
    
    print(f"Get project info response: {response.status_code}")
    if response.status_code != 200:
        print(f"Error getting project info: {response.status_code} - {response.text}")
        return None
    
    return response.json()

def get_current_user():
    """Get current user information"""
    url = f"{JIRA_BASE_URL}/rest/api/3/myself"
    response = requests.get(url, headers=HEADERS, auth=AUTH)
    
    print(f"Get current user response: {response.status_code}")
    if response.status_code != 200:
        print(f"Error getting user info: {response.status_code} - {response.text}")
        return None
    
    return response.json()

def list_projects():
    """List all available projects"""
    url = f"{JIRA_BASE_URL}/rest/api/3/project"
    response = requests.get(url, headers=HEADERS, auth=AUTH)
    
    print(f"List projects response: {response.status_code}")
    if response.status_code != 200:
        print(f"Error listing projects: {response.status_code} - {response.text}")
        return []
    
    projects = response.json()
    print(f"Found {len(projects)} projects")
    return projects

def create_project(project_name, project_key):
    """Create a new Jira project"""
    url = f"{JIRA_BASE_URL}/rest/api/3/project"
    payload = json.dumps({
        "key": project_key,
        "name": project_name,
        "projectTypeKey": "software",
        "projectTemplateKey": "com.pyxis.greenhopper.jira:gh-simplified-agility-kanban",
        "description": f"Python Academy Learning Platform - {project_name}",
        "leadAccountId": None,  # Will use the current user as lead
        "assigneeType": "PROJECT_LEAD"
    })
    response = requests.post(url, data=payload, headers=HEADERS, auth=AUTH)
    
    if response.status_code != 201:
        print(f"Error creating project '{project_name}': {response.status_code} - {response.text}")
        return None
    
    return response.json().get("key")

def create_epic(epic_name):
    url = f"{JIRA_BASE_URL}/rest/api/3/issue"
    payload = json.dumps({
        "fields": {
            "project": {"key": PROJECT_KEY},
            "summary": epic_name,
            "issuetype": {"name": "Epic"},
            "labels": LABELS
            # Removed customfield_10011 for now
        }
    })
    response = requests.post(url, data=payload, headers=HEADERS, auth=AUTH)
    
    if response.status_code != 201:
        print(f"Error creating epic '{epic_name}': {response.status_code} - {response.text}")
        return None
    
    return response.json().get("key")

def create_story(summary, epic_key):
    url = f"{JIRA_BASE_URL}/rest/api/3/issue"
    payload = json.dumps({
        "fields": {
            "project": {"key": PROJECT_KEY},
            "summary": summary,
            "issuetype": {"name": "Task"},  # Changed from "Story" to "Task"
            "labels": LABELS
            # We'll link to epic manually later if needed
        }
    })
    response = requests.post(url, data=payload, headers=HEADERS, auth=AUTH)
    
    if response.status_code != 201:
        print(f"Error creating task '{summary}': {response.status_code} - {response.text}")
        return None
    
    return response.json().get("key")

# === MAIN ===
def main():
    print("=== JIRA ISSUE CREATION SCRIPT ===")
    
    # First, let's check if we can authenticate and get user info
    print("Checking authentication...")
    user_info = get_current_user()
    if user_info:
        print(f"✓ Authenticated as: {user_info.get('displayName')} ({user_info.get('emailAddress')})")
    else:
        print("✗ Authentication failed")
        return
    
    # Use the existing project you created
    project_key = "LP"  # Learning Platform project
    
    print(f"\nChecking project: {project_key}")
    project_info = get_project_info(project_key)
    if project_info:
        print(f"✓ Project found: {project_info.get('name')} ({project_info.get('key')})")
        print(f"  Project Type: {project_info.get('projectTypeKey')}")
        print(f"  Lead: {project_info.get('lead', {}).get('displayName', 'Unknown')}")
    else:
        print("✗ Could not access project")
        return
    
    # Update the global PROJECT_KEY to use the existing project
    global PROJECT_KEY
    PROJECT_KEY = project_key
    
    print("\nStarting Jira issue creation...")
    print(f"Jira Base URL: {JIRA_BASE_URL}")
    print(f"Using Project Key: {PROJECT_KEY}")
    print(f"Email: {JIRA_EMAIL}")
    print("---")
    
    for module in MODULES:
        print(f"Creating Epic: {module['name']}")
        epic_key = create_epic(module["name"])
        if epic_key:
            print(f"✓ Created Epic: {module['name']} -> {epic_key}")
            for session in module["sessions"]:
                story_key = create_story(session, epic_key)
                if story_key:
                    print(f"  ✓ Task: {session} -> {story_key}")
                else:
                    print(f"  ✗ Failed to create task: {session}")
        else:
            print(f"✗ Failed to create epic: {module['name']}")
            print(f"  Skipping sessions for this module.")

if __name__ == "__main__":
    print("Script is starting...")
    main()
    print("Script completed.")
