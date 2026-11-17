#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash download_wildrgbd.sh [--target_dir DIR] [--categories all|apple,bottle] [--list]
Download WildRGB-D ZIPs and split ZIP parts without merging or extracting them.
Default: ./data/WildRGBD, all 46 categories. Category names are case-sensitive (e.g. TV).
--list prints selected filenames and URLs without downloading.
Requires wget or curl. Transfers show speed and resume .part files.
EOF
}
TARGET_DIR=./data/WildRGBD
CATEGORIES=all
LIST=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --list) LIST=1; shift ;;
    --target_dir|--categories)
      [[ $# -ge 2 && -n "$2" ]] || { echo "Missing value for $1" >&2; exit 2; }
      case "$1" in --target_dir) TARGET_DIR="$2" ;; --categories) CATEGORIES="$2" ;; esac
      shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../scripts/download_common.sh"
WORK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/wildrgbd.XXXXXX")"
trap 'rm -rf -- "$WORK_DIR"' EXIT
# The bundled list follows the categories and archive names in the official download.py.
awk -F '\t' -v wanted="$CATEGORIES" '
BEGIN { n = split(wanted, categories, ","); for (i=1; i<=n; i++) selected[categories[i]]=1 }
!/^#/ && NF == 3 {
  known[$1]=1
  if (wanted == "all" || $1 in selected) print $2 "\t" $3
}
END {
  if (wanted != "all") for (category in selected) if (!(category in known)) {
    print "Unknown category: " category > "/dev/stderr"; invalid=1
  }
  if (invalid) exit 2
}' "$SCRIPT_DIR/archives.tsv" > "$WORK_DIR/download.tsv"
if [[ "$LIST" == 1 ]]; then
  cat "$WORK_DIR/download.tsv"
else
  download_manifest "$WORK_DIR/download.tsv" "$TARGET_DIR"
fi
