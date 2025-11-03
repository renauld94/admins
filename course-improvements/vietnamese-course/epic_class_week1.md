# Epic Week 1 — Survival Vietnamese (enhanced)

This is an 'epic' lesson page designed to be pasted into a Moodle `mod/page` or used as instructor notes. It expands the Week 1 material with ASR practice, active tasks, and a clear rubric.

Learning objectives

- Greet others and introduce yourself with basic personal details.
- Ask and answer simple questions about name, nationality, and time.
- Produce a 30-second spoken self-introduction (recording) and submit a short transcript.

Key resources

- Week 1 lesson content and flashcards (see repo assets).
- ASR helper: `ASR_INTEGRATION.md` and the `asr_service` example in this folder.
- Optional external demo: https://thinhlx1993.github.io/vietnamese_asr/

Classroom flow (one 60–90 minute session)

1) Warm-up (10 min): quick flashcard SRS quiz — students review 10 words and post one sentence in the forum.
2) Listening/model (10 min): teacher plays a 45s native-speaker intro audio (hosted in course files) and asks students to identify 3 facts.
3) Pair roleplay (15 min): students practice greetings and introductions in breakout rooms (or forum if asynchronous).
4) ASR practice & submission (20 min): students record a 30s self-intro, transcribe with the thinhlx demo or the local ASR service, and submit both audio and transcript to the Assignment activity.
5) Peer feedback and reflection (15 min): each student comments on one peer's submission using the rubric.

Assessment rubric (example)

- Pronunciation (40%): Intelligibility and correct tone handling for core words.
- Fluency (30%): Smooth delivery, natural pauses, and speed.
- Accuracy (30%): Correct use of vocabulary and short grammatical forms.

Quick Moodle embed (HTML snippet for `mod/page`)

```html
<h2>Week 1 — Survival Vietnamese</h2>
<p>Record a 30-second self-introduction and submit the audio file along with a transcript.</p>
<h3>ASR helper (student)</h3>
<ol>
  <li>Use the demo: <a href="https://thinhlx1993.github.io/vietnamese_asr/" target="_blank">thinhlx Vietnamese ASR</a> to generate a transcript, or</li>
  <li>If your instructor enabled the course ASR service, use the upload form below (private to this course).</li>
</ol>
<!-- Example simple upload form that posts to your ASR service. Replace ACTION with your service URL and secure it in production. -->
<form action="https://asr.yourdomain.tld/transcribe" method="post" enctype="multipart/form-data">
  <input type="file" name="file" accept="audio/*" required />
  <input type="submit" value="Upload and transcribe" />
</form>

<h3>Rubric</h3>
<ul>
  <li>Pronunciation: 0-40</li>
  <li>Fluency: 0-30</li>
  <li>Accuracy: 0-30</li>
</ul>

<p>Teachers: grade in the Assignment activity using the rubric above. For large cohorts, consider spot-checking and using peer assessment.</p>
````

---

## Media Enhancements

### Native Speaker Audio
Listen to a native speaker introduction:

<audio controls>
  <source src="https://moodle.simondatalab.de/vietnamese-audio/common_voice_vi_42723027.mp3" type="audio/mpeg">
  Your browser does not support the audio element.
</audio>

### Pronunciation/Tone Video Guide
Watch this video for a complete guide to Vietnamese tones and pronunciation:

<iframe width="560" height="315" src="https://www.youtube.com/embed/1k7l9sQ2TzQ" title="Vietnamese Tones Guide" frameborder="0" allowfullscreen></iframe>

### Animated Tone Diagram
![Vietnamese Tone Diagram](https://upload.wikimedia.org/wikipedia/commons/6/6b/Vietnamese_tone_marks.png)

### Interactive Quiz
Try this interactive quiz to test your knowledge:

<a href="https://h5p.org/content-types-and-applications" target="_blank">Vietnamese Week 1 Quiz (H5P Example)</a>

---
