#!/usr/bin/env bash
# Download UnrealStereo4K (SMD-Nets, CVPR 2021) — see README.md.
#
# Usage: ./download_unrealstereo4k.sh [-o OUTPUT_ROOT] [-q] [-x] [SCENE ...]
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/UnrealStereo4K
#   -q               download the quarter-resolution (960x540) version from Hugging Face
#                    instead of the full 3840x2160 version from S3
#   -x               unzip after downloading
#   SCENE            scene ids 0-8 (default: all). Scene 8 (16 GB) is the 200-pair
#                    out-of-domain test set; scenes 0-7 are 67-76 GB each (~600 GB total).
#
# Downloads are resumable (wget -c): re-run the same command to continue.

OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/UnrealStereo4K
QUARTER=0
EXTRACT=0
while getopts "o:qxh" opt; do
  case "$opt" in
    o) OUTPUT_ROOT="$OPTARG" ;;
    q) QUARTER=1 ;;
    x) EXTRACT=1 ;;
    *) sed -n '2,13p' "$0"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
SCENES=("$@")
[ ${#SCENES[@]} -eq 0 ] && SCENES=(0 1 2 3 4 5 6 7 8)

if [ "$QUARTER" -eq 1 ]; then
  OUTPUT_ROOT="$OUTPUT_ROOT/quarter_res"
fi
mkdir -p "$OUTPUT_ROOT" || exit 1
cd "$OUTPUT_ROOT" || exit 1
echo "Output: $(pwd) | scenes: ${SCENES[*]} | quarter: $QUARTER | unzip: $EXTRACT"

FAILED=0
for s in "${SCENES[@]}"; do
  case "$s" in [0-8]) ;; *) echo "Unknown scene: $s (expected 0-8)" >&2; FAILED=1; continue ;; esac
  id=$(printf %05d "$s")
  if [ "$QUARTER" -eq 1 ]; then
    f="$id.zip"
    url="https://huggingface.co/datasets/fabiotosi92/UnrealStereo4K/resolve/main/$f"
  else
    f="UnrealStereo4K_$id.zip"
    url="https://s3.eu-central-1.amazonaws.com/avg-projects/smd_nets/$f"
  fi
  echo "=== $f"
  wget -c "$url" || { echo "[fail] $f" >&2; FAILED=1; continue; }
  [ "$EXTRACT" -eq 1 ] && unzip -n -q "$f"
done

if [ "$FAILED" -ne 0 ]; then
  echo "Some downloads failed; re-run this script to resume." >&2
  exit 1
fi
echo "All files downloaded."
