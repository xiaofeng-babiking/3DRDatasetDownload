#!/usr/bin/env bash
# Download InteriorNet from the link list sent by the maintainers (see README.md).
#
# InteriorNet has no public download links: fill in the terms-of-use form
# https://docs.google.com/forms/d/15sjV-CAud1ENBxK-hJSSrweE7IGc8VXWDbgZiq1trGc
# and the maintainers e-mail you the links. Save them, one URL per line, to a text file
# (lines starting with # are ignored) and pass it with -l.
#
# Usage: ./download_interiornet.sh -l LINK_LIST [-o OUTPUT_ROOT] [-x]
#   -l LINK_LIST     text file with one URL per line (required)
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/InteriorNet
#   -x               extract .zip / .tar / .tar.gz / .tgz archives after downloading
#
# Plain HTTP(S) links are fetched with wget -c (resumable). Google Drive links
# (drive.google.com) are fetched with gdown (pip install gdown); folder links are
# downloaded recursively with `gdown --folder`.

LIST=""
OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/InteriorNet
EXTRACT=0
while getopts "l:o:xh" opt; do
  case "$opt" in
    l) LIST="$OPTARG" ;;
    o) OUTPUT_ROOT="$OPTARG" ;;
    x) EXTRACT=1 ;;
    *) sed -n '2,17p' "$0"; exit 1 ;;
  esac
done

[ -n "$LIST" ] || { echo "Missing -l LINK_LIST (request access via the Google Form first)" >&2; exit 1; }
[ -f "$LIST" ] || { echo "Link list not found: $LIST" >&2; exit 1; }
LIST=$(cd "$(dirname "$LIST")" && pwd)/$(basename "$LIST")

mkdir -p "$OUTPUT_ROOT/downloads" || exit 1
cd "$OUTPUT_ROOT" || exit 1
echo "Output: $(pwd) | links: $(grep -cvE '^\s*(#|$)' "$LIST") | extract: $EXTRACT"

FAILED=0
while read -r url; do
  url=$(echo "$url" | tr -d '\r' | xargs)
  [ -z "$url" ] && continue
  case "$url" in \#*) continue ;; esac
  echo "=== $url"
  case "$url" in
    *drive.google.com/drive/folders/*)
      command -v gdown >/dev/null || { echo "gdown not found: pip install gdown" >&2; exit 1; }
      gdown --folder --continue -O downloads "$url" || { echo "[fail] $url" >&2; FAILED=1; } ;;
    *drive.google.com/*|*drive.usercontent.google.com/*)
      command -v gdown >/dev/null || { echo "gdown not found: pip install gdown" >&2; exit 1; }
      (cd downloads && gdown --fuzzy --continue "$url") || { echo "[fail] $url" >&2; FAILED=1; } ;;
    *)
      wget -c --content-disposition -P downloads "$url" || { echo "[fail] $url" >&2; FAILED=1; } ;;
  esac
done < "$LIST"

if [ "$EXTRACT" -eq 1 ]; then
  mkdir -p data
  find downloads -type f \( -name '*.zip' -o -name '*.tar' -o -name '*.tar.gz' -o -name '*.tgz' \) | while read -r f; do
    [ -f "$f.extracted" ] && continue
    case "$f" in
      *.zip)            unzip -n -q "$f" -d data ;;
      *.tar.gz|*.tgz)   tar -xzf "$f" -C data ;;
      *.tar)            tar -xf "$f" -C data ;;
    esac && touch "$f.extracted"
  done
fi

if [ "$FAILED" -ne 0 ]; then
  echo "Some downloads failed; re-run this script to resume." >&2
  exit 1
fi
echo "All files downloaded."
