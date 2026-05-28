#!/bin/bash

FORMAT="png"
OUT="out"
UPDATE_DRIVE=false

usage() {
  echo "Usage: $0 [--svg] [--update-drive]"
  echo ""
  echo "Options:"
  echo "  --svg           Generate diagrams in SVG format (default: PNG)"
  echo "  --update-drive  Upload SVGs to Google Drive (forces --svg, requires DRIVE_FOLDER_ID)"
  echo "  --help          Show this help message"
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --svg)          FORMAT="svg" ;;
    --update-drive) UPDATE_DRIVE=true; FORMAT="svg" ;;
    --help)         usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
  shift
done

rm -rf "$OUT"
mkdir -p "$OUT"

find . -name "*.puml" | while read -r file; do
  dir="$OUT/$(dirname "$file" | sed 's|^\./||')"
  mkdir -p "$dir"
  if ! plantuml -t"$FORMAT" -o "$(realpath "$dir")" "$file" 2>/dev/null; then
    echo "WARN: failed to generate $file"
  fi
done

echo "Done. $FORMAT images saved to $OUT/"

if $UPDATE_DRIVE; then
  echo ""
  echo "Updating Google Drive folder..."
  SCRIPT_DIR="$(dirname "$0")"
  PYTHON="${SCRIPT_DIR}/.venv/bin/python"
  if [ ! -f "$PYTHON" ]; then
    PYTHON="python3"
  fi
  "$PYTHON" "${SCRIPT_DIR}/upload_drive.py"
fi
