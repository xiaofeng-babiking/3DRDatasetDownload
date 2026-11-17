#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash download_co3dv2.sh [--target_dir DIR] [--categories all|apple,chair]
                             [--subset full|singlesequence] [--links_json FILE] [--list]
Download CO3Dv2 archives only; never extract them.
Default: ./data/Co3Dv2, all categories, full subset.
--links_json uses a local copy of the official co3d/links.json.
--list prints selected filenames and URLs without downloading dataset files.
Requires Python 3 and wget or curl. Transfers show speed and resume .part files.
EOF
}
TARGET_DIR=./data/Co3Dv2
CATEGORIES=all
SUBSET=full
LINKS_JSON=""
LIST=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --list) LIST=1; shift ;;
    --target_dir|--categories|--subset|--links_json)
      [[ $# -ge 2 && -n "$2" ]] || { echo "Missing value for $1" >&2; exit 2; }
      case "$1" in
        --target_dir) TARGET_DIR="$2" ;;
        --categories) CATEGORIES="$2" ;;
        --subset) SUBSET="$2" ;;
        --links_json) LINKS_JSON="$2" ;;
      esac
      shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done
[[ "$SUBSET" == full || "$SUBSET" == singlesequence ]] || { echo "Invalid subset: $SUBSET" >&2; exit 2; }
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/download_common.sh"
require_command python3
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/co3dv2.XXXXXX")"
trap 'rm -rf -- "$WORK_DIR"' EXIT
if [[ -z "$LINKS_JSON" ]]; then
  LINKS_JSON="$WORK_DIR/links.json"
  download_file 'https://raw.githubusercontent.com/facebookresearch/co3d/main/co3d/links.json' "$LINKS_JSON" >&2
fi
python3 - "$LINKS_JSON" "$SUBSET" "$CATEGORIES" > "$WORK_DIR/download.tsv" <<'PY'
import json
import sys
from pathlib import PurePosixPath
from urllib.parse import urlsplit

with open(sys.argv[1]) as handle:
    links = json.load(handle)[sys.argv[2]]
selected = set(links) if sys.argv[3] == 'all' else set(sys.argv[3].split(','))
unknown = selected - set(links)
if unknown:
    raise SystemExit('Unknown categories: ' + ', '.join(sorted(unknown)))
selected.add('METADATA')
for category, urls in links.items():
    if category in selected:
        for url in urls:
            print(PurePosixPath(urlsplit(url).path).name + '\t' + url)
PY
if [[ "$LIST" == 1 ]]; then
  cat "$WORK_DIR/download.tsv"
else
  download_manifest "$WORK_DIR/download.tsv" "$TARGET_DIR/$SUBSET"
fi
