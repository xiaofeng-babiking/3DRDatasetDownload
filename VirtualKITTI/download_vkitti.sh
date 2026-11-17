#!/usr/bin/env bash
# Official Virtual KITTI 1.3.1 archives, download only.
set -euo pipefail
SCRIPT_DIR=$(cd -- "$(dirname -- "$0")" && pwd)
source "$SCRIPT_DIR/../scripts/download_common.sh"
TARGET_DIR=./data/VirtualKITTI
MODALITIES=()
usage() {
  cat <<'EOF'
Usage: bash download_vkitti.sh [--target_dir DIR] [MODALITY ...]
  MODALITY: rgb depthgt extrinsicsgt motgt scenegt flowgt, or all (default).
  --target_dir, -o DIR   Output directory (default: ./data/VirtualKITTI).
  -h, --help            Show help without accessing the network.
Downloads official v1.3.1 archives and checksums; does not extract them.
For Virtual KITTI 2, use VirtualKITTI2/download_vkitti2.sh.
EOF
}
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target_dir|-o)
      [[ $# -ge 2 && -n "$2" ]] || { echo 'Missing output directory.' >&2; exit 1; }
      TARGET_DIR="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    rgb|depthgt|extrinsicsgt|motgt|scenegt|flowgt|all) MODALITIES+=("$1"); shift ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 1 ;;
  esac
done
if [[ ${#MODALITIES[@]} -eq 0 || " ${MODALITIES[*]} " == *' all '* ]]; then
  MODALITIES=(rgb depthgt extrinsicsgt motgt scenegt flowgt)
fi
BASE=https://download.europe.naverlabs.com/virtual-kitti-1.3.1
FAILED=0
download_file "$BASE/vkitti_1.3.1_md5_checksums.txt" "$TARGET_DIR/vkitti_1.3.1_md5_checksums.txt" || FAILED=1
for modality in "${MODALITIES[@]}"; do
  filename="vkitti_1.3.1_$modality.tar"
  case "$modality" in extrinsicsgt|motgt) filename="$filename.gz" ;; esac
  download_file "$BASE/$filename" "$TARGET_DIR/$filename" || FAILED=1
done
[[ "$FAILED" -eq 0 ]] || { echo 'Some downloads failed; re-run to resume.' >&2; exit 1; }
echo 'Download complete. Archives retained without extraction.'
