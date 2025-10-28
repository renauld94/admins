# Digital Unicorn / ICON PLC / AMD — Evidence Resume

Date: 2025-10-22

This is a concise, human-readable resume of the evidence bundle, analysis results, and recommended next steps. Open this file in VS Code for a quick briefing.

## Top-level summary
- Evidence bundle: `/tmp/du_evidence_dashboard.zip` (contains all extracted files, dashboard, and analysis)
- Extracted events: ` /tmp/du_events.json` — 986 events (raw export)
- Conversation analysis summary: `deploy/du_conversations_analysis.json`
- Conversation timeline CSV: `deploy/du_conversations_timeline.csv`
- Chat HTML analysis: `deploy/du_chat_html_analysis.json` (structure present, message bodies not present in the exported HTML)

## Key findings (automated)
- Total events extracted: **986** (all from `conversations.json`).
- Participant identity: all events currently show `from` empty in the extractor output (labeled `unknown`). This suggests either anonymized exports or different field names in the source JSON; see "Field mapping" below.
- Timestamps and per-day counts were not normalized in the first pass (many events lacked ISO timestamps in the extractor's expected fields).
- `chat.html` contained layout and structure, but the exported HTML provided no message text in the parsed nodes (0 messages found by the simple parser).

## Notable artifacts and where to find them
- Legal advisory (machine-generated): `workspace/agents/context/legal-advisor/advice_1761091311.json`
- Timeline dashboard (private): `deploy/du_timeline_dashboard.html` — open in a browser next to `deploy/du_events.json` or copy `/tmp/du_events.json` into the same directory.
- Extracted events: `/tmp/du_events.json` (49M, 986 events)
- Analysis outputs:
  - `deploy/du_conversations_analysis.json` (summary)
  - `deploy/du_conversations_timeline.csv` (timeline rows)
  - `deploy/du_chat_html_analysis.json` and `deploy/du_chat_html_summary.txt` (chat.html parsing results)
- Proxy and remediation files:
  - `deploy/cf_service_token_proxy.py` (proxy server)
  - `~/.config/cf_proxy/env` (holds CF_CLIENT_ID / CF_CLIENT_SECRET, permission 600)
  - `deploy/cf_proxy_healthcheck.sh` and `/tmp/cf_proxy_healthcheck_output.txt` (healthcheck)
  - `deploy/cloudflare_access_remediation.md` (notes for Cloudflare admin)

## How to view the timeline dashboard (private, offline)
1. Copy `/tmp/du_events.json` into the `deploy/` folder (or open the HTML and point it at the file):

```bash
cp /tmp/du_events.json deploy/du_events.json
# then open the file
xdg-open deploy/du_timeline_dashboard.html
```

2. The HTML loads `du_events.json` and will render events chronologically. Do not publish this file — it contains confidential communications.

## Field mapping & next technical step (recommended)
- The extractor currently maps `message`, `from`, and `timestamp`. The raw events show empty `from` fields. Next step: print 10 raw events so we can determine the correct keys (for example `author`, `user`, `sender`, or nested objects). After mapping, re-run the analyzer to populate participant and daily counts and extract keywords.

If you want me to proceed automatically, I'll:
1. Print 10 raw events and pick the correct keys.
2. Re-run the analysis to produce an enriched `deploy/du_conversations_analysis.json` (with participants and events_per_day) and update the CSV timeline.

## Cloudflare Access (access issue and short-term fix)
- Symptom: `403 Forbidden` from Cloudflare Access when requests are unauthenticated.
- Short-term: local header-injecting proxy (`cf_service_token_proxy.py`) injects Cloudflare service-token pair and receives `CF_Authorization` cookie. Healthcheck shows: `CF_Authorization cookie present`.
- Medium/long-term: whitelist proxy IP in Cloudflare or update Access policy to accept the service-token AUD, and implement secret rotation & secrets manager.
- See: `deploy/cloudflare_access_remediation.md` for exact steps to share with the Cloudflare admin.

## Actionables (pick one)
- [ ] Run the automatic field-mapping & re-run the analyzer (recommended). I will auto-detect author/timestamp fields and rebuild the participant timelines.
- [ ] Produce a party-centric timeline (filter events for keywords: "Digital Unicorn", "ICON PLC", "AMD") and a short human-oriented chronology of disputes, escalations, and dates.
- [ ] Draft an email to your Cloudflare admin with the diagnostics and exact policy changes required (I can pre-fill it).

## Privacy & Handling
- The evidence includes confidential communications and client data. Keep `/tmp/du_evidence_dashboard.zip` and `deploy/du_timeline_dashboard.html` local to the machine and do not publish or share without redaction.

---

If you want the field-mapping step, say "Map fields and analyze" and I'll run it now and update the JSON/CSV and this resume with the enriched results.