#!/usr/bin/env python3
"""
Find the correct Epic Link field ID for Jira
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

def find_epic_fields():
    """Find Epic-related fields"""
    print("=== FINDING EPIC FIELDS ===")
    
    # Get all fields
    url = f"{JIRA_BASE_URL}/rest/api/3/field"
    response = requests.get(url, headers=HEADERS, auth=AUTH)
    
    if response.status_code != 200:
        print(f"Error getting fields: {response.status_code} - {response.text}")
        return
    
    fields = response.json()
    epic_fields = []
    
    for field in fields:
        name = field.get('name', '').lower()
        if 'epic' in name or field.get('id', '') == 'customfield_10011':
            epic_fields.append({
                'id': field.get('id'),
                'name': field.get('name'),
                'custom': field.get('custom', False),
                'schema': field.get('schema', {})
            })
    
    print(f"Found {len(epic_fields)} Epic-related fields:")
    for field in epic_fields:
        print(f"  - {field['id']}: {field['name']} (Custom: {field['custom']})")
    
    return epic_fields

def get_create_issue_metadata():
    """Get metadata for creating issues in the project"""
    print("\n=== GETTING CREATE ISSUE METADATA ===")
    
    url = f"{JIRA_BASE_URL}/rest/api/3/issue/createmeta"
    params = {
        'projectKeys': PROJECT_KEY,
        'issuetypeNames': 'Epic,Story',
        'expand': 'projects.issuetypes.fields'
    }
    
    response = requests.get(url, headers=HEADERS, auth=AUTH, params=params)
    
    if response.status_code != 200:
        print(f"Error getting create metadata: {response.status_code} - {response.text}")
        return
    
    metadata = response.json()
    
    for project in metadata.get('projects', []):
        print(f"\nProject: {project.get('name')} ({project.get('key')})")
        for issuetype in project.get('issuetypes', []):
            print(f"  Issue Type: {issuetype.get('name')}")
            fields = issuetype.get('fields', {})
            
            # Look for Epic-related fields
            epic_fields = []
            for field_id, field_info in fields.items():
                field_name = field_info.get('name', '').lower()
                if 'epic' in field_name:
                    epic_fields.append(f"    - {field_id}: {field_info.get('name')}")
            
            if epic_fields:
                print("    Epic-related fields:")
                for field in epic_fields:
                    print(field)
            else:
                print("    No Epic-related fields found")

if __name__ == "__main__":
    find_epic_fields()
    get_create_issue_metadata()
