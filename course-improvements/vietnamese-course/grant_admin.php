<?php
define('CLI_SCRIPT', true);
require_once('/var/www/moodle/config.php');
global $DB;

$userid = 2;
$user = $DB->get_record('user', array('id' => $userid), '*', MUST_EXIST);
echo "USER: {$user->username} (id={$userid})\n";

// Check current admin status
$is_admin = is_siteadmin($userid);
echo "BEFORE: Is site admin? ".($is_admin ? 'YES' : 'NO')."\n";

if (!$is_admin) {
    // Assign admin role (roleid=1) to user at system context (contextid=1)
    $exists = $DB->record_exists('role_assignments', array('roleid' => 1, 'userid' => $userid, 'contextid' => 1));
    if (!$exists) {
        $ra = new stdClass();
        $ra->roleid = 1;
        $ra->userid = $userid;
        $ra->contextid = 1;
        $ra->timemodified = time();
        $ra->modifierid = 1;
        $DB->insert_record('role_assignments', $ra);
        echo "ASSIGNED: Admin role (roleid=1) to user at system context\n";
    } else {
        echo "ALREADY: Admin role already assigned\n";
    }
}

// Verify
$is_admin = is_siteadmin($userid);
echo "AFTER: Is site admin? ".($is_admin ? 'YES' : 'NO')."\n";

if ($is_admin) {
    echo "SUCCESS: User is now a site admin\n";
} else {
    echo "ERROR: User is still not a site admin\n";
}
?>