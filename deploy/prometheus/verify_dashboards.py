#!/usr/bin/env python3
"""
Verify Grafana Dashboards and Prometheus Connection
"""

import requests
import getpass
import json

GRAFANA_URL = "https://grafana.simondatalab.de"

print("🔍 Grafana Dashboard & Prometheus Verification")
print("=" * 70)
print()

username = input("Enter Grafana admin username [simonadmin]: ").strip() or "simonadmin"
password = getpass.getpass("Enter admin password: ")

session = requests.Session()
session.auth = (username, password)
session.headers.update({"Content-Type": "application/json"})

# 1. Check Prometheus datasource
print("1️⃣  Checking Prometheus datasource configuration...")
response = session.get(f"{GRAFANA_URL}/api/datasources/name/Prometheus")
if response.status_code == 200:
    ds = response.json()
    print(f"   ✅ Datasource ID: {ds['id']}")
    print(f"   ✅ URL: {ds['url']}")
    print(f"   ✅ Access: {ds['access']}")
else:
    print(f"   ❌ Failed: {response.status_code}")
    exit(1)

print()

# 2. Test Prometheus query
print("2️⃣  Testing Prometheus query (up metric)...")
test_url = f"{GRAFANA_URL}/api/datasources/proxy/{ds['id']}/api/v1/query"
test_response = session.get(test_url, params={"query": "up"})

if test_response.status_code == 200:
    result = test_response.json()
    if result.get('status') == 'success':
        targets = result.get('data', {}).get('result', [])
        print(f"   ✅ Query successful! Found {len(targets)} targets:")
        for target in targets:
            instance = target['metric'].get('instance', 'N/A')
            job = target['metric'].get('job', 'N/A')
            value = target['value'][1]
            status = "🟢 UP" if value == "1" else "🔴 DOWN"
            print(f"      {status} {job:20s} {instance}")
    else:
        print(f"   ⚠️  Query returned but status: {result.get('status')}")
else:
    print(f"   ❌ Query failed: {test_response.status_code}")
    print(f"      {test_response.text[:200]}")

print()

# 3. List imported dashboards
print("3️⃣  Checking imported dashboards...")
response = session.get(f"{GRAFANA_URL}/api/search?type=dash-db")
if response.status_code == 200:
    dashboards = response.json()
    print(f"   ✅ Found {len(dashboards)} dashboards:")
    for dash in dashboards:
        print(f"      📊 {dash['title']:40s} (UID: {dash['uid']})")
else:
    print(f"   ❌ Failed: {response.status_code}")

print()

# 4. Test specific metrics for each scrape job
print("4️⃣  Testing metrics from each monitoring target...")
test_queries = [
    ("Proxmox Host CPU", 'node_cpu_seconds_total{job="proxmox-host"}'),
    ("Proxmox Host Memory", 'node_memory_MemTotal_bytes{job="proxmox-host"}'),
    ("VM 159 CPU", 'node_cpu_seconds_total{job="vm159-node"}'),
    ("VM 159 Memory", 'node_memory_MemTotal_bytes{job="vm159-node"}'),
    ("Docker Containers", 'container_last_seen{job="vm159-cadvisor"}'),
]

for name, query in test_queries:
    response = session.get(test_url, params={"query": query})
    if response.status_code == 200:
        result = response.json()
        if result.get('status') == 'success':
            results = result.get('data', {}).get('result', [])
            if results:
                print(f"   ✅ {name:25s} - {len(results)} series")
            else:
                print(f"   ⚠️  {name:25s} - No data")
        else:
            print(f"   ❌ {name:25s} - Query error")
    else:
        print(f"   ❌ {name:25s} - HTTP {response.status_code}")

print()
print("=" * 70)
print("🎉 Verification complete!")
print()
print("📝 Next steps:")
print("   1. Open Grafana dashboards in browser")
print("   2. Check browser console for any remaining errors")
print("   3. Verify graphs are displaying data")
print()
