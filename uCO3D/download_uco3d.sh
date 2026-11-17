#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash download_uco3d.sh [--target_dir DIR] [--modalities all|rgb_videos,point_clouds]
                            [--super_categories all|stationery] [--small_subset]
                            [--source huggingface|cdn] [--category_json FILE]
                            [--links_json FILE] [--list]
Download uCO3D ZIP archives only. Default: ./data/uCO3D, all modalities/categories.
Metadata is always included in full downloads; --small_subset selects examples.zip.
--source defaults to the official Hugging Face mirror. CDN URLs are refreshed per run.
--category_json / --links_json accept local copies of the official JSON manifests.
--list prints the selection without downloading dataset archives (may fetch manifests).
Requires Python 3 and wget or curl. Transfers show speed and resume .part files.
EOF
}
TARGET_DIR=./data/uCO3D
MODALITIES=all
SUPER_CATEGORIES=all
SMALL_SUBSET=0
SOURCE=huggingface
CATEGORY_JSON=""
LINKS_JSON=""
LIST=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --list) LIST=1; shift ;;
    --small_subset) SMALL_SUBSET=1; shift ;;
    --target_dir|--modalities|--super_categories|--source|--category_json|--links_json)
      [[ $# -ge 2 && -n "$2" ]] || { echo "Missing value for $1" >&2; exit 2; }
      case "$1" in
        --target_dir) TARGET_DIR="$2" ;;
        --modalities) MODALITIES="$2" ;;
        --super_categories) SUPER_CATEGORIES="$2" ;;
        --source) SOURCE="$2" ;;
        --category_json) CATEGORY_JSON="$2" ;;
        --links_json) LINKS_JSON="$2" ;;
      esac
      shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done
[[ "$SOURCE" == huggingface || "$SOURCE" == cdn ]] || { echo "Invalid source: $SOURCE" >&2; exit 2; }
if [[ "$SMALL_SUBSET" == 1 && ( "$MODALITIES" != all || "$SUPER_CATEGORIES" != all ) ]]; then
  echo "--small_subset cannot be combined with modality/category filters." >&2
  exit 2
fi
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/download_common.sh"
require_command python3
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/uco3d.XXXXXX")"
trap 'rm -rf -- "$WORK_DIR"' EXIT
if [[ -z "$CATEGORY_JSON" ]]; then
  CATEGORY_JSON="$WORK_DIR/category_to_archives.json"
  download_file 'https://raw.githubusercontent.com/facebookresearch/uco3d/main/dataset_download/category_to_archives.json' "$CATEGORY_JSON" >&2
fi
if [[ "$SOURCE" == cdn && -z "$LINKS_JSON" ]]; then
  LINKS_JSON="$WORK_DIR/links.json"
  download_file 'https://raw.githubusercontent.com/uco3d/uco3d.github.io/refs/heads/main/links/uco3d_dataset_download_urls.json' "$LINKS_JSON" >&2
fi
python3 - "$CATEGORY_JSON" "$MODALITIES" "$SUPER_CATEGORIES" "$SMALL_SUBSET" "$SOURCE" "$LINKS_JSON" > "$WORK_DIR/download.tsv" <<'PY'
import json
import sys
from urllib.parse import quote

path, modalities, categories, small, source, links_path = sys.argv[1:]
with open(path) as handle:
    mapping = json.load(handle)
known_modalities = set(mapping) - {'metadata', 'examples'}
known_categories = {category for modality in known_modalities for category in mapping[modality]}
selected_modalities = known_modalities if modalities == 'all' else set(modalities.split(','))
selected_categories = known_categories if categories == 'all' else set(categories.split(','))
unknown = selected_modalities - (known_modalities | {'metadata'})
if unknown:
    raise SystemExit('Unknown modalities: ' + ', '.join(sorted(unknown)))
unknown = selected_categories - known_categories
if unknown:
    raise SystemExit('Unknown super categories: ' + ', '.join(sorted(unknown)))
if small == '1':
    entries = [mapping['examples']]
else:
    entries = [mapping['metadata']]
    for modality in sorted(selected_modalities - {'metadata'}):
        for category, archives in mapping[modality].items():
            if category in selected_categories:
                entries.extend(archives.values())
links = {}
if source == 'cdn':
    with open(links_path) as handle:
        links = json.load(handle)['main_data']
seen = set()
for entry in entries:
    name = entry['filename']
    if name in seen:
        continue
    seen.add(name)
    url = ('https://huggingface.co/datasets/facebook/uco3d/resolve/main/' + quote(name)
           if source == 'huggingface' else links[name]['download_url'])
    print(name + '\t' + url)
PY
if [[ "$LIST" == 1 ]]; then
  cat "$WORK_DIR/download.tsv"
else
  download_manifest "$WORK_DIR/download.tsv" "$TARGET_DIR"
fi
