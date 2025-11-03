Overview

This folder contains a concise course review and a set of ready-to-use assets to level-up the Vietnamese class (Moodle course id=10).

Contents

- lesson_plan.md — a week-by-week plan, activities, learning objectives, and assessment ideas to make the course "epic".
- quiz_topic1.gift — a sample GIFT-format quiz file (multiple-choice, short answer, matching) you can import directly into Moodle's Question bank.
- ai_prompts.txt — curated prompts to run on your local models at `https://ollama.simondatalab.de` or `https://openwebui.simondatalab.de` to generate dialogues, flashcards, translations, audio scripts, and images.
 - ASR_INTEGRATION.md — guidance and starter scripts to add Automatic Speech Recognition (ASR) practice to the course (local Whisper, thinhlx demo, Moodle integration notes).

How to use

1. Review the lesson_plan.md and adapt the objectives to your students.
2. Import `quiz_topic1.gift` into Moodle: Site administration -> Question bank -> Import -> GIFT format.
3. Use the prompts in `ai_prompts.txt` with your local LLMs (Ollama/OpenWebUI) to generate expanded content. Example (Ollama CLI):

   ollama generate -m <model> "<prompt>"

4. For interactive/video/audio materials, feed the LLM outputs to your favourite TTS/recording pipeline and upload the result to the course (or host on your server and embed).

If you want I can:
- Generate the full course content (all lessons) via your Ollama/OpenWebUI endpoints given a preferred model.
- Produce SCORM packages or bulk GIFT files for the whole course ready for import.
- Create nginx/snippets and Moodle mod_pages and activity scaffolding using Moodle webservice API (requires API token).

Tell me which of the above you'd like me to do next (generate all lessons; produce SCORM; create bulk quiz bank; or prepare upload scripts).