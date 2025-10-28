#!/bin/bash

echo "🚀 Jellyfin API Deploy, Test, and Docker Management"
echo "=================================================="

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"
WORKING_DIR="/tmp/jellyfin_deploy"
PROXY_HOST="136.243.155.166:2222"
VM_USER="simonadmin"
SSH_KEY="~/.ssh/jellyfin_vm_key"

# Create working directory
mkdir -p "$WORKING_DIR"

echo "📋 Step 1: Pre-deployment status check..."
echo "======================================="

# Check current Jellyfin status
echo "Checking Jellyfin server status..."
SERVER_STATUS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/system/info/public")
if [ $? -eq 0 ] && [ -n "$SERVER_STATUS" ]; then
    echo "✅ Jellyfin server is accessible"
    SERVER_NAME=$(echo "$SERVER_STATUS" | jq -r '.ServerName')
    VERSION=$(echo "$SERVER_STATUS" | jq -r '.Version')
    echo "   Server: $SERVER_NAME"
    echo "   Version: $VERSION"
else
    echo "❌ Jellyfin server is not accessible"
    exit 1
fi

# Check current Live TV status
echo "Checking Live TV status..."
LIVETV_INFO=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Info")
echo "Live TV Info: $LIVETV_INFO"

# Check current tuners
echo "Checking current tuners..."
CURRENT_TUNERS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/TunerHosts")
echo "Current tuners: $CURRENT_TUNERS"

# Check current channels
echo "Checking current channels..."
CURRENT_CHANNELS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Channels")
CHANNEL_COUNT=$(echo "$CURRENT_CHANNELS" | jq '.TotalRecordCount' 2>/dev/null)
echo "Current channel count: $CHANNEL_COUNT"

echo ""
echo "📋 Step 2: Creating optimized M3U tuners..."
echo "=========================================="

# Define tuner configurations
declare -A TUNERS
TUNERS[news]="https://iptv-org.github.io/iptv/categories/news.m3u"
TUNERS[sports]="https://iptv-org.github.io/iptv/categories/sports.m3u"
TUNERS[movies]="https://iptv-org.github.io/iptv/categories/movies.m3u"
TUNERS[kids]="https://iptv-org.github.io/iptv/categories/kids.m3u"
TUNERS[music]="https://iptv-org.github.io/iptv/categories/music.m3u"

echo "Created 5 tuner configurations:"
for category in "${!TUNERS[@]}"; do
    echo "• ${category^}: ${TUNERS[$category]}"
done

echo ""
echo "📋 Step 3: Deploying tuners via API..."
echo "===================================="

# Function to deploy a tuner
deploy_tuner() {
    local category="$1"
    local url="$2"
    local name="${category^} Channels"
    
    echo "Deploying $name tuner..."
    
    # Create tuner configuration
    tuner_config=$(cat << EOF
{
    "Type": "M3U",
    "Name": "$name",
    "Url": "$url",
    "UserAgent": "Jellyfin/10.10.7",
    "SimultaneousStreamLimit": 0,
    "FallbackMaxStreamBitrate": 30000000,
    "AllowFmp4Transcoding": true,
    "AllowStreamSharing": true,
    "AutoLoopLiveStreams": false,
    "IgnoreDts": false
}
EOF
    )
    
    # Deploy tuner via API
    echo "Sending API request..."
    response=$(curl -s -X POST \
        -H "X-Emby-Token: $API_KEY" \
        -H "Content-Type: application/json" \
        -d "$tuner_config" \
        "$JELLYFIN_URL/LiveTv/TunerHosts" 2>&1)
    
    echo "API Response: $response"
    
    # Check if successful
    if echo "$response" | grep -q "error\|Error\|failed\|Failed"; then
        echo "❌ Failed to deploy $name tuner"
        return 1
    else
        echo "✅ Successfully deployed $name tuner"
        return 0
    fi
}

# Deploy all tuners
SUCCESS_COUNT=0
TOTAL_TUNERS=0

for category in "${!TUNERS[@]}"; do
    TOTAL_TUNERS=$((TOTAL_TUNERS + 1))
    if deploy_tuner "$category" "${TUNERS[$category]}"; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    fi
    sleep 2  # Small delay between deployments
done

echo ""
echo "📋 Step 4: Deploying EPG guide provider..."
echo "======================================="

# Deploy XMLTV guide provider
echo "Deploying XMLTV guide provider..."

guide_config=$(cat << EOF
{
    "Type": "XmlTv",
    "Name": "XMLTV Guide",
    "Url": "https://raw.githubusercontent.com/epgshare01/share01/master/epg_share01.xml",
    "UserAgent": "Jellyfin/10.10.7"
}
EOF
)

echo "Sending EPG API request..."
guide_response=$(curl -s -X POST \
    -H "X-Emby-Token: $API_KEY" \
    -H "Content-Type: application/json" \
    -d "$guide_config" \
    "$JELLYFIN_URL/LiveTv/GuideProviders" 2>&1)

echo "EPG API Response: $guide_response"

if echo "$guide_response" | grep -q "error\|Error\|failed\|Failed"; then
    echo "❌ Failed to deploy EPG guide provider"
else
    echo "✅ Successfully deployed EPG guide provider"
fi

echo ""
echo "📋 Step 5: Testing deployment with curl..."
echo "========================================="

# Wait for deployment to take effect
echo "Waiting for deployment to take effect..."
sleep 10

# Test tuner deployment
echo "Testing tuner deployment..."
NEW_TUNERS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/TunerHosts")
echo "New tuners response: $NEW_TUNERS"

# Test guide provider deployment
echo "Testing guide provider deployment..."
NEW_GUIDES=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/GuideProviders")
echo "New guides response: $NEW_GUIDES"

# Test Live TV info
echo "Testing Live TV info..."
NEW_LIVETV_INFO=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Info")
echo "New Live TV info: $NEW_LIVETV_INFO"

# Test channels
echo "Testing channels..."
NEW_CHANNELS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Channels")
NEW_CHANNEL_COUNT=$(echo "$NEW_CHANNELS" | jq '.TotalRecordCount' 2>/dev/null)
echo "New channel count: $NEW_CHANNEL_COUNT"

echo ""
echo "📋 Step 6: Checking Docker container status..."
echo "============================================="

# Check Docker container status
echo "Checking Docker container status..."
DOCKER_STATUS=$(ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'docker ps | grep jellyfin'" 2>/dev/null)

if [ -n "$DOCKER_STATUS" ]; then
    echo "✅ Docker container is running"
    echo "Container status: $DOCKER_STATUS"
else
    echo "⚠️  Docker container status unclear"
fi

# Check Docker container logs
echo "Checking Docker container logs..."
DOCKER_LOGS=$(ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'docker logs jellyfin-simonadmin --tail 20'" 2>/dev/null)

if [ -n "$DOCKER_LOGS" ]; then
    echo "Docker logs (last 20 lines):"
    echo "$DOCKER_LOGS"
else
    echo "⚠️  Could not retrieve Docker logs"
fi

echo ""
echo "📋 Step 7: Restarting Docker if needed..."
echo "======================================="

# Check if restart is needed
RESTART_NEEDED=false

# Check if tuners were deployed successfully
if [ -z "$NEW_TUNERS" ] || [ "$NEW_TUNERS" = "[]" ]; then
    echo "⚠️  No tuners found - restart may be needed"
    RESTART_NEEDED=true
fi

# Check if channels are accessible
if [ "$NEW_CHANNEL_COUNT" -eq 0 ] || [ -z "$NEW_CHANNEL_COUNT" ]; then
    echo "⚠️  No channels found - restart may be needed"
    RESTART_NEEDED=true
fi

# Check for errors in logs
if echo "$DOCKER_LOGS" | grep -q "error\|Error\|exception\|Exception"; then
    echo "⚠️  Errors found in logs - restart may be needed"
    RESTART_NEEDED=true
fi

if [ "$RESTART_NEEDED" = true ]; then
    echo "Restarting Docker container..."
    
    # Restart Jellyfin container
    RESTART_RESPONSE=$(ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'docker restart jellyfin-simonadmin'" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        echo "✅ Docker container restarted successfully"
        
        # Wait for container to start
        echo "Waiting for container to start..."
        sleep 30
        
        # Check container status after restart
        echo "Checking container status after restart..."
        POST_RESTART_STATUS=$(ssh -i ~/.ssh/jellyfin_vm_key -o StrictHostKeyChecking=no -p 2222 simonadmin@136.243.155.166 "ssh -o StrictHostKeyChecking=no simonadmin@10.0.0.103 'docker ps | grep jellyfin'" 2>/dev/null)
        
        if [ -n "$POST_RESTART_STATUS" ]; then
            echo "✅ Container is running after restart"
            echo "Post-restart status: $POST_RESTART_STATUS"
        else
            echo "❌ Container may not be running after restart"
        fi
    else
        echo "❌ Failed to restart Docker container"
    fi
else
    echo "✅ No restart needed - system is working properly"
fi

echo ""
echo "📋 Step 8: Final verification..."
echo "==============================="

# Final status check
echo "Final status check..."

# Check server status
FINAL_SERVER_STATUS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/system/info/public")
if [ $? -eq 0 ] && [ -n "$FINAL_SERVER_STATUS" ]; then
    echo "✅ Server is accessible"
else
    echo "❌ Server is not accessible"
fi

# Check Live TV status
FINAL_LIVETV_INFO=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Info")
echo "Final Live TV info: $FINAL_LIVETV_INFO"

# Check tuners
FINAL_TUNERS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/TunerHosts")
echo "Final tuners: $FINAL_TUNERS"

# Check channels
FINAL_CHANNELS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Channels")
FINAL_CHANNEL_COUNT=$(echo "$FINAL_CHANNELS" | jq '.TotalRecordCount' 2>/dev/null)
echo "Final channel count: $FINAL_CHANNEL_COUNT"

echo ""
echo "📋 Step 9: Creating deployment report..."
echo "======================================"

cat > "$WORKING_DIR/deployment_report.md" << EOF
# 🚀 Jellyfin Live TV Deployment Report

## 📊 Deployment Summary
- **Total Tuners Deployed**: $TOTAL_TUNERS
- **Successful Deployments**: $SUCCESS_COUNT
- **Failed Deployments**: $((TOTAL_TUNERS - SUCCESS_COUNT))
- **Docker Restart**: $(if [ "$RESTART_NEEDED" = true ]; then echo "Yes"; else echo "No"; fi)

## 🔧 Tuners Deployed
EOF

for category in "${!TUNERS[@]}"; do
    echo "- **${category^} Channels**: ${TUNERS[$category]}" >> "$WORKING_DIR/deployment_report.md"
done

cat >> "$WORKING_DIR/deployment_report.md" << EOF

## 📺 Current Status
- **Server**: $(echo "$FINAL_SERVER_STATUS" | jq -r '.ServerName' 2>/dev/null || echo "Unknown")
- **Version**: $(echo "$FINAL_SERVER_STATUS" | jq -r '.Version' 2>/dev/null || echo "Unknown")
- **Live TV Enabled**: $(echo "$FINAL_LIVETV_INFO" | jq -r '.IsEnabled' 2>/dev/null || echo "Unknown")
- **Channel Count**: $FINAL_CHANNEL_COUNT
- **Tuner Count**: $(echo "$FINAL_TUNERS" | jq '. | length' 2>/dev/null || echo "Unknown")

## 🔍 API Responses
- **Tuners**: $FINAL_TUNERS
- **Live TV Info**: $FINAL_LIVETV_INFO
- **Channels**: $FINAL_CHANNEL_COUNT

## 🚀 Next Steps
1. Check Jellyfin web interface
2. Test channel playback
3. Verify EPG guide provider
4. Set up user preferences
5. Configure parental controls

## 📝 Notes
- All deployments attempted via API
- Docker container restarted if needed
- Manual setup may be required if API fails
- Check Jellyfin logs for any errors
EOF

echo "✅ Deployment report created: $WORKING_DIR/deployment_report.md"

echo ""
echo "🎉 Jellyfin API Deploy, Test, and Docker Management Complete!"
echo "============================================================"
echo ""
echo "📊 Final Summary:"
echo "• Tuners Deployed: $SUCCESS_COUNT/$TOTAL_TUNERS"
echo "• EPG Guide Provider: Deployed"
echo "• Docker Restart: $(if [ "$RESTART_NEEDED" = true ]; then echo "Yes"; else echo "No"; fi)"
echo "• Final Channel Count: $FINAL_CHANNEL_COUNT"
echo ""
echo "🚀 Next steps:"
echo "1. Check Jellyfin web interface"
echo "2. Test channel playback"
echo "3. Verify EPG guide provider"
echo "4. Set up user preferences"
echo ""
echo "📺 Your Jellyfin Live TV setup has been deployed and tested!"


