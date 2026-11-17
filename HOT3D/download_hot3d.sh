#!/usr/bin/env bash
# HOT3D full VRS release, using the official per-user CDN manifests.
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
usage() {
  cat <<'EOF'
Usage: bash HOT3D/download_hot3d.sh [options]
  --subset NAME       all (default), aria, quest, assets
  --urls_dir DIR      Directory containing Hot3D{Aria,Quest,Assets}_download_urls.json
                      Default: ../Aria/urls relative to this script
  --url_json FILE     Override the manifest when selecting one subset
  --target_dir DIR   Default: ./data/HOT3D
  --n_workers N      Parallel downloads (default: 8)
  --sequence GLOB    Select sequences (repeatable)
  --max_sequences N Limit sequences per subset
  --list             List filenames without downloading
  -h, --help         Show this help

Obtain personal manifests from https://www.projectaria.com/datasets/hot3D/.
Requires Python 3; supports SHA1 checks, resume, speed reporting; no extraction.
EOF
}
SUBSET=all
URLS_DIR="$SCRIPT_DIR/../Aria/urls"
URL_JSON=""
TARGET_DIR=./data/HOT3D
FORWARD_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --subset|--urls_dir|--url_json|--target_dir|--n_workers|--sequence|--max_sequences)
      [[ $# -ge 2 && -n "$2" ]] || { echo "Missing value for $1" >&2; exit 2; }
      case "$1" in
        --subset) SUBSET="$2" ;;
        --urls_dir) URLS_DIR="$2" ;;
        --url_json) URL_JSON="$2" ;;
        --target_dir) TARGET_DIR="$2" ;;
        *) FORWARD_ARGS+=("$1" "$2") ;;
      esac
      shift 2 ;;
    --list) FORWARD_ARGS+=(--list); shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done
case "$SUBSET" in
  all) SUBSETS=(aria quest assets) ;;
  aria|quest|assets) SUBSETS=("$SUBSET") ;;
  *) echo "Unknown subset: $SUBSET" >&2; exit 2 ;;
esac
[[ "$SUBSET" != all || -z "$URL_JSON" ]] || { echo "--url_json requires a single --subset" >&2; exit 2; }
MANIFESTS=()
for subset in "${SUBSETS[@]}"; do
  case "$subset" in aria) stem=Aria ;; quest) stem=Quest ;; assets) stem=Assets ;; esac
  manifest="${URL_JSON:-$URLS_DIR/Hot3D${stem}_download_urls.json}"
  [[ -f "$manifest" ]] || { echo "Missing $manifest; obtain it from https://www.projectaria.com/datasets/hot3D/" >&2; exit 2; }
  MANIFESTS+=("$manifest")
done
for ((i=0; i<${#SUBSETS[@]}; i++)); do
  bash "$SCRIPT_DIR/../Aria/download_aria.sh" --dataset "hot3d-${SUBSETS[$i]}" \
    --url_json "${MANIFESTS[$i]}" --target_dir "$TARGET_DIR/${SUBSETS[$i]}" ${FORWARD_ARGS[@]+"${FORWARD_ARGS[@]}"}
done
