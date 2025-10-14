#!/bin/bash

# INTERACTIVE CLOUDFLARE API CACHE PURGE
# Interactive script to set up credentials and purge cache

echo "🌌 INTERACTIVE CLOUDFLARE API CACHE PURGE"
echo "=========================================="
echo ""

# Check if credentials are already set
if [ ! -z "$CLOUDFLARE_API_TOKEN" ] || ([ ! -z "$CLOUDFLARE_EMAIL" ] && [ ! -z "$CLOUDFLARE_API_KEY" ]); then
    echo "✅ API credentials already set!"
    echo ""
    echo "Running cache purge..."
    ./purge_cloudflare_api.sh
    exit $?
fi

echo "❌ No API credentials found!"
echo ""
echo "📋 SETUP INSTRUCTIONS:"
echo "======================="
echo ""
echo "1. Go to: https://dash.cloudflare.com/profile/api-tokens"
echo "2. Click: 'Create Token'"
echo "3. Use: 'Custom token' template"
echo "4. Set permissions:"
echo "   - Zone:Zone:Read"
echo "   - Zone:Cache Purge:Edit"
echo "5. Set zone resources:"
echo "   - Include: simondatalab.de"
echo "6. Click: 'Continue to summary'"
echo "7. Click: 'Create Token'"
echo "8. Copy the token"
echo ""

echo "🔧 CREDENTIAL SETUP:"
echo "===================="
echo ""
echo "Choose your setup method:"
echo "1. API Token (recommended)"
echo "2. Global API Key + Email"
echo "3. Exit"
echo ""

read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo ""
        echo "📝 API Token Setup:"
        echo "------------------"
        read -p "Enter your API token: " api_token
        if [ ! -z "$api_token" ]; then
            export CLOUDFLARE_API_TOKEN="$api_token"
            echo "✅ API token set!"
            echo ""
            echo "🚀 Running cache purge..."
            ./purge_cloudflare_api.sh
        else
            echo "❌ No API token provided!"
            exit 1
        fi
        ;;
    2)
        echo ""
        echo "📝 Global API Key Setup:"
        echo "----------------------"
        read -p "Enter your email: " email
        read -p "Enter your global API key: " api_key
        if [ ! -z "$email" ] && [ ! -z "$api_key" ]; then
            export CLOUDFLARE_EMAIL="$email"
            export CLOUDFLARE_API_KEY="$api_key"
            echo "✅ Email and API key set!"
            echo ""
            echo "🚀 Running cache purge..."
            ./purge_cloudflare_api.sh
        else
            echo "❌ Email or API key missing!"
            exit 1
        fi
        ;;
    3)
        echo ""
        echo "👋 Exiting..."
        exit 0
        ;;
    *)
        echo ""
        echo "❌ Invalid choice!"
        exit 1
        ;;
esac
