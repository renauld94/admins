#!/bin/bash

# Cloudflare Tunnel Route Checker
# Fetches and displays current tunnel routes

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Cloudflare Configuration
TUNNEL_ID="a10f0734-57e8-439f-8d1d-ef7a1cf54da0"

# Check for API token
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    print_error "CLOUDFLARE_API_TOKEN environment variable not set"
    echo ""
    echo "To get your API token:"
    echo "1. Go to: https://dash.cloudflare.com/profile/api-tokens"
    echo "2. Click: 'Create Token'"
    echo "3. Use template: 'Edit Cloudflare Zero Trust'"
    echo "4. Copy the token and run:"
    echo ""
    echo "   export CLOUDFLARE_API_TOKEN='your-token-here'"
    echo "   $0"
    echo ""
    exit 1
fi

# Get Account ID
print_status "Getting Cloudflare Account ID..."
ACCOUNTS_RESPONSE=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json")

ACCOUNT_ID=$(echo "$ACCOUNTS_RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

if [ -z "$ACCOUNT_ID" ]; then
    print_error "Failed to get Account ID"
    echo "Response: $ACCOUNTS_RESPONSE"
    exit 1
fi

print_success "Account ID: $ACCOUNT_ID"

# Get tunnel configuration
print_status "Fetching tunnel configuration..."
TUNNEL_CONFIG=$(curl -s -X GET \
    "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/cfd_tunnel/$TUNNEL_ID/configurations" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json")

# Save full response
echo "$TUNNEL_CONFIG" > /tmp/tunnel_config_full.json

# Check if successful
if ! echo "$TUNNEL_CONFIG" | grep -q '"success":true'; then
    print_error "Failed to fetch tunnel configuration"
    echo "Response:"
    cat /tmp/tunnel_config_full.json
    exit 1
fi

print_success "Tunnel configuration fetched successfully!"
echo ""

# Parse and display routes
print_status "Current Tunnel Routes:"
echo ""
echo "════════════════════════════════════════════════════════════"

# Extract ingress rules and display them
echo "$TUNNEL_CONFIG" | jq -r '.result.config.ingress[]? | "  \(.hostname // "catch-all") → \(.service)"' 2>/dev/null || {
    print_warning "Could not parse with jq, showing raw config:"
    echo "$TUNNEL_CONFIG" | grep -E 'hostname|service' || cat /tmp/tunnel_config_full.json
}

echo "════════════════════════════════════════════════════════════"
echo ""

print_status "Full configuration saved to: /tmp/tunnel_config_full.json"
echo ""

# Show which services should be where
echo "════════════════════════════════════════════════════════════"
echo "EXPECTED ROUTING (based on your VMs):"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "CT 150 (10.0.0.150) - Portfolio:"
echo "  • www.simondatalab.de"
echo "  • simondatalab.de"
echo "  • prometheus.simondatalab.de (port 9090)"
echo "  • analytics.simondatalab.de (port 3000)"
echo "  • api.simondatalab.de (port 8000)"
echo ""
echo "VM 159 (10.0.0.110) - AI Services:"
echo "  • openwebui.simondatalab.de (port 3001)"
echo "  • ollama.simondatalab.de (port 11434)"
echo "  • mlflow.simondatalab.de (port 5000)"
echo ""
echo "VM 9001 (10.0.0.104) - LMS:"
echo "  • grafana.simondatalab.de (port 3000)"
echo "  • moodle.simondatalab.de (port 80)"
echo ""
echo "VM 106 (10.0.0.111) - GeoServer:"
echo "  • geoneuralviz.simondatalab.de (port 8080)"
echo ""
echo "VM 200 (10.0.0.103) - Media:"
echo "  • jellyfin.simondatalab.de (port 8096)"
echo "  • booklore.simondatalab.de (port 8083)"
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""

print_status "To view full JSON config:"
echo "  cat /tmp/tunnel_config_full.json | jq '.result.config'"
echo ""

print_status "To update tunnel routes, run:"
echo "  /home/simon/Learning-Management-System-Academy/scripts/update_cloudflare_tunnel_routes.sh"
