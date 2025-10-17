#!/usr/bin/env python3
"""
Grafana Dashboard Import - Simplified Version
Works with any admin account
"""

import requests
import json
import getpass
import sys

GRAFANA_URL = "https://grafana.simondatalab.de"

print("🚀 Grafana Dashboard Import Tool")
print("=" * 60)
print()
print("Available users in your Grafana:")
print("  1. simonadmin (admin@localhost)")
print("  2. sn.renauld@gmail.com")
print()
print("Make sure your account has 'Admin' role!")
print()

username = input("Enter username (or email): ").strip()
password = getpass.getpass("Enter password: ")

session = requests.Session()
session.auth = (username, password)
session.headers.update({"Content-Type": "application/json"})

def test_admin():
    """Check if user has admin permissions"""
    response = session.get(f"{GRAFANA_URL}/api/admin/settings")
    return response.status_code == 200

def get_datasource():
    """Get or create Prometheus datasource"""
    # Check existing
    response = session.get(f"{GRAFANA_URL}/api/datasources/name/Prometheus")
    if response.status_code == 200:
        print("✅ Prometheus datasource found")
        return response.json()
    
    # Create new
    print("📊 Creating Prometheus datasource...")
    config = {
        "name": "Prometheus",
        "type": "prometheus",
        "url": "http://localhost:9091",
        "access": "proxy",
        "isDefault": True
    }
    response = session.post(f"{GRAFANA_URL}/api/datasources", json=config)
    if response.status_code in [200, 201]:
        print("✅ Datasource created")
        return response.json()
    return None

def import_dashboard(dash_id, name):
    """Import dashboard from grafana.com"""
    print(f"\n📥 Importing: {name} (ID: {dash_id})")
    
    # Download from grafana.com
    url = f"https://grafana.com/api/dashboards/{dash_id}/revisions/latest/download"
    resp = requests.get(url)
    if resp.status_code != 200:
        print(f"❌ Download failed")
        return False
    
    # Import
    payload = {
        "dashboard": resp.json(),
        "overwrite": True,
        "folderId": 0
    }
    
    resp = session.post(f"{GRAFANA_URL}/api/dashboards/db", json=payload)
    if resp.status_code in [200, 201]:
        result = resp.json()
        url = f"{GRAFANA_URL}{result.get('url', '')}"
        print(f"✅ Imported! URL: {url}")
        return True
    else:
        print(f"❌ Failed: {resp.status_code}")
        if resp.status_code == 403:
            print("   You need Admin role! Change it in Grafana UI:")
            print("   Administration → Users → Your User → Change Role to Admin")
        return False

print("🔐 Checking permissions...")
if not test_admin():
    print()
    print("❌ Your account needs Admin permissions!")
    print()
    print("To fix this:")
    print("1. Login to Grafana as an admin user")
    print("2. Go to: Administration → Users and access → Users")
    print("3. Click on your user (sn.renauld@gmail.com)")
    print("4. Change 'Organization role' to 'Admin'")
    print("5. Save and run this script again")
    print()
    sys.exit(1)

print("✅ Admin access confirmed!")
print()

# Get datasource
ds = get_datasource()
if not ds:
    print("❌ Failed to configure datasource")
    sys.exit(1)

print()
print("=" * 60)
print("Importing Dashboards...")
print("=" * 60)

dashboards = [
    (1860, "Node Exporter Full"),
    (179, "Docker Container Metrics"),
    (893, "System Monitoring")
]

success = 0
for dash_id, name in dashboards:
    if import_dashboard(dash_id, name):
        success += 1

print()
print("=" * 60)
print(f"🎉 Complete! Imported {success}/{len(dashboards)} dashboards")
print()
print(f"📊 View at: {GRAFANA_URL}/dashboards")
print()
