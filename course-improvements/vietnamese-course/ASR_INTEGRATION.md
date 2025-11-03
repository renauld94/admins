```markdown
# ASR integration for the Vietnamese course

This short guide explains practical, low-risk ways to add Automatic Speech Recognition (ASR) practice and instructor workflows to the Week 1 materials.

Links

- thinhlx demo (quick student-facing demo): https://thinhlx1993.github.io/vietnamese_asr/

Goals / contract

- Input: student audio (wav/mp3) recorded on phone or desktop.
- Output: short transcript + confidence/word timestamps (if available) to support teacher feedback.
- Error modes: noisy audio, very short clips, unsupported formats.

Two recommended approaches (quick to adopt):

1) Student-facing, no server changes (manual):
   - Ask students to visit the thinhlx demo link above and record audio there.
   - Student copies/pastes the transcript into the Moodle assignment/forum post, or uploads audio to the assignment and includes a short reflection.
   - Pros: zero server work. Cons: depends on third-party demo availability and privacy considerations.

2) Local (recommended for production): local Whisper/VOSK service or containerized ASR
   - Run a simple local transcription service (Whisper) and give students a short script to transcribe before uploading, or integrate a small web tool to upload and transcribe on the server.

Quick starter: Python Whisper transcription (local)

Requirements (example):

- Python 3.10+
- pip install -U "whisper"  # or `pip install -U openai-whisper` depending on your preferred package

Example script (transcribe.py):

```python
import sys
import whisper

model = whisper.load_model('small')
audio_path = sys.argv[1]
result = model.transcribe(audio_path)
print(result['text'])
```

Usage:

```bash
python3 transcribe.py path/to/student_audio.wav
```

Notes:

- For production and better accuracy you can use `whisperx` for word-timestamps and forced-alignment.
- If you prefer a lightweight on-device approach use `vosk` with a Vietnamese model.

Moodle integration options

- Simple: ask students to upload their audio to an Assignment activity and paste the transcript into the submission text.
- Advanced: create a small web service (Flask/FastAPI) that accepts uploads, runs Whisper, and returns a JSON transcript. Protect it behind Moodle login or add it as an External tool/LTI.

Operational checklist for admins

1. Decide: third-party demo (thinhlx) vs local ASR.
2. If local: prepare a VM/container with enough CPU/RAM (and optional GPU) and the transcription service.
3. Add docs for teachers: how to grade, rubric examples (pronunciation / fluency / accuracy), example transcripts.
4. Privacy: inform students if audio is sent to an external demo. Prefer local service for sensitive classes.

Next steps I can do for you (pick one):

- Create a minimal Flask/FastAPI transcription endpoint + example upload page and a Moodle-ready embed snippet.
- Produce a teacher-facing rubric and a sample marking script to accept transcriptions and compute a simple score.
- Generate the full lesson transcripts and sample student answers for Week 1.

``` 
