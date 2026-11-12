#!/usr/bin/env bash
# Download BEDLAM (CVPR 2023) — see README.md.
#
# Two sources:
#   hf   (default) Hugging Face mirrors Intelligent-Systems/BEDLAM (30fps PNG, masks, mp4,
#        ground truth) and Intelligent-Systems/BEDLAM-depth (EXR depth). Both are gated:
#        accept the BEDLAM license on each dataset page, then `hf auth login`.
#   mpi  MPI download server (download.is.tue.mpg.de). Fetches the 6fps training subset +
#        labels used by the BEDLAM training code (list: bedlam_mpi_files.txt, taken from
#        https://github.com/pixelite1201/BEDLAM/blob/master/fetch_training_data.sh).
#        Needs a BEDLAM account (https://bedlam.is.tue.mpg.de/); credentials are read from
#        $BEDLAM_USERNAME / $BEDLAM_PASSWORD or prompted.
#
# Usage: ./download_bedlam.sh [-o OUTPUT_ROOT] [-s hf|mpi] [-q SEQ_GLOB] [-x] [MODALITY ...]
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/BEDLAM
#   -s SOURCE        hf (default) or mpi
#   -q SEQ_GLOB      (hf only) restrict to sequences matching a glob, e.g. '20221010_*'
#                    (default: all 30 sequence batches)
#   -x               extract the downloaded tar files
#   MODALITY         (hf only) any of: png masks mp4 ground_truth depth all
#                    (default: ground_truth mp4)
#                      png           30fps 1280x720 images   ~2.39 TB
#                      masks         segmentation masks      ~33 GB
#                      mp4           videos                  ~22 GB
#                      ground_truth  camera/body GT CSV+JSON ~0.1 GB
#                      depth         32-bit EXR depth        ~4.09 TB (BEDLAM-depth repo)

OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/BEDLAM
SOURCE=hf
SEQ='*'
EXTRACT=0
while getopts "o:s:q:xh" opt; do
  case "$opt" in
    o) OUTPUT_ROOT="$OPTARG" ;;
    s) SOURCE="$OPTARG" ;;
    q) SEQ="$OPTARG" ;;
    x) EXTRACT=1 ;;
    *) sed -n '2,27p' "$0"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
MODS=("$@")
[ ${#MODS[@]} -eq 0 ] && MODS=(ground_truth mp4)
[ "${MODS[0]}" = all ] && MODS=(png masks mp4 ground_truth depth)

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$OUTPUT_ROOT" || exit 1
cd "$OUTPUT_ROOT" || exit 1

FAILED=0
extract_tars() {  # extract_tars <dir>
  local t
  find "$1" \( -name '*.tar' -o -name '*.tar.gz' \) | while read -r t; do
    [ -f "$t.extracted" ] && continue
    case "$t" in
      *.tar.gz) tar -xzf "$t" -C "$(dirname "$t")" ;;
      *)        tar -xf  "$t" -C "$(dirname "$t")" ;;
    esac && touch "$t.extracted"
  done
}

case "$SOURCE" in
  hf)
    command -v hf >/dev/null || { echo "hf CLI not found: pip install -U huggingface_hub" >&2; exit 1; }
    echo "Output: $(pwd) | source: hf | sequences: $SEQ | modalities: ${MODS[*]} | extract: $EXTRACT"
    MAIN=(); DEPTH=0
    for m in "${MODS[@]}"; do
      case "$m" in
        png|masks|mp4|ground_truth) MAIN+=(--include "$SEQ/$m/*") ;;
        depth) DEPTH=1 ;;
        *) echo "Unknown modality: $m (expected png masks mp4 ground_truth depth all)" >&2; exit 1 ;;
      esac
    done
    if [ ${#MAIN[@]} -gt 0 ]; then
      hf download Intelligent-Systems/BEDLAM --repo-type dataset --local-dir BEDLAM \
        --include 'LICENSE.md' --include 'README.md' "${MAIN[@]}" || FAILED=1
      [ "$EXTRACT" -eq 1 ] && extract_tars BEDLAM
    fi
    if [ "$DEPTH" -eq 1 ]; then
      hf download Intelligent-Systems/BEDLAM-depth --repo-type dataset --local-dir BEDLAM-depth \
        --include "$SEQ/depth/*" || FAILED=1
      [ "$EXTRACT" -eq 1 ] && extract_tars BEDLAM-depth
    fi ;;
  mpi)
    LIST="$SCRIPT_DIR/bedlam_mpi_files.txt"
    [ -f "$LIST" ] || { echo "Missing $LIST" >&2; exit 1; }
    urle() { local LANG=C i c; for ((i = 0; i < ${#1}; i++)); do c="${1:i:1}"
      [[ "$c" == [a-zA-Z0-9.~-] ]] && printf '%s' "$c" || printf '%%%02X' "'$c"; done; }
    username=${BEDLAM_USERNAME:-}; password=${BEDLAM_PASSWORD:-}
    [ -z "$username" ] && read -r -p "Username (BEDLAM): " username
    [ -z "$password" ] && { read -r -s -p "Password (BEDLAM): " password; echo; }
    POST="username=$(urle "$username")&password=$(urle "$password")"
    echo "Output: $(pwd) | source: mpi | files: $(grep -c . "$LIST")"
    while read -r sfile; do
      [ -z "$sfile" ] && continue
      mkdir -p "mpi/$(dirname "$sfile")"
      echo "=== $sfile"
      wget --post-data "$POST" -c -O "mpi/$sfile" \
        "https://download.is.tue.mpg.de/download.php?domain=bedlam&resume=1&sfile=$sfile" \
        || { echo "[fail] $sfile" >&2; FAILED=1; }
    done < "$LIST"
    [ "$EXTRACT" -eq 1 ] && extract_tars mpi ;;
  *) echo "Unknown source: $SOURCE (expected hf or mpi)" >&2; exit 1 ;;
esac

if [ "$FAILED" -ne 0 ]; then
  echo "Some downloads failed; re-run this script to resume." >&2
  exit 1
fi
echo "All files downloaded."
