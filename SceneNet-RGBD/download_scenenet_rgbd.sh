#!/usr/bin/env bash
# Download SceneNet RGB-D (see README.md).
#
# The official links on https://robotvault.bitbucket.io/scenenet-rgbd.html
# (www.doc.ic.ac.uk/~bjm113/scenenet_data/...) return 404 as of 2026-11-12, so this
# script downloads from the unofficial Hugging Face mirror haotongl/SceneNetRGBD.
#
# Usage: ./download_scenenet_rgbd.sh [-o OUTPUT_ROOT] [-x] [PART ...]
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/SceneNet-RGBD
#   -x               extract the tarballs after downloading
#   PART             any of: val train protobuf all, or a single shard train_0 .. train_16
#                    (default: val protobuf)
#                      val       validation set                        15.5 GB
#                      train     training set, 17 shards train_0..16   ~16.6 GB each, ~277 GB
#                      protobuf  trajectory protobufs (val + 17 train)  ~32 MB each
#
# Downloads are resumable (wget -c): re-run the same command to continue.

OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/SceneNet-RGBD
EXTRACT=0
while getopts "o:xh" opt; do
  case "$opt" in
    o) OUTPUT_ROOT="$OPTARG" ;;
    x) EXTRACT=1 ;;
    *) sed -n '2,18p' "$0"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
PARTS=("$@")
[ ${#PARTS[@]} -eq 0 ] && PARTS=(val protobuf)

BASE=https://huggingface.co/datasets/haotongl/SceneNetRGBD/resolve/main

mkdir -p "$OUTPUT_ROOT" || exit 1
cd "$OUTPUT_ROOT" || exit 1
echo "Output: $(pwd) | parts: ${PARTS[*]} | extract: $EXTRACT"

FAILED=0
fetch() {  # fetch <path in repo> <local dir>
  mkdir -p "$2"
  wget -c -P "$2" "$BASE/$1" || { echo "[fail] $1" >&2; FAILED=1; return 1; }
  # Untarring is slow: the archives contain a very large number of small files.
  if [ "$EXTRACT" -eq 1 ] && [[ "$1" == *.tar.gz ]]; then
    tar -xzf "$2/$(basename "$1")" -C "$2"
  fi
}

get_part() {
  local i
  case "$1" in
    val)      fetch SceneNetRGBD-val.tar.gz val ;;
    train)    for i in $(seq 0 16); do fetch "train_$i.tar.gz" train; done ;;
    train_[0-9]|train_1[0-6]) fetch "$1.tar.gz" train ;;
    protobuf)
      fetch protobufs/scenenet_rgbd_val.pb protobufs
      for i in $(seq 0 16); do fetch "protobufs/scenenet_rgbd_train_$i.pb" protobufs; done ;;
    all)      for p in val protobuf train; do get_part "$p"; done ;;
    *) echo "Unknown part: $1 (expected: val train train_N protobuf all)" >&2; FAILED=1 ;;
  esac
}

for p in "${PARTS[@]}"; do
  echo "=== $p"
  get_part "$p"
done

if [ "$FAILED" -ne 0 ]; then
  echo "Some downloads failed; re-run this script to resume." >&2
  exit 1
fi
echo "All files downloaded."
