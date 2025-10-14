#!/usr/bin/env python3
"""
Simple Jira authentication test
"""
import os
import requests
from dotenv import load_dotenv
import base64

# Clear any existing environment variables and reload
for key in ['JIRA_BASE_URL', 'JIRA_EMAIL', 'JIRA_API_TOKEN']:
    if key in os.environ:
        del os.environ[key]

# Load environment variables fresh
load_dotenv(override=True)

JIRA_BASE_URL = os.getenv("JIRA_BASE_URL")
JIRA_EMAIL = os.getenv("JIRA_EMAIL")
JIRA_API_TOKEN = os.getenv("JIRA_API_TOKEN")

print("=== JIRA AUTHENTICATION TEST ===")
print(f"Base URL: {JIRA_BASE_URL}")
print(f"Email: {JIRA_EMAIL}")
print(f"API Token: {JIRA_API_TOKEN[:10]}...{JIRA_API_TOKEN[-10:]}")
print()

# Test 1: Basic auth with requests library (current method)
print("Test 1: Using requests.auth.HTTPBasicAuth")
auth = (JIRA_EMAIL, JIRA_API_TOKEN)
headers = {
    "Accept": "application/json",
    "Content-Type": "application/json"
}

url = f"{JIRA_BASE_URL}/rest/api/3/myself"
response = requests.get(url, headers=headers, auth=auth)
print(f"Status Code: {response.status_code}")
print(f"Response: {response.text[:200]}")
print()

# Test 2: Manual basic auth header
print("Test 2: Using manual Basic Auth header")
credentials = f"{JIRA_EMAIL}:{JIRA_API_TOKEN}"
encoded_credentials = base64.b64encode(credentials.encode()).decode()
headers_manual = {
    "Accept": "application/json",
    "Content-Type": "application/json",
    "Authorization": f"Basic {encoded_credentials}"
}

response2 = requests.get(url, headers=headers_manual)
print(f"Status Code: {response2.status_code}")
print(f"Response: {response2.text[:200]}")
print()

# Test 3: Simple connectivity test
print("Test 3: Basic connectivity test")
try:
    response3 = requests.get(JIRA_BASE_URL, timeout=10)
    print(f"Base URL accessible: {response3.status_code}")
except Exception as e:
    print(f"Connection error: {e}")
