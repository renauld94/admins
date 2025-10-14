<?php
define('CLI_SCRIPT', true);
// Auto-add sessions to Moodle course
// This script will automatically create folder activities for all sessions

require_once('/opt/bitnami/moodle/config.php');
require_once($CFG->libdir.'/moodlelib.php');
require_once($CFG->libdir.'/filelib.php');

global $DB, $USER;

// Set up the environment
$USER = get_admin(); // Run as admin
$courseid = 2; // Your course ID

// Get course
$course = $DB->get_record('course', array('id' => $courseid), '*', MUST_EXIST);

// Session data - Module 1
$module1_sessions = array(
    "1.01 System Setup & Introduction",
    "1.02 Installing Python", 
    "1.03 Installing Jupyter Notebooks",
    "1.04 Installing Git and Bitbucket",
    "1.05 Installing PySpark",
    "1.06 Setting Up Virtual Environments", 
    "1.07 Configuring Environment Variables",
    "1.08 Testing the Setup",
    "1.09 Accessing Learning Resources"
);

// Add Module 1 sessions to section 1
$sectionnum = 1;
foreach ($module1_sessions as $index => $session_name) {
    $session_num = $index + 1;
    $source_dir = "/tmp/moodle_upload/module_1/session_1_{$session_num}";
    
    if (file_exists($source_dir)) {
        // Create folder activity
        $folder = new stdClass();
        $folder->course = $courseid;
        $folder->name = $session_name;
        $folder->intro = "Session content for {$session_name}";
        $folder->introformat = FORMAT_HTML;
        $folder->revision = 1;
        $folder->timemodified = time();
        
        $folder->id = $DB->insert_record('folder', $folder);
        
        // Add to course_modules
        $cm = new stdClass();
        $cm->course = $courseid;
        $cm->module = $DB->get_field('modules', 'id', array('name' => 'folder'));
        $cm->instance = $folder->id;
        $cm->section = $DB->get_field('course_sections', 'id', array('course' => $courseid, 'section' => $sectionnum));
        $cm->added = time();
        $cm->visible = 1;
        $cm->visibleold = 1;
        $cm->groupmode = 0;
        $cm->groupingid = 0;
        $cm->completion = 0;
        
        $cm->id = $DB->insert_record('course_modules', $cm);
        
        // Update course section sequence
        $section = $DB->get_record('course_sections', array('course' => $courseid, 'section' => $sectionnum));
        if (!empty($section->sequence)) {
            $section->sequence .= ',' . $cm->id;
        } else {
            $section->sequence = $cm->id;
        }
        $DB->update_record('course_sections', $section);
        
        // Copy files to Moodle file area
        $context = context_module::instance($cm->id);
        $fs = get_file_storage();
        
        $files = scandir($source_dir);
        foreach ($files as $file) {
            if ($file != '.' && $file != '..' && is_file($source_dir . '/' . $file)) {
                $fileinfo = array(
                    'contextid' => $context->id,
                    'component' => 'mod_folder',
                    'filearea' => 'content',
                    'itemid' => 0,
                    'filepath' => '/',
                    'filename' => $file
                );
                
                $fs->create_file_from_pathname($fileinfo, $source_dir . '/' . $file);
            }
        }
        
        echo "✅ Added session: {$session_name}\n";
    } else {
        echo "❌ Source directory not found: {$source_dir}\n";
    }
}

rebuild_course_cache($courseid);
echo "\n🎉 Module 1 sessions added successfully!\n";
echo "📊 Check your course at: http://localhost:8086/course/view.php?id=2\n";
