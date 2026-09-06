#!/bin/bash

FORMAT="png"
OUT="out"
UPDATE_DRIVE=false
FETCH_LINKS=false
COMPILE_LATEX=false
REPORT_ONLY=false
SKIP_DIAGRAMS=false

REPORT_TEX="./src/documentos/relatorio-estagio/relatorio-estagio.tex"

usage() {
  echo "Usage: $0 [--svg] [--latex] [--only-report] [--skip-diagrams] [--update-drive] [--fetch-links]"
  echo ""
  echo "Options:"
  echo "  --svg             Generate diagrams in SVG format (default: PNG)"
  echo "  --latex           Compile LaTeX documents to PDF"
  echo "  --only-report     Compile only $REPORT_TEX (implies --latex)"
  echo "  --skip-diagrams   Reuse the images already in $OUT/ instead of regenerating them"
  echo "  --update-drive    Upload SVGs to Google Drive (forces --svg, requires DRIVE_FOLDER_ID)"
  echo "  --fetch-links     Fetch Drive links from API and update diagramas-drive.json"
  echo "  --help            Show this help message"
  echo ""
  echo "Example: $0 --only-report --skip-diagrams   # fast rebuild of the report alone"
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --svg)          FORMAT="svg" ;;
    --latex)         COMPILE_LATEX=true ;;
    --only-report)   REPORT_ONLY=true; COMPILE_LATEX=true ;;
    --skip-diagrams) SKIP_DIAGRAMS=true ;;
    --update-drive) UPDATE_DRIVE=true; FORMAT="svg" ;;
    --fetch-links)  FETCH_LINKS=true ;;
    --help)         usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
  shift
done

if $SKIP_DIAGRAMS; then
  if [ ! -d "$OUT" ]; then
    echo "ERROR: --skip-diagrams needs $OUT/ to exist. Run without it at least once."
    exit 1
  fi
  echo "Skipping diagram generation, reusing $OUT/"
  mkdir -p "$OUT"
else
  rm -rf "$OUT"
  mkdir -p "$OUT"

  find . -name "*.puml" | while read -r file; do
    dir="$OUT/$(dirname "$file" | sed 's|^\./||')"
    mkdir -p "$dir"
    if ! plantuml -DPLANTUML_LIMIT_SIZE=16384 -t"$FORMAT" -o "$(realpath "$dir")" "$file" 2>/dev/null; then
      echo "WARN: failed to generate $file"
    fi
  done

  echo "Done. $FORMAT images saved to $OUT/"
fi

if $COMPILE_LATEX; then
  echo ""
  echo "Compiling LaTeX documents..."

  echo "  Generating out/drive-links.tex from diagramas-drive.json..."
  python3 << 'PYEOF'
import json, re, os

with open('src/data/diagramas-drive.json') as f:
    data = json.load(f)

os.makedirs('out', exist_ok=True)
with open('out/drive-links.tex', 'w') as out:
    for entry in data:
        name = entry['name']
        link = entry['link']
        macro = ''.join(w.capitalize() for w in re.split(r'[_\-]', name.rsplit('.', 1)[0]))
        out.write(f'\\def\\link{macro}{{{link}}}\n')
PYEOF

  if $REPORT_ONLY; then
    if [ ! -f "$REPORT_TEX" ]; then
      echo "ERROR: $REPORT_TEX not found."
      exit 1
    fi
    TEX_FILES="$REPORT_TEX"
  else
    TEX_FILES="$(find . -name "*.tex")"
  fi

  echo "$TEX_FILES" | while read -r file; do
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
      (cd "$src_dir" && find . -name "*.aux" -delete && rm -f "$filename.log" "$filename.toc" \
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
