#!/usr/bin/env python3
"""
Fix Grafana Prometheus Data Source URL
Changes from localhost:9091 to 10.0.0.1:9091
"""

import requests
import json
import getpass

GRAFANA_URL = "https://grafana.simondatalab.de"

print("🔧 Fixing Grafana Prometheus Data Source")
print("=" * 60)
print()
print("⚠️  IMPORTANT: Username is 'simonadmin' (NOT your password or email)")
print("=" * 60)
print()

username = input("Enter Grafana admin username [simonadmin]: ").strip() or "simonadmin"
password = getpass.getpass("Enter admin password: ")

session = requests.Session()
session.auth = (username, password)
session.headers.update({"Content-Type": "application/json"})

# Get current datasource
print("📊 Getting current Prometheus datasource...")
response = session.get(f"{GRAFANA_URL}/api/datasources/name/Prometheus")

if response.status_code != 200:
    print(f"❌ Failed to get datasource: {response.status_code}")
    exit(1)

datasource = response.json()
ds_id = datasource['id']

print(f"✅ Found datasource ID: {ds_id}")
print(f"   Current URL: {datasource.get('url', 'N/A')}")
print()

# Update URL
print("🔄 Updating URL to point to Proxmox host...")
datasource['url'] = "http://10.0.0.1:9091"
datasource['access'] = "proxy"

response = session.put(
    f"{GRAFANA_URL}/api/datasources/{ds_id}",
    json=datasource
)

if response.status_code == 200:
    print("✅ Datasource updated successfully!")
    print(f"   New URL: http://10.0.0.1:9091")
    print()
    
    # Test the datasource
    print("🧪 Testing Prometheus connection...")
    test_url = f"{GRAFANA_URL}/api/datasources/proxy/{ds_id}/api/v1/query"
    test_params = {"query": "up"}
    
    test_response = session.get(test_url, params=test_params)
    if test_response.status_code == 200:
        result = test_response.json()
        if result.get('status') == 'success':
            print("✅ Prometheus connection working!")
            print(f"   Found {len(result.get('data', {}).get('result', []))} targets")
        else:
            print("⚠️  Query returned but with errors")
    else:
        print(f"❌ Test failed: {test_response.status_code}")
else:
    print(f"❌ Failed to update datasource: {response.status_code}")
    print(f"   Response: {response.text}")

print()
print("=" * 60)
print("🎉 Done! Refresh your Grafana dashboards to see metrics")
print()
