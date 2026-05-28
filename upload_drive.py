#!/usr/bin/env python3

import os
import sys
from pathlib import Path

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload

SCOPES = ["https://www.googleapis.com/auth/drive"]
CREDENTIALS_FILE = Path(__file__).parent / "credentials.json"
TOKEN_FILE = Path(__file__).parent / "token.json"
OUT_BASE = Path(__file__).parent / "out" / "src" / "plantuml"


def get_service():
    creds = None
    if TOKEN_FILE.exists():
        creds = Credentials.from_authorized_user_file(str(TOKEN_FILE), SCOPES)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            if not CREDENTIALS_FILE.exists():
                print(f"Error: {CREDENTIALS_FILE} not found.")
                print("Download it from Google Cloud Console > APIs > Credentials > OAuth 2.0 Client IDs.")
                sys.exit(1)
            flow = InstalledAppFlow.from_client_secrets_file(str(CREDENTIALS_FILE), SCOPES)
            creds = flow.run_local_server(port=0)
        TOKEN_FILE.write_text(creds.to_json())
    return build("drive", "v3", credentials=creds)


def list_items(service, folder_id):
    items = []
    page_token = None
    while True:
        resp = service.files().list(
            q=f"'{folder_id}' in parents and trashed=false",
            fields="nextPageToken, files(id, name)",
            pageToken=page_token,
        ).execute()
        items.extend(resp.get("files", []))
        page_token = resp.get("nextPageToken")
        if not page_token:
            break
    return items


def clear_folder(service, folder_id):
    items = list_items(service, folder_id)
    for item in items:
        service.files().delete(fileId=item["id"]).execute()
        print(f"  deleted: {item['name']}")
    if not items:
        print("  (folder already empty)")


def get_or_create_subfolder(service, name, parent_id, cache):
    key = f"{parent_id}/{name}"
    if key in cache:
        return cache[key]
    resp = service.files().list(
        q=f"name='{name}' and '{parent_id}' in parents and mimeType='application/vnd.google-apps.folder' and trashed=false",
        fields="files(id)",
    ).execute()
    files = resp.get("files", [])
    if files:
        folder_id = files[0]["id"]
    else:
        meta = {"name": name, "mimeType": "application/vnd.google-apps.folder", "parents": [parent_id]}
        folder_id = service.files().create(body=meta, fields="id").execute()["id"]
    cache[key] = folder_id
    return folder_id


def upload_svg(service, file_path, parent_id):
    meta = {"name": file_path.name, "parents": [parent_id]}
    media = MediaFileUpload(str(file_path), mimetype="image/svg+xml", resumable=False)
    service.files().create(body=meta, media_body=media, fields="id").execute()
    print(f"  uploaded: {file_path.relative_to(OUT_BASE)}")


def main():
    folder_id = os.environ.get("DRIVE_FOLDER_ID")
    if not folder_id:
        print("Error: DRIVE_FOLDER_ID environment variable is not set.")
        print("Set it in your .env file or export it before running this script.")
        sys.exit(1)

    if not OUT_BASE.exists():
        print(f"Error: {OUT_BASE} does not exist.")
        print("Run ./generate.sh --svg first.")
        sys.exit(1)

    svg_files = sorted(OUT_BASE.rglob("*.svg"))
    if not svg_files:
        print("No SVG files found. Run ./generate.sh --svg first.")
        sys.exit(1)

    print(f"Authenticating with Google Drive...")
    service = get_service()

    print(f"\nClearing Drive folder ({folder_id})...")
    clear_folder(service, folder_id)

    print(f"\nUploading {len(svg_files)} SVG files...")
    folder_cache = {}
    for svg_file in svg_files:
        rel = svg_file.relative_to(OUT_BASE)
        parts = rel.parts
        parent = folder_id
        for part in parts[:-1]:
            parent = get_or_create_subfolder(service, part, parent, folder_cache)
        upload_svg(service, svg_file, parent)

    print(f"\nDone. {len(svg_files)} files uploaded.")


if __name__ == "__main__":
    main()
