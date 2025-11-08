#!/usr/bin/env python3
"""Produce a dry-run plan for Moodle deployment using generated/professional/ assets.

This script does NOT contact Moodle. It scans the generated directory and prints
what the deployer would upload/create for each week (quizzes, lessons, flashcards,
dialogues, audio). Run locally to validate before running the real deploy.

Usage:
  python3 preview_moodle_deploy.py
"""
import os
import textwrap


def find_generated(gen_dir):
    if not os.path.exists(gen_dir):
        print(f'Generated dir not found: {gen_dir}')
        return []
    return sorted(os.listdir(gen_dir))


def plan_actions(files):
    # group by week
    weeks = {}
    for f in files:
        if f.startswith('week'):
            # weekN_suffix
            parts = f.split('_', 1)
            if len(parts) == 2:
                week = parts[0]
                weeks.setdefault(week, []).append(f)
    return weeks


def main():
    base = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
    gen_dir = os.path.join(base, 'generated', 'professional')
    files = find_generated(gen_dir)
    if not files:
        return

    weeks = plan_actions(files)
    total_quizzes = 0
    total_lessons = 0
    total_flash = 0
    total_dialogue = 0

    print('\nPreview Moodle deployment (dry-run)')
    print(f'  Generated directory: {gen_dir}\n')

    for w in sorted(weeks.keys()):
        items = weeks[w]
        print(f'== {w} ==')
        # quiz
        q = [i for i in items if i.endswith('.gift')]
        if q:
            print(f'  - Will import GIFT quiz: {os.path.join(gen_dir,q[0])}')
            total_quizzes += 1
        else:
            print('  - No GIFT quiz found')

        # lesson
        l = [i for i in items if i.endswith('.html')]
        if l:
            print(f'  - Will upload lesson page (Page resource): {os.path.join(gen_dir,l[0])}')
            print('      * The deployer will inject the Vietnamese Tutor Agent widget snippet into the lesson HTML.')
            total_lessons += 1
        else:
            print('  - No lesson HTML found')

        # flashcards
        fcsv = [i for i in items if i.endswith('flashcards.csv')]
        if fcsv:
            print(f'  - Will upload flashcards file: {os.path.join(gen_dir,fcsv[0])}')
            total_flash += 1
        else:
            print('  - No flashcards found')

        # dialogue
        d = [i for i in items if i.endswith('dialogue.txt')]
        if d:
            print(f'  - Will attach dialogue file / link in assignment: {os.path.join(gen_dir,d[0])}')
            total_dialogue += 1
        else:
            print('  - No dialogue file found')

        # audio
        aud = [i for i in items if i.endswith('.mp3') or i.endswith('.wav')]
        if aud:
            print(f'  - Audio files present: {len(aud)} (these will be uploaded as course files)')

        print('')

    print('Summary:')
    print(f'  Lessons to upload: {total_lessons}')
    print(f'  Quizzes to import: {total_quizzes}')
    print(f'  Flashcard files: {total_flash}')
    print(f'  Dialogues to link: {total_dialogue}')

    print('\nWhen ready to perform the real deploy:')
    print('  1) Ensure you have a Moodle webservices token saved to ~/.moodle_token')
    print("  2) Run: python3 moodle_deployer.py --deploy-all --course-id 10")


if __name__ == '__main__':
    main()
