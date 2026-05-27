#!/bin/bash

FORMAT="png"
OUT="out"

usage() {
  echo "Usage: $0 [--svg]"
  echo ""
  echo "Options:"
  echo "  --svg    Generate diagrams in SVG format (default: PNG)"
  echo "  --help   Show this help message"
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --svg)  FORMAT="svg" ;;
    --help) usage ;;
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
