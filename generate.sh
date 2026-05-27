#!/bin/bash

OUT="out"
mkdir -p "$OUT"

errors=()

find . -name "*.puml" | while read -r file; do
  dir="$OUT/$(dirname "$file" | sed 's|^\./||')"
  mkdir -p "$dir"
  if ! plantuml -o "$(realpath "$dir")" "$file" 2>/dev/null; then
    echo "WARN: failed to generate $file"
  fi
done

echo "Done. Images saved to $OUT/"
