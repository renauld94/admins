#!/bin/bash

# Complete datasource reconfiguration for Grafana

GRAFANA_URL="https://grafana.simondatalab.de"
DATASOURCE_ID="1"

echo "=========================================="
echo "Complete Prometheus Datasource Fix"
echo "=========================================="
echo ""

read -sp "Enter Grafana password: " GRAFANA_PASS
echo ""
read -sp "Enter Prometheus password (for simonadmin): " PROM_PASS
echo ""
echo ""

# Create complete datasource config
cat > /tmp/prometheus_datasource.json <<EOF
{
  "id": 1,
  "uid": "PBFA97CFB590B2093",
  "orgId": 1,
  "name": "Prometheus",
  "type": "prometheus",
  "typeName": "Prometheus",
  "typeLogoUrl": "public/plugins/prometheus/img/prometheus_logo.svg",
  "access": "proxy",
  "url": "http://prometheus:9090",
  "user": "",
  "database": "",
  "basicAuth": true,
  "basicAuthUser": "simonadmin",
  "isDefault": true,
  "jsonData": {
    "httpMethod": "POST",
    "timeInterval": "15s"
  },
  "secureJsonData": {
    "basicAuthPassword": "$PROM_PASS"
  },
  "readOnly": false
}
EOF

echo "1. Updating datasource with complete configuration..."
RESPONSE=$(curl -s -w "\n%{http_code}" -u "sn.renauld@gmail.com:$GRAFANA_PASS" \
    -X PUT \
    -H "Content-Type: application/json" \
    -d @/tmp/prometheus_datasource.json \
    "$GRAFANA_URL/api/datasources/$DATASOURCE_ID")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Datasource updated!"
    echo ""
    echo "$RESPONSE_BODY" | jq '{message, name: .datasource.name, url: .datasource.url, basicAuth: .datasource.basicAuth}'
    echo ""
    echo "2. Testing connection..."
    sleep 2
    
    TEST_RESPONSE=$(curl -s -u "sn.renauld@gmail.com:$GRAFANA_PASS" \
        "$GRAFANA_URL/api/datasources/uid/PBFA97CFB590B2093/health")
    
    echo "$TEST_RESPONSE" | jq '.'
    echo ""
    
    if echo "$TEST_RESPONSE" | grep -q '"status":"OK"'; then
        echo "=========================================="
        echo "✅ SUCCESS! Datasource is working!"
        echo "=========================================="
    else
        echo "⚠️  Health check returned error, but datasource may still work"
        echo "   Try refreshing dashboard: $GRAFANA_URL/d/agent-monitoring"
    fi
else
    echo "❌ Failed (HTTP $HTTP_CODE)"
    echo "$RESPONSE_BODY" | jq '.'
    exit 1
fi

rm -f /tmp/prometheus_datasource.json
