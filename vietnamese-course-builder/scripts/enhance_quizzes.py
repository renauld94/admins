#!/usr/bin/env python3
"""
Lightweight quiz enhancer: converts placeholder MCQs into mixed templates
for human review (translation, cloze, listening + MC).
"""
import json
from pathlib import Path
from datetime import datetime

ROOT = Path(__file__).resolve().parents[1]
QUIZ_DIR = ROOT / 'output' / 'quizzes'
COURSE = ROOT / 'output' / 'course_structure.json'

def upgrade_quiz(path: Path):
    with path.open('r', encoding='utf-8') as fh:
        quiz = json.load(fh)

    lesson_id = quiz.get('lesson_id')
    lesson_name = quiz.get('lesson_name')
    generated_at = datetime.utcnow().isoformat() + 'Z'

    new_questions = []
    # 1) Translation task
    new_questions.append({
        'id': f'{lesson_id}_t1',
        'type': 'translation',
        'prompt': f'Translate into Vietnamese: "{lesson_name}"',
        'answer': None,
        'metadata': {'auto_generated': True, 'needs_review': True, 'generated_at': generated_at}
    })

    # 2) Cloze / fill-in-the-blank
    new_questions.append({
        'id': f'{lesson_id}_c1',
        'type': 'cloze',
        'prompt': f'Fill the blank in a short Vietnamese sentence relevant to {lesson_name}.',
        'blanks': 1,
        'metadata': {'auto_generated': True, 'needs_review': True, 'generated_at': generated_at}
    })

    # 3) Listening (uses generated audio placeholder)
    audio_path = f'output/audio/{lesson_id}_audio.mp3'
    new_questions.append({
        'id': f'{lesson_id}_l1',
        'type': 'listening',
        'prompt': 'Listen to the audio and select the correct transcription.',
        'audio': audio_path,
        'choices': [
            {'text': 'Placeholder A', 'correct': False},
            {'text': 'Placeholder B', 'correct': True},
            {'text': 'Placeholder C', 'correct': False}
        ],
        'metadata': {'auto_generated': True, 'needs_review': True, 'generated_at': generated_at}
    })

    # Keep remaining questions but flag as upgraded
    for q in quiz.get('questions', [])[3:]:
        q.setdefault('metadata', {})
        q['metadata'].update({'auto_upgraded': True, 'generated_at': generated_at})
        new_questions.append(q)

    quiz['questions'] = new_questions
    quiz['upgraded_at'] = generated_at

    with path.open('w', encoding='utf-8') as fh:
        json.dump(quiz, fh, ensure_ascii=False, indent=2)

def main():
    if not QUIZ_DIR.exists():
        print('Quiz directory not found:', QUIZ_DIR)
        return 1
    count = 0
    for p in sorted(QUIZ_DIR.glob('*.quiz.json')):
        upgrade_quiz(p)
        count += 1
    print(f'Upgraded {count} quiz files in {QUIZ_DIR}')
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
