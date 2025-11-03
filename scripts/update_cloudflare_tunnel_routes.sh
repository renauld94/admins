#!/bin/bash

# Cloudflare Tunnel Route Update Script
# Updates tunnel routes via Cloudflare API to fix service routing

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
ACCOUNT_EMAIL="sn.renauld@gmail.com"
TUNNEL_ID="a10f0734-57e8-439f-8d1d-ef7a1cf54da0"

# Check for API token
if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    print_error "CLOUDFLARE_API_TOKEN environment variable not set"
    echo ""
    echo "To get your API token:"
    echo "1. Go to: https://dash.cloudflare.com/profile/api-tokens"
    echo "2. Click: 'Create Token'"
    echo "3. Use template: 'Edit Cloudflare Zero Trust'"
    echo "4. Or create custom token with permissions:"
    echo "   - Account:Cloudflare Tunnel:Edit"
    echo "   - Account:Access:Edit"
    echo "5. Copy the token and run:"
    echo ""
    echo "   export CLOUDFLARE_API_TOKEN='your-token-here'"
    echo "   $0"
    echo ""
    exit 1
fi

# Get Account ID from API
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

# Get current tunnel configuration
print_status "Fetching current tunnel configuration..."
TUNNEL_CONFIG=$(curl -s -X GET \
    "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/cfd_tunnel/$TUNNEL_ID/configurations" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json")

echo "$TUNNEL_CONFIG" | jq '.' > /tmp/current_tunnel_config.json 2>/dev/null || echo "$TUNNEL_CONFIG" > /tmp/current_tunnel_config.json

print_success "Current config saved to /tmp/current_tunnel_config.json"

# Define the correct routing configuration
print_status "Creating updated tunnel configuration..."

cat > /tmp/new_tunnel_config.json << 'EOF'
{
  "config": {
    "ingress": [
      {
        "hostname": "www.simondatalab.de",
        "service": "http://10.0.0.150:80"
      },
      {
        "hostname": "simondatalab.de",
        "service": "http://10.0.0.150:80"
      },
      {
        "hostname": "prometheus.simondatalab.de",
        "service": "http://10.0.0.150:9090"
      },
      {
        "hostname": "analytics.simondatalab.de",
        "service": "http://10.0.0.150:3000"
      },
      {
        "hostname": "api.simondatalab.de",
        "service": "http://10.0.0.150:8000"
      },
      {
        "hostname": "openwebui.simondatalab.de",
        "service": "http://10.0.0.110:3001"
      },
      {
        "hostname": "ollama.simondatalab.de",
        "service": "http://10.0.0.110:11434"
      },
      {
        "hostname": "mlflow.simondatalab.de",
        "service": "http://10.0.0.110:5000"
      },
      {
        "hostname": "grafana.simondatalab.de",
        "service": "http://10.0.0.104:3000"
      },
      {
        "hostname": "moodle.simondatalab.de",
        "service": "http://10.0.0.104:80"
      },
      {
        "hostname": "geoneuralviz.simondatalab.de",
        "service": "http://10.0.0.111:8080"
      },
      {
        "hostname": "jellyfin.simondatalab.de",
        "service": "http://10.0.0.103:8096"
      },
      {
        "hostname": "booklore.simondatalab.de",
        "service": "http://10.0.0.103:8083"
      },
      {
        "service": "http_status:404"
      }
    ]
  }
}
EOF

print_success "New configuration created"

# Show the changes
print_status "Configuration changes:"
echo ""
echo "════════════════════════════════════════════════════════════"
echo "SERVICE ROUTING MAP:"
echo "════════════════════════════════════════════════════════════"
echo "Portfolio Services (CT 150 - 10.0.0.150):"
echo "  ✓ www.simondatalab.de → http://10.0.0.150:80"
echo "  ✓ simondatalab.de → http://10.0.0.150:80"
echo "  ✓ prometheus.simondatalab.de → http://10.0.0.150:9090"
echo "  ✓ analytics.simondatalab.de → http://10.0.0.150:3000"
echo "  ✓ api.simondatalab.de → http://10.0.0.150:8000"
echo ""
echo "AI Services (VM 159 - 10.0.0.110):"
echo "  ✓ openwebui.simondatalab.de → http://10.0.0.110:3001"
echo "  ✓ ollama.simondatalab.de → http://10.0.0.110:11434"
echo "  ✓ mlflow.simondatalab.de → http://10.0.0.110:5000"
echo ""
echo "LMS Services (VM 9001 - 10.0.0.104):"
echo "  ✓ grafana.simondatalab.de → http://10.0.0.104:3000"
echo "  ✓ moodle.simondatalab.de → http://10.0.0.104:80"
echo ""
echo "Geo Services (VM 106 - 10.0.0.111):"
echo "  ✓ geoneuralviz.simondatalab.de → http://10.0.0.111:8080"
echo ""
echo "Media Services (VM 200 - 10.0.0.103):"
echo "  ✓ jellyfin.simondatalab.de → http://10.0.0.103:8096"
echo "  ✓ booklore.simondatalab.de → http://10.0.0.103:8083"
echo "════════════════════════════════════════════════════════════"
echo ""

# Ask for confirmation
read -p "Apply this configuration? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    print_warning "Configuration update cancelled"
    exit 0
fi

# Apply the new configuration
print_status "Updating tunnel configuration..."

UPDATE_RESPONSE=$(curl -s -X PUT \
    "https://api.cloudflare.com/client/v4/accounts/$ACCOUNT_ID/cfd_tunnel/$TUNNEL_ID/configurations" \
    -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" \
    --data @/tmp/new_tunnel_config.json)

echo "$UPDATE_RESPONSE" | jq '.' > /tmp/tunnel_update_response.json 2>/dev/null || echo "$UPDATE_RESPONSE" > /tmp/tunnel_update_response.json

# Check if successful
if echo "$UPDATE_RESPONSE" | grep -q '"success":true'; then
    print_success "Tunnel configuration updated successfully!"
    echo ""
    print_status "Changes will propagate within 30-60 seconds"
    echo ""
    print_status "Test the routes:"
    echo "  curl -I https://openwebui.simondatalab.de/"
    echo "  curl -I https://grafana.simondatalab.de/"
    echo "  curl -I https://jellyfin.simondatalab.de/"
    echo ""
else
    print_error "Failed to update tunnel configuration"
    echo "Response saved to: /tmp/tunnel_update_response.json"
    cat /tmp/tunnel_update_response.json
    exit 1
fi

# Show verification commands
echo ""
echo "════════════════════════════════════════════════════════════"
echo "VERIFICATION COMMANDS:"
echo "════════════════════════════════════════════════════════════"
echo ""
echo "# Check Open WebUI (should redirect to Cloudflare Access login):"
echo "curl -I https://openwebui.simondatalab.de/"
echo ""
echo "# Check Grafana (should redirect to Cloudflare Access login):"
echo "curl -I https://grafana.simondatalab.de/"
echo ""
echo "# Check Jellyfin (should redirect to /web/):"
echo "curl -I https://jellyfin.simondatalab.de/"
echo ""
echo "# Check portfolio (should return 200 OK):"
echo "curl -I https://www.simondatalab.de/"
echo ""
echo "════════════════════════════════════════════════════════════"

print_success "Tunnel routing update complete!"
