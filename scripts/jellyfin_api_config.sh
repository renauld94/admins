#!/bin/bash

#############################################################################
# Jellyfin API Configuration
#############################################################################
# Your Jellyfin API credentials for automation scripts
#############################################################################

# Jellyfin Server Details
JELLYFIN_URL="http://136.243.155.166:8096"
JELLYFIN_USER="simonadmin"
JELLYFIN_USER_ID="0efdd3b94bcc4b77a52343bf70d948b0"  # From console logs

# API Keys
JELLYFIN_API_KEY="f870ddf763334cfba15fb45b091b10a8"  # fixguides app

# SSH Access (for direct container access)
VM_IP="10.0.0.103"
PROXY_HOST="136.243.155.166:2222"
VM_USER="simonadmin"
CONTAINER="jellyfin-simonadmin"

#############################################################################
# Usage Examples
#############################################################################

# Example 1: Get Live TV channels via API
get_channels() {
    curl -s "${JELLYFIN_URL}/LiveTv/Channels?api_key=${JELLYFIN_API_KEY}&UserId=${JELLYFIN_USER_ID}" | jq '.'
}

# Example 2: Get channel count
get_channel_count() {
    curl -s "${JELLYFIN_URL}/LiveTv/Channels?api_key=${JELLYFIN_API_KEY}&UserId=${JELLYFIN_USER_ID}" | jq '.TotalRecordCount'
}

# Example 3: Refresh Live TV guide data
refresh_guide() {
    curl -X POST "${JELLYFIN_URL}/LiveTv/GuideData/Refresh?api_key=${JELLYFIN_API_KEY}"
    echo "Guide data refresh initiated"
}

# Example 4: Get tuner information
get_tuners() {
    curl -s "${JELLYFIN_URL}/LiveTv/Tuners?api_key=${JELLYFIN_API_KEY}" | jq '.'
}

# Example 5: Get current recordings
get_recordings() {
    curl -s "${JELLYFIN_URL}/LiveTv/Recordings?api_key=${JELLYFIN_API_KEY}&UserId=${JELLYFIN_USER_ID}" | jq '.'
}

# Example 6: Get Live TV programs
get_programs() {
    curl -s "${JELLYFIN_URL}/LiveTv/Programs?api_key=${JELLYFIN_API_KEY}&UserId=${JELLYFIN_USER_ID}&limit=100" | jq '.'
}

#############################################################################
# Export variables for use in other scripts
#############################################################################

export JELLYFIN_URL
export JELLYFIN_API_KEY
export JELLYFIN_USER_ID
export VM_IP
export PROXY_HOST
export VM_USER
export CONTAINER

echo "✅ Jellyfin API configuration loaded"
echo "   Server: ${JELLYFIN_URL}"
echo "   API Key: ${JELLYFIN_API_KEY:0:20}..."
echo "   User ID: ${JELLYFIN_USER_ID}"
