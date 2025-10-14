<?php
// Temporary debug addition - add this after the if condition in frontpage.php
// Add this right after: if ($PAGE->pagelayout === 'frontpage' && !$has_redirect_params) {

// Debug: Add a visible HTML comment to check if condition is met
$customcontent = '<!-- DEBUG: Frontpage condition met, custom content should load -->' . PHP_EOL;

// Continue with original file loading logic...
$indexpath = $CFG->dirroot . '/theme/jnjboost/index.html';
if (file_exists($indexpath)) {
    $customcontent .= file_get_contents($indexpath);
    
    // Replace __WWWROOT__ with actual Moodle URL
    $customcontent = str_replace('__WWWROOT__', $CFG->wwwroot, $customcontent);
    
    // Additional cleanup for any remaining issues
    $customcontent = preg_replace('/🧠/u', '', $customcontent);
    $customcontent = str_replace('NeuroData Science Academy', 'Professional Learning Academy', $customcontent);
    $customcontent = str_replace('NeuroData Science', 'Professional Learning Platform', $customcontent);
} else {
    $customcontent .= '<!-- DEBUG: Index.html file not found at: ' . $indexpath . ' -->' . PHP_EOL;
}
?>