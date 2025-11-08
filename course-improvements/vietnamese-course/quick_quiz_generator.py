#!/usr/bin/env python3
"""
Fast Quiz Generator for Vietnamese Course
Generates GIFT-format quiz files directly without needing Ollama
"""
import json
from pathlib import Path
from datetime import datetime

SCRIPT_DIR = Path(__file__).parent
GENERATED = SCRIPT_DIR / 'generated' / 'professional'

# Template quiz questions for each week
WEEK_QUIZZES = {
    1: {
        'title': 'Week 1: Greetings & Introductions',
        'questions': [
            {
                'text': 'How do you say "Hello" in Vietnamese?',
                'answers': [
                    ('Xin chào', True),
                    ('Cảm ơn', False),
                    ('Tạm biệt', False),
                    ('Bạn khỏe không?', False),
                ]
            },
            {
                'text': 'What is the Vietnamese phrase for "Thank you"?',
                'answers': [
                    ('Cảm ơn', True),
                    ('Xin chào', False),
                    ('Tạm biệt', False),
                    ('Vâng', False),
                ]
            },
            {
                'text': 'Which greeting is used when saying goodbye?',
                'answers': [
                    ('Tạm biệt', True),
                    ('Xin chào', False),
                    ('Cảm ơn bạn', False),
                    ('Đồng ý', False),
                ]
            },
        ]
    },
    2: {
        'title': 'Week 2: Numbers & Time',
        'questions': [
            {
                'text': 'How do you count to three in Vietnamese?',
                'answers': [
                    ('Một, hai, ba', True),
                    ('Một, hai, bốn', False),
                    ('Hai, ba, bốn', False),
                    ('Ba, bốn, năm', False),
                ]
            },
            {
                'text': 'What time is "12:00 PM" called?',
                'answers': [
                    ('Trưa', True),
                    ('Sáng', False),
                    ('Tối', False),
                    ('Đêm', False),
                ]
            },
        ]
    },
    3: {
        'title': 'Week 3: Family & Relationships',
        'questions': [
            {
                'text': 'What is "mother" in Vietnamese?',
                'answers': [
                    ('Mẹ', True),
                    ('Bố', False),
                    ('Em gái', False),
                    ('Anh trai', False),
                ]
            },
        ]
    },
    4: {
        'title': 'Week 4: Food & Dining',
        'questions': [
            {
                'text': 'What is the Vietnamese word for "rice"?',
                'answers': [
                    ('Cơm', True),
                    ('Bánh', False),
                    ('Nước', False),
                    ('Thịt', False),
                ]
            },
        ]
    },
    5: {
        'title': 'Week 5: Shopping & Commerce',
        'questions': [
            {
                'text': 'How much does this cost?',
                'answers': [
                    ('Cái này bao nhiêu tiền?', True),
                    ('Cảm ơn bạn', False),
                    ('Tạm biệt', False),
                    ('Xin chào', False),
                ]
            },
        ]
    },
    6: {
        'title': 'Week 6: Travel & Direction',
        'questions': [
            {
                'text': 'What means "Where is the bathroom?"?',
                'answers': [
                    ('Nhà vệ sinh ở đâu?', True),
                    ('Khách sạn ở đâu?', False),
                    ('Ga tàu ở đâu?', False),
                    ('Sân bay ở đâu?', False),
                ]
            },
        ]
    },
    7: {
        'title': 'Week 7: Work & Career',
        'questions': [
            {
                'text': 'What is "job" or "work" in Vietnamese?',
                'answers': [
                    ('Công việc', True),
                    ('Trường học', False),
                    ('Bệnh viện', False),
                    ('Cửa hàng', False),
                ]
            },
        ]
    },
    8: {
        'title': 'Week 8: Comprehensive Review',
        'questions': [
            {
                'text': 'Complete the phrase: "Xin chào, tôi tên là ___"',
                'answers': [
                    ('tên của bạn (your name)', True),
                    ('Cảm ơn', False),
                    ('Tạm biệt', False),
                    ('Khỏe', False),
                ]
            },
        ]
    },
}

def generate_gift_question(q_text, answers):
    """Generate GIFT format question"""
    lines = [f"::{q_text}::"]
    for ans_text, is_correct in answers:
        prefix = '=' if is_correct else '~'
        lines.append(f"{prefix}{ans_text}")
    lines.append('')  # blank line after question
    return '\n'.join(lines)

def generate_quiz_files():
    """Generate GIFT quiz files for all weeks"""
    GENERATED.mkdir(parents=True, exist_ok=True)
    
    for week, quiz_data in WEEK_QUIZZES.items():
        filename = GENERATED / f'week{week}_quiz.gift'
        
        # Build GIFT content
        gift_lines = [
            f"// Generated: {datetime.now().isoformat()}",
            f"// {quiz_data['title']}",
            f"// Vietnamese Course - Week {week}",
            "",
        ]
        
        for q in quiz_data['questions']:
            gift_lines.append(generate_gift_question(q['text'], q['answers']))
        
        content = '\n'.join(gift_lines)
        filename.write_text(content)
        print(f"✓ Generated {filename.name} ({len(quiz_data['questions'])} questions)")
    
    print(f"\nAll quizzes generated in {GENERATED}")

if __name__ == '__main__':
    generate_quiz_files()
