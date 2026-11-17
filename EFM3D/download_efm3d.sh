#!/usr/bin/env bash
# EFM3D benchmark data: ASE, ADT and AEO. Archives are never extracted.
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
usage() {
  cat <<'EOF'
Usage: bash EFM3D/download_efm3d.sh [options]
  --subset NAME       all (default), ase-train, ase-eval, ase-mesh, adt,
                      adt-mesh, aeo
  --urls_dir DIR      Official CDN JSON directory (default: ../Aria/urls)
  --url_json FILE     Override the CDN JSON for a single subset
  --target_dir DIR   Default: ./data/EFM3D
  --n_workers N      Parallel downloads (default: 8)
  --max_sequences N Limit sequences in ASE/ADT/AEO (not mesh archives)
  --list             List selected filenames/URLs without downloading
  -h, --help         Show this help

ASE train/eval selects ATEK configs efm/efm_eval. ADT selects the six official
evaluation sequences. Download the personal JSONs from projectaria.com first.
The ADT mesh ZIP is public and needs no JSON. Requires Python 3 and, for that
ZIP, wget or curl. Resume, SHA1 (when supplied), speed; no extraction.
EOF
}
SUBSET=all
URLS_DIR="$SCRIPT_DIR/../Aria/urls"
URL_JSON=""
TARGET_DIR=./data/EFM3D
N_WORKERS=8
MAX_SEQUENCES=""
LIST_ONLY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --subset|--urls_dir|--url_json|--target_dir|--n_workers|--max_sequences)
      [[ $# -ge 2 && -n "$2" ]] || { echo "Missing value for $1" >&2; exit 2; }
      case "$1" in
        --subset) SUBSET="$2" ;;
        --urls_dir) URLS_DIR="$2" ;;
        --url_json) URL_JSON="$2" ;;
        --target_dir) TARGET_DIR="$2" ;;
        --n_workers) N_WORKERS="$2" ;;
        --max_sequences) MAX_SEQUENCES="$2" ;;
      esac
      shift 2 ;;
    --list) LIST_ONLY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done
[[ "$N_WORKERS" =~ ^[1-9][0-9]*$ ]] || { echo "--n_workers must be positive" >&2; exit 2; }
[[ -z "$MAX_SEQUENCES" || "$MAX_SEQUENCES" =~ ^[1-9][0-9]*$ ]] || { echo "--max_sequences must be positive" >&2; exit 2; }
case "$SUBSET" in
  all) SUBSETS=(ase-train ase-eval ase-mesh adt adt-mesh aeo) ;;
  ase-train|ase-eval|ase-mesh|adt|adt-mesh|aeo) SUBSETS=("$SUBSET") ;;
  *) echo "Unknown subset: $SUBSET" >&2; exit 2 ;;
esac
[[ "$SUBSET" != all || -z "$URL_JSON" ]] || { echo "--url_json requires a single --subset" >&2; exit 2; }
MANIFESTS=()
for subset in "${SUBSETS[@]}"; do
  case "$subset" in
    ase-train|ase-eval) name=AriaSyntheticEnvironment_ATEK_download_urls.json ;;
    ase-mesh) name=ase_mesh_download_urls.json ;;
    adt) name=ADT_download_urls.json ;;
    aeo) name=AEO_download_urls.json ;;
    adt-mesh) MANIFESTS+=(""); continue ;;
  esac
  manifest="${URL_JSON:-$URLS_DIR/$name}"
  [[ -f "$manifest" ]] || { echo "Missing $manifest; obtain the official CDN JSON from https://www.projectaria.com/datasets/" >&2; exit 2; }
  MANIFESTS+=("$manifest")
done
source "$SCRIPT_DIR/../scripts/download_common.sh"
for ((i=0; i<${#SUBSETS[@]}; i++)); do
  subset="${SUBSETS[$i]}"
  if [[ "$subset" == adt-mesh ]]; then
    url=https://github.com/facebookresearch/efm3d/releases/download/v1.0/adt_mesh.zip
    if [[ "$LIST_ONLY" -eq 1 ]]; then printf 'adt_mesh.zip\t%s\n' "$url"; else download_file "$url" "$TARGET_DIR/adt-mesh/adt_mesh.zip"; fi
    continue
  fi
  ARGS=(--url_json "${MANIFESTS[$i]}" --target_dir "$TARGET_DIR/$subset" --n_workers "$N_WORKERS")
  case "$subset" in
    ase-train) ARGS+=(--dataset ase-atek --config efm) ;;
    ase-eval) ARGS+=(--dataset ase-atek --config efm_eval) ;;
    ase-mesh) ARGS+=(--dataset ase-mesh) ;;
    adt)
      ARGS+=(--dataset adt
        --sequence Apartment_release_work_seq106_M1292
        --sequence Apartment_release_work_seq136_M1292
        --sequence Apartment_release_decoration_seq136_M1292
        --sequence Apartment_release_decoration_seq138_M1292
        --sequence Apartment_release_recognition_seq136_M1292
        --sequence Apartment_release_recognition_seq140_M1292) ;;
    aeo) ARGS+=(--dataset aeo) ;;
  esac
  if [[ -n "$MAX_SEQUENCES" && "$subset" != ase-mesh ]]; then ARGS+=(--max_sequences "$MAX_SEQUENCES"); fi
  if [[ "$LIST_ONLY" -eq 1 ]]; then ARGS+=(--list); fi
  bash "$SCRIPT_DIR/../Aria/download_aria.sh" "${ARGS[@]}"
done
