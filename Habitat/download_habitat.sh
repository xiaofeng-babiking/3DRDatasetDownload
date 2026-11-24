#!/usr/bin/env bash
# HM3D archive downloader. Archives are kept compressed.
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
usage() {
  cat <<'EOF'
Usage: bash Habitat/download_habitat.sh [options]
  --target_dir DIR    Default: ./data/Habitat
  --all               Download all 37 archives in both Matterport release tables,
                      including public examples. Other selectors can narrow this.
  --version VERSION   0.1, 0.2, or all. Selects archives from the release tables.
  --split NAME        train, val, minival, example, or all (default: train,val,minival;
                      with --all: includes example)
  --format NAME       habitat (default: BASIS mesh), glb, obj+mtl (v0.1), or all
  --netrc FILE        curl netrc containing Matterport API token ID/secret
                      Default: $HOME/.netrc (required except example/--list)
  --without_semantics Skip semantic annotation/config archives
  --list              List filenames and official URLs without downloading
  -h, --help          Show this help

Default: HM3D v0.2 habitat meshes, Habitat-Sim scene configs, and semantics.
Use --all --list to print the complete official catalog without credentials.
Request access and API credentials through the official HM3D/Matterport site:
https://github.com/matterport/habitat-matterport-3dresearch
Example archives are public. Requires curl; resumable with speed display.
EOF
}
TARGET_DIR=/Volumes/Expansion1/3DRDatasets/Habitat
ALL_ARCHIVES=0
VERSION=
SPLIT=all
FORMAT=
NETRC_FILE="${HOME}/.netrc"
SEMANTICS=1
LIST_ONLY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target_dir|--version|--split|--format|--netrc)
      [[ $# -ge 2 && -n "$2" ]] || { echo "Missing value for $1" >&2; exit 2; }
      case "$1" in
        --target_dir) TARGET_DIR="$2" ;;
        --version)
          case "$2" in
            0.1|v0.1|0.2|v0.2|all) VERSION="${2#v}" ;;
            *) echo "Unknown version: $2" >&2; exit 2 ;;
          esac ;;
        --split) SPLIT="$2" ;;
        --format) FORMAT="$2" ;;
        --netrc) NETRC_FILE="$2" ;;
      esac
      shift 2 ;;
    --all) ALL_ARCHIVES=1; shift ;;
    --without_semantics) SEMANTICS=0; shift ;;
    --list) LIST_ONLY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done
if [[ "$ALL_ARCHIVES" -eq 1 ]]; then
  VERSION=${VERSION:-all}
  FORMAT=${FORMAT:-all}
fi
FORMAT=${FORMAT:-habitat}
case "$SPLIT" in
  all|train|val|minival|example) ;;
  *) echo "Unknown split: $SPLIT" >&2; exit 2 ;;
esac
case "$FORMAT" in
  habitat|glb|all) ;;
  obj+mtl)
    [[ "$VERSION" != 0.2 ]] || { echo 'OBJ+MTL archives are available in v0.1 only.' >&2; exit 2; }
    VERSION=0.1 ;;
  *) echo "Unknown format: $FORMAT" >&2; exit 2 ;;
esac
source "$SCRIPT_DIR/../scripts/download_common.sh"
if [[ "$LIST_ONLY" -eq 0 ]]; then
  require_command curl
  if [[ "$SPLIT" != example && ! -f "$NETRC_FILE" ]]; then
    echo "Missing Matterport credential file: $NETRC_FILE" >&2
    echo "Use --netrc FILE; format: machine api.matterport.com login TOKEN_ID password TOKEN_SECRET" >&2
    exit 2
  fi
fi

# Manifest columns: release, split, format, download URL. The "sim" entries
# supply the original Habitat-Sim preset's additional scene configs. The
# example scene config is shared with the v0.1 table and is listed only once.
while read -r release split format url; do
  case "$VERSION" in
    '')  [[ "$release" == 0.2 || "$format" == configs ]] || continue ;;
    all) [[ "$release" != sim ]] || continue ;;
    *)   [[ "$release" == "$VERSION" ]] || continue ;;
  esac
  if [[ "$SPLIT" == all ]]; then
    [[ "$ALL_ARCHIVES" -eq 1 || "$split" != example ]] || continue
  else
    [[ "$split" == "$SPLIT" ]] || continue
  fi
  case "$format" in
    semantic-*) [[ "$SEMANTICS" -eq 1 ]] || continue ;;
    configs) ;; # Scene configs accompany any selected mesh format.
    *) [[ "$FORMAT" == all || "$FORMAT" == "$format" ]] || continue ;;
  esac

  name=${url##*/}
  if [[ "$LIST_ONLY" -eq 1 ]]; then printf '%s\t%s\n' "$name" "$url"; continue; fi
  destination="$TARGET_DIR/$split/$name"
  if [[ -f "$destination" ]]; then echo "[skip] $destination"; continue; fi
  mkdir -p -- "$TARGET_DIR/$split"
  AUTH_ARGS=()
  if [[ "$url" == https://api.matterport.com/* ]]; then AUTH_ARGS=(--netrc-file "$NETRC_FILE"); fi
  echo "[download] $name"
  if curl --fail --location --retry 5 --connect-timeout 30 --continue-at - \
    ${AUTH_ARGS[@]+"${AUTH_ARGS[@]}"} --output "$destination.part" "$url"; then
    mv -- "$destination.part" "$destination"
  else
    echo "Download failed: $name. Partial data retained. Check access/credentials if HTTP 401/403." >&2
    exit 1
  fi
done <<'ARCHIVES'
0.2 minival glb https://api.matterport.com/resources/habitat/hm3d-minival-glb-v0.2.tar
0.2 minival habitat https://api.matterport.com/resources/habitat/hm3d-minival-habitat-v0.2.tar
0.2 minival semantic-annots https://api.matterport.com/resources/habitat/hm3d-minival-semantic-annots-v0.2.tar
0.2 minival semantic-configs https://api.matterport.com/resources/habitat/hm3d-minival-semantic-configs-v0.2.tar
0.2 train glb https://api.matterport.com/resources/habitat/hm3d-train-glb-v0.2.tar
0.2 train habitat https://api.matterport.com/resources/habitat/hm3d-train-habitat-v0.2.tar
0.2 train semantic-annots https://api.matterport.com/resources/habitat/hm3d-train-semantic-annots-v0.2.tar
0.2 train semantic-configs https://api.matterport.com/resources/habitat/hm3d-train-semantic-configs-v0.2.tar
0.2 val glb https://api.matterport.com/resources/habitat/hm3d-val-glb-v0.2.tar
0.2 val habitat https://api.matterport.com/resources/habitat/hm3d-val-habitat-v0.2.tar
0.2 val semantic-annots https://api.matterport.com/resources/habitat/hm3d-val-semantic-annots-v0.2.tar
0.2 val semantic-configs https://api.matterport.com/resources/habitat/hm3d-val-semantic-configs-v0.2.tar
0.2 example glb https://github.com/matterport/habitat-matterport-3dresearch/raw/main/example/hm3d-example-glb-v0.2.tar
0.2 example habitat https://github.com/matterport/habitat-matterport-3dresearch/raw/main/example/hm3d-example-habitat-v0.2.tar
0.2 example semantic-annots https://github.com/matterport/habitat-matterport-3dresearch/raw/main/example/hm3d-example-semantic-annots-v0.2.tar
0.2 example semantic-configs https://github.com/matterport/habitat-matterport-3dresearch/raw/main/example/hm3d-example-semantic-configs-v0.2.tar
0.1 minival glb https://api.matterport.com/resources/habitat/hm3d-minival-glb.tar
0.1 minival habitat https://api.matterport.com/resources/habitat/hm3d-minival-habitat.tar
0.1 minival obj+mtl https://api.matterport.com/resources/habitat/hm3d-minival-obj+mtl.tar.gz
0.1 minival semantic-annots https://api.matterport.com/resources/habitat/hm3d-minival-semantic-annots-v0.1.tar.gz
0.1 minival semantic-configs https://api.matterport.com/resources/habitat/hm3d-minival-semantic-configs-v0.1.tar
0.1 train glb https://api.matterport.com/resources/habitat/hm3d-train-glb.tar
0.1 train habitat https://api.matterport.com/resources/habitat/hm3d-train-habitat.tar
0.1 train obj+mtl https://api.matterport.com/resources/habitat/hm3d-train-obj+mtl.tar.gz
0.1 train semantic-annots https://api.matterport.com/resources/habitat/hm3d-train-semantic-annots-v0.1.tar.gz
0.1 train semantic-configs https://api.matterport.com/resources/habitat/hm3d-train-semantic-configs-v0.1.tar
0.1 val glb https://api.matterport.com/resources/habitat/hm3d-val-glb.tar
0.1 val habitat https://api.matterport.com/resources/habitat/hm3d-val-habitat.tar
0.1 val obj+mtl https://api.matterport.com/resources/habitat/hm3d-val-obj+mtl.tar.gz
0.1 val semantic-annots https://api.matterport.com/resources/habitat/hm3d-val-semantic-annots-v0.1.tar.gz
0.1 val semantic-configs https://api.matterport.com/resources/habitat/hm3d-val-semantic-configs-v0.1.tar
0.1 example configs https://github.com/matterport/habitat-matterport-3dresearch/raw/main/example/hm3d-example-configs.tar
0.1 example glb https://github.com/matterport/habitat-matterport-3dresearch/raw/main/example/hm3d-example-glb.tar
0.1 example habitat https://github.com/matterport/habitat-matterport-3dresearch/raw/main/example/hm3d-example-habitat.tar
0.1 example obj+mtl https://github.com/matterport/habitat-matterport-3dresearch/raw/main/example/hm3d-example-obj+mtl.tar.gz
0.1 example semantic-annots https://github.com/matterport/habitat-matterport-3dresearch/raw/main/example/hm3d-example-semantic-annots-v0.1.tar.gz
0.1 example semantic-configs https://github.com/matterport/habitat-matterport-3dresearch/raw/main/example/hm3d-example-semantic-configs-v0.1.tar
sim train configs https://api.matterport.com/resources/habitat/hm3d-train-configs.tar
sim val configs https://api.matterport.com/resources/habitat/hm3d-val-configs.tar
sim minival configs https://api.matterport.com/resources/habitat/hm3d-minival-configs.tar
ARCHIVES
