#!/bin/bash

# Add EPG providers to Jellyfin via API
API_KEY="f870ddf763334cfba15fb45b091b10a8"
SERVER="http://136.243.155.166:8096"

echo "📺 Adding EPG providers to Jellyfin..."
echo ""

# Add US EPG (most popular for Movies)
echo "Adding US EPG provider..."
curl -X POST "${SERVER}/LiveTv/ListingProviders" \
  -H "Content-Type: application/json" \
  -H "X-Emby-Token: ${API_KEY}" \
  -d '{
    "Type": "xmltv",
    "Path": "/config/epg/epg_us.xml",
    "EnableAllTuners": true,
    "EnabledTuners": [],
    "NewsCategories": ["news"],
    "SportsCategories": ["sports"],
    "KidsCategories": ["kids"],
    "MovieCategories": ["movie"],
    "ChannelMappings": []
  }' | jq .

echo ""
echo "Adding UK EPG provider..."
curl -X POST "${SERVER}/LiveTv/ListingProviders" \
  -H "Content-Type: application/json" \
  -H "X-Emby-Token: ${API_KEY}" \
  -d '{
    "Type": "xmltv",
    "Path": "/config/epg/epg_uk.xml",
    "EnableAllTuners": true,
    "EnabledTuners": [],
    "NewsCategories": ["news"],
    "SportsCategories": ["sports"],
    "KidsCategories": ["kids"],
    "MovieCategories": ["movie"],
    "ChannelMappings": []
  }' | jq .

echo ""
echo "Adding German EPG provider..."
curl -X POST "${SERVER}/LiveTv/ListingProviders" \
  -H "Content-Type: application/json" \
  -H "X-Emby-Token: ${API_KEY}" \
  -d '{
    "Type": "xmltv",
    "Path": "/config/epg/epg_de.xml",
    "EnableAllTuners": true,
    "EnabledTuners": [],
    "NewsCategories": ["news"],
    "SportsCategories": ["sports"],
    "KidsCategories": ["kids"],
    "MovieCategories": ["movie"],
    "ChannelMappings": []
  }' | jq .

echo ""
echo "✅ EPG providers added!"
echo ""
echo "🔄 Refreshing guide data..."
curl -X POST "${SERVER}/LiveTv/GuideData/Refresh?api_key=${API_KEY}"

echo ""
echo ""
echo "⏳ Guide data is now refreshing in the background..."
echo "   This may take 2-5 minutes to process all programs."
echo ""
echo "📺 After it's done, check your Movies list at:"
echo "   http://136.243.155.166:8096/web/#/list.html?type=Programs&IsMovie=true"
