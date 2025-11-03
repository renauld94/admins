#!/usr/bin/env python3
"""
Test the Ollama Code Assistant Agent
"""
import requests
import json

BASE_URL = "http://127.0.0.1:5110"

def test_health():
    """Test health endpoint."""
    print("🔍 Testing health endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/health", timeout=5)
        print(f"✅ Health check: {response.json()}")
        return True
    except Exception as e:
        print(f"❌ Health check failed: {e}")
        return False


def test_models():
    """Test list models."""
    print("\n🔍 Testing model list...")
    try:
        response = requests.get(f"{BASE_URL}/models", timeout=10)
        data = response.json()
        if data.get("success"):
            print(f"✅ Available models:")
            for model in data.get("models", []):
                print(f"   - {model['name']} ({model['size']} bytes)")
            return True
        else:
            print(f"❌ Model list failed: {data.get('error')}")
            return False
    except Exception as e:
        print(f"❌ Model list failed: {e}")
        return False


def test_generate():
    """Test code generation."""
    print("\n🔍 Testing code generation...")
    try:
        response = requests.post(
            f"{BASE_URL}/generate",
            json={
                "prompt": "Write a function to calculate fibonacci numbers",
                "language": "python",
                "model": "deepseek-coder:6.7b"
            },
            timeout=60
        )
        data = response.json()
        if data.get("success"):
            print(f"✅ Code generated successfully!")
            print(f"Generated code preview:")
            print(data["response"][:200] + "...")
            if "saved_to" in data:
                print(f"📁 Saved to: {data['saved_to']}")
            return True
        else:
            print(f"❌ Generation failed: {data.get('error')}")
            return False
    except Exception as e:
        print(f"❌ Generation failed: {e}")
        return False


def test_review():
    """Test code review."""
    print("\n🔍 Testing code review...")
    code = """
def add(a, b):
    return a + b
"""
    try:
        response = requests.post(
            f"{BASE_URL}/review",
            json={
                "code": code,
                "language": "python"
            },
            timeout=60
        )
        data = response.json()
        if data.get("success"):
            print(f"✅ Code reviewed successfully!")
            print(f"Review preview:")
            print(data["response"][:200] + "...")
            return True
        else:
            print(f"❌ Review failed: {data.get('error')}")
            return False
    except Exception as e:
        print(f"❌ Review failed: {e}")
        return False


def test_explain():
    """Test code explanation."""
    print("\n🔍 Testing code explanation...")
    code = """
def factorial(n):
    if n <= 1:
        return 1
    return n * factorial(n - 1)
"""
    try:
        response = requests.post(
            f"{BASE_URL}/explain",
            json={
                "code": code,
                "language": "python"
            },
            timeout=60
        )
        data = response.json()
        if data.get("success"):
            print(f"✅ Code explained successfully!")
            print(f"Explanation preview:")
            print(data["response"][:200] + "...")
            return True
        else:
            print(f"❌ Explanation failed: {data.get('error')}")
            return False
    except Exception as e:
        print(f"❌ Explanation failed: {e}")
        return False


if __name__ == "__main__":
    print("=" * 60)
    print("🤖 Ollama Code Assistant Agent Test Suite")
    print("=" * 60)
    
    results = []
    
    # Run tests
    results.append(("Health Check", test_health()))
    results.append(("List Models", test_models()))
    results.append(("Generate Code", test_generate()))
    results.append(("Review Code", test_review()))
    results.append(("Explain Code", test_explain()))
    
    # Summary
    print("\n" + "=" * 60)
    print("📊 Test Summary")
    print("=" * 60)
    for name, passed in results:
        status = "✅ PASS" if passed else "❌ FAIL"
        print(f"{status} - {name}")
    
    total = len(results)
    passed = sum(1 for _, p in results if p)
    print(f"\nTotal: {passed}/{total} tests passed")
    print("=" * 60)
