#!/usr/bin/env bash
# Download Apple Hypersim (461 scenes, ~1.9 TB) — see README.md.
# Scene URLs (hypersim_urls.txt) are taken from the official
# code/python/tools/dataset_download_images.py in https://github.com/apple/ml-hypersim.
#
# Usage: ./download_hypersim.sh [-o OUTPUT_ROOT] [-x] [-d] [SCENE_PATTERN ...]
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/Hypersim
#   -x               unzip each scene into OUTPUT_ROOT/scenes after downloading
#   -d               delete the zip after a successful unzip (implies -x)
#   SCENE_PATTERN    shell glob(s) on the scene name, e.g. ai_001_001 'ai_00[1-3]_*'
#                    (default: all 457 scene zips, 1-20 GB each)
#
# Downloads are resumable (wget -c): re-run the same command to continue.

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
URL_LIST="$SCRIPT_DIR/hypersim_urls.txt"

OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/Hypersim
EXTRACT=0
DELETE=0
while getopts "o:xdh" opt; do
  case "$opt" in
    o) OUTPUT_ROOT="$OPTARG" ;;
    x) EXTRACT=1 ;;
    d) EXTRACT=1; DELETE=1 ;;
    *) sed -n '2,14p' "$0"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
PATTERNS=("$@")
[ ${#PATTERNS[@]} -eq 0 ] && PATTERNS=('*')

[ -f "$URL_LIST" ] || { echo "Missing $URL_LIST" >&2; exit 1; }
mkdir -p "$OUTPUT_ROOT/downloads" || exit 1
cd "$OUTPUT_ROOT" || exit 1
echo "Output: $(pwd) | scenes: ${PATTERNS[*]} | unzip: $EXTRACT | delete zip: $DELETE"

FAILED=0
N=0
while read -r url; do
  [ -z "$url" ] && continue
  f=$(basename "$url"); scene=${f%.zip}
  match=0
  for p in "${PATTERNS[@]}"; do
    # shellcheck disable=SC2053
    [[ "$scene" == $p ]] && { match=1; break; }
  done
  [ "$match" -eq 0 ] && continue
  N=$((N + 1))
  if [ -f "scenes/$scene/.done" ]; then
    echo "[skip] $scene already extracted"; continue
  fi
  echo "=== $scene"
  wget -c -P downloads "$url" || { echo "[fail] $scene" >&2; FAILED=1; continue; }
  if [ "$EXTRACT" -eq 1 ]; then
    mkdir -p scenes
    if unzip -n -q "downloads/$f" -d scenes; then
      touch "scenes/$scene/.done"
      [ "$DELETE" -eq 1 ] && rm -f "downloads/$f"
    else
      echo "[fail] unzip $f" >&2; FAILED=1
    fi
  fi
done < "$URL_LIST"

echo "Matched $N scene(s)."
[ "$N" -eq 0 ] && { echo "No scene matched: ${PATTERNS[*]} (see hypersim_urls.txt)" >&2; exit 1; }
if [ "$FAILED" -ne 0 ]; then
  echo "Some downloads failed; re-run this script to resume." >&2
  exit 1
fi
echo "All files downloaded."
