#!/usr/bin/env bash
# Source: https://nianticspatial.com/research/map-free/dataset
set -euo pipefail
usage() {
  cat <<'EOF'
Usage: download_mapfree.sh [--target_dir DIR] [--split LIST] [--list]
Download archives only. Default directory: ./data/Mapfree
--split LIST  Comma-separated train,val,test,colmap,sample; default: all
              all means train,val,test,colmap (sample is a duplicate subset).
--list        Print filename<TAB>URL without downloading.
-h, --help    Show help.
Read the license at https://nianticspatial.com/research/map-free/dataset.
EOF
}
die() { printf 'Error: %s\n' "$*" >&2; exit 2; }
target_dir="./data/Mapfree"
split="all"
list_only=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target_dir|--split)
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || die "$1 requires a value"
      case "$1" in --target_dir) target_dir="$2";; --split) split="$2";; esac
      shift 2;;
    --list) list_only=1; shift;;
    -h|--help) usage; exit 0;;
    *) die "unknown argument: $1";;
  esac
done
[[ "$split" != all ]] || split="train,val,test,colmap"
IFS=',' read -r -a splits <<< "$split"
for item in "${splits[@]}"; do
  case "$item" in train|val|test|colmap|sample) ;; *) die "invalid split: $item";; esac
done
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../scripts/download_common.sh"
base="https://storage.googleapis.com/niantic-lon-static/research/map-free-reloc/dataset"
for item in "${splits[@]}"; do
  if [[ "$list_only" == 1 ]]; then
    printf '%s.zip\t%s/%s.zip\n' "$item" "$base" "$item"
  else
    download_file "$base/$item.zip" "$target_dir/$item.zip"
  fi
done
