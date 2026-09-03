#!/usr/bin/env bash
# Resize photos for the web and drop them into images/gallery/.
#
# Usage: tools/resize.sh <source-folder>
#
# For each .jpg/.jpeg/.png in <source-folder>, writes a web-ready copy into
# images/gallery/ with the long edge scaled to 2000px, JPEG quality 80, and
# the filename lowercased with spaces replaced by hyphens. Source files are
# never modified or overwritten.

set -euo pipefail

SRC_DIR="${1:-}"
DEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/images/gallery"

if [ -z "$SRC_DIR" ]; then
  echo "Usage: tools/resize.sh <source-folder>" >&2
  exit 1
fi

if [ ! -d "$SRC_DIR" ]; then
  echo "Error: source folder '$SRC_DIR' does not exist." >&2
  exit 1
fi

# Prefer ImageMagick 7's 'magick', fall back to legacy 'convert'.
if command -v magick >/dev/null 2>&1; then
  CONVERT=(magick)
elif command -v convert >/dev/null 2>&1; then
  CONVERT=(convert)
else
  echo "Warning: ImageMagick is not installed. Install it (e.g. 'brew install imagemagick') and re-run this script." >&2
  exit 0
fi

mkdir -p "$DEST_DIR"

shopt -s nullglob nocaseglob
files=("$SRC_DIR"/*.jpg "$SRC_DIR"/*.jpeg "$SRC_DIR"/*.png)
shopt -u nocaseglob

if [ ${#files[@]} -eq 0 ]; then
  echo "No .jpg/.jpeg/.png files found in '$SRC_DIR'."
  exit 0
fi

for src in "${files[@]}"; do
  base="$(basename "$src")"
  name="${base%.*}"
  ext="jpg"
  clean_name="$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
  dest="$DEST_DIR/$clean_name.$ext"

  "${CONVERT[@]}" "$src" -auto-orient -resize "2000x2000>" -quality 80 "$dest"
  echo "wrote $dest"
done
