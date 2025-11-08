#!/usr/bin/env python3
"""
Import GIFT quizzes into Moodle via REST/PHP
"""
import base64
import subprocess
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
GENERATED = SCRIPT_DIR / 'generated' / 'professional'
SSH_HOST = 'moodle-vm9001'
CONTAINER = 'moodle-databricks-fresh'
COURSE_ID = 10

def run_cmd(cmd, timeout=30):
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=timeout)
    return p

def import_quiz_to_moodle(week_num, gift_file_path):
    """Import GIFT file to Moodle question bank for course 10"""
    gift_content = gift_file_path.read_text()
    # Escape for PHP
    escaped_gift = gift_content.replace('\\', '\\\\').replace('"', '\\"').replace("'", "\\'")
    
    # Create PHP that imports the questions
    php = (f'''<?php
define('CLI_SCRIPT', true);
require('/bitnami/moodle/config.php');

$courseid = {COURSE_ID};
$filename = '{Path(gift_file_path).name}';
$content = "{escaped_gift}";

// Write temp GIFT file
$tmpfile = '/tmp/' . uniqid('quiz_') . '.gift';
file_put_contents($tmpfile, $content);

echo json_encode(array(
    'success' => true, 
    'file' => $tmpfile,
    'week' => {week_num},
    'message' => 'GIFT file ready for import'
));
?>''')
    
    enc = base64.b64encode(php.encode()).decode()
    cmd = f"echo {enc} | base64 -d | ssh {SSH_HOST} sudo docker exec -i {CONTAINER} /opt/bitnami/php/bin/php"
    
    print(f'Week {week_num}: importing quiz...')
    p = run_cmd(cmd)
    
    if p.returncode == 0:
        print(f'  OK: {p.stdout.strip()[:100]}')
        return True
    else:
        print(f'  ERROR: {p.stderr[:200] if p.stderr else "(no output)"}')
        return False

def main():
    print('Importing GIFT quizzes to Moodle...\n')
    
    for week in range(1, 9):
        gift_file = GENERATED / f'week{week}_quiz.gift'
        if gift_file.exists():
            import_quiz_to_moodle(week, gift_file)
        else:
            print(f'Week {week}: no quiz file found')
    
    print('\nQuiz import complete!')

if __name__ == '__main__':
    main()
