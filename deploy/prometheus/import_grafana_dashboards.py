#!/usr/bin/env python3
"""
Grafana Dashboard Auto-Import Script
Configures Prometheus data source and imports monitoring dashboards
"""

import requests
import json
import time
import sys
import getpass

# Grafana Configuration
GRAFANA_URL = "https://grafana.simondatalab.de"
GRAFANA_USER = input("Enter Grafana username (default: sn.renauld@gmail.com): ").strip() or "sn.renauld@gmail.com"
GRAFANA_PASSWORD = getpass.getpass("Enter Grafana password: ")

# Prometheus Configuration
PROMETHEUS_URL = "http://localhost:9091"

# Dashboards to import
DASHBOARDS = [
    {
        "id": 1860,
        "name": "Node Exporter Full",
        "description": "Complete metrics for Proxmox host and VM 159"
    },
    {
        "id": 179,
        "name": "Docker Container & Host Metrics",
        "description": "Container metrics for Ollama, OpenWebUI, MLflow"
    },
    {
        "id": 893,
        "name": "Docker and System Monitoring",
        "description": "Alternative comprehensive Docker monitoring"
    }
]

session = requests.Session()
session.auth = (GRAFANA_USER, GRAFANA_PASSWORD)
session.headers.update({"Content-Type": "application/json"})

def check_grafana_health():
    """Check if Grafana is accessible"""
    try:
        response = session.get(f"{GRAFANA_URL}/api/health", verify=True)
        if response.status_code == 200:
            print("✅ Grafana is accessible")
            return True
        else:
            print(f"❌ Grafana returned status {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Cannot connect to Grafana: {e}")
        return False

def get_or_create_datasource():
    """Get existing Prometheus datasource or create new one"""
    # Check if datasource exists
    response = session.get(f"{GRAFANA_URL}/api/datasources/name/Prometheus")
    
    if response.status_code == 200:
        print("✅ Prometheus datasource already exists")
        return response.json()
    
    # Create new datasource
    print("📊 Creating Prometheus datasource...")
    datasource_config = {
        "name": "Prometheus",
        "type": "prometheus",
        "url": PROMETHEUS_URL,
        "access": "proxy",
        "isDefault": True,
        "jsonData": {
            "httpMethod": "POST",
            "timeInterval": "30s"
        }
    }
    
    response = session.post(
        f"{GRAFANA_URL}/api/datasources",
        json=datasource_config
    )
    
    if response.status_code in [200, 201]:
        print("✅ Prometheus datasource created successfully")
        return response.json()
    else:
        print(f"❌ Failed to create datasource: {response.status_code}")
        print(f"   Response: {response.text}")
        return None

def test_datasource(datasource_id):
    """Test the datasource connection"""
    print("🧪 Testing Prometheus connection...")
    response = session.get(f"{GRAFANA_URL}/api/datasources/{datasource_id}")
    
    if response.status_code == 200:
        # Try to query Prometheus
        test_url = f"{GRAFANA_URL}/api/datasources/proxy/{datasource_id}/api/v1/query"
        test_params = {"query": "up"}
        
        test_response = session.get(test_url, params=test_params)
        if test_response.status_code == 200:
            print("✅ Prometheus datasource is working")
            return True
        else:
            print("⚠️  Datasource created but connection test failed")
            return False
    return False

def import_dashboard(dashboard_id, dashboard_name, datasource_uid):
    """Import dashboard from Grafana.com"""
    print(f"\n📥 Importing dashboard: {dashboard_name} (ID: {dashboard_id})")
    
    # Get dashboard JSON from Grafana.com
    try:
        grafana_com_url = f"https://grafana.com/api/dashboards/{dashboard_id}/revisions/latest/download"
        response = requests.get(grafana_com_url)
        
        if response.status_code != 200:
            print(f"❌ Failed to download dashboard from Grafana.com")
            return False
        
        dashboard_json = response.json()
        
        # Prepare import payload
        import_payload = {
            "dashboard": dashboard_json,
            "overwrite": True,
            "inputs": [
                {
                    "name": "DS_PROMETHEUS",
                    "type": "datasource",
                    "pluginId": "prometheus",
                    "value": datasource_uid
                }
            ],
            "folderId": 0
        }
        
        # Import dashboard
        import_response = session.post(
            f"{GRAFANA_URL}/api/dashboards/import",
            json=import_payload
        )
        
        if import_response.status_code in [200, 201]:
            result = import_response.json()
            dashboard_url = f"{GRAFANA_URL}{result.get('importedUrl', '')}"
            print(f"✅ Dashboard imported successfully")
            print(f"   URL: {dashboard_url}")
            return True
        else:
            print(f"❌ Failed to import dashboard: {import_response.status_code}")
            print(f"   Response: {import_response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Error importing dashboard: {e}")
        return False

def create_custom_ai_dashboard(datasource_uid):
    """Create a custom dashboard for AI workloads"""
    print(f"\n📊 Creating custom AI Infrastructure dashboard...")
    
    custom_dashboard = {
        "dashboard": {
            "title": "AI Infrastructure Monitoring",
            "tags": ["ai", "containers", "infrastructure"],
            "timezone": "browser",
            "panels": [
                {
                    "id": 1,
                    "title": "Ollama Container Memory",
                    "type": "graph",
                    "gridPos": {"x": 0, "y": 0, "w": 12, "h": 8},
                    "targets": [
                        {
                            "expr": "container_memory_usage_bytes{name=\"ollama\"}",
                            "legendFormat": "Ollama Memory",
                            "refId": "A"
                        }
                    ],
                    "datasource": {"uid": datasource_uid}
                },
                {
                    "id": 2,
                    "title": "OpenWebUI Container Memory",
                    "type": "graph",
                    "gridPos": {"x": 12, "y": 0, "w": 12, "h": 8},
                    "targets": [
                        {
                            "expr": "container_memory_usage_bytes{name=\"openwebui\"}",
                            "legendFormat": "OpenWebUI Memory",
                            "refId": "A"
                        }
                    ],
                    "datasource": {"uid": datasource_uid}
                },
                {
                    "id": 3,
                    "title": "Total AI Stack Memory Usage",
                    "type": "stat",
                    "gridPos": {"x": 0, "y": 8, "w": 8, "h": 4},
                    "targets": [
                        {
                            "expr": "sum(container_memory_usage_bytes{name=~\"ollama|openwebui|mlflow\"})",
                            "refId": "A"
                        }
                    ],
                    "datasource": {"uid": datasource_uid}
                },
                {
                    "id": 4,
                    "title": "Container CPU Usage",
                    "type": "graph",
                    "gridPos": {"x": 0, "y": 12, "w": 24, "h": 8},
                    "targets": [
                        {
                            "expr": "rate(container_cpu_usage_seconds_total{name=~\"ollama|openwebui|mlflow\"}[5m])",
                            "legendFormat": "{{name}}",
                            "refId": "A"
                        }
                    ],
                    "datasource": {"uid": datasource_uid}
                }
            ],
            "schemaVersion": 16,
            "version": 0
        },
        "folderId": 0,
        "overwrite": True
    }
    
    response = session.post(
        f"{GRAFANA_URL}/api/dashboards/db",
        json=custom_dashboard
    )
    
    if response.status_code in [200, 201]:
        result = response.json()
        dashboard_url = f"{GRAFANA_URL}{result.get('url', '')}"
        print(f"✅ Custom AI dashboard created")
        print(f"   URL: {dashboard_url}")
        return True
    else:
        print(f"⚠️  Failed to create custom dashboard: {response.status_code}")
        return False

def main():
    print("🚀 Grafana Dashboard Auto-Import")
    print("=" * 60)
    print()
    
    # Check Grafana health
    if not check_grafana_health():
        print("\n❌ Cannot proceed - Grafana is not accessible")
        sys.exit(1)
    
    print()
    
    # Create or get datasource
    datasource = get_or_create_datasource()
    if not datasource:
        print("\n❌ Cannot proceed - Failed to configure datasource")
        sys.exit(1)
    
    datasource_uid = datasource.get('uid') or datasource.get('datasource', {}).get('uid')
    datasource_id = datasource.get('id') or datasource.get('datasource', {}).get('id')
    
    print(f"   Datasource UID: {datasource_uid}")
    print(f"   Datasource ID: {datasource_id}")
    print()
    
    # Test datasource
    test_datasource(datasource_id)
    print()
    
    # Import dashboards
    successful_imports = 0
    for dashboard in DASHBOARDS:
        if import_dashboard(dashboard['id'], dashboard['name'], datasource_uid):
            successful_imports += 1
        time.sleep(2)  # Be nice to Grafana.com API
    
    print()
    
    # Create custom AI dashboard
    create_custom_ai_dashboard(datasource_uid)
    
    print()
    print("=" * 60)
    print(f"🎉 Dashboard import complete!")
    print(f"   Successfully imported: {successful_imports}/{len(DASHBOARDS)} dashboards")
    print()
    print(f"📊 Access your dashboards at:")
    print(f"   {GRAFANA_URL}/dashboards")
    print()

if __name__ == "__main__":
    main()
