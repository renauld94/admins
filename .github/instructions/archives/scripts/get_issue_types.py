#!/usr/bin/env python3
"""
Get available issue types for the project
"""
import os
import json
import requests
from dotenv import load_dotenv

# Clear environment and reload
for key in ['JIRA_BASE_URL', 'JIRA_EMAIL', 'JIRA_API_TOKEN', 'PROJECT_KEY']:
    if key in os.environ:
        del os.environ[key]

load_dotenv(override=True)

JIRA_BASE_URL = os.getenv("JIRA_BASE_URL")
JIRA_EMAIL = os.getenv("JIRA_EMAIL")
JIRA_API_TOKEN = os.getenv("JIRA_API_TOKEN")
PROJECT_KEY = "LP"

AUTH = (JIRA_EMAIL, JIRA_API_TOKEN)
HEADERS = {
    "Accept": "application/json",
    "Content-Type": "application/json"
}

def get_issue_types():
    """Get available issue types for the project"""
    print("=== GETTING ISSUE TYPES ===")
    
    url = f"{JIRA_BASE_URL}/rest/api/3/issue/createmeta"
    params = {
        'projectKeys': PROJECT_KEY,
        'expand': 'projects.issuetypes'
    }
    
    response = requests.get(url, headers=HEADERS, auth=AUTH, params=params)
    
    if response.status_code != 200:
        print(f"Error getting issue types: {response.status_code} - {response.text}")
        return
    
    metadata = response.json()
    
    for project in metadata.get('projects', []):
        print(f"\nProject: {project.get('name')} ({project.get('key')})")
        print("Available Issue Types:")
        for issuetype in project.get('issuetypes', []):
            print(f"  - {issuetype.get('name')} (ID: {issuetype.get('id')})")

if __name__ == "__main__":
    get_issue_types()
