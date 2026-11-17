#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash download_megadepth.sh [--target_dir DIR] [--component all|images_depth|sfm] [--list]
Download the official Cornell MegaDepth v1 archives without extracting them.
Default: ./data/MegaDepth; all (images/depth ~199 GB plus SfM models ~667 GB).
--list prints filenames and URLs without downloading.
Requires wget or curl. Transfers show speed, resume .part files and skip completed files.
EOF
}
TARGET_DIR=./data/MegaDepth
COMPONENT=all
LIST=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --list) LIST=1; shift ;;
    --target_dir|--component)
      [[ $# -ge 2 && -n "$2" ]] || { echo "Missing value for $1" >&2; exit 2; }
      case "$1" in --target_dir) TARGET_DIR="$2" ;; --component) COMPONENT="$2" ;; esac
      shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done
case "$COMPONENT" in all|images_depth|sfm) ;; *) echo "Invalid component: $COMPONENT" >&2; exit 2 ;; esac
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/download_common.sh"
fetch_component() {
  if [[ "$LIST" == 1 ]]; then
    printf '%s\t%s\n' "$1" "$2"
  else
    download_file "$2" "$TARGET_DIR/$1"
  fi
}
if [[ "$COMPONENT" == all || "$COMPONENT" == images_depth ]]; then
  fetch_component MegaDepth_v1.tar.gz 'https://www.cs.cornell.edu/projects/megadepth/dataset/Megadepth_v1/MegaDepth_v1.tar.gz'
fi
if [[ "$COMPONENT" == all || "$COMPONENT" == sfm ]]; then
  fetch_component MegaDepth_SfM_v1.tar.xz 'https://www.cs.cornell.edu/projects/megadepth/dataset/MegaDepth_SfM/MegaDepth_SfM_v1.tar.xz'
fi
