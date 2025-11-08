#!/usr/bin/env python3
"""
Fast audio embed: Uploads PHP script to container, executes it there.
Avoids shell escaping and buffer limit issues.
"""
import base64
import subprocess
import uuid
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
GENERATED = SCRIPT_DIR / 'generated' / 'professional'
PAGE_IDS = [163, 164, 165, 166, 167, 168, 169, 170]
SSH_HOST = 'moodle-vm9001'
CONTAINER = 'moodle-databricks-fresh'

def run(cmd, timeout=60):
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=timeout)
    return p

for i, pid in enumerate(PAGE_IDS, start=1):
    audio_candidates = list(GENERATED.glob(f'audio_{i}_*.mp3'))
    if not audio_candidates:
        print(f'Week {i}: no audio files, skipping')
        continue

    # Build HTML block
    audio_html_parts = ['<div class="epic-audio-block" style="margin:12px 0;">', f'<h4>Audio for Week {i}</h4>']
    for a in audio_candidates:
        b64 = base64.b64encode(a.read_bytes()).decode('utf-8')
        audio_html_parts.append(f'<div style="margin-bottom:8px;"><strong>{a.name}</strong><br>')
        audio_html_parts.append(f'<audio controls preload="none"><source src="data:audio/mpeg;base64,{b64}" type="audio/mpeg"></audio></div>')
    audio_html_parts.append('</div>')
    audio_block = '\n'.join(audio_html_parts)

    # Create PHP script
    encoded_block = base64.b64encode(audio_block.encode('utf-8')).decode('utf-8')
    php = (
        "<?php\n"
        "define('CLI_SCRIPT', true);\n"
        "require('/bitnami/moodle/config.php');\n"
        f"$pid={pid};\n"
        "$page=$DB->get_record('page', array('id'=>$pid));\n"
        "if($page){\n"
        f"$decoded=base64_decode('{encoded_block}');\n"
        "if(strpos($page->content,'epic-audio-block')===false){\n"
        "$page->content.=$decoded;\n"
        "$page->timemodified=time();\n"
        "$DB->update_record('page',$page);\n"
        "echo json_encode(array('success'=>true,'id'=>$page->id));\n"
        "}else{echo json_encode(array('success'=>true,'message'=>'already'));}\n"
        "}else{echo json_encode(array('success'=>false,'error'=>'notfound'));}\n"
        "?>"
    )

    # Write PHP to temp file
    temp_name = f'/tmp/moodle_audio_{uuid.uuid4().hex[:8]}.php'
    temp_local = Path(f'/tmp/{Path(temp_name).name}')
    temp_local.write_text(php)
    
    print(f'Week {i} (page {pid}): embedding {len(audio_candidates)} audio files...')
    
    # Copy to container
    copy_cmd = f"scp {temp_local} {SSH_HOST}:{temp_name} 2>/dev/null"
    p = run(copy_cmd, timeout=30)
    if p.returncode != 0:
        print(f'  ERR: scp failed - {p.stderr[:200]}')
        temp_local.unlink()
        continue
    
    # Execute on container
    exec_cmd = f"ssh {SSH_HOST} 'sudo docker exec {CONTAINER} /opt/bitnami/php/bin/php {temp_name}'"
    p = run(exec_cmd, timeout=30)
    
    # Clean up
    cleanup_cmd = f"ssh {SSH_HOST} 'rm -f {temp_name}' 2>/dev/null"
    run(cleanup_cmd, timeout=10)
    temp_local.unlink()
    
    if p.returncode != 0:
        print(f'  ERR: {p.stderr[:200] if p.stderr else "(no stderr)"}')
    else:
        result = p.stdout.strip()
        print(f'  OK: {result}')

print('\nDone embedding audio blocks')
