#!/usr/bin/env bash
# Download EDEN (Enclosed garDEN scenes) from https://lhoangan.github.io/eden/ (see README.md).
#
# Usage: ./download_eden.sh [-o OUTPUT_ROOT] [-s] [-x] [MODALITY ...]
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/EDEN
#   -s               download the small sample set instead of the full set
#   -x               unzip after downloading
#   MODALITY         any of the names below, or "all"
#                    (default: Stats CameraInfo LightInfo RGB Depth)
#                      name           full set   sample set
#                      Stats          26 MB      -
#                      CameraInfo     197 MB     -
#                      LightInfo      131 MB     -
#                      RGB            333 GB     11 GB
#                      Segmentation   13 GB      439 MB
#                      Depth          241 GB     7.7 GB
#                      SurfaceNormal  130 GB     4.6 GB
#                      Intrinsics     440 GB     14 GB   (intrinsic image decomposition)
#
# Downloads are resumable (wget -c): re-run the same command to continue.

OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/EDEN
SAMPLE=0
EXTRACT=0
while getopts "o:sxh" opt; do
  case "$opt" in
    o) OUTPUT_ROOT="$OPTARG" ;;
    s) SAMPLE=1 ;;
    x) EXTRACT=1 ;;
    *) sed -n '2,21p' "$0"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
MODS=("$@")
[ ${#MODS[@]} -eq 0 ] && MODS=(Stats CameraInfo LightInfo RGB Depth)

ALL=(Stats CameraInfo LightInfo RGB Segmentation Depth SurfaceNormal Intrinsics)
SAMPLE_MODS=" RGB Segmentation Depth SurfaceNormal Intrinsics "
[ "${MODS[0]}" = all ] && MODS=("${ALL[@]}")

if [ "$SAMPLE" -eq 1 ]; then
  BASE=https://isis-data.science.uva.nl/hale/EDEN-samples
  OUTPUT_ROOT="$OUTPUT_ROOT/samples"
else
  BASE=https://isis-data.science.uva.nl/hale/EDEN
fi

mkdir -p "$OUTPUT_ROOT" || exit 1
cd "$OUTPUT_ROOT" || exit 1
echo "Output: $(pwd) | modalities: ${MODS[*]} | sample: $SAMPLE | unzip: $EXTRACT"

FAILED=0
for m in "${MODS[@]}"; do
  case " ${ALL[*]} " in *" $m "*) ;; *) echo "Unknown modality: $m" >&2; FAILED=1; continue ;; esac
  if [ "$SAMPLE" -eq 1 ] && [[ "$SAMPLE_MODS" != *" $m "* ]]; then
    echo "[skip] $m has no sample version"; continue
  fi
  url="$BASE/$m.zip"
  # On the official page the full-set Intrinsics link has no .zip extension.
  [ "$SAMPLE" -eq 0 ] && [ "$m" = Intrinsics ] && url="$BASE/Intrinsics"
  echo "=== $m"
  wget -c -O "$m.zip" "$url" || { echo "[fail] $m" >&2; FAILED=1; continue; }
  [ "$EXTRACT" -eq 1 ] && unzip -n -q "$m.zip"
done

if [ "$FAILED" -ne 0 ]; then
  echo "Some downloads failed; re-run this script to resume." >&2
  exit 1
fi
echo "All files downloaded."
