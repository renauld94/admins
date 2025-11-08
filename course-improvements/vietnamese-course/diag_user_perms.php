<?php
define('CLI_SCRIPT', true);
require_once('/var/www/moodle/config.php');
global $DB;

// Get token user (userid=2 based on earlier diag)
$userid = 2;
$user = $DB->get_record('user', array('id' => $userid), '*', MUST_EXIST);
echo "USER: id={$user->id} username={$user->username} firstname={$user->firstname} lastname={$user->lastname}\n";

// Check user roles
$roles = $DB->get_records_sql("
  SELECT r.id, r.name, r.shortname, c.contextlevel 
  FROM {role_assignments} ra
  JOIN {role} r ON ra.roleid = r.id
  JOIN {context} c ON ra.contextid = c.id
  WHERE ra->userid = ?
", array($userid));
echo "ROLES (count=".count($roles)."):\n";
foreach ($roles as $role) echo " - {$role->shortname} (name={$role->name}) in context {$role->contextlevel}\n";

// Check if user is admin
$isadmin = is_siteadmin($userid) ? 'YES (site admin)' : 'NO';
echo "IS SITE ADMIN: $isadmin\n";

// Check service capabilities
$service = $DB->get_record('external_services', array('shortname' => 'vietnamese_deployment'), '*', MUST_EXIST);
echo "\nSERVICE CAPABILITIES:\n";
echo "  enabled={$service->enabled}\n";
echo "  restrictedusers={$service->restrictedusers}\n";
echo "  downloadfiles={$service->downloadfiles}\n";
echo "  uploadfiles={$service->uploadfiles}\n";

// Check user authorization for service
$auth = $DB->get_record('external_services_users', array('externalserviceid' => $service->id, 'userid' => $userid));
if ($auth) {
  echo "USER AUTHORIZED FOR SERVICE: YES (timecreated={$auth->timecreated})\n";
} else {
  echo "USER AUTHORIZED FOR SERVICE: NO\n";
}

// Check if user has moodle/webservice:createtoken capability
$ctx = context_system::instance();
$can_create_token = has_capability('moodle/webservice:createtoken', $ctx, $userid);
echo "USER CAN CREATE TOKEN: ".($can_create_token ? 'YES' : 'NO')."\n";

// Check core functions specifically
$funcs_to_check = array('core_question_get_categories', 'core_question_import_questions', 'mod_page_add_page');
echo "\nFUNCTION CHECKS:\n";
foreach ($funcs_to_check as $fn) {
  $has_fn = $DB->record_exists('external_services_functions', array('externalserviceid' => $service->id, 'functionname' => $fn));
  echo "  $fn: ".($has_fn ? 'ADDED' : 'NOT ADDED')."\n";
}
?>