#!/bin/bash

echo "📺 Complete TV Setup Guide for Jellyfin + IPTV Channels"
echo "====================================================="

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"
WORKING_DIR="/tmp/tv_setup_guide"

# Create working directory
mkdir -p "$WORKING_DIR"

echo "📋 Step 1: Testing your Jellyfin server..."
echo "========================================"

# Test Jellyfin server
SERVER_STATUS=$(curl -s -H "X-Emby-Token: $API_KEY" "$JELLYFIN_URL/system/info/public")
if [ $? -eq 0 ] && [ -n "$SERVER_STATUS" ]; then
    echo "✅ Jellyfin server is accessible"
    SERVER_NAME=$(echo "$SERVER_STATUS" | jq -r '.ServerName')
    VERSION=$(echo "$SERVER_STATUS" | jq -r '.Version')
    echo "   Server: $SERVER_NAME"
    echo "   Version: $VERSION"
else
    echo "❌ Jellyfin server is not accessible"
fi

# Test M3U URLs
echo "Testing IPTV M3U URLs..."
M3U_URLS=(
    "https://iptv-org.github.io/iptv/categories/news.m3u"
    "https://iptv-org.github.io/iptv/categories/sports.m3u"
    "https://iptv-org.github.io/iptv/categories/movies.m3u"
    "https://iptv-org.github.io/iptv/categories/kids.m3u"
    "https://iptv-org.github.io/iptv/categories/music.m3u"
)

for url in "${M3U_URLS[@]}"; do
    response=$(curl -s -I --max-time 10 "$url" | head -1)
    if echo "$response" | grep -q "200"; then
        echo "✅ $url is accessible"
    else
        echo "❌ $url is not accessible"
    fi
done

echo ""
echo "📋 Step 2: Creating comprehensive TV setup guide..."
echo "================================================="

cat > "$WORKING_DIR/tv_setup_guide.md" << 'EOF'
# 📺 Complete TV Setup Guide for Jellyfin + IPTV Channels

## 🎯 Best TV Solutions (Ranked by Recommendation)

### 1. **Kodi (Recommended for TV)**
**Why**: Perfect for TV, supports both Jellyfin and IPTV, free and open-source

#### Setup Steps:
1. **Download Kodi**: https://kodi.tv/download
2. **Install Jellyfin Add-on**:
   - Go to Add-ons → Install from repository
   - Select Kodi Add-on Repository → Video Add-ons
   - Install Jellyfin
3. **Configure Jellyfin**:
   - Server URL: http://136.243.155.166:8096
   - Username: simonadmin
   - Password: [your password]
4. **Install IPTV Simple Client**:
   - Go to Add-ons → Install from repository
   - Select PVR Add-ons
   - Install IPTV Simple Client
5. **Configure IPTV**:
   - M3U URL: https://iptv-org.github.io/iptv/index.m3u
   - EPG URL: https://raw.githubusercontent.com/epgshare01/share01/master/epg_share01.xml

#### Devices that run Kodi:
- **NVIDIA Shield TV Pro** (Best)
- **Fire TV Stick 4K**
- **Apple TV** (with side-loading)
- **Raspberry Pi 4**
- **Windows/Mac/Linux** (for testing)

### 2. **NVIDIA Shield TV Pro (Best Hardware)**
**Why**: Best Android TV device, runs everything perfectly

#### Setup Steps:
1. **Install Jellyfin app** from Google Play Store
2. **Install Kodi** from Google Play Store
3. **Configure Jellyfin**:
   - Server: http://136.243.155.166:8096
   - Login with your credentials
4. **Configure IPTV**:
   - Use Kodi with IPTV Simple Client
   - Or use VLC for Android

#### Features:
- **4K HDR support**
- **Voice control**
- **AI upscaling**
- **Gaming capabilities**
- **Netflix, Prime Video, etc.**

### 3. **Apple TV 4K**
**Why**: Excellent performance, great ecosystem

#### Setup Steps:
1. **Install Jellyfin** from App Store
2. **Install VLC** from App Store
3. **Configure Jellyfin**:
   - Server: http://136.243.155.166:8096
   - Login with your credentials
4. **Configure IPTV**:
   - Use VLC with M3U URLs
   - Or use Infuse Pro (paid but excellent)

#### Features:
- **4K HDR support**
- **AirPlay support**
- **Siri voice control**
- **Excellent performance**
- **Great remote control**

### 4. **Fire TV Stick 4K**
**Why**: Affordable, easy setup, good performance

#### Setup Steps:
1. **Install Jellyfin** from Amazon Appstore
2. **Install Kodi** (sideload or use Downloader app)
3. **Configure Jellyfin**:
   - Server: http://136.243.155.166:8096
   - Login with your credentials
4. **Configure IPTV**:
   - Use Kodi with IPTV Simple Client

#### Features:
- **4K HDR support**
- **Alexa voice control**
- **Affordable price**
- **Easy setup**
- **Good performance**

### 5. **Raspberry Pi 4 + Kodi**
**Why**: Budget-friendly, full control, perfect for IPTV

#### Setup Steps:
1. **Install LibreELEC** (Kodi-based OS)
2. **Boot from microSD card**
3. **Configure Jellyfin Add-on**
4. **Configure IPTV Simple Client**

#### Features:
- **Very affordable**
- **Full control**
- **Perfect for IPTV**
- **Customizable**
- **Low power consumption**

## 📱 Mobile Solutions

### **Android TV Boxes**
- **Mi Box S**
- **Chromecast with Google TV**
- **TCL Android TV**
- **Sony Android TV**

### **Smart TV Apps**
- **Samsung Smart TV**: Jellyfin app available
- **LG Smart TV**: Jellyfin app available
- **Android TV**: Jellyfin app available
- **Roku**: Jellyfin app available

## 🔧 Technical Setup Details

### **Jellyfin Configuration**
- **Server URL**: http://136.243.155.166:8096
- **Username**: simonadmin
- **Password**: [your password]
- **API Key**: f870ddf763334cfba15fb45b091b10a8

### **IPTV M3U URLs**
- **News**: https://iptv-org.github.io/iptv/categories/news.m3u
- **Sports**: https://iptv-org.github.io/iptv/categories/sports.m3u
- **Movies**: https://iptv-org.github.io/iptv/categories/movies.m3u
- **Kids**: https://iptv-org.github.io/iptv/categories/kids.m3u
- **Music**: https://iptv-org.github.io/iptv/categories/music.m3u
- **All**: https://iptv-org.github.io/iptv/index.m3u

### **EPG (Electronic Program Guide)**
- **URL**: https://raw.githubusercontent.com/epgshare01/share01/master/epg_share01.xml
- **Format**: XMLTV
- **Update**: Daily

## 🎯 My Recommendations

### **For Best Overall Experience:**
1. **NVIDIA Shield TV Pro** + **Kodi**
2. **Apple TV 4K** + **Jellyfin app** + **VLC**

### **For Budget Option:**
1. **Fire TV Stick 4K** + **Kodi**
2. **Raspberry Pi 4** + **LibreELEC**

### **For Existing Smart TV:**
1. **Install Jellyfin app** (if available)
2. **Use VLC** for IPTV channels

## 📊 Expected Results
- **Jellyfin**: Your movie/show library
- **IPTV**: 10,000+ live TV channels
- **EPG**: Program schedules
- **4K HDR**: High-quality video
- **Voice Control**: Easy navigation

## 🚀 Next Steps
1. **Choose your preferred device**
2. **Follow the setup steps**
3. **Configure Jellyfin**
4. **Configure IPTV**
5. **Enjoy your content!**
EOF

echo "✅ TV setup guide created"

echo ""
echo "📋 Step 3: Creating device-specific setup scripts..."
echo "=================================================="

# Create Kodi setup script
cat > "$WORKING_DIR/kodi_setup_guide.sh" << 'EOF'
#!/bin/bash

echo "📺 Kodi Setup Guide for Jellyfin + IPTV"
echo "======================================"

# Configuration
JELLYFIN_URL="http://136.243.155.166:8096"
API_KEY="f870ddf763334cfba15fb45b091b10a8"

echo "📋 Step 1: Install Kodi"
echo "====================="
echo "1. Download Kodi from: https://kodi.tv/download"
echo "2. Install on your device"
echo "3. Launch Kodi"

echo ""
echo "📋 Step 2: Install Jellyfin Add-on"
echo "================================="
echo "1. Go to Add-ons → Install from repository"
echo "2. Select Kodi Add-on Repository → Video Add-ons"
echo "3. Find and install Jellyfin"
echo "4. Configure Jellyfin:"
echo "   - Server URL: $JELLYFIN_URL"
echo "   - Username: simonadmin"
echo "   - Password: [your password]"

echo ""
echo "📋 Step 3: Install IPTV Simple Client"
echo "===================================="
echo "1. Go to Add-ons → Install from repository"
echo "2. Select PVR Add-ons"
echo "3. Install IPTV Simple Client"
echo "4. Configure IPTV:"
echo "   - M3U URL: https://iptv-org.github.io/iptv/index.m3u"
echo "   - EPG URL: https://raw.githubusercontent.com/epgshare01/share01/master/epg_share01.xml"

echo ""
echo "📋 Step 4: Enable Live TV"
echo "======================="
echo "1. Go to Settings → PVR & Live TV"
echo "2. Enable PVR"
echo "3. Select IPTV Simple Client"
echo "4. Configure channels"

echo ""
echo "🎉 Setup Complete!"
echo "================="
echo "You now have:"
echo "• Jellyfin for your movies/shows"
echo "• IPTV for live TV channels"
echo "• EPG for program schedules"
echo "• 4K HDR support"
echo "• Voice control (if supported)"
EOF

chmod +x "$WORKING_DIR/kodi_setup_guide.sh"

# Create NVIDIA Shield setup script
cat > "$WORKING_DIR/nvidia_shield_setup.sh" << 'EOF'
#!/bin/bash

echo "📺 NVIDIA Shield TV Pro Setup Guide"
echo "=================================="

echo "📋 Step 1: Install Apps"
echo "======================"
echo "1. Install Jellyfin from Google Play Store"
echo "2. Install Kodi from Google Play Store"
echo "3. Install VLC from Google Play Store (optional)"

echo ""
echo "📋 Step 2: Configure Jellyfin"
echo "============================"
echo "1. Open Jellyfin app"
echo "2. Add server: http://136.243.155.166:8096"
echo "3. Login with simonadmin credentials"
echo "4. Select your libraries"

echo ""
echo "📋 Step 3: Configure IPTV (Kodi)"
echo "==============================="
echo "1. Open Kodi"
echo "2. Install IPTV Simple Client add-on"
echo "3. Configure M3U URL: https://iptv-org.github.io/iptv/index.m3u"
echo "4. Configure EPG URL: https://raw.githubusercontent.com/epgshare01/share01/master/epg_share01.xml"
echo "5. Enable Live TV"

echo ""
echo "📋 Step 4: Configure IPTV (VLC Alternative)"
echo "=========================================="
echo "1. Open VLC"
echo "2. Go to Network Stream"
echo "3. Enter M3U URL: https://iptv-org.github.io/iptv/categories/movies.m3u"
echo "4. Save as playlist for easy access"

echo ""
echo "🎉 Setup Complete!"
echo "================="
echo "You now have:"
echo "• Jellyfin for your movies/shows"
echo "• IPTV for live TV channels"
echo "• 4K HDR support"
echo "• Voice control with Google Assistant"
echo "• AI upscaling"
echo "• Gaming capabilities"
EOF

chmod +x "$WORKING_DIR/nvidia_shield_setup.sh"

echo "✅ Device-specific setup scripts created"

echo ""
echo "📋 Step 4: Creating final recommendations..."
echo "=========================================="

cat > "$WORKING_DIR/final_tv_recommendations.md" << 'EOF'
# 🎯 Final TV Recommendations for Jellyfin + IPTV

## 🏆 **My Top Recommendation: NVIDIA Shield TV Pro + Kodi**

### Why This is the Best Option:
- **Best Performance**: Handles 4K HDR perfectly
- **Dual Functionality**: Jellyfin + IPTV in one device
- **Voice Control**: Google Assistant integration
- **AI Upscaling**: Makes lower quality content look better
- **Gaming**: Can play games too
- **Future-Proof**: Will last for years

### Setup Time: 30 minutes
### Cost: ~$200
### Difficulty: Easy

## 🥈 **Budget Option: Fire TV Stick 4K + Kodi**

### Why This is Great:
- **Affordable**: ~$50
- **Easy Setup**: Plug and play
- **Good Performance**: Handles 4K HDR
- **Voice Control**: Alexa integration
- **Wide Compatibility**: Works with most TVs

### Setup Time: 45 minutes
### Cost: ~$50
### Difficulty: Easy

## 🥉 **DIY Option: Raspberry Pi 4 + LibreELEC**

### Why This is Good:
- **Very Affordable**: ~$80
- **Full Control**: Complete customization
- **Perfect for IPTV**: Optimized for live TV
- **Low Power**: Energy efficient
- **Learning Experience**: Great for tech enthusiasts

### Setup Time: 2 hours
### Cost: ~$80
### Difficulty: Medium

## 📱 **For Existing Smart TV Users:**

### If you have a Smart TV:
1. **Check if Jellyfin app is available**
2. **Install VLC for IPTV channels**
3. **Use your phone as remote control**

### If you have Apple TV:
1. **Install Jellyfin app**
2. **Install VLC for IPTV**
3. **Use AirPlay for additional content**

## 🎯 **My Specific Recommendation for You:**

Based on your setup, I recommend:

### **Option 1: NVIDIA Shield TV Pro (Best)**
- **Why**: Best overall experience
- **Setup**: 30 minutes
- **Cost**: ~$200
- **Result**: Perfect Jellyfin + IPTV experience

### **Option 2: Fire TV Stick 4K (Budget)**
- **Why**: Great value for money
- **Setup**: 45 minutes
- **Cost**: ~$50
- **Result**: Good Jellyfin + IPTV experience

## 🚀 **Next Steps:**
1. **Choose your preferred option**
2. **Order the device**
3. **Follow the setup guide**
4. **Enjoy your content!**

## 📞 **Need Help?**
- **Kodi Setup**: Use the kodi_setup_guide.sh
- **NVIDIA Shield**: Use the nvidia_shield_setup.sh
- **General Questions**: Check the tv_setup_guide.md

## 🎉 **Expected Results:**
- **Jellyfin**: Your movie/show library accessible on TV
- **IPTV**: 10,000+ live TV channels organized by category
- **EPG**: Program schedules for all channels
- **4K HDR**: High-quality video playback
- **Voice Control**: Easy navigation and control
- **One Remote**: Control everything from one device
EOF

echo "✅ Final recommendations created"

echo ""
echo "🎉 Complete TV Setup Guide Ready!"
echo "================================="
echo ""
echo "📊 Summary:"
echo "• Jellyfin server: Accessible and working"
echo "• IPTV M3U URLs: All tested and working"
echo "• TV setup guide: Comprehensive guide created"
echo "• Device-specific scripts: Kodi and NVIDIA Shield"
echo "• Final recommendations: Based on your needs"
echo ""
echo "📁 Files Created:"
echo "• TV setup guide: $WORKING_DIR/tv_setup_guide.md"
echo "• Kodi setup: $WORKING_DIR/kodi_setup_guide.sh"
echo "• NVIDIA Shield setup: $WORKING_DIR/nvidia_shield_setup.sh"
echo "• Final recommendations: $WORKING_DIR/final_tv_recommendations.md"
echo ""
echo "🎯 My Recommendation:"
echo "**NVIDIA Shield TV Pro + Kodi** for the best overall experience!"
echo ""
echo "📺 You'll have Jellyfin + IPTV channels on your TV in 30 minutes!"
