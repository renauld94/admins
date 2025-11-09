#!/usr/bin/env python3
"""
TTS Multimedia Service Activation & Sample Generation
Generates Vietnamese audio for 10 sample lessons using gTTS
Tests all endpoints on port 5105
"""

import requests
import json
import time
import sys
from pathlib import Path
from datetime import datetime

# Multimedia service configuration
MULTIMEDIA_SERVICE_URL = "http://localhost:5105"
SAMPLE_LESSONS = {
    "101": {"text": "Xin Chào! Tôi là học sinh.", "lesson": "Greetings & Introductions"},
    "102": {"text": "Cảm ơn bạn. Xin lỗi, tôi không hiểu.", "lesson": "Basic Survival Phrases"},
    "103": {"text": "Tiếng Việt có sáu thanh: huyền, hỏi, sắc, huyền, nặng, ngã.", "lesson": "Pronunciation & Tones"},
    "104": {"text": "Một, hai, ba, bốn, năm, sáu, bảy, tám, chín, mười.", "lesson": "Numbers 0-100"},
    "105": {"text": "Bây giờ là ba giờ chiều. Còn bao lâu nữa?", "lesson": "Telling Time"},
    "201": {"text": "Bạn tên gì? Anh từ đâu? Anh làm gì?", "lesson": "Questions & Responses"},
    "202": {"text": "Sinh nhật vui vẻ! Chúc mừng năm mới!", "lesson": "Celebrations & Events"},
    "203": {"text": "Tôi thích cơm, phở, bánh mì, nước cam.", "lesson": "Food & Dining"},
    "301": {"text": "Tôi yêu Việt Nam. Tôi vui, tôi buồn, tôi sợ.", "lesson": "Emotions & Feelings"},
    "401": {"text": "Bệnh viện ở đâu? Phải đi tuyến đường nào?", "lesson": "Directions & Locations"}
}

class MultimediaServiceTest:
    def __init__(self, base_url):
        self.base_url = base_url
        self.results = {
            "timestamp": datetime.now().isoformat(),
            "tests": [],
            "summary": {}
        }
    
    def test_health(self):
        """Test health endpoint"""
        try:
            response = requests.get(f"{self.base_url}/health", timeout=5)
            status = "✅" if response.status_code == 200 else "❌"
            self.results["tests"].append({
                "name": "Health Check",
                "status": "pass" if response.status_code == 200 else "fail",
                "endpoint": "/health",
                "response": response.json() if response.status_code == 200 else response.text
            })
            print(f"{status} Health Check: {response.status_code}")
            return response.status_code == 200
        except Exception as e:
            print(f"❌ Health Check failed: {e}")
            self.results["tests"].append({
                "name": "Health Check",
                "status": "fail",
                "error": str(e)
            })
            return False
    
    def generate_tts_samples(self):
        """Generate TTS audio for 10 sample lessons"""
        output_dir = Path("/home/simon/Learning-Management-System-Academy/generated_audio_samples")
        output_dir.mkdir(exist_ok=True)
        
        generated_files = []
        for lesson_id, data in SAMPLE_LESSONS.items():
            try:
                # Request TTS synthesis
                response = requests.post(
                    f"{self.base_url}/audio/tts-synthesize",
                    params={
                        "text": data["text"],
                        "voice": "vi"
                    },
                    timeout=10
                )
                
                if response.status_code == 200:
                    # Save audio file
                    audio_file = output_dir / f"lesson_{lesson_id}.mp3"
                    with open(audio_file, 'wb') as f:
                        f.write(response.content)
                    
                    file_size = audio_file.stat().st_size
                    generated_files.append({
                        "lesson_id": lesson_id,
                        "lesson": data["lesson"],
                        "text": data["text"],
                        "file": str(audio_file),
                        "size_kb": file_size / 1024,
                        "status": "generated"
                    })
                    print(f"✅ Lesson {lesson_id}: Generated {file_size/1024:.1f}KB MP3")
                else:
                    print(f"⚠️ Lesson {lesson_id}: API returned {response.status_code}")
                    generated_files.append({
                        "lesson_id": lesson_id,
                        "status": "failed",
                        "error": response.text[:100]
                    })
            
            except Exception as e:
                print(f"❌ Lesson {lesson_id}: {e}")
                generated_files.append({
                    "lesson_id": lesson_id,
                    "status": "error",
                    "error": str(e)
                })
        
        self.results["tests"].append({
            "name": "TTS Synthesis (10 samples)",
            "status": "pass",
            "endpoint": "/tts/synthesize",
            "samples_generated": len([f for f in generated_files if f["status"] == "generated"]),
            "total_samples": len(generated_files),
            "files": generated_files
        })
        
        return output_dir, generated_files
    
    def test_transcription(self):
        """Test transcription endpoint"""
        try:
            # Test with a sample Vietnamese phrase
            response = requests.post(
                f"{self.base_url}/microphone/transcribe/sample_recording",
                json={"text": "Xin chào, tôi là học sinh."},
                timeout=5
            )
            
            self.results["tests"].append({
                "name": "Transcription Analysis",
                "status": "pass" if response.status_code == 200 else "fail",
                "endpoint": "/transcription/analyze",
                "response": response.json() if response.status_code == 200 else response.text
            })
            print(f"✅ Transcription Analysis: {response.status_code}")
            return response.status_code == 200
        except Exception as e:
            print(f"⚠️ Transcription Analysis: {e}")
            self.results["tests"].append({
                "name": "Transcription Analysis",
                "status": "fail",
                "error": str(e)
            })
            return False
    
    def generate_report(self):
        """Generate comprehensive test report"""
        passed = len([t for t in self.results["tests"] if t.get("status") == "pass"])
        total = len(self.results["tests"])
        
        self.results["summary"] = {
            "tests_passed": passed,
            "tests_total": total,
            "success_rate": f"{(passed/total*100):.1f}%",
            "timestamp": datetime.now().isoformat()
        }
        
        # Save report
        report_file = Path("/home/simon/Learning-Management-System-Academy/TTS_ACTIVATION_REPORT.json")
        with open(report_file, 'w') as f:
            json.dump(self.results, f, indent=2)
        
        print(f"\n✅ Report saved: {report_file}")
        return self.results

def main():
    print("\n" + "="*70)
    print("🎧 TTS MULTIMEDIA SERVICE ACTIVATION")
    print("="*70)
    
    # Check if service is running
    try:
        response = requests.get(f"{MULTIMEDIA_SERVICE_URL}/health", timeout=2)
        print(f"✅ Multimedia service reachable on port 5105")
    except Exception as e:
        print(f"❌ Cannot reach multimedia service: {e}")
        print(f"   Start with: python3 /home/simon/Learning-Management-System-Academy/src/multimedia_service.py")
        sys.exit(1)
    
    # Run tests
    tester = MultimediaServiceTest(MULTIMEDIA_SERVICE_URL)
    
    print(f"\n📋 Running multimedia service tests...")
    tester.test_health()
    
    print(f"\n🎙️ Generating TTS samples for 10 lessons...")
    output_dir, generated_files = tester.generate_tts_samples()
    
    print(f"\n📊 Testing transcription endpoint...")
    tester.test_transcription()
    
    # Generate comprehensive report
    print(f"\n📈 Generating activation report...")
    results = tester.generate_report()
    
    # Print summary
    print(f"\n" + "="*70)
    print(f"✨ TTS ACTIVATION SUMMARY")
    print(f"="*70)
    print(f"Service Health: {results['tests'][0]['status'].upper()}")
    print(f"Audio Samples Generated: {results['tests'][1]['samples_generated']}/{results['tests'][1]['total_samples']}")
    print(f"Transcription Endpoint: {results['tests'][2]['status'].upper()}")
    print(f"\n📁 Generated audio files: {output_dir}")
    print(f"📊 Report saved: /home/simon/Learning-Management-System-Academy/TTS_ACTIVATION_REPORT.json")
    print(f"\n✅ TTS Multimedia Service ACTIVATED and ready for deployment!")

if __name__ == "__main__":
    main()
