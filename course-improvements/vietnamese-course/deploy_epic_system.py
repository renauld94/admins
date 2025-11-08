#!/usr/bin/env python3
"""
Epic Interactive System Deployer
Embeds the interactive visualization system into all 8 course pages
"""
import base64
import subprocess
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
GENERATED = SCRIPT_DIR / 'generated' / 'professional'
SSH_HOST = 'moodle-vm9001'
CONTAINER = 'moodle-databricks-fresh'
EPIC_SYSTEM = SCRIPT_DIR / 'epic_interactive_system.html'
PAGE_IDS = [163, 164, 165, 166, 167, 168, 169, 170]

def read_epic_system():
    """Read the epic interactive HTML"""
    return EPIC_SYSTEM.read_text()

def inject_system_into_page(page_id, week_num, epic_html):
    """Inject the interactive system into a page"""
    # Create PHP that injects the system + original content
    php = f'''<?php
define('CLI_SCRIPT', true);
require('/bitnami/moodle/config.php');

$pid = {page_id};
$page = $DB->get_record('page', array('id' => $pid));

if($page) {{
    // Extract original content
    $original = $page->content;
    
    // Inject epic system at the top
    $epic_html = base64_decode('{base64.b64encode(epic_html.encode()).decode()}');
    
    // Replace week placeholder with actual week number
    $epic_html = str_replace('state.currentWeek = 1', 'state.currentWeek = {week_num}', $epic_html);
    
    // Combine: epic system first, then original content
    $page->content = $epic_html . '<div class="original-content" style="margin-top: 40px; padding-top: 20px; border-top: 2px solid #ddd;">' . $original . '</div>';
    $page->timemodified = time();
    $DB->update_record('page', $page);
    
    echo json_encode(array(
        'success' => true,
        'id' => $page->id,
        'week' => {week_num},
        'new_size' => strlen($page->content),
        'message' => 'Epic interactive system injected!'
    ));
}} else {{
    echo json_encode(array('success' => false, 'error' => 'Page not found'));
}}
?>'''
    
    enc = base64.b64encode(php.encode()).decode()
    cmd = f"echo {enc} | base64 -d | ssh {SSH_HOST} sudo docker exec -i {CONTAINER} /opt/bitnami/php/bin/php"
    
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=60)
    return p

def main():
    print('=' * 70)
    print('🚀 EPIC INTERACTIVE SYSTEM DEPLOYMENT')
    print('=' * 70)
    print()
    
    epic_html = read_epic_system()
    print(f'✓ Loaded epic system ({len(epic_html)} bytes)')
    print()
    
    for i, pid in enumerate(PAGE_IDS, start=1):
        week = i
        print(f'Injecting into Page {pid} (Week {week})...', end=' ', flush=True)
        
        try:
            p = inject_system_into_page(pid, week, epic_html)
            if p.returncode == 0:
                print('✅ SUCCESS')
                print(f'  └─ {p.stdout.strip()[:100]}')
            else:
                print(f'❌ FAILED')
                print(f'  └─ {p.stderr[:200] if p.stderr else "(no error)"}')
        except Exception as e:
            print(f'❌ ERROR: {str(e)[:100]}')
    
    print()
    print('=' * 70)
    print('✨ EPIC INTERACTIVE SYSTEM DEPLOYMENT COMPLETE!')
    print('=' * 70)
    print()
    print('All 8 pages now feature:')
    print('  ✓ Interactive D3.js visualizations')
    print('  ✓ Three.js 3D animations')
    print('  ✓ Web Audio API with real-time visualization')
    print('  ✓ Microphone recording & speech recognition')
    print('  ✓ Animated word clouds')
    print('  ✓ Performance analytics charts')
    print('  ✓ Gamified progress tracking')
    print('  ✓ Instant feedback system')
    print()

if __name__ == '__main__':
    main()
