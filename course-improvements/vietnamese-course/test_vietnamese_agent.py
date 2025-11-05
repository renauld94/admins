#!/usr/bin/env python3
"""
Test script for Vietnamese Tutor Agent

Tests all major features:
- Health check
- Grammar checking
- Vocabulary practice
- Dialogue generation
- Translation
- Quiz generation
- Flashcard generation
- Personalized study sessions
"""
import requests
import json
import sys
import os
from typing import Dict, Any

BASE_URL = "http://localhost:5001"

# Read auth token from workspace
TOKEN_FILE = os.path.join(os.path.dirname(__file__), '..', '..', 'workspace', 'agents', '.token')
AUTH_TOKEN = None
try:
    with open(TOKEN_FILE, 'r') as f:
        AUTH_TOKEN = f.read().strip()
except:
    pass

def get_headers() -> dict:
    """Get headers with authorization if token exists."""
    headers = {"Content-Type": "application/json"}
    if AUTH_TOKEN:
        headers["Authorization"] = f"Bearer {AUTH_TOKEN}"
    return headers


def print_section(title: str):
    """Print section header."""
    print("\n" + "=" * 70)
    print(f"  {title}")
    print("=" * 70)


def test_health() -> bool:
    """Test health endpoint."""
    print_section("Health Check")
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=5)
        data = response.json()
        
        print(f"Status: {data.get('status')}")
        print(f"Agent: {data.get('agent')}")
        print(f"Ollama: {data.get('ollama_status')}")
        print(f"ASR: {data.get('asr_status')}")
        print(f"Models: {json.dumps(data.get('models', {}), indent=2)}")
        
        return data.get('status') == 'ok'
    except Exception as e:
        print(f"❌ Health check failed: {e}")
        return False


def test_grammar_check() -> bool:
    """Test grammar checking."""
    print_section("Grammar Check Test")
    
    test_cases = [
        {
            "text": "Tôi đi chợ hôm qua",
            "level": "intermediate",
            "description": "Correct grammar (past tense)"
        },
        {
            "text": "Tôi tên là John và tôi đến từ Mỹ",
            "level": "beginner",
            "description": "Introduction (correct)"
        }
    ]
    
    for i, test in enumerate(test_cases, 1):
        print(f"\n[Test {i}] {test['description']}")
        print(f"Text: \"{test['text']}\"")
        print(f"Level: {test['level']}")
        
        try:
            response = requests.post(
                f"{BASE_URL}/grammar/check",
                json={"text": test["text"], "level": test["level"]},
                headers=get_headers(), timeout=180
            )
            
            if response.status_code == 200:
                data = response.json()
                if data.get("success"):
                    print("✅ Grammar check completed")
                    print("\nFeedback:")
                    print(data.get("response", "")[:500])  # First 500 chars
                    if len(data.get("response", "")) > 500:
                        print("... (truncated)")
                else:
                    print(f"❌ Error: {data.get('error')}")
                    return False
            else:
                print(f"❌ Request failed: {response.status_code}")
                return False
        except Exception as e:
            print(f"❌ Exception: {e}")
            return False
    
    return True


def test_vocabulary_practice() -> bool:
    """Test vocabulary practice generation."""
    print_section("Vocabulary Practice Test")
    
    words = ["xin chào", "cảm ơn", "tạm biệt"]
    print(f"Testing words: {', '.join(words)}")
    
    try:
        response = requests.post(
            f"{BASE_URL}/vocabulary/practice",
            json={
                "words": words,
                "include_examples": True,
                "include_tones": True
            },
            headers=get_headers(), timeout=180
        )
        
        if response.status_code == 200:
            data = response.json()
            if data.get("success"):
                print("✅ Vocabulary practice generated")
                print("\nSample output:")
                print(data.get("response", "")[:600])
                if len(data.get("response", "")) > 600:
                    print("... (truncated)")
                return True
            else:
                print(f"❌ Error: {data.get('error')}")
                return False
        else:
            print(f"❌ Request failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Exception: {e}")
        return False


def test_dialogue_generation() -> bool:
    """Test dialogue generation."""
    print_section("Dialogue Generation Test")
    
    print("Topic: ordering food at a restaurant")
    print("Level: beginner")
    print("Exchanges: 4")
    
    try:
        response = requests.post(
            f"{BASE_URL}/dialogue/generate",
            json={
                "topic": "ordering food at a restaurant",
                "level": "beginner",
                "num_exchanges": 4
            },
            headers=get_headers(), timeout=180
        )
        
        if response.status_code == 200:
            data = response.json()
            if data.get("success"):
                print("✅ Dialogue generated")
                print("\nSample output:")
                print(data.get("response", "")[:700])
                if len(data.get("response", "")) > 700:
                    print("... (truncated)")
                return True
            else:
                print(f"❌ Error: {data.get('error')}")
                return False
        else:
            print(f"❌ Request failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Exception: {e}")
        return False


def test_translation() -> bool:
    """Test translation with explanation."""
    print_section("Translation Test")
    
    print("Text: 'I would like to order coffee'")
    print("Source: English -> Target: Vietnamese")
    
    try:
        response = requests.post(
            f"{BASE_URL}/translate",
            json={
                "text": "I would like to order coffee",
                "source_lang": "en",
                "target_lang": "vi",
                "include_explanation": True
            },
            headers=get_headers(), timeout=180
        )
        
        if response.status_code == 200:
            data = response.json()
            if data.get("success"):
                print("✅ Translation completed")
                print("\nResult:")
                print(data.get("response", "")[:500])
                if len(data.get("response", "")) > 500:
                    print("... (truncated)")
                return True
            else:
                print(f"❌ Error: {data.get('error')}")
                return False
        else:
            print(f"❌ Request failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Exception: {e}")
        return False


def test_quiz_generation() -> bool:
    """Test quiz generation."""
    print_section("Quiz Generation Test (GIFT Format)")
    
    print("Topic: greetings")
    print("Level: beginner")
    print("Questions: 5")
    
    try:
        response = requests.post(
            f"{BASE_URL}/quiz/generate",
            json={
                "topic": "greetings",
                "level": "beginner",
                "num_questions": 5,
                "question_types": ["multiple_choice", "fill_blank"]
            },
            headers=get_headers(), timeout=180
        )
        
        if response.status_code == 200:
            data = response.json()
            if data.get("success"):
                print("✅ Quiz generated")
                if "gift_file" in data:
                    print(f"GIFT file saved: {data['gift_file']}")
                print("\nSample output:")
                print(data.get("response", "")[:500])
                if len(data.get("response", "")) > 500:
                    print("... (truncated)")
                return True
            else:
                print(f"❌ Error: {data.get('error')}")
                return False
        else:
            print(f"❌ Request failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Exception: {e}")
        return False


def test_flashcard_generation() -> bool:
    """Test flashcard generation."""
    print_section("Flashcard Generation Test (CSV)")
    
    words = ["xin chào", "cảm ơn"]
    print(f"Words: {', '.join(words)}")
    
    try:
        response = requests.post(
            f"{BASE_URL}/flashcards/generate",
            json={
                "vocabulary_list": words,
                "include_audio_prompts": True
            },
            headers=get_headers(), timeout=180
        )
        
        if response.status_code == 200:
            data = response.json()
            if data.get("success"):
                print("✅ Flashcards generated")
                if "csv_file" in data:
                    print(f"CSV file saved: {data['csv_file']}")
                print("\nSample output:")
                print(data.get("response", "")[:400])
                if len(data.get("response", "")) > 400:
                    print("... (truncated)")
                return True
            else:
                print(f"❌ Error: {data.get('error')}")
                return False
        else:
            print(f"❌ Request failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Exception: {e}")
        return False


def test_personalized_session() -> bool:
    """Test personalized study session generation."""
    print_section("Personalized Study Session Test")
    
    print("Level: intermediate")
    print("Focus: pronunciation, vocabulary")
    print("Duration: 20 minutes")
    
    try:
        response = requests.post(
            f"{BASE_URL}/study-session/personalized",
            json={
                "level": "intermediate",
                "focus_areas": ["pronunciation", "vocabulary"],
                "duration_minutes": 20
            },
            timeout=120
        )
        
        if response.status_code == 200:
            data = response.json()
            if data.get("success"):
                print("✅ Study session generated")
                if "session_file" in data:
                    print(f"Session file saved: {data['session_file']}")
                print("\nSample output:")
                print(data.get("response", "")[:500])
                if len(data.get("response", "")) > 500:
                    print("... (truncated)")
                return True
            else:
                print(f"❌ Error: {data.get('error')}")
                return False
        else:
            print(f"❌ Request failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Exception: {e}")
        return False


def main():
    """Run all tests."""
    print("\n" + "=" * 70)
    print("  VIETNAMESE TUTOR AGENT - TEST SUITE")
    print("=" * 70)
    print(f"Target: {BASE_URL}")
    print("=" * 70)
    
    results = {}
    
    # Run tests
    results["Health Check"] = test_health()
    
    if not results["Health Check"]:
        print("\n❌ Agent is not healthy. Stopping tests.")
        print("\nTo start the agent:")
        print("  sudo systemctl start vietnamese-tutor-agent")
        print("  sudo journalctl -u vietnamese-tutor-agent -f")
        sys.exit(1)
    
    results["Grammar Check"] = test_grammar_check()
    results["Vocabulary Practice"] = test_vocabulary_practice()
    results["Dialogue Generation"] = test_dialogue_generation()
    results["Translation"] = test_translation()
    results["Quiz Generation"] = test_quiz_generation()
    results["Flashcard Generation"] = test_flashcard_generation()
    results["Personalized Session"] = test_personalized_session()
    
    # Summary
    print("\n" + "=" * 70)
    print("  TEST SUMMARY")
    print("=" * 70)
    
    passed = sum(1 for r in results.values() if r)
    total = len(results)
    
    for test_name, result in results.items():
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{status} - {test_name}")
    
    print("=" * 70)
    print(f"Results: {passed}/{total} tests passed")
    print("=" * 70)
    
    if passed == total:
        print("\n🎉 All tests passed! Vietnamese Tutor Agent is EPIC!")
        sys.exit(0)
    else:
        print(f"\n⚠️  {total - passed} test(s) failed. Check logs for details.")
        sys.exit(1)


if __name__ == "__main__":
    main()
