#!/bin/bash

# Update Grafana Prometheus datasource to use Docker host gateway IP
# This allows Grafana container to reach Prometheus container via host bridge

GRAFANA_URL="https://grafana.simondatalab.de"
DATASOURCE_UID="PBFA97CFB590B2093"
NEW_URL="http://172.22.0.1:9090"

echo "=========================================="
echo "Grafana Datasource URL Update"
echo "=========================================="
echo ""
echo "From: http://localhost:9090"
echo "To:   $NEW_URL"
echo ""
echo "This uses the Docker host gateway IP so Grafana container"
echo "can reach your local Prometheus container."
echo ""
echo "=========================================="
echo ""

# Prompt for credentials
read -p "Enter your Grafana username (sn.renauld@gmail.com): " USERNAME
read -sp "Enter your Grafana password: " PASSWORD
echo ""
echo ""

# Get current datasource configuration
echo "1. Fetching current datasource configuration..."
CURRENT_CONFIG=$(curl -s -u "$USERNAME:$PASSWORD" \
    "$GRAFANA_URL/api/datasources/uid/$DATASOURCE_UID")

if [ $? -ne 0 ]; then
    echo "❌ Failed to fetch datasource configuration"
    exit 1
fi

echo "✓ Current datasource retrieved"
echo ""

# Get datasource ID
DATASOURCE_ID=$(echo "$CURRENT_CONFIG" | jq -r '.id')
echo "   Datasource ID: $DATASOURCE_ID"
echo "   Current URL: $(echo "$CURRENT_CONFIG" | jq -r '.url')"
echo ""

# Update the URL in the configuration
echo "2. Updating datasource URL..."
UPDATED_CONFIG=$(echo "$CURRENT_CONFIG" | jq --arg url "$NEW_URL" '.url = $url')

# Send update request
UPDATE_RESPONSE=$(curl -s -w "\n%{http_code}" -u "$USERNAME:$PASSWORD" \
    -X PUT \
    -H "Content-Type: application/json" \
    -d "$UPDATED_CONFIG" \
    "$GRAFANA_URL/api/datasources/$DATASOURCE_ID")

HTTP_CODE=$(echo "$UPDATE_RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$UPDATE_RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Datasource updated successfully!"
    echo ""
    echo "$RESPONSE_BODY" | jq -r '.message'
    echo ""
    echo "New URL: $(echo "$RESPONSE_BODY" | jq -r '.datasource.url')"
    echo ""
    echo "=========================================="
    echo "✅ SUCCESS!"
    echo "=========================================="
    echo ""
    echo "Now test the datasource:"
    echo "1. Go to: $GRAFANA_URL/datasources/edit/$DATASOURCE_UID"
    echo "2. Click 'Save & Test' button"
    echo "3. Should see: 'Data source is working'"
    echo ""
    echo "Then check your dashboards:"
    echo "• Agent Monitoring: $GRAFANA_URL/d/agent-monitoring"
    echo "• Docker & Host: $GRAFANA_URL/d/64nrElFmk/docker-and-host-monitoring-w-prometheus"
    echo ""
else
    echo "❌ Failed to update datasource (HTTP $HTTP_CODE)"
    echo ""
    echo "Response:"
    echo "$RESPONSE_BODY" | jq '.' 2>/dev/null || echo "$RESPONSE_BODY"
    exit 1
fi
