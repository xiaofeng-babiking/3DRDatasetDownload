#!/usr/bin/env bash
# Download Virtual KITTI 2 (v2.0.3) from NAVER LABS Europe (see README.md).
#
# Usage: ./download_vkitti2.sh [-o OUTPUT_ROOT] [-x] [-c] [MODALITY ...]
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/VirtualKITTI2
#   -x               extract the tar files after downloading
#   -c               verify MD5 checksums after downloading
#   MODALITY         any of the names below, or "all" (default: rgb depth textgt)
#                      rgb                    7.01 GB
#                      depth                  7.58 GB
#                      classSegmentation      969 MB
#                      instanceSegmentation   166 MB
#                      forwardFlow            29.6 GB
#                      backwardFlow           27.1 GB
#                      forwardSceneFlow       14.8 GB
#                      backwardSceneFlow      14.8 GB
#                      textgt                 23.3 MB  (camera params, 2D/3D boxes, MOT GT)
#
# Downloads are resumable (wget -c): re-run the same command to continue.

OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/VirtualKITTI2
EXTRACT=0
CHECK=0
while getopts "o:xch" opt; do
  case "$opt" in
    o) OUTPUT_ROOT="$OPTARG" ;;
    x) EXTRACT=1 ;;
    c) CHECK=1 ;;
    *) sed -n '2,20p' "$0"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
MODS=("$@")
[ ${#MODS[@]} -eq 0 ] && MODS=(rgb depth textgt)

ALL=(rgb depth classSegmentation instanceSegmentation forwardFlow backwardFlow forwardSceneFlow backwardSceneFlow textgt)
BASE=https://download.europe.naverlabs.com/virtual_kitti_2.0.3
[ "${MODS[0]}" = all ] && MODS=("${ALL[@]}")

mkdir -p "$OUTPUT_ROOT" || exit 1
cd "$OUTPUT_ROOT" || exit 1
echo "Output: $(pwd) | modalities: ${MODS[*]} | extract: $EXTRACT"

wget -c "$BASE/vkitti_2.0.3_md5_checksums.txt" || exit 1

FAILED=0
for m in "${MODS[@]}"; do
  case " ${ALL[*]} " in *" $m "*) ;; *) echo "Unknown modality: $m" >&2; FAILED=1; continue ;; esac
  f="vkitti_2.0.3_${m}.tar"; [ "$m" = textgt ] && f="vkitti_2.0.3_textgt.tar.gz"
  echo "=== $f"
  wget -c "$BASE/$f" || { echo "[fail] $f" >&2; FAILED=1; continue; }
  if [ "$CHECK" -eq 1 ]; then
    expected=$(grep "$f" vkitti_2.0.3_md5_checksums.txt | awk '{print $1}')
    actual=$( (md5sum "$f" 2>/dev/null || md5 -r "$f") | awk '{print $1}')
    if [ -n "$expected" ] && [ "$expected" != "$actual" ]; then
      echo "[md5 mismatch] $f expected $expected got $actual" >&2; FAILED=1; continue
    fi
    echo "[md5 ok] $f"
  fi
  # every tar unpacks into the same SceneXX/<variation>/... tree
  [ "$EXTRACT" -eq 1 ] && tar -xf "$f"
done

if [ "$FAILED" -ne 0 ]; then
  echo "Some downloads failed; re-run this script to resume." >&2
  exit 1
fi
echo "All files downloaded."
