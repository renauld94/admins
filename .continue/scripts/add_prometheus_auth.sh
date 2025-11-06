#!/bin/bash

# Add basic authentication to Grafana Prometheus datasource

GRAFANA_URL="https://grafana.simondatalab.de"
DATASOURCE_ID="1"
PROM_USER="simonadmin"

echo "=========================================="
echo "Add Prometheus Basic Auth to Grafana"
echo "=========================================="
echo ""
echo "Prometheus username: $PROM_USER"
echo ""

# Get passwords
read -sp "Enter Grafana password (sn.renauld@gmail.com): " GRAFANA_PASS
echo ""
read -sp "Enter Prometheus password (for simonadmin): " PROM_PASS
echo ""
echo ""

# Get current datasource config
echo "1. Fetching current datasource configuration..."
CURRENT_CONFIG=$(curl -s -u "sn.renauld@gmail.com:$GRAFANA_PASS" \
    "$GRAFANA_URL/api/datasources/$DATASOURCE_ID")

if [ $? -ne 0 ]; then
    echo "❌ Failed to fetch datasource"
    exit 1
fi

echo "✓ Current config retrieved"
echo ""

# Update with basic auth
echo "2. Enabling basic authentication..."
UPDATED_CONFIG=$(echo "$CURRENT_CONFIG" | jq \
    --arg user "$PROM_USER" \
    --arg pass "$PROM_PASS" \
    '.basicAuth = true | .basicAuthUser = $user | .secureJsonData.basicAuthPassword = $pass')

# Send update
RESPONSE=$(curl -s -w "\n%{http_code}" -u "sn.renauld@gmail.com:$GRAFANA_PASS" \
    -X PUT \
    -H "Content-Type: application/json" \
    -d "$UPDATED_CONFIG" \
    "$GRAFANA_URL/api/datasources/$DATASOURCE_ID")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Basic authentication enabled!"
    echo ""
    echo "Username: $(echo "$RESPONSE_BODY" | jq -r '.datasource.basicAuthUser')"
    echo "URL: $(echo "$RESPONSE_BODY" | jq -r '.datasource.url')"
    echo ""
    echo "=========================================="
    echo "✅ SUCCESS!"
    echo "=========================================="
    echo ""
    echo "Now test the datasource:"
    echo "1. Go to: $GRAFANA_URL/datasources/edit/PBFA97CFB590B2093"
    echo "2. Click 'Save & Test' - should work now!"
    echo "3. Check dashboard: $GRAFANA_URL/d/agent-monitoring"
else
    echo "❌ Failed (HTTP $HTTP_CODE)"
    echo ""
    echo "$RESPONSE_BODY" | jq '.' 2>/dev/null || echo "$RESPONSE_BODY"
    exit 1
fi
