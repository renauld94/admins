#!/bin/bash

# MANUAL CLOUDFLARE API CACHE PURGE
# Manual script to purge cache with pre-set credentials

echo "🌌 MANUAL CLOUDFLARE API CACHE PURGE"
echo "===================================="
echo ""

# Check if credentials are set
if [ -z "$CLOUDFLARE_API_TOKEN" ] && [ -z "$CLOUDFLARE_EMAIL" ] && [ -z "$CLOUDFLARE_API_KEY" ]; then
    echo "❌ No API credentials found!"
    echo ""
    echo "Please set your credentials first:"
    echo ""
    echo "For API Token (recommended):"
    echo "  export CLOUDFLARE_API_TOKEN='your-api-token'"
    echo ""
    echo "For Global API Key:"
    echo "  export CLOUDFLARE_EMAIL='your-email@example.com'"
    echo "  export CLOUDFLARE_API_KEY='your-global-api-key'"
    echo ""
    echo "Get credentials from: https://dash.cloudflare.com/profile/api-tokens"
    echo ""
    exit 1
fi

echo "✅ API credentials found!"
echo ""

# Show which method is being used
if [ ! -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "Using API Token authentication..."
else
    echo "Using Email + API Key authentication..."
fi

echo ""

# Run the cache purge
echo "🚀 Running cache purge..."
./purge_cloudflare_api.sh

# Check exit status
if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 Cache purge completed successfully!"
    echo ""
    echo "🧪 Testing deployment..."
    ./test_neural_geoserver_deployment.sh
else
    echo ""
    echo "❌ Cache purge failed!"
    echo ""
    echo "Please check:"
    echo "1. Your API credentials are correct"
    echo "2. You have the right permissions"
    echo "3. Your domain is accessible"
    echo ""
    exit 1
fi
