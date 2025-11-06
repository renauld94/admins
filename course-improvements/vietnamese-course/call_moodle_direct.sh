#!/bin/bash

# Direct Moodle Webservice Caller via SSH
# Bypasses all HTTP/Cloudflare by calling Moodle PHP functions directly

set -e

TOKEN_FILE="$HOME/.moodle_token"
SSH_HOST="moodle-vm9001"
CONTAINER="moodle-databricks-fresh"

if [ ! -f "$TOKEN_FILE" ]; then
    echo "❌ Token file not found: $TOKEN_FILE"
    exit 1
fi

TOKEN=$(cat "$TOKEN_FILE")
WS_FUNCTION="${1:-core_webservice_get_site_info}"

echo "🔧 Calling Moodle webservice: $WS_FUNCTION"
echo "🔑 Using token: ${TOKEN:0:8}...${TOKEN: -8}"
echo ""

# Create PHP script
PHP_SCRIPT=$(cat <<'EOPHP'
<?php
define('CLI_SCRIPT', true);
require('/bitnami/moodle/config.php');
require_once($CFG->libdir . '/externallib.php');

$token = getenv('MOODLE_TOKEN');
$wsfunction = getenv('WS_FUNCTION');

// Authenticate
$tokenrecord = $DB->get_record('external_tokens', array('token' => $token));
if (!$tokenrecord) {
    echo json_encode(array('error' => 'Invalid token'));
    exit(1);
}

// Set user
$USER = $DB->get_record('user', array('id' => $tokenrecord->userid));
if (!$USER) {
    echo json_encode(array('error' => 'User not found'));
    exit(1);
}

// Call webservice
try {
    $function = external_api::external_function_info($wsfunction);
    $result = call_user_func(array($function->classname, $function->methodname));
    echo json_encode($result, JSON_PRETTY_PRINT);
} catch (Exception $e) {
    echo json_encode(array('error' => $e->getMessage(), 'exception' => get_class($e)));
    exit(1);
}
?>
EOPHP
)

# Execute via SSH
ssh "$SSH_HOST" "sudo docker exec -e MOODLE_TOKEN='$TOKEN' -e WS_FUNCTION='$WS_FUNCTION' $CONTAINER php" <<< "$PHP_SCRIPT" 2>&1 | grep -v "Warning: chdir"

echo ""
echo "✅ Done"
