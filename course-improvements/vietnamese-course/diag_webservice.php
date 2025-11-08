<?php
define('CLI_SCRIPT', true);
require_once('/var/www/moodle/config.php');
global $DB;
$short = 'vietnamese_deployment';
$svc = $DB->get_record('external_services', array('shortname' => $short));
if (!$svc) { echo "SERVICE NOT FOUND\n"; exit(1); }
echo "SERVICE: id={$svc->id} name={$svc->name} shortname={$svc->shortname} enabled={$svc->enabled} restrictedusers={$svc->restrictedusers} downloadfiles={$svc->downloadfiles} uploadfiles={$svc->uploadfiles}\n";
// list functions
$funcs = $DB->get_records('external_services_functions', array('externalserviceid' => $svc->id));
echo "FUNCTIONS (count=".count($funcs)."):\n";
foreach ($funcs as $f) echo " - {$f->functionname}\n";
// tokens for this service
$tokens = $DB->get_records('external_tokens', array('externalserviceid' => $svc->id));
echo "TOKENS (count=".count($tokens)."):\n";
foreach ($tokens as $t) echo " - token={$t->token} userid={$t->userid} validuntil={$t->validuntil} tokentype={$t->tokentype}\n";
// authorized users
$users = $DB->get_records('external_services_users', array('externalserviceid'=>$svc->id));
echo "AUTHORIZED USERS (count=".count($users)."):\n";
foreach ($users as $u) echo " - userid={$u->userid} timecreated={$u->timecreated}\n";

// Check REST protocol enabled
$protocols = $DB->get_recordset_sql("SELECT * FROM {external_services} LIMIT 1");
// Instead check admin setting via config: webservice_enabled and rest protocol?
$restenabled = get_config('webservice','enabled') ? 'webservices enabled' : 'webservices disabled';
echo "WEB_SERVICE_CONFIG: $restenabled\n";
// Check manage protocols setting
$restproto = get_config('webservice','enabledprotocols');
echo "WEB_SERVICE_ENABLED_PROTOCOLS: ".($restproto?:'')."\n";
?>