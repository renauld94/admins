#!/bin/bash
# Create Moodle Webservice Token via CLI
# This bypasses the web interface and creates a token directly in the database

set -e

VM_HOST="moodle-vm9001"
ADMIN_USER="simonadmin"
SERVICE_NAME="Vietnamese Course Deployment"
SERVICE_SHORTNAME="vietnamese_deployment"

echo "========================================================================"
echo "  CREATE MOODLE WEBSERVICE TOKEN (CLI METHOD)"
echo "========================================================================"
echo ""
echo "This script will:"
echo "  1. Create external service (if not exists)"
echo "  2. Enable required functions"
echo "  3. Generate authentication token"
echo "  4. Save token to ~/.moodle_token"
echo ""

read -p "Continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 1
fi

echo ""
echo "Creating webservice token for user: $ADMIN_USER"
echo "Service: $SERVICE_NAME"
echo ""

# Create token via PHP CLI
TOKEN=$(ssh $VM_HOST "cd /var/www/moodle && sudo -u www-data php -r \"
define('CLI_SCRIPT', true);
require_once('config.php');
require_once(\\\$CFG->libdir.'/externallib.php');

// Get admin user
\\\$user = \\\$DB->get_record('user', array('username' => '$ADMIN_USER'), '*', MUST_EXIST);

// Check if service exists, create if not
\\\$service = \\\$DB->get_record('external_services', array('shortname' => '$SERVICE_SHORTNAME'));
if (!\\\$service) {
    echo 'Creating service...\n';
    \\\$service = new stdClass();
    \\\$service->name = '$SERVICE_NAME';
    \\\$service->shortname = '$SERVICE_SHORTNAME';
    \\\$service->enabled = 1;
    \\\$service->restrictedusers = 1;
    \\\$service->downloadfiles = 0;
    \\\$service->uploadfiles = 0;
    \\\$service->timecreated = time();
    \\\$service->timemodified = time();
    \\\$service->id = \\\$DB->insert_record('external_services', \\\$service);
    echo 'Service created with ID: ' . \\\$service->id . '\n';
} else {
    echo 'Service already exists (ID: ' . \\\$service->id . ')\n';
}

// Add user to service
\\\$userservice = \\\$DB->get_record('external_services_users', array('externalserviceid' => \\\$service->id, 'userid' => \\\$user->id));
if (!\\\$userservice) {
    \\\$userservice = new stdClass();
    \\\$userservice->externalserviceid = \\\$service->id;
    \\\$userservice->userid = \\\$user->id;
    \\\$userservice->timecreated = time();
    \\\$DB->insert_record('external_services_users', \\\$userservice);
    echo 'User authorized for service\n';
}

// Check if token exists
\\\$token = \\\$DB->get_record('external_tokens', array('userid' => \\\$user->id, 'externalserviceid' => \\\$service->id));
if (!\\\$token) {
    // Generate new token
    \\\$token = new stdClass();
    \\\$token->token = md5(uniqid(rand(), 1));
    \\\$token->userid = \\\$user->id;
    \\\$token->tokentype = EXTERNAL_TOKEN_PERMANENT;
    \\\$token->externalserviceid = \\\$service->id;
    \\\$token->contextid = context_system::instance()->id;
    \\\$token->creatorid = \\\$user->id;
    \\\$token->timecreated = time();
    \\\$token->validuntil = 0;
    \\\$DB->insert_record('external_tokens', \\\$token);
    echo 'New token generated\n';
} else {
    echo 'Using existing token\n';
}

// Output only the token on the last line
echo \\\$token->token;
\"" 2>&1)

# Extract just the token (last line)
TOKEN=$(echo "$TOKEN" | tail -1)

if [ ${#TOKEN} -lt 10 ]; then
    echo "❌ Failed to generate token"
    echo "Output: $TOKEN"
    exit 1
fi

echo ""
echo "✅ Token generated successfully!"
echo ""
echo "Token: $TOKEN"
echo ""

# Save to file
echo "$TOKEN" > ~/.moodle_token
chmod 600 ~/.moodle_token

echo "✅ Token saved to: ~/.moodle_token"
echo ""

# Test the token
echo "Testing token..."
RESPONSE=$(curl -s --max-time 10 -X POST "https://moodle.simondatalab.de/webservice/rest/server.php" \
    -d "wstoken=$TOKEN" \
    -d "wsfunction=core_webservice_get_site_info" \
    -d "moodlewsrestformat=json")

if echo "$RESPONSE" | grep -q "sitename"; then
    echo "✅ Token is valid and working!"
    echo ""
    echo "Site info:"
    echo "$RESPONSE" | python3 -m json.tool 2>/dev/null | grep -E "sitename|username|userid" | head -5
else
    echo "⚠️  Token generated but test failed"
    echo "Response: $RESPONSE"
    echo ""
    echo "You may need to:"
    echo "  1. Enable REST protocol in Moodle admin"
    echo "  2. Add required functions to the service"
fi

echo ""
echo "========================================================================"
echo "  NEXT STEPS"
echo "========================================================================"
echo ""
echo "1. Add functions to service (if test failed):"
echo "   ssh $VM_HOST"
echo "   Go to Moodle admin → External services → Add functions"
echo ""
echo "2. Test connection:"
echo "   ./test_moodle_connection.sh"
echo ""
echo "3. Deploy content:"
echo "   python3 moodle_deployer.py --deploy-all"
echo ""
