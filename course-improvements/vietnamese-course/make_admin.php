<?php
define('CLI_SCRIPT', true);
require_once('/var/www/moodle/config.php');
require_once($CFG->dirroot . '/lib/accesslib.php');

$roleid = 1; // manager/admin role id (usually 1)
$userid = 2; // token user previously observed
$context = context_system::instance();

try {
    // role_assign returns void but will throw on failure in some versions; use assign_capability or direct DB insert fallback
    role_assign($roleid, $userid, $context->id);
    echo "Role assignment attempted: roleid={$roleid} userid={$userid} contextid={$context->id}\n";
    echo is_siteadmin($userid) ? "User is now site admin\n" : "User is NOT site admin\n";
} catch (Exception $e) {
    echo "Exception during role_assign: " . $e->getMessage() . "\n";
}

?>