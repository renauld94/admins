<?php
// Sets Moodle additionalhtmlhead by appending payload from file.
// Container path assumptions: Bitnami Moodle image and PHP at /opt/bitnami/php/bin/php
define('CLI_SCRIPT', true);
require_once('/opt/bitnami/moodle/config.php');

$payloadPath = '/tmp/moodle_head_payload.html';
if (!file_exists($payloadPath)) {
    fwrite(STDERR, "Payload file not found: $payloadPath\n");
    exit(1);
}

$payload = file_get_contents($payloadPath);
if ($payload === false) {
    fwrite(STDERR, "Failed to read payload file.\n");
    exit(1);
}

$existing = (string) get_config('core', 'additionalhtmlhead');
if (strpos($existing, 'moodle-simondatalab.css') !== false) {
    echo "Already\n";
    exit(0);
}

set_config('additionalhtmlhead', $existing . $payload);
echo "Updated\n";
exit(0);
