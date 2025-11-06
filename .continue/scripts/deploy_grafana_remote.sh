#!/bin/bash

# Deploy Grafana 11.4.0 setup to remote server
# This script exports the local Grafana configuration and deploys to the remote instance

echo "=========================================="
echo "Grafana Deployment to grafana.simondatalab.de"
echo "=========================================="
echo ""

read -sp "Enter remote Grafana admin password: " REMOTE_PASS
echo ""
REMOTE_URL="https://grafana.simondatalab.de"
REMOTE_USER="admin"

echo ""
echo "1. Exporting local Prometheus datasource..."
curl -s -u "admin:Desjardins1###" "http://localhost:3000/api/datasources" | jq '.[] | select(.type=="prometheus")' > /tmp/prometheus_ds.json
cat /tmp/prometheus_ds.json

echo ""
echo "2. Creating Prometheus datasource on remote Grafana..."
curl -s -u "$REMOTE_USER:$REMOTE_PASS" -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Prometheus",
    "type": "prometheus",
    "url": "http://prometheus:9090",
    "access": "proxy",
    "isDefault": true,
    "jsonData": {
      "timeInterval": "15s"
    }
  }' \
  "$REMOTE_URL/api/datasources" | jq '{id, name, message}'

echo ""
echo "3. Exporting local agent monitoring dashboard..."
curl -s -u "admin:Desjardins1###" "http://localhost:3000/api/dashboards/uid/agent-monitoring" | jq '.dashboard' > /tmp/agent_dashboard.json

echo "4. Importing dashboard to remote Grafana..."
jq '{dashboard: ., overwrite: true}' /tmp/agent_dashboard.json | \
curl -s -u "$REMOTE_USER:$REMOTE_PASS" -X POST \
  -H "Content-Type: application/json" \
  -d @- \
  "$REMOTE_URL/api/dashboards/db" | jq '{status, uid, url, message}'

echo ""
echo "=========================================="
echo "✅ Deployment Complete"
echo "=========================================="
echo ""
echo "Remote Grafana: $REMOTE_URL"
echo "Dashboard: $REMOTE_URL/d/agent-monitoring"
echo "Username: $REMOTE_USER"
echo ""
