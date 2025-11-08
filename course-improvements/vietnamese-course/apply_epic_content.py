#!/usr/bin/env python3
import json
import subprocess
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
EPIC_TEMPLATE = SCRIPT_DIR / 'epic_class_week1.html'
GENERATED_DIR = SCRIPT_DIR / 'generated' / 'professional'

SSH_HOST = 'moodle-vm9001'
CONTAINER = 'moodle-databricks-fresh'
COURSE_ID = 10

def run_cmd(cmd, timeout=30):
    res = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
    return res

# 1) Get mapping of course_modules -> page ids and names
php_get = r"""
<?php
require('/bitnami/moodle/config.php');
$cmrows = $DB->get_records_sql("SELECT cm.id AS cmid, p.id AS pageid, p.name AS name, cm.section AS sectionnum
    FROM {course_modules} cm
    JOIN {modules} m ON m.id = cm.module
    JOIN {page} p ON p.id = cm.instance
    WHERE cm.course = ? AND m.name = 'page'", array(%d));
$out = array();
foreach ($cmrows as $r) {
    $out[] = array('cmid' => $r->cmid, 'pageid' => $r->pageid, 'name' => $r->name, 'section' => $r->sectionnum);
}
echo json_encode($out);
?>
""" % COURSE_ID

print('Fetching page mappings from Moodle...')
enc = subprocess.run(['bash','-lc', f"echo {json.dumps(php_get)} | ssh {SSH_HOST} 'sudo docker exec -i {CONTAINER} php -'"], capture_output=True, text=True)
if enc.returncode != 0:
    print('Error fetching mappings:', enc.stderr)
    raise SystemExit(1)

try:
    mappings = json.loads(enc.stdout.strip())
except Exception as e:
    print('Failed to parse mapping JSON:', e, enc.stdout[:1000])
    raise

print(f'Found {len(mappings)} page modules')

# read epic template
if not EPIC_TEMPLATE.exists():
    print('Epic template not found:', EPIC_TEMPLATE)
    raise SystemExit(1)

epic_html = EPIC_TEMPLATE.read_text()

# For each page mapping, load corresponding week content if present
results = []
for m in mappings:
    cmid = int(m['cmid'])
    pageid = int(m['pageid'])
    name = m.get('name') or ''
    section = m.get('section') or 0
    # Attempt to find a weekN file based on section or page name
    week_file = None
    # prefer section mapping if between 1..8
    if isinstance(section, int) and 1 <= section <= 8:
        candidate = GENERATED_DIR / f'week{section}_lesson.html'
        if candidate.exists():
            week_file = candidate
    # fallback: search for weekN in name
    if not week_file:
        for i in range(1,9):
            candidate = GENERATED_DIR / f'week{i}_lesson.html'
            if candidate.exists() and f'Week {i}' in name:
                week_file = candidate
                break
    # final fallback: choose week1
    if not week_file:
        week_file = GENERATED_DIR / 'week1_lesson.html' if (GENERATED_DIR / 'week1_lesson.html').exists() else None

    lesson_html = week_file.read_text() if week_file and week_file.exists() else ''

    # Build widget HTML (simple injection similar to agent)
    widget_html = f"""
<!-- EPIC WIDGET: start -->
<div class=\"vietnamese-tutor-widget\"> 
  <h3>🤖 Your Vietnamese AI Tutor — {name}</h3>
  <p>Interactive pronunciation, practice and tips.</p>
  <iframe src=\"https://agent.simondatalab.de/vietnamese-tutor?lesson={name.replace(' ','+')}&week={section}\" width=\"100%\" height=\"420\" style=\"border:0;\"></iframe>
</div>
<!-- EPIC WIDGET: end -->
"""

    # Compose new content: existing lesson + epic template + widget
    new_content = lesson_html + '\n' + epic_html + '\n' + widget_html

    # Create PHP code that updates the page content for the pageid
    # Use base64 to avoid length issues
    php_update = """
<?php
require('/bitnami/moodle/config.php');
$pid = %d;
$page = $DB->get_record('page', array('id' => $pid));
if ($page) {
    $page->content = %s;
    $page->timemodified = time();
    $DB->update_record('page', $page);
    echo json_encode(array('success' => true, 'id' => $page->id));
} else {
    echo json_encode(array('success' => false, 'error' => 'Page not found'));
}
?>
""" % (pageid, '%s')

    # Encode new_content in PHP string safely by using base64 decode in PHP
    b64 = new_content.encode('utf-8').hex()  # temp use hex to embed
    # Instead, we'll base64 encode and in PHP decode it
    import base64
    b64_content = base64.b64encode(new_content.encode('utf-8')).decode('utf-8')
    php_full = "<?php\nrequire('/bitnami/moodle/config.php');\n$pid = %d;\n$decoded = base64_decode('%s');\n$page = $DB->get_record('page', array('id' => $pid));\nif ($page) {\n    $page->content = $decoded;\n    $page->timemodified = time();\n    $DB->update_record('page', $page);\n    echo json_encode(array('success' => true, 'id' => $page->id));\n} else {\n    echo json_encode(array('success' => false, 'error' => 'Page not found'));\n}\n?>" % (pageid, b64_content)

    # base64-encode the php_full to safely transmit
    import base64 as _b
    encoded = _b.b64encode(php_full.encode('utf-8')).decode('utf-8')
    cmd = ['ssh', SSH_HOST, f"sudo docker exec {CONTAINER} bash -lc 'echo {encoded} | base64 -d | php' 2>&1"]
    print(f'Updating pageid={pageid} (cmid={cmid}) name="{name}" using week file {week_file.name if week_file else "(none)"}...')
    res = run_cmd(cmd, timeout=60)
    if res.returncode != 0:
        print('Update command failed:', res.stderr[:500])
        results.append({'pageid': pageid, 'success': False, 'error': res.stderr})
    else:
        out = res.stdout.strip()
        try:
            parsed = json.loads(out)
            print(' ->', parsed)
            results.append({'pageid': pageid, 'success': parsed.get('success', False), 'raw': parsed})
        except Exception as e:
            print('Failed to parse output:', e, out[:500])
            results.append({'pageid': pageid, 'success': False, 'raw_output': out})

# Summary
print('\nUpdate summary:')
for r in results:
    print(r)

print('\nDone.')
