# BigBlueButton — Moodle Integration Setup

This guide summarizes the steps to integrate BigBlueButton with your Moodle course and schedule sessions.

## Prerequisites

- BigBlueButton server URL and shared secret (or hosted BBB credentials)
- Moodle BigBlueButton plugin installed (`mod_bigbluebuttonbn`)

## Site configuration

1. Go to Site administration → Plugins → Activity modules → BigBlueButtonBN.
2. Enter the BBB Server URL and shared secret.
3. Save and verify connection.

## Course setup (Course ID 2)

- Create activity → BigBlueButton Room for each session type:
  - Lectures (weekly)
  - Deep Dives (weekly)
  - Labs (per module)
  - Office Hours (daily)
  - Capstone Reviews (Module 6)
- Defaults:
  - Recording: ON, auto-publish to course page
  - Max participants: 50
  - Lock room after start (allow instructor override)
  - Closed captions: enabled (auto-transcription)

## Calendar & notifications

- Add each BBB session to the course calendar.
- Configure email reminders: 1 week, 1 day, 1 hour, 15 minutes.
- Offer iCal download for personal calendars.

## Accessibility

- Ensure captions are enabled.
- Verify keyboard navigation in the room.
- Offer high-contrast theme if needed.

## Recording & playback

- Confirm recording storage and retention.
- Transcription service (e.g., AWS Transcribe or Kaltura) if desired.
- Publish playback links in the course within 30 minutes after session end.
