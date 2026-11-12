#!/usr/bin/env bash
# Download ParallelDomain-4D (and optionally Kubric-4D) from the GCD project page
# https://gcd.cs.columbia.edu/ (see README.md).
#
# Usage: ./download_paralleldomain4d.sh [-o OUTPUT_ROOT] [-x] [PART ...]
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/ParallelDomain-4D
#   -x               extract after downloading
#   PART             any of the names below (default: pd4d)
#                      pd4d          ParallelDomain-4D, basic modalities      2.3 TB tar
#                      pd4d_other    ParallelDomain-4D, additional modalities 3.2 TB tar
#                                    (merge into the same folder as pd4d)
#                      kubric_tiny   Kubric-4D tiny train subset (20 scenes)  48 GB
#                      kubric_val    Kubric-4D validation (100 scenes)        239 GB
#                      kubric_test   Kubric-4D test (100 scenes)              237 GB
#
# Downloads are resumable (wget -c): re-run the same command to continue.
# The Kubric-4D train set (6.5 TB, 18 parts) uses the official script
# gcd_kubric4d_train_dl.sh from the project page.

OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/ParallelDomain-4D
EXTRACT=0
while getopts "o:xh" opt; do
  case "$opt" in
    o) OUTPUT_ROOT="$OPTARG" ;;
    x) EXTRACT=1 ;;
    *) sed -n '2,20p' "$0"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
PARTS=("$@")
[ ${#PARTS[@]} -eq 0 ] && PARTS=(pd4d)

TCOW=https://s3.us-east-1.amazonaws.com/tri-ml-public.s3.amazonaws.com/urp/datasets/tcow

mkdir -p "$OUTPUT_ROOT" || exit 1
cd "$OUTPUT_ROOT" || exit 1
echo "Output: $(pwd) | parts: ${PARTS[*]} | extract: $EXTRACT"

FAILED=0
for p in "${PARTS[@]}"; do
  case "$p" in
    pd4d)        url=https://tri-ml-public.s3.amazonaws.com/datasets/ParallelDomain-4D.tar ;;
    pd4d_other)  url=$TCOW/ParallelDomain-4D-OtherModalities.tar ;;
    kubric_tiny) url=$TCOW/gcd_kubric4d_tiny.tar.gz ;;
    kubric_val)  url=$TCOW/gcd_kubric4d_val.tar.gz ;;
    kubric_test) url=$TCOW/gcd_kubric4d_test.tar.gz ;;
    *) echo "Unknown part: $p" >&2; FAILED=1; continue ;;
  esac
  f=$(basename "$url")
  echo "=== $f"
  wget -c "$url" || { echo "[fail] $f" >&2; FAILED=1; continue; }
  if [ "$EXTRACT" -eq 1 ]; then
    case "$f" in
      *.tar.gz) tar -xzf "$f" ;;
      *.tar)    tar -xf "$f" ;;
    esac
  fi
done

if [ "$FAILED" -ne 0 ]; then
  echo "Some downloads failed; re-run this script to resume." >&2
  exit 1
fi
echo "All files downloaded."
