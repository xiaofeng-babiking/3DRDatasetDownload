#!/usr/bin/env bash
# Download MVS-Synth (DeepMVS, CVPR 2018) from Hugging Face (phuang17/MVS-Synth) — see README.md.
#
# Usage: ./download_mvs_synth.sh [-o OUTPUT_ROOT] [-x] [RESOLUTION ...]
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/MVS-Synth
#   -x               extract after downloading
#   RESOLUTION       any of: 1080 720 540 all   (default: 1080)
#                      1080   1920x1080   34 GB
#                      720    1280x720    16 GB
#                      540    960x540     ~10.5 GB
#
# Downloads are resumable (wget -c): re-run the same command to continue.

OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/MVS-Synth
EXTRACT=0
while getopts "o:xh" opt; do
  case "$opt" in
    o) OUTPUT_ROOT="$OPTARG" ;;
    x) EXTRACT=1 ;;
    *) sed -n '2,13p' "$0"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
RES=("$@")
[ ${#RES[@]} -eq 0 ] && RES=(1080)
[ "${RES[0]}" = all ] && RES=(1080 720 540)

BASE=https://huggingface.co/datasets/phuang17/MVS-Synth/resolve/main

mkdir -p "$OUTPUT_ROOT" || exit 1
cd "$OUTPUT_ROOT" || exit 1
echo "Output: $(pwd) | resolutions: ${RES[*]} | extract: $EXTRACT"

FAILED=0
for r in "${RES[@]}"; do
  case "$r" in 1080|720|540) ;; *) echo "Unknown resolution: $r (expected 1080 720 540)" >&2; FAILED=1; continue ;; esac
  f="GTAV_${r}.tar.gz"
  echo "=== $f"
  wget -c "$BASE/$f" || { echo "[fail] $f" >&2; FAILED=1; continue; }
  [ "$EXTRACT" -eq 1 ] && tar -xzf "$f"
done

if [ "$FAILED" -ne 0 ]; then
  echo "Some downloads failed; re-run this script to resume." >&2
  exit 1
fi
echo "All files downloaded."
