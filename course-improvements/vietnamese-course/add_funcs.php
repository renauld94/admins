<?php
define('CLI_SCRIPT', true);
require_once('/var/www/moodle/config.php');
global $DB;
$short = 'vietnamese_deployment';
$service = $DB->get_record('external_services', array('shortname' => $short), '*', MUST_EXIST);
$functions = array(
  'core_question_get_categories',
  'core_question_import_questions',
  'core_question_create_categories',
  'mod_page_add_page',
  'core_webservice_get_site_info',
  'core_course_get_contents',
  'core_course_get_courses',
  'core_enrol_get_enrolled_users'
);
foreach ($functions as $fn) {
    if (! $DB->record_exists('external_services_functions', array('externalserviceid' => $service->id, 'functionname' => $fn))) {
        $rec = new stdClass();
        $rec->externalserviceid = $service->id;
        $rec->functionname = $fn;
        $DB->insert_record('external_services_functions', $rec);
        echo "Added: $fn\n";
    } else {
        echo "Exists: $fn\n";
    }
}
$rows = $DB->get_records('external_services_functions', array('externalserviceid' => $service->id));
foreach ($rows as $r) echo "FUNCTION: {$r->functionname}\n";
?>