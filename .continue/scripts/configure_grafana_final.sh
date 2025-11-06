#!/bin/bash

# Manual Grafana datasource configuration via UI bypass
# Directly updates the datasource to use prometheus container name

echo "=========================================="
echo "Configuring Grafana Prometheus Datasource"
echo "=========================================="
echo ""
echo "Setting up connection to: http://prometheus:9090"
echo ""

read -sp "Enter your Grafana password: " GRAFANA_PASS
echo ""
echo ""

# Step 1: Get current datasource
echo "1. Fetching datasource configuration..."
DATASOURCE=$(curl -s -u "sn.renauld@gmail.com:$GRAFANA_PASS" \
    https://grafana.simondatalab.de/api/datasources/1)

echo "   Current URL: $(echo "$DATASOURCE" | jq -r '.url')"
echo ""

# Step 2: Update with prometheus container name
echo "2. Updating datasource URL to http://prometheus:9090..."
UPDATED=$(curl -s -u "sn.renauld@gmail.com:$GRAFANA_PASS" \
    -X PUT \
    -H "Content-Type: application/json" \
    -d '{
      "id": 1,
      "uid": "PBFA97CFB590B2093",
      "orgId": 1,
      "name": "Prometheus",
      "type": "prometheus",
      "typeLogoUrl": "public/plugins/prometheus/img/prometheus_logo.svg",
      "access": "proxy",
      "url": "http://prometheus:9090",
      "user": "",
      "database": "",
      "basicAuth": false,
      "basicAuthUser": "",
      "withCredentials": false,
      "isDefault": true,
      "jsonData": {
        "timeInterval": "15s"
      },
      "secureJsonFields": {},
      "version": 1,
      "readOnly": false
    }' \
    https://grafana.simondatalab.de/api/datasources/1)

echo "$UPDATED" | jq '.'
echo ""

# Step 3: Verify
echo "3. Verifying configuration..."
VERIFY=$(curl -s -u "sn.renauld@gmail.com:$GRAFANA_PASS" \
    https://grafana.simondatalab.de/api/datasources/1)

echo "   Final URL: $(echo "$VERIFY" | jq -r '.url')"
echo "   Access Mode: $(echo "$VERIFY" | jq -r '.access')"
echo ""

echo "=========================================="
echo "✅ Configuration Complete"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Open Grafana: https://grafana.simondatalab.de"
echo "2. Go to Data Sources settings"
echo "3. Click on Prometheus datasource"
echo "4. Scroll down and click 'Save & Test'"
echo "5. You should see 'Data source is working' in green"
echo ""
echo "If test still fails in UI but you see this message,"
echo "refresh your dashboard: https://grafana.simondatalab.de/d/agent-monitoring"
echo "The panels may work despite the test showing an error."
echo ""
