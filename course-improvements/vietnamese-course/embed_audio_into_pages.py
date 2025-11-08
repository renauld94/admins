#!/usr/bin/env python3
import base64
import subprocess
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
GENERATED = SCRIPT_DIR / 'generated' / 'professional'
PAGE_IDS = [163,164,165,166,167,168,169,170]
SSH_HOST = 'moodle-vm9001'
CONTAINER = 'moodle-databricks-fresh'

def run(cmd, timeout=60):
    p = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=timeout)
    return p

for i, pid in enumerate(PAGE_IDS, start=1):
    # find audio files for this week
    audio_candidates = list(GENERATED.glob(f'audio_{i}_*.mp3'))
    if not audio_candidates:
        print(f'Week {i}: no audio files, skipping')
        continue

    # Build HTML block with inline base64 mp3 players
    audio_html_parts = ['<div class="epic-audio-block" style="margin:12px 0;">', f'<h4>Audio for Week {i}</h4>']
    for a in audio_candidates:
        b64 = base64.b64encode(a.read_bytes()).decode('utf-8')
        audio_html_parts.append(f'<div style="margin-bottom:8px;"><strong>{a.name}</strong><br>')
        audio_html_parts.append(f'<audio controls preload="none"><source src="data:audio/mpeg;base64,{b64}" type="audio/mpeg"></audio></div>')
    audio_html_parts.append('</div>')
    audio_block = '\n'.join(audio_html_parts)

    # Prepare PHP which base64-decodes incoming content and appends if not present
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

    enc = base64.b64encode(php.encode('utf-8')).decode('utf-8')
    # Pipe directly: echo <encoded> | base64 -d | ssh host docker exec -i container /full/php/path
    cmd = f"echo {enc} | base64 -d | ssh {SSH_HOST} sudo docker exec -i {CONTAINER} /opt/bitnami/php/bin/php"
    print(f'Updating page {pid} (week {i}) with {len(audio_candidates)} audio files...')
    p = run(cmd)
    if p.returncode != 0:
        print('ERROR updating page', pid, p.stderr[:500] if p.stderr else '(no stderr)')
    else:
        print('->', p.stdout.strip())

print('Done embedding audio blocks')
