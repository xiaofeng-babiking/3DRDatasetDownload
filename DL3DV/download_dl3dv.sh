#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash download_dl3dv.sh [--target_dir DIR] [--resolution 480P|960P|2K|4K]
                            [--file_type images+poses|video|colmap_cache]
                            [--subset all|1K|2K|...|11K] [--dry_run]
Default: ./data/DL3DV, 480P images+poses, all subsets. Archives are never extracted.
Files are saved under DIR/<official-repository-name>/ to separate different releases.
Requires hf (pip install -U huggingface_hub in your environment).
First request access on the selected official Hugging Face dataset page, then run
hf auth login (or set HF_TOKEN). The script does not accept terms on your behalf.
--dry_run prints the exact command and access page without contacting the server.
EOF
}
TARGET_DIR=./data/DL3DV
RESOLUTION=480P
FILE_TYPE=images+poses
SUBSET=all
DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --dry_run) DRY_RUN=1; shift ;;
    --target_dir|--resolution|--file_type|--subset)
      [[ $# -ge 2 && -n "$2" ]] || { echo "Missing value for $1" >&2; exit 2; }
      case "$1" in
        --target_dir) TARGET_DIR="$2" ;;
        --resolution) RESOLUTION="$2" ;;
        --file_type) FILE_TYPE="$2" ;;
        --subset) SUBSET="$2" ;;
      esac
      shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 2 ;;
  esac
done
case "$RESOLUTION" in 480P|960P|2K|4K) ;; *) echo "Invalid resolution: $RESOLUTION" >&2; exit 2 ;; esac
case "$SUBSET" in all|[1-9]K|10K|11K) ;; *) echo "Invalid subset: $SUBSET" >&2; exit 2 ;; esac
case "$FILE_TYPE" in
  images+poses) REPO="DL3DV/DL3DV-ALL-$RESOLUTION"; PATTERN='*.zip' ;;
  video) REPO=DL3DV/DL3DV-ALL-video; PATTERN='*/video.mp4' ;;
  colmap_cache) REPO=DL3DV/DL3DV-ALL-ColmapCache; PATTERN='*.zip' ;;
  *) echo "Invalid file type: $FILE_TYPE" >&2; exit 2 ;;
esac
if [[ "$SUBSET" != all ]]; then PATTERN="$SUBSET/$PATTERN"; fi
COMMAND=(hf download "$REPO" --repo-type dataset --local-dir "$TARGET_DIR/${REPO##*/}" --include "$PATTERN")
echo "Access page: https://huggingface.co/datasets/$REPO"
if [[ "$DRY_RUN" == 1 ]]; then
  printf '%q ' "${COMMAND[@]}"
  printf '\n'
  exit 0
fi
if ! command -v hf >/dev/null 2>&1; then
  echo "Missing hf CLI; install huggingface_hub in your Python environment." >&2
  exit 1
fi
export HF_HUB_DISABLE_PROGRESS_BARS=0
exec "${COMMAND[@]}"
