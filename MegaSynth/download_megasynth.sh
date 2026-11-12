#!/usr/bin/env bash
# Download MegaSynth (~700K procedurally generated scenes) from Hugging Face
# (hwjiang/MegaSynth) — see README.md.
#
# Usage: ./download_megasynth.sh [-o OUTPUT_ROOT] [-x] [-d] [SPLIT ...]
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/MegaSynth
#   -x               unzip each split after downloading
#   -d               delete the zip after a successful unzip (implies -x)
#   SPLIT            split ids 0-99 or ranges like 0-9 (default: 0-99, ~4.04 TB total,
#                    ~40 GB per split)
#
# Downloads are resumable (wget -c): re-run the same command to continue.

OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/MegaSynth
EXTRACT=0
DELETE=0
while getopts "o:xdh" opt; do
  case "$opt" in
    o) OUTPUT_ROOT="$OPTARG" ;;
    x) EXTRACT=1 ;;
    d) EXTRACT=1; DELETE=1 ;;
    *) sed -n '2,13p' "$0"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
[ $# -eq 0 ] && set -- 0-99

IDS=()
for a in "$@"; do
  case "$a" in
    *-*) IDS+=($(seq "${a%-*}" "${a#*-}")) ;;
    *)   IDS+=("$a") ;;
  esac
done

BASE=https://huggingface.co/datasets/hwjiang/MegaSynth/resolve/main

mkdir -p "$OUTPUT_ROOT" || exit 1
cd "$OUTPUT_ROOT" || exit 1
echo "Output: $(pwd) | splits: ${#IDS[@]} | unzip: $EXTRACT | delete zip: $DELETE"

FAILED=0
for i in "${IDS[@]}"; do
  if ! [[ "$i" =~ ^[0-9]+$ ]] || [ "$i" -gt 99 ]; then
    echo "Unknown split: $i (expected 0-99)" >&2; FAILED=1; continue
  fi
  f="split_$i.zip"
  if [ -f "split_$i.done" ]; then echo "[skip] $f already extracted"; continue; fi
  echo "=== $f"
  wget -c "$BASE/$f" || { echo "[fail] $f" >&2; FAILED=1; continue; }
  if [ "$EXTRACT" -eq 1 ]; then
    if unzip -n -q "$f"; then
      touch "split_$i.done"
      [ "$DELETE" -eq 1 ] && rm -f "$f"
    else
      echo "[fail] unzip $f" >&2; FAILED=1
    fi
  fi
done

if [ "$FAILED" -ne 0 ]; then
  echo "Some downloads failed; re-run this script to resume." >&2
  exit 1
fi
echo "All files downloaded."
