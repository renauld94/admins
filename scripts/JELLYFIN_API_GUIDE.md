# 🔑 Jellyfin API Integration

## 📋 Your API Credentials

I've configured your Jellyfin API key for automated management:

- **Server**: http://136.243.155.166:8096
- **API Key**: `f870ddf763334cfba15fb45b091b10a8` (fixguides app)
- **User**: simonadmin
- **User ID**: `0efdd3b94bcc4b77a52343bf70d948b0`
- **Issued**: 10/14/2025 8:39 AM

---

## 🛠️ Created Tools

### 1. **jellyfin_api_config.sh**
Configuration file with all your credentials and helper functions.

**Functions included:**
- `get_channels()` - Get all Live TV channels
- `get_channel_count()` - Count total channels
- `refresh_guide()` - Refresh EPG guide data
- `get_tuners()` - List tuner devices
- `get_recordings()` - Get recordings
- `get_programs()` - Get Live TV programs

### 2. **jellyfin_channel_manager.sh** ⭐
Interactive menu-driven channel manager using your API.

**Features:**
1. Show channel count
2. List all channels (first 20)
3. List tuner devices
4. Refresh guide data
5. Show Live TV programs (now playing)
6. Export channel list to file
7. Check API connection
8. Exit

---

## 🚀 Usage

### Run the Channel Manager:

```bash
cd /home/simon/Learning-Management-System-Academy/scripts
./jellyfin_channel_manager.sh
```

This will show an interactive menu to manage your channels via API.

### Use API Functions in Scripts:

```bash
# Load configuration
source ./jellyfin_api_config.sh

# Get channel count
TOTAL=$(curl -s "${JELLYFIN_URL}/LiveTv/Channels?api_key=${JELLYFIN_API_KEY}&UserId=${JELLYFIN_USER_ID}" | jq '.TotalRecordCount')
echo "Total channels: $TOTAL"

# Refresh guide data
curl -X POST "${JELLYFIN_URL}/LiveTv/GuideData/Refresh?api_key=${JELLYFIN_API_KEY}"
```

---

## 📊 API Capabilities

With your API key, you can:

### Live TV
- ✅ Get channel list
- ✅ Get channel details
- ✅ Get EPG program data
- ✅ Refresh guide data
- ✅ Manage tuners
- ✅ Schedule recordings

### Media Library
- ✅ Browse collections
- ✅ Get item metadata
- ✅ Search media
- ✅ Get images

### Playback
- ✅ Get stream URLs
- ✅ Control playback
- ✅ Get codec info
- ✅ Transcode settings

### Administration
- ✅ Get system info
- ✅ Manage plugins
- ✅ View logs
- ✅ Configuration management

---

## 🔧 API Examples

### Get Channel Count:
```bash
curl -s "http://136.243.155.166:8096/LiveTv/Channels?api_key=f870ddf763334cfba15fb45b091b10a8&UserId=0efdd3b94bcc4b77a52343bf70d948b0" | jq '.TotalRecordCount'
```

### List First 10 Channels:
```bash
curl -s "http://136.243.155.166:8096/LiveTv/Channels?api_key=f870ddf763334cfba15fb45b091b10a8&UserId=0efdd3b94bcc4b77a52343bf70d948b0&limit=10" | jq '.Items[] | .Name'
```

### Refresh Guide Data:
```bash
curl -X POST "http://136.243.155.166:8096/LiveTv/GuideData/Refresh?api_key=f870ddf763334cfba15fb45b091b10a8"
```

### Get Server Info:
```bash
curl -s "http://136.243.155.166:8096/System/Info/Public" | jq '.'
```

### Get Tuner Info:
```bash
curl -s "http://136.243.155.166:8096/LiveTv/Tuners?api_key=f870ddf763334cfba15fb45b091b10a8" | jq '.'
```

---

## 🔐 Security Notes

### API Key Storage
- ✅ API key stored in local config file
- ⚠️ Keep `jellyfin_api_config.sh` secure (contains credentials)
- ⚠️ Don't commit to public repositories

### Recommendations:
1. **Set proper file permissions**:
   ```bash
   chmod 600 jellyfin_api_config.sh
   ```

2. **Use environment variables** (optional):
   ```bash
   export JELLYFIN_API_KEY="f870ddf763334cfba15fb45b091b10a8"
   ```

3. **Rotate API keys periodically** in Jellyfin settings

---

## 📚 Common Use Cases

### 1. Automated Channel Organization
```bash
# Get all channels, filter by category, create new playlists
source jellyfin_api_config.sh
curl -s "${JELLYFIN_URL}/LiveTv/Channels?api_key=${JELLYFIN_API_KEY}&UserId=${JELLYFIN_USER_ID}" | \
    jq '.Items[] | select(.ChannelType == "News") | .Name'
```

### 2. Monitor Channel Availability
```bash
# Check which channels are currently streaming
curl -s "${JELLYFIN_URL}/LiveTv/Programs?api_key=${JELLYFIN_API_KEY}&IsAiring=true" | \
    jq '.Items[] | "\(.ChannelName): \(.Name)"'
```

### 3. Export Channel Lists
```bash
# Export to CSV for analysis
curl -s "${JELLYFIN_URL}/LiveTv/Channels?api_key=${JELLYFIN_API_KEY}&UserId=${JELLYFIN_USER_ID}&limit=10000" | \
    jq -r '.Items[] | [.ChannelNumber, .Name, .Type] | @csv' > channels.csv
```

### 4. Scheduled Guide Refresh
```bash
# Add to crontab for daily refresh
0 3 * * * curl -X POST "http://136.243.155.166:8096/LiveTv/GuideData/Refresh?api_key=f870ddf763334cfba15fb45b091b10a8"
```

---

## 🧪 Testing Your API

Run the channel manager to test:

```bash
./jellyfin_channel_manager.sh
```

Select option **7** to check API connection.

Expected output:
```
✅ Server reachable: http://136.243.155.166:8096
   Server: 7e93cc7959f9
   Version: 10.10.7
✅ API key valid
   User: simonadmin
✅ Live TV API accessible
```

---

## 📖 Jellyfin API Documentation

Full API reference: https://api.jellyfin.org/

Key endpoints for Live TV:
- `/LiveTv/Channels` - Channel list
- `/LiveTv/Programs` - EPG program data
- `/LiveTv/Tuners` - Tuner devices
- `/LiveTv/GuideData` - Guide operations
- `/LiveTv/Recordings` - Recording management

---

## 🎯 Integration with Existing Scripts

Your API key can be used with the channel organization scripts:

```bash
# After organizing channels with quick_organize_channels.sh
# Refresh guide data via API
source jellyfin_api_config.sh
curl -X POST "${JELLYFIN_URL}/LiveTv/GuideData/Refresh?api_key=${JELLYFIN_API_KEY}"
```

---

## ✅ Summary

**Created:**
- ✅ `jellyfin_api_config.sh` - API configuration with your key
- ✅ `jellyfin_channel_manager.sh` - Interactive channel manager
- ✅ Helper functions for common operations
- ✅ This documentation

**Your API key is ready to use for:**
- Automated channel management
- Guide data refresh
- Channel monitoring
- Export/reporting
- Integration with other tools

**Next step**: Run `./jellyfin_channel_manager.sh` to test! 🚀
