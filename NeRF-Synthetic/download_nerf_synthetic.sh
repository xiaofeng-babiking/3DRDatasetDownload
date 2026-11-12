#!/usr/bin/env bash
# Download the NeRF Synthetic (Blender) dataset — 8 object scenes (see README.md).
#
# Usage: ./download_nerf_synthetic.sh [-o OUTPUT_ROOT] [-s SOURCE] [-x] [SCENE ...]
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/NeRF-Synthetic
#   -s SOURCE        hf      per-scene zips from the Hugging Face mirror
#                            nerfbaselines/nerfbaselines-data (default, resumable, no login)
#                    gdrive  the official nerf_synthetic.zip (~1.3 GB, all scenes) from the
#                            authors' Google Drive folder, via gdown (pip install gdown)
#   -x               unzip after downloading
#   SCENE            any of: chair drums ficus hotdog lego materials mic ship (default: all)
#                    (only used with -s hf; gdrive always fetches all scenes)

OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/NeRF-Synthetic
SOURCE=hf
EXTRACT=0
while getopts "o:s:xh" opt; do
  case "$opt" in
    o) OUTPUT_ROOT="$OPTARG" ;;
    s) SOURCE="$OPTARG" ;;
    x) EXTRACT=1 ;;
    *) sed -n '2,13p' "$0"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
ALL=(chair drums ficus hotdog lego materials mic ship)
SCENES=("$@")
[ ${#SCENES[@]} -eq 0 ] && SCENES=("${ALL[@]}")

mkdir -p "$OUTPUT_ROOT" || exit 1
cd "$OUTPUT_ROOT" || exit 1
echo "Output: $(pwd) | source: $SOURCE | scenes: ${SCENES[*]} | unzip: $EXTRACT"

FAILED=0
case "$SOURCE" in
  hf)
    BASE=https://huggingface.co/datasets/nerfbaselines/nerfbaselines-data/resolve/main/blender
    wget -c "$BASE/README.txt" || FAILED=1
    for s in "${SCENES[@]}"; do
      case " ${ALL[*]} " in *" $s "*) ;; *) echo "Unknown scene: $s" >&2; FAILED=1; continue ;; esac
      echo "=== $s"
      wget -c "$BASE/$s.zip" || { echo "[fail] $s" >&2; FAILED=1; continue; }
      # each zip contains a top-level <scene>/ folder
      [ "$EXTRACT" -eq 1 ] && unzip -n -q "$s.zip" -d nerf_synthetic
    done ;;
  gdrive)
    command -v gdown >/dev/null || { echo "gdown not found: pip install gdown" >&2; exit 1; }
    # File id of nerf_synthetic.zip inside the official folder
    # https://drive.google.com/drive/folders/1cK3UDIJqKAAm7zyrxRYVFJ0BRMgrwhh4
    # (same id used by nerfstudio's `ns-download-data blender`).
    if [ ! -f nerf_synthetic.zip ]; then
      gdown --continue 18JxhpWD-4ZmuFKLzKlAw-w5PpzZxXOcG -O nerf_synthetic.zip || FAILED=1
    fi
    [ "$FAILED" -eq 0 ] && [ "$EXTRACT" -eq 1 ] && unzip -n -q nerf_synthetic.zip ;;
  *) echo "Unknown source: $SOURCE (expected hf or gdrive)" >&2; exit 1 ;;
esac

if [ "$FAILED" -ne 0 ]; then
  echo "Some downloads failed; re-run this script to resume." >&2
  exit 1
fi
echo "All files downloaded."
