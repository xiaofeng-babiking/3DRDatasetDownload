#!/usr/bin/env bash
# Original Replica v1 dataset, not a rendered SLAM subset.
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
usage() {
  cat <<'EOF'
Usage: bash Replica/download_replica.sh [options]
  --target_dir DIR    Default: ./data/Replica
  --without_configs Skip the supplementary Habitat config ZIP
  --list             List URLs without downloading
  -h, --help         Show this help

Downloads the official v1.0 release's 17 archive parts (aa-aq) and configs.
No concatenation or extraction. Resume and transfer speed are supported.
Requires wget or curl. Source: https://github.com/facebookresearch/Replica-Dataset
EOF
}
TARGET_DIR=./data/Replica
CONFIGS=1
LIST_ONLY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target_dir) [[ $# -ge 2 && -n "$2" ]] || { echo "Missing --target_dir value" >&2; exit 2; }; TARGET_DIR="$2"; shift 2 ;;
    --without_configs) CONFIGS=0; shift ;;
    --list) LIST_ONLY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done
source "$SCRIPT_DIR/../scripts/download_common.sh"
fetch() {
  if [[ "$LIST_ONLY" -eq 1 ]]; then printf '%s\t%s\n' "$2" "$1"; else download_file "$1" "$TARGET_DIR/$2"; fi
}
for suffix in a b c d e f g h i j k l m n o p q; do
  name="replica_v1_0.tar.gz.parta$suffix"
  fetch "https://github.com/facebookresearch/Replica-Dataset/releases/download/v1.0/$name" "$name"
done
if [[ "$CONFIGS" -eq 1 ]]; then
  fetch "https://dl.fbaipublicfiles.com/habitat/Replica/additional_habitat_configs.zip" additional_habitat_configs.zip
fi
