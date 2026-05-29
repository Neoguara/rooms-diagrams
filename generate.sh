#!/bin/bash

FORMAT="png"
OUT="out"
UPDATE_DRIVE=false
FETCH_LINKS=false
COMPILE_LATEX=false

usage() {
  echo "Usage: $0 [--svg] [--latex] [--update-drive] [--fetch-links]"
  echo ""
  echo "Options:"
  echo "  --svg           Generate diagrams in SVG format (default: PNG)"
  echo "  --latex         Compile LaTeX documents to PDF"
  echo "  --update-drive  Upload SVGs to Google Drive (forces --svg, requires DRIVE_FOLDER_ID)"
  echo "  --fetch-links   Fetch Drive links from API and update diagramas-drive.json"
  echo "  --help          Show this help message"
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --svg)          FORMAT="svg" ;;
    --latex)        COMPILE_LATEX=true ;;
    --update-drive) UPDATE_DRIVE=true; FORMAT="svg" ;;
    --fetch-links)  FETCH_LINKS=true ;;
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

if $COMPILE_LATEX; then
  echo ""
  echo "Compiling LaTeX documents..."

  find . -name "*.tex" | while read -r file; do
    if ! grep -q '\\documentclass' "$file"; then
      continue
    fi

    src_dir="$(dirname "$file")"
    filename="$(basename "$file" .tex)"
    dest_dir="$OUT/$(echo "$src_dir" | sed 's|^\./||')"
    mkdir -p "$dest_dir"

    echo "  Compiling $file..."

    (cd "$src_dir" && pdflatex -interaction=nonstopmode "$filename.tex" > /dev/null 2>&1)

    if grep -q '\\bibliography' "$file"; then
      (cd "$src_dir" && bibtex "$filename" > /dev/null 2>&1)
      (cd "$src_dir" && pdflatex -interaction=nonstopmode "$filename.tex" > /dev/null 2>&1)
    fi

    (cd "$src_dir" && pdflatex -interaction=nonstopmode "$filename.tex" > /dev/null 2>&1)

    if [ -f "$src_dir/$filename.pdf" ]; then
      mv "$src_dir/$filename.pdf" "$dest_dir/$filename.pdf"
      echo "  -> $dest_dir/$filename.pdf"
      (cd "$src_dir" && rm -f ./*.aux "$filename.log" "$filename.toc" \
        "$filename.lot" "$filename.lof" "$filename.out" "$filename.bbl" "$filename.blg" \
        "$filename.brf")
    else
      echo "WARN: failed to compile $file"
    fi
  done

  echo "Done. PDFs saved to $OUT/"
fi

SCRIPT_DIR="$(dirname "$0")"
PYTHON="${SCRIPT_DIR}/.venv/bin/python"
if [ ! -f "$PYTHON" ]; then
  PYTHON="python3"
fi

if $UPDATE_DRIVE; then
  echo ""
  echo "Updating Google Drive folder..."
  "$PYTHON" "${SCRIPT_DIR}/upload_drive.py"
elif $FETCH_LINKS; then
  echo ""
  "$PYTHON" "${SCRIPT_DIR}/upload_drive.py" --fetch-links
fi
