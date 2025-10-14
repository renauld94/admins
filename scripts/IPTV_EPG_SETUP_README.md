# 📺 Enhanced iptv-org EPG Setup Script

## 🎯 Overview
This enhanced script (`add_iptv_org_epg.sh`) downloads Electronic Program Guide (EPG) data from iptv-org and installs it into your Jellyfin Docker container for Live TV functionality.

## 🔧 Key Improvements Made

### ✅ Enhanced Error Handling
- **Pre-flight checks**: Validates SSH connection, Docker container status, and required commands
- **Progress tracking**: Shows download/upload/install progress with success/failure indicators
- **Graceful failures**: Continues with partial success if some files fail
- **Comprehensive validation**: Validates EPG files before installation

### ✅ Robust SSH Connection Management
- **Connection testing**: Tests SSH connectivity before proceeding
- **ProxyJump support**: Uses modern SSH ProxyJump syntax (`-J`) instead of deprecated methods
- **Timeout handling**: Includes connection timeouts to prevent hanging
- **Troubleshooting guidance**: Provides specific commands for connection issues

### ✅ Docker Container Validation
- **Container status checks**: Verifies Jellyfin container is running before installation
- **Permission handling**: Sets proper file ownership for Jellyfin user
- **Installation verification**: Confirms files are properly installed in container
- **Error recovery**: Provides commands to restart container if needed

### ✅ Alternative Execution Methods
- **Manual fallback**: Complete manual instructions if automated script fails
- **Step-by-step guidance**: Detailed commands for each step
- **Troubleshooting section**: Common issues and solutions
- **Multiple scenarios**: Handles different failure modes

## 📋 Script Features

### 🌍 Comprehensive EPG Coverage
Downloads EPG data for 20 countries/regions:
- **Americas**: US, Canada, Brazil, Mexico, Argentina
- **Europe**: UK, Germany, France, Spain, Italy, Netherlands, Russia
- **Asia**: Japan, South Korea, India, China
- **Middle East**: UAE, Saudi Arabia, Egypt
- **Oceania**: Australia

### 🔄 Automated Process Flow
1. **Pre-flight checks** → SSH connection, Docker status, required tools
2. **Download EPG files** → Parallel downloads with progress tracking
3. **File validation** → Ensures XML files are valid and not empty
4. **Upload to VM** → Secure file transfer with error handling
5. **Container installation** → Copy files to Jellyfin container
6. **Permission setup** → Set proper ownership for Jellyfin user
7. **Verification** → Confirm files are properly installed
8. **Cleanup** → Remove temporary files

### 🛠️ Error Recovery
- **Partial success handling**: Continues if some files fail
- **Detailed error messages**: Shows exactly what failed and why
- **Recovery commands**: Provides specific commands to fix issues
- **Alternative methods**: Manual instructions when automation fails

## 🚀 Usage

### Quick Start
```bash
cd "/home/simon/Desktop/Learning Management System Academy/scripts"
./add_iptv_org_epg.sh
```

### Test Script
```bash
./test_iptv_epg_script.sh
```

## 🔧 Configuration

### Target Environment
- **VM**: 10.0.0.103 (VM 200 with Jellyfin)
- **Container**: jellyfin-simonadmin
- **Proxy Host**: 136.243.155.166:2222
- **VM User**: simonadmin

### EPG Files Location
Files are installed to: `/config/iptv_org_epg_*.xml` in the Jellyfin container

## 📺 Jellyfin Configuration

### Web Interface Setup
1. **Access**: http://136.243.155.166:8096/web/
2. **Login**: simonadmin
3. **Navigate**: Admin Panel → Live TV
4. **Add Provider**: Click '+' next to 'TV Guide Data Providers'
5. **Select**: XMLTV
6. **Configure**: Use `/config/iptv_org_epg_*.xml` files
7. **Refresh**: Click 'Refresh Guide Data'

## 🔧 Troubleshooting

### SSH Connection Issues
```bash
# Check VM status
ssh -p 2222 root@136.243.155.166 'qm status 200'

# Test jump host
ssh -p 2222 root@136.243.155.166

# Test VM connection
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103
```

### Docker Container Issues
```bash
# Check container status
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker ps'

# Start container if stopped
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker start jellyfin-simonadmin'

# Check container logs
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker logs jellyfin-simonadmin'
```

### EPG File Issues
```bash
# Verify files exist
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker exec jellyfin-simonadmin ls -la /config/iptv_org_epg_*.xml'

# Check permissions
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker exec jellyfin-simonadmin ls -la /config/iptv_org_epg_*.xml'

# Restart Jellyfin
ssh -J root@136.243.155.166:2222 simonadmin@10.0.0.103 'docker restart jellyfin-simonadmin'
```

## 💡 Important Notes

### EPG vs TV Channels
- **EPG files**: Provide program guide data (schedules, descriptions)
- **M3U tuners**: Provide actual TV channels to watch
- **Both needed**: EPG + M3U tuners = complete Live TV experience

### Manual Alternative
If the automated script fails, the script provides complete manual instructions for:
1. Downloading EPG files locally
2. Uploading to VM via SCP
3. Copying to Jellyfin container
4. Configuring in web interface

## 🎉 Success Indicators

The script will show:
- ✅ Successful downloads for each EPG file
- ✅ Successful uploads to VM
- ✅ Successful installation in container
- ✅ Proper file verification
- ✅ Configuration instructions

## 📞 Support

If you encounter issues:
1. **Check the troubleshooting section** in the script output
2. **Use the manual method** provided as fallback
3. **Verify VM and container status** using provided commands
4. **Check Jellyfin logs** for any application-level issues

---

**🎯 Target**: VM 10.0.0.103 (VM 200 with Jellyfin)  
**🌐 Jellyfin URL**: http://136.243.155.166:8096/web/  
**👤 Login**: simonadmin  
**📺 Purpose**: Add comprehensive EPG data for Live TV functionality
