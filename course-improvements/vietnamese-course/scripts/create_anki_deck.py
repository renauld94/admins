import csv
import genanki
import sys

import os
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CSV_PATH = os.path.join(ROOT, 'generated', 'flashcards_generated.csv')
OUT_PATH = os.path.join(ROOT, 'generated', 'vietnamese_week1_flashcards.apkg')

model = genanki.Model(
  1607392319,
  'Simple Model',
  fields=[
    {'name': 'Question'},
    {'name': 'Answer'},
  ],
  templates=[
    {
      'name': 'Card 1',
      'qfmt': '{{Question}}',
      'afmt': '{{FrontSide}}<hr id="answer">{{Answer}}',
    },
  ])

deck = genanki.Deck(
  2059400110,
  'Vietnamese Week1 Flashcards')

try:
    with open(CSV_PATH, newline='', encoding='utf-8') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            q = row.get('Front','').strip()
            a = row.get('Back','').strip()
            if not q or not a:
                continue
            note = genanki.Note(model=model, fields=[q,a])
            deck.add_note(note)
    genanki.Package(deck).write_to_file(OUT_PATH)
    print('WROTE', OUT_PATH)
except Exception as e:
    print('ERROR', e)
    sys.exit(2)
