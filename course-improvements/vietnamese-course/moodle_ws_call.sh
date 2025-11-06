#!/bin/bash

# Call Moodle webservice directly - WORKING VERSION
# Uses base64 to avoid quote escaping hell

set -e

TOKEN=$(cat ~/.moodle_token)
WS_FUNCTION="${1:-core_webservice_get_site_info}"

echo "🔧 Calling $WS_FUNCTION via direct PHP..."

# Create PHP script and encode it
PHP_CODE=$(cat <<'EOF'
<?php
define('CLI_SCRIPT', true);
require('/bitnami/moodle/config.php');
require_once($CFG->libdir . '/externallib.php');

$token = getenv('MOODLE_TOKEN');
$wsfunction = getenv('WS_FUNCTION');

$tokenrecord = $DB->get_record('external_tokens', array('token' => $token));
if (!$tokenrecord) {
    echo json_encode(array('error' => 'Invalid token'));
    exit(1);
}

$USER = $DB->get_record('user', array('id' => $tokenrecord->userid));
if (!$USER) {
    echo json_encode(array('error' => 'User not found'));
    exit(1);
}

try {
    $function = external_api::external_function_info($wsfunction);
    $result = call_user_func(array($function->classname, $function->methodname));
    echo json_encode($result, JSON_PRETTY_PRINT);
} catch (Exception $e) {
    echo json_encode(array('error' => $e->getMessage(), 'exception' => get_class($e)), JSON_PRETTY_PRINT);
    exit(1);
}
EOF
)

# Encode and execute
ENCODED=$(echo "$PHP_CODE" | base64 -w 0)

ssh moodle-vm9001 "sudo docker exec -e MOODLE_TOKEN='$TOKEN' -e WS_FUNCTION='$WS_FUNCTION' moodle-databricks-fresh bash -c 'echo $ENCODED | base64 -d | php' 2>&1 | grep -v 'Warning: chdir'"

echo ""
