#!/usr/bin/env bash
# Download Dynamic Replica archives without unpacking, using official download helpers — see README.md.
#
# Prerequisite: accept the license on the "data" tab of https://dynamic-stereo.github.io/
# and download links.json (the download URLs are personalised/expiring, so they are not
# stored in this repository).
#
# Usage: ./download_dynamic_replica.sh -l LINKS_JSON [-o OUTPUT_ROOT] [-w N] [SPLIT ...]
#   -l LINKS_JSON    path to links.json from the project website (required)
#   -o OUTPUT_ROOT   default: /Volumes/Expansion1/3DRDatasets/DynamicReplica
#   -w N             parallel download workers (default: 4)
#   SPLIT            any of: real valid test train (default: real valid test)
#                    unpacked sizes: train 1.8 TB, test 328 GB, valid 106 GB, real 152 MB
#
# Environment:
#   PYTHON   interpreter to use (default: python3). Missing packages from requirements.txt
#            (requests, tqdm) are installed into it automatically.
#
# Downloads are SHA256-checked; existing archives are skipped. Re-running continues
# unfinished downloads (partial archives restart). Archives are kept without unpacking.

if [[ "${1:-}" == --help || "${1:-}" == -h ]]; then
  sed -n '2,/^$/p' "$0"
  exit 0
fi

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PYTHON=${PYTHON:-python3}
LINKS=""
OUTPUT_ROOT=/Volumes/Expansion1/3DRDatasets/DynamicReplica
WORKERS=4
while getopts "l:o:w:h" opt; do
  case "$opt" in
    l) LINKS="$OPTARG" ;;
    o) OUTPUT_ROOT="$OPTARG" ;;
    w) WORKERS="$OPTARG" ;;
    *) sed -n '2,20p' "$0"; exit 1 ;;
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
OUTPUT_ROOT=$(cd "$OUTPUT_ROOT" && pwd)
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

echo "Output: $(pwd)/dynamic_replica_data | splits: ${SPLITS[*]} | workers: $WORKERS | download only (no unpacking)"
# The official CLI always unpacks. Call only its download helper, retaining checksum
# validation and skipping completed archives. Threads avoid spawning Python from stdin.
PYTHONPATH="$CODE_DIR:$CODE_DIR/dynamic_stereo${PYTHONPATH:+:$PYTHONPATH}" \
  "$PYTHON" - "$LINKS" "$OUTPUT_ROOT/dynamic_replica_data" "$WORKERS" "${SPLITS[@]}" <<'PY'
import json
import os
import sys
from concurrent.futures import ThreadPoolExecutor
from functools import partial

from tqdm import tqdm
from dynamic_stereo.scripts import download_utils

links_file, download_folder, workers, *splits = sys.argv[1:]
with open(links_file) as f:
    links = json.load(f)
data_links = [
    (split, os.path.split(url)[-1], url)
    for split, urls in links.items()
    if split in splits
    for url in urls
]
os.makedirs(download_folder, exist_ok=True)
download = partial(
    download_utils._download_split_file,
    download_folder,
    checksum_check=True,
    sha256s_file=os.path.join(os.path.dirname(download_utils.__file__), "dr_sha256.json"),
    skip_downloaded_files=True,
)
with ThreadPoolExecutor(max_workers=int(workers)) as pool:
    results = list(tqdm(pool.map(lambda link: download(link=link), data_links), total=len(data_links)))
failed = [name for name, ok in results if not ok]
if failed:
    sys.exit("Download/checksum failed: " + ", ".join(failed))
print("Done. Archives retained without unpacking.")
PY
