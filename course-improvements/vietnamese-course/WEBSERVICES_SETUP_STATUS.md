# Moodle Webservices Setup - Summary

## ✅ Completed Steps

### 1. Passwordless SSH Access
- ✓ SSH key added to VM 9001 (simonadmin@10.0.0.104)
- ✓ SSH config entry added: `ssh moodle-vm9001`
- ✓ Connection verified and working

### 2. Moodle Installation Fixed
- ✓ Fixed missing cache directory (restored from backup)
- ✓ Fixed dataroot permissions (/home/example/moodledata)
- ✓ Moodle location: /var/www/moodle
- ✓ Database: PostgreSQL

### 3. Webservices Enabled (CLI)
- ✓ enablewebservices = 1
- ✓ enablemobilewebservice = 1  
- ✓ REST protocol enabled = 1

## ⚠️ Remaining Steps (Web Interface Required)

The REST protocol needs to be enabled in the Moodle web interface settings. Follow these steps:

### Step 1: Enable REST Protocol
1. Go to: https://moodle.simondatalab.de/admin/settings.php?section=webserviceprotocols
2. Check the box next to "REST protocol"
3. Click "Save changes"

### Step 2: Create External Service
1. Go to: https://moodle.simondatalab.de/admin/settings.php?section=externalservices
2. Click "Add" under "External services"
3. Fill in:
   - Name: `Vietnamese Course Deployment`
   - Short name: `vietnamese_deployment`
   - Enabled: ✓ Yes
   - Authorized users only: ✓ Yes
4. Click "Add service"

### Step 3: Add Functions to Service
Click "Add functions" next to your new service and add these:

**Core functions:**
- `core_course_get_contents`
- `core_course_get_courses`
- `core_webservice_get_site_info`

**Question bank:**
- `core_question_get_categories`
- `core_question_create_categories`

**Module functions:**
- `mod_page_add_page`
- `mod_assign_create_assignments`
- `mod_resource_add_resource`

### Step 4: Authorize User
1. Click "Authorised users" next to your service
2. Select your admin user
3. Click "Add"

### Step 5: Create Token
1. Go to: https://moodle.simondatalab.de/admin/settings.php?section=webservicetokens
2. Under "Create token", select:
   - User: Your admin account
   - Service: Vietnamese Course Deployment
3. Click "Save changes"
4. **Copy the generated token**

### Step 6: Save Token
```bash
echo "YOUR_TOKEN_HERE" > ~/.moodle_token
chmod 600 ~/.moodle_token
```

### Step 7: Test Connection
```bash
./test_moodle_connection.sh
```

## Quick Commands

```bash
# Test SSH connection
ssh moodle-vm9001

# Enable webservices (already done)
./enable_moodle_webservices_cli.sh

# Setup token (after web config)
./setup_moodle_webservices.sh

# Test connection
./test_moodle_connection.sh

# Deploy content
cd /home/simon/Learning-Management-System-Academy/course-improvements/vietnamese-course
python3 moodle_deployer.py --deploy-all
```

## Files Created

1. `setup_passwordless_ssh_vm9001.sh` - Set up SSH keys (✓ complete)
2. `enable_moodle_webservices_cli.sh` - Enable via CLI (✓ complete)
3. `enable_webservices_proxmox.sh` - Alternative Proxmox method
4. `test_moodle_connection.sh` - Test connectivity
5. `setup_moodle_webservices.sh` - Interactive setup guide

## Connection Details

- **Moodle URL:** https://moodle.simondatalab.de
- **VM:** 9001 (10.0.0.104)
- **User:** simonadmin
- **Bastion:** root@136.243.155.166:2222
- **Moodle Dir:** /var/www/moodle
- **Database:** PostgreSQL (moodle)

## Next Action Required

**You need to complete Steps 1-6 above via the Moodle web interface** to finish enabling the REST API and create the authentication token.

The CLI has done everything possible - the remaining steps require web UI access for security reasons.
