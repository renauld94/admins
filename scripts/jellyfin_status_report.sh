#!/bin/bash

# Jellyfin Status Report using API Key
# This script checks your Jellyfin server status and Live TV configuration

API_KEY="f870ddf763334cfba15fb45b091b10a8"
JELLYFIN_URL="http://136.243.155.166:8096"

echo "📺 Jellyfin Server Status Report"
echo "================================"
echo ""

# System Info
echo "🔧 System Information:"
echo "---------------------"
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/System/Info" | jq -r '
  "Server Name: " + .ServerName,
  "Version: " + .Version,
  "Operating System: " + .OperatingSystemDisplayName,
  "Local Address: " + .LocalAddress,
  "Has Pending Restart: " + (.HasPendingRestart | tostring),
  "Is Shutting Down: " + (.IsShuttingDown | tostring)
' 2>/dev/null || echo "jq not available, showing raw data:"
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/System/Info" | head -5
echo ""

# Live TV Status
echo "📺 Live TV Status:"
echo "-----------------"
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Info" | jq -r '
  "Live TV Enabled: " + (.IsEnabled | tostring),
  "Enabled Users: " + (.EnabledUsers | length | tostring),
  "Services: " + (.Services | length | tostring)
' 2>/dev/null || echo "jq not available, showing raw data:"
curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Info" | head -5
echo ""

# Live TV Channels
echo "📺 Live TV Channels:"
echo "-------------------"
CHANNELS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Channels")
CHANNEL_COUNT=$(echo "$CHANNELS" | jq -r '.TotalRecordCount' 2>/dev/null || echo "Unknown")

if [ "$CHANNEL_COUNT" != "Unknown" ] && [ "$CHANNEL_COUNT" -gt 0 ]; then
    echo "Total Channels: $CHANNEL_COUNT"
    echo ""
    echo "Channel List:"
    echo "$CHANNELS" | jq -r '.Items[] | "  • " + .Name' 2>/dev/null || echo "  • Channel names not available"
else
    echo "No channels found or error retrieving channel data"
fi
echo ""

# Live TV Programs
echo "📺 Live TV Programs:"
echo "-------------------"
PROGRAMS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Programs")
PROGRAM_COUNT=$(echo "$PROGRAMS" | jq -r '.TotalRecordCount' 2>/dev/null || echo "Unknown")

if [ "$PROGRAM_COUNT" != "Unknown" ] && [ "$PROGRAM_COUNT" -gt 0 ]; then
    echo "Total Programs: $PROGRAM_COUNT"
    echo ""
    echo "Program List:"
    echo "$PROGRAMS" | jq -r '.Items[] | "  • " + .Name + " (" + .ChannelName + ")"' 2>/dev/null || echo "  • Program names not available"
else
    echo "No programs found - this may indicate EPG data needs to be refreshed"
fi
echo ""

# Tuners
echo "📺 Tuner Devices:"
echo "----------------"
TUNERS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/Tuners")
TUNER_COUNT=$(echo "$TUNERS" | jq -r 'length' 2>/dev/null || echo "Unknown")

if [ "$TUNER_COUNT" != "Unknown" ] && [ "$TUNER_COUNT" -gt 0 ]; then
    echo "Total Tuners: $TUNER_COUNT"
    echo ""
    echo "Tuner List:"
    echo "$TUNERS" | jq -r '.[] | "  • " + .Name + " (" + .Type + ")"' 2>/dev/null || echo "  • Tuner names not available"
else
    echo "No tuners configured"
fi
echo ""

# Guide Providers
echo "📺 Guide Providers:"
echo "------------------"
GUIDE_PROVIDERS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/LiveTv/GuideProviders")
GUIDE_COUNT=$(echo "$GUIDE_PROVIDERS" | jq -r 'length' 2>/dev/null || echo "Unknown")

if [ "$GUIDE_COUNT" != "Unknown" ] && [ "$GUIDE_COUNT" -gt 0 ]; then
    echo "Total Guide Providers: $GUIDE_COUNT"
    echo ""
    echo "Guide Provider List:"
    echo "$GUIDE_PROVIDERS" | jq -r '.[] | "  • " + .Name + " (" + .Type + ")"' 2>/dev/null || echo "  • Guide provider names not available"
else
    echo "No guide providers configured"
fi
echo ""

# Summary
echo "📋 Summary:"
echo "==========="
if [ "$CHANNEL_COUNT" != "Unknown" ] && [ "$CHANNEL_COUNT" -gt 0 ]; then
    echo "✅ Live TV is working with $CHANNEL_COUNT channels"
else
    echo "❌ No Live TV channels found"
fi

if [ "$PROGRAM_COUNT" != "Unknown" ] && [ "$PROGRAM_COUNT" -gt 0 ]; then
    echo "✅ Program guide is populated with $PROGRAM_COUNT programs"
else
    echo "⚠️  Program guide is empty - may need to refresh guide data"
fi

if [ "$TUNER_COUNT" != "Unknown" ] && [ "$TUNER_COUNT" -gt 0 ]; then
    echo "✅ $TUNER_COUNT tuner(s) configured"
else
    echo "❌ No tuners configured"
fi

if [ "$GUIDE_COUNT" != "Unknown" ] && [ "$GUIDE_COUNT" -gt 0 ]; then
    echo "✅ $GUIDE_COUNT guide provider(s) configured"
else
    echo "❌ No guide providers configured"
fi

echo ""
echo "🌐 Access Jellyfin at: $JELLYFIN_URL/web/"
echo "📺 Live TV URL: $JELLYFIN_URL/web/#/livetv.html?collectionType=livetv"
echo ""
echo "🔧 If Live TV is not working:"
echo "  1. Check tuner configuration in Admin Panel → Live TV"
echo "  2. Check guide provider configuration"
echo "  3. Refresh guide data"
echo "  4. Restart Jellyfin if needed"
