#!/usr/bin/env bash
# Download Dynamic Replica (DynamicStereo, CVPR 2023) with the official downloader — see README.md.
#
# Prerequisite: accept the license on the "data" tab of https://dynamic-stereo.github.io/
# and download links.json (the download URLs are personalised/expiring, so they are not
# stored in this repository).
#
# Usage: ./download_dynamic_replica.sh -l LINKS_JSON [-o OUTPUT_ROOT] [-c] [-w N] [SPLIT ...]
#   -l LINKS_JSON    path to links.json from the project website (required)
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/DynamicReplica
#   -c               delete archives after unpacking (--clear_archives_after_unpacking)
#   -w N             parallel download / extract workers (default: 4)
#   SPLIT            any of: real valid test train (default: real valid test)
#                    unpacked sizes: train 1.8 TB, test 328 GB, valid 106 GB, real 152 MB
#
# Environment:
#   PYTHON   interpreter to use (default: python3). Missing packages from requirements.txt
#            (requests, tqdm) are installed into it automatically.
#
# The official downloader verifies SHA256 checksums and skips archives that already exist,
# so re-running the same command resumes an interrupted download.

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PYTHON=${PYTHON:-python3}
LINKS=""
OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/DynamicReplica
CLEAR=0
WORKERS=4
while getopts "l:o:cw:h" opt; do
  case "$opt" in
    l) LINKS="$OPTARG" ;;
    o) OUTPUT_ROOT="$OPTARG" ;;
    c) CLEAR=1 ;;
    w) WORKERS="$OPTARG" ;;
    *) sed -n '2,21p' "$0"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
SPLITS=("$@")
[ ${#SPLITS[@]} -eq 0 ] && SPLITS=(real valid test)

[ -n "$LINKS" ] || { echo "Missing -l LINKS_JSON (download links.json from https://dynamic-stereo.github.io/)" >&2; exit 1; }
[ -f "$LINKS" ] || { echo "links.json not found: $LINKS" >&2; exit 1; }
LINKS=$(cd "$(dirname "$LINKS")" && pwd)/$(basename "$LINKS")
for s in "${SPLITS[@]}"; do
  case "$s" in real|valid|test|train) ;; *) echo "Unknown split: $s (expected real valid test train)" >&2; exit 1 ;; esac
done

mkdir -p "$OUTPUT_ROOT" || exit 1
cd "$OUTPUT_ROOT" || exit 1

# The official script imports itself as `dynamic_stereo.scripts.download_utils`,
# so the repository must be importable as a package named dynamic_stereo.
CODE_DIR="$OUTPUT_ROOT/_code"
if [ ! -d "$CODE_DIR/dynamic_stereo" ]; then
  mkdir -p "$CODE_DIR" && git clone --depth 1 https://github.com/facebookresearch/dynamic_stereo "$CODE_DIR/dynamic_stereo" || exit 1
fi
command -v "$PYTHON" >/dev/null || { echo "Python not found: $PYTHON" >&2; exit 1; }
if ! "$PYTHON" -c "import requests, tqdm" 2>/dev/null; then
  echo "Installing requirements into $("$PYTHON" -c 'import sys; print(sys.executable)') ..."
  "$PYTHON" -m pip install -r "$SCRIPT_DIR/requirements.txt" || exit 1
fi

EXTRA=()
[ "$CLEAR" -eq 1 ] && EXTRA+=(--clear_archives_after_unpacking)

echo "Output: $(pwd)/dynamic_replica_data | splits: ${SPLITS[*]} | workers: $WORKERS"
PYTHONPATH="$CODE_DIR:$CODE_DIR/dynamic_stereo${PYTHONPATH:+:$PYTHONPATH}" \
  "$PYTHON" "$CODE_DIR/dynamic_stereo/scripts/download_dynamic_replica.py" \
    --link_list_file "$LINKS" \
    --download_folder "$OUTPUT_ROOT/dynamic_replica_data" \
    --download_splits "${SPLITS[@]}" \
    --n_download_workers "$WORKERS" --n_extract_workers "$WORKERS" \
    "${EXTRA[@]}"
