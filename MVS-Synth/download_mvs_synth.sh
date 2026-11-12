#!/usr/bin/env bash
# Download MVS-Synth (DeepMVS, CVPR 2018) from Hugging Face (phuang17/MVS-Synth) with the hf CLI
# (pip install -U huggingface_hub; no login needed) — see README.md.
#
# Usage: ./download_mvs_synth.sh [-o OUTPUT_ROOT] [-x] [RESOLUTION ...]
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/MVS-Synth
#   -x               extract after downloading
#   RESOLUTION       any of: 1080 720 540 all   (default: 1080)
#                      1080   1920x1080   34 GB
#                      720    1280x720    16 GB
#                      540    960x540     ~10.5 GB
#
# Downloads are resumable: re-run the same command to continue.

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

command -v hf >/dev/null || { echo "hf CLI not found: pip install -U huggingface_hub" >&2; exit 1; }

FILES=()
for r in "${RES[@]}"; do
  case "$r" in
    1080|720|540) FILES+=("GTAV_${r}.tar.gz") ;;
    *) echo "Unknown resolution: $r (expected 1080 720 540 all)" >&2; exit 1 ;;
  esac
done

mkdir -p "$OUTPUT_ROOT" || exit 1
cd "$OUTPUT_ROOT" || exit 1
echo "Output: $(pwd) | files: ${FILES[*]} | extract: $EXTRACT"

if ! hf download phuang17/MVS-Synth "${FILES[@]}" --repo-type dataset --local-dir .; then
  echo "Download failed; re-run this script to resume." >&2
  exit 1
fi

if [ "$EXTRACT" -eq 1 ]; then
  for f in "${FILES[@]}"; do
    echo "=== extract $f"
    tar -xzf "$f" || { echo "[fail] extract $f" >&2; exit 1; }
  done
fi
echo "All files downloaded."
