#!/usr/bin/env bash
# HM3D v0.2 archive downloader; does not invoke Habitat's extracting installer.
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
usage() {
  cat <<'EOF'
Usage: bash Habitat/download_habitat.sh [options]
  --target_dir DIR    Default: ./data/Habitat
  --split NAME        all (default: train,val,minival), train, val, minival, example
  --format NAME       habitat (default: BASIS mesh), glb, all
  --netrc FILE        curl netrc containing Matterport API token ID/secret
                      Default: $HOME/.netrc (required except example/--list)
  --without_semantics Skip semantic annotation/config archives
  --list              List filenames and official URLs without downloading
  -h, --help          Show this help

HM3D v0.2: mesh archives + configs + semantics; archives remain compressed.
Request access and API credentials through the official HM3D/Matterport site:
https://github.com/matterport/habitat-matterport-3dresearch
Example archives are public. Requires curl; resumable with speed display.
EOF
}
TARGET_DIR=./data/Habitat
SPLIT=all
FORMAT=habitat
NETRC_FILE="${HOME}/.netrc"
SEMANTICS=1
LIST_ONLY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target_dir|--split|--format|--netrc)
      [[ $# -ge 2 && -n "$2" ]] || { echo "Missing value for $1" >&2; exit 2; }
      case "$1" in
        --target_dir) TARGET_DIR="$2" ;;
        --split) SPLIT="$2" ;;
        --format) FORMAT="$2" ;;
        --netrc) NETRC_FILE="$2" ;;
      esac
      shift 2 ;;
    --without_semantics) SEMANTICS=0; shift ;;
    --list) LIST_ONLY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done
case "$SPLIT" in
  all) SPLITS=(train val minival) ;;
  train|val|minival|example) SPLITS=("$SPLIT") ;;
  *) echo "Unknown split: $SPLIT" >&2; exit 2 ;;
esac
case "$FORMAT" in
  habitat|glb) FORMATS=("$FORMAT" configs) ;;
  all) FORMATS=(habitat glb configs) ;;
  *) echo "Unknown format: $FORMAT" >&2; exit 2 ;;
esac
if [[ "$SEMANTICS" -eq 1 ]]; then FORMATS+=(semantic-annots semantic-configs); fi
source "$SCRIPT_DIR/../scripts/download_common.sh"
if [[ "$LIST_ONLY" -eq 0 ]]; then
  require_command curl
  if [[ "$SPLIT" != example && ! -f "$NETRC_FILE" ]]; then
    echo "Missing Matterport credential file: $NETRC_FILE" >&2
    echo "Use --netrc FILE; format: machine api.matterport.com login TOKEN_ID password TOKEN_SECRET" >&2
    exit 2
  fi
fi
for split in "${SPLITS[@]}"; do
  for format in "${FORMATS[@]}"; do
    if [[ "$format" == configs ]]; then name="hm3d-$split-configs.tar"; else name="hm3d-$split-$format-v0.2.tar"; fi
    if [[ "$split" == example ]]; then
      url="https://github.com/matterport/habitat-matterport-3dresearch/raw/main/example/$name"
    else
      url="https://api.matterport.com/resources/habitat/$name"
    fi
    if [[ "$LIST_ONLY" -eq 1 ]]; then printf '%s\t%s\n' "$name" "$url"; continue; fi
    destination="$TARGET_DIR/$split/$name"
    if [[ -f "$destination" ]]; then echo "[skip] $destination"; continue; fi
    mkdir -p -- "$TARGET_DIR/$split"
    AUTH_ARGS=()
    if [[ "$split" != example ]]; then AUTH_ARGS=(--netrc-file "$NETRC_FILE"); fi
    echo "[download] $name"
    if curl --fail --location --retry 5 --connect-timeout 30 --continue-at - \
      ${AUTH_ARGS[@]+"${AUTH_ARGS[@]}"} --output "$destination.part" "$url"; then
      mv -- "$destination.part" "$destination"
    else
      echo "Download failed: $name. Partial data retained. Check access/credentials if HTTP 401/403." >&2
      exit 1
    fi
  done
done
