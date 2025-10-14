# 🚀 Learning Odyssey Deployment Guide

## Quick Deployment to Moodle Course

Your Learning Odyssey system is ready to deploy to your Moodle course at [https://moodle.simondatalab.de/course/view.php?id=2](https://moodle.simondatalab.de/course/view.php?id=2).

## 🎯 Deployment Options

### Option 1: Remote Deployment (Recommended)
```bash
# Run the remote deployment script
./deploy-remote.sh
```

This script will:
- Connect to your server via SSH
- Copy all implementation files
- Set up proper permissions
- Create Moodle integration files

### Option 2: Manual Deployment
```bash
# Run the local deployment script on the server
ssh simonadmin@10.0.0.104
./deploy-odyssey.sh
```

## 📋 Pre-Deployment Checklist

- [ ] SSH access to `simonadmin@10.0.0.104` is working
- [ ] Moodle course ID 2 is accessible
- [ ] Server has Python 3.8+ installed
- [ ] Web server (Apache/Nginx) is running
- [ ] Database access is configured

## 🔧 Post-Deployment Steps

### 1. Add Odyssey Page to Moodle Course
1. Go to [Course Administration](https://moodle.simondatalab.de/course/view.php?id=2)
2. Click "Turn editing on"
3. Add a new "Page" resource
4. Title: "Learning Odyssey"
5. Content: Copy from `odyssey-course.html`
6. Save and return to course

### 2. Set Up AI Oracle Service
```bash
# SSH to server
ssh simonadmin@10.0.0.104

# Install Python dependencies
cd /var/www/html/moodle/course/2/odyssey
pip3 install -r requirements.txt

# Start AI Oracle service
cd ai
python3 ai-oracle-system.py &
```

### 3. Configure Databricks Analytics
```bash
# Update credentials in databricks-analytics.py
cd /var/www/html/moodle/course/2/odyssey/analytics
nano databricks-analytics.py
# Update your Databricks credentials
```

### 4. Test Deployment
```bash
# Run the test script
cd /var/www/html/moodle/course/2/odyssey
./test-deployment.sh
```

## 🌐 Access URLs

After deployment, you can access:

- **Main Course**: [https://moodle.simondatalab.de/course/view.php?id=2](https://moodle.simondatalab.de/course/view.php?id=2)
- **Odyssey Demo**: [https://moodle.simondatalab.de/course/2/odyssey/odyssey-demo.html](https://moodle.simondatalab.de/course/2/odyssey/odyssey-demo.html)
- **AI Oracle API**: `http://10.0.0.104:8001` (if running)
- **Analytics API**: `http://10.0.0.104:8002` (if running)

## 🎭 Features Deployed

### ✅ Core Components
- **AI Oracle System**: Intelligent learning assistance
- **3D Learning Universe**: Interactive module visualization
- **Analytics Dashboard**: Real-time learning metrics
- **Databricks Analytics**: Comprehensive learning tracking

### ✅ Moodle Integration
- **Course Page**: Integrated HTML interface
- **Responsive Design**: Works on all devices
- **Interactive Chat**: AI Oracle assistance
- **Progress Tracking**: Real-time updates

### ✅ Narrative Elements
- **5 Learning Phases**: Thematic story progression
- **AI Characters**: Oracle, Data Ghosts, Architect of Truth
- **Immersive UI**: Cosmic design with animations
- **Achievement System**: Gamified learning rewards

## 🔍 Troubleshooting

### Connection Issues
```bash
# Test SSH connection
ssh -v simonadmin@10.0.0.104

# Check server status
ssh simonadmin@10.0.0.104 "systemctl status apache2"
```

### File Permission Issues
```bash
# Fix permissions
ssh simonadmin@10.0.0.104 "chown -R www-data:www-data /var/www/html/moodle/course/2/odyssey"
```

### AI Oracle Not Working
```bash
# Check Python dependencies
ssh simonadmin@10.0.0.104 "cd /var/www/html/moodle/course/2/odyssey/ai && python3 -c 'import asyncio, pandas, numpy'"
```

### Moodle Integration Issues
- Ensure the course is accessible
- Check that the page resource was added correctly
- Verify HTML content is properly formatted

## 📊 Monitoring

### Check Deployment Status
```bash
# Run test script
ssh simonadmin@10.0.0.104 "cd /var/www/html/moodle/course/2/odyssey && ./test-deployment.sh"
```

### View Logs
```bash
# Check AI Oracle logs
ssh simonadmin@10.0.0.104 "tail -f /var/log/syslog | grep odyssey"
```

### Monitor Performance
- Check server resources: `htop`
- Monitor web server logs: `tail -f /var/log/apache2/access.log`
- Check database performance if using Databricks

## 🚀 Launch Checklist

- [ ] All files deployed successfully
- [ ] Moodle course page created
- [ ] AI Oracle service running
- [ ] Databricks analytics configured
- [ ] Test deployment passed
- [ ] Course is accessible to students
- [ ] All features working correctly

## 🎉 Success!

Once deployed, your Learning Odyssey will transform the J&J Python Academy into an immersive, intelligent learning experience that:

- **Engages learners** with 3D interactive environments
- **Provides AI assistance** through the Oracle system
- **Tracks progress** with real-time analytics
- **Tells a compelling story** through narrative elements
- **Adapts to individual needs** with personalized recommendations

Your students will embark on a journey from data literacy to mastery, guided by AI mentors and supported by cutting-edge technology! 🌌✨

---

**Deployment Status**: Ready for Launch 🚀  
**Course URL**: [https://moodle.simondatalab.de/course/view.php?id=2](https://moodle.simondatalab.de/course/view.php?id=2)  
**Last Updated**: October 14, 2025
