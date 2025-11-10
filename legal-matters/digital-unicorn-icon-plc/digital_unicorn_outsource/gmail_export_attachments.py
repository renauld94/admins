#!/usr/bin/env python3
# gmail_export_attachments.py
import os, io, sys, time, csv, hashlib
from pathlib import Path
from base64 import urlsafe_b64decode
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# Scopes: Gmail readonly + Drive/file metadata if uploading
SCOPES = [
    "https://www.googleapis.com/auth/gmail.readonly",
    "https://www.googleapis.com/auth/drive.file"  # required only for Drive upload
]

# Query: messages to search
QUERY = '("digital unicorn" OR "icon PLC")'

def sha256_of_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(8192), b""):
            h.update(chunk)
    return h.hexdigest()

def authenticate():
    creds = None
    token_path = Path("token.json")
    if token_path.exists():
        creds = Credentials.from_authorized_user_file(token_path, SCOPES)
    if not creds or not creds.valid:
        flow = InstalledAppFlow.from_client_secrets_file("credentials.json", SCOPES)
        creds = flow.run_local_server(port=0)
        with open(token_path, "w") as f:
            f.write(creds.to_json())
    return creds

def main():
    creds = authenticate()
    gmail = build("gmail", "v1", credentials=creds)

    ts = time.strftime("%Y%m%dT%H%M%SZ", time.gmtime())
    base = Path(f"/home/simon/evidence/gmail_export_{ts}")
    attachments_dir = base / "attachments"
    base.mkdir(parents=True, exist_ok=True)
    attachments_dir.mkdir(parents=True, exist_ok=True)

    index_file = base / "gmail_attachments_index.csv"
    manifest_file = base / "manifest.sha256"

    print("Searching Gmail for:", QUERY)
    try:
        results = gmail.users().messages().list(userId="me", q=QUERY, maxResults=500).execute()
    except HttpError as e:
        print("Gmail API error:", e)
        sys.exit(1)

    messages = results.get("messages", []) or []
    print(f"Found {len(messages)} messages (first page).")

    # If paginated, follow nextPageToken
    page_token = results.get("nextPageToken")
    while page_token:
        res = gmail.users().messages().list(userId="me", q=QUERY, pageToken=page_token, maxResults=500).execute()
        messages.extend(res.get("messages", []) or [])
        page_token = res.get("nextPageToken")

    print("Total messages found:", len(messages))

    rows = []
    checks = []

    for i, m in enumerate(messages, 1):
        mid = m["id"]
        msg = gmail.users().messages().get(userId="me", id=mid, format="full").execute()
        headers = {h["name"].lower(): h["value"] for h in msg.get("payload", {}).get("headers", [])}
        subject = headers.get("subject", "")
        sender = headers.get("from", "")
        date = headers.get("date", "")
        parts = msg.get("payload", {}).get("parts", []) or []
        # walk parts recursively
        def walk_parts(p):
            if p.get("parts"):
                for sub in p["parts"]:
                    yield from walk_parts(sub)
            else:
                yield p
        for part in walk_parts(msg.get("payload", {})):
            filename = part.get("filename")
            body = part.get("body", {})
            mime = part.get("mimeType")
            if filename:
                # only take PDFs and Excel files
                fn_lower = filename.lower()
                keep = False
                if fn_lower.endswith(".pdf") or mime == "application/pdf":
                    keep = True
                if fn_lower.endswith(".xls") or fn_lower.endswith(".xlsx") or \
                   mime.startswith("application/vnd.openxmlformats-officedocument.spreadsheet") or \
                   mime.startswith("application/vnd.ms-excel"):
                    keep = True
                if not keep:
                    # skip other filetypes
                    continue
                # fetch attachment content
                attach_id = body.get("attachmentId")
                if not attach_id:
                    continue
                att = gmail.users().messages().attachments().get(userId="me", messageId=mid, id=attach_id).execute()
                data = att.get("data")
                if not data:
                    continue
                file_data = urlsafe_b64decode(data)
                safe_fn = filename.replace("/", "_").replace("\\", "_")
                out_path = attachments_dir / f"{mid}_{safe_fn}"
                with open(out_path, "wb") as f:
                    f.write(file_data)
                sha = sha256_of_file(out_path)
                checks.append((sha, str(out_path)))
                rows.append([mid, date, sender, subject, filename, str(out_path), sha, mime])
                print(f"[{i}/{len(messages)}] Saved {filename} -> {out_path}")
    # write CSV index
    with open(index_file, "w", newline="") as csvf:
        writer = csv.writer(csvf)
        writer.writerow(["message_id", "date", "from", "subject", "attachment_filename", "saved_path", "sha256", "mime"])
        writer.writerows(rows)
    # write manifest
    with open(manifest_file, "w") as mf:
        for sha, path in checks:
            mf.write(f"{sha}  {path}\n")

    print("Done. Files saved under:", base)
    print("Index:", index_file)
    print("Manifest:", manifest_file)

if __name__ == "__main__":
    main()