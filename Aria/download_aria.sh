#!/usr/bin/env bash
# Download official Project Aria CDN manifests; never extract archives.
set -euo pipefail
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<'EOF'
Usage: bash Aria/download_aria.sh [options]
  --dataset NAME       aea (default), adt, aeo, ase, ase-mesh, ase-atek,
                       adt-atek, gen2pilot, nymeria, dtc, reading,
                       hot3d-aria, hot3d-quest, hot3d-assets, custom
  --url_json FILE      Official signed *_download_urls.json
                       Default: Aria/urls/<dataset's official filename>
  --target_dir DIR    Default: ./data/Aria/<dataset>
  --n_workers N       Parallel downloads (default: 8)
  --config NAME       Select an ATEK configuration, e.g. efm or efm_eval
  --sequence GLOB     Select sequences; repeatable (quote wildcard patterns)
  --max_sequences N  Limit sequences per configuration
  --list              List selected filenames without downloading
  -h, --help          Show this help

First obtain a personal CDN JSON from https://www.projectaria.com/datasets/.
Requires Python 3 (standard library only). Downloads resume and verify SHA1;
speed is reported every 10 seconds. Archives remain compressed.
EOF
}

DATASET=aea
URL_JSON=""
TARGET_DIR=""
N_WORKERS=8
SELECT_ARGS=()
LIST_ONLY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dataset|--url_json|--target_dir|--n_workers|--config|--sequence|--max_sequences)
      [[ $# -ge 2 && -n "$2" ]] || { echo "Missing value for $1" >&2; exit 2; }
      case "$1" in
        --dataset) DATASET="$2" ;;
        --url_json) URL_JSON="$2" ;;
        --target_dir) TARGET_DIR="$2" ;;
        --n_workers) N_WORKERS="$2" ;;
        *) SELECT_ARGS+=("$1" "$2") ;;
      esac
      shift 2 ;;
    --list) LIST_ONLY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done
case "$DATASET" in
  aea) JSON_NAME=AriaEverydayActivities_download_urls.json ;;
  adt) JSON_NAME=ADT_download_urls.json ;;
  aeo) JSON_NAME=AEO_download_urls.json ;;
  ase) JSON_NAME=aria_synthetic_environments_dataset_download_urls.json ;;
  ase-mesh) JSON_NAME=ase_mesh_download_urls.json ;;
  ase-atek) JSON_NAME=AriaSyntheticEnvironment_ATEK_download_urls.json ;;
  adt-atek) JSON_NAME=AriaDigitalTwin_ATEK_download_urls.json ;;
  gen2pilot) JSON_NAME=gen2pilot_download_urls.json ;;
  nymeria) JSON_NAME=Nymeria_download_urls.json ;;
  dtc) JSON_NAME=DTC_download_urls.json ;;
  reading) JSON_NAME=ReadingInTheWild_download_urls.json ;;
  hot3d-aria) JSON_NAME=Hot3DAria_download_urls.json ;;
  hot3d-quest) JSON_NAME=Hot3DQuest_download_urls.json ;;
  hot3d-assets) JSON_NAME=Hot3DAssets_download_urls.json ;;
  custom) JSON_NAME="" ;;
  *) echo "Unknown dataset: $DATASET" >&2; exit 2 ;;
esac
[[ "$N_WORKERS" =~ ^[1-9][0-9]*$ ]] || { echo "--n_workers must be positive" >&2; exit 2; }
if [[ -z "$URL_JSON" && -n "$JSON_NAME" ]]; then URL_JSON="$SCRIPT_DIR/urls/$JSON_NAME"; fi
if [[ -z "$URL_JSON" || ! -f "$URL_JSON" ]]; then
  echo "Missing CDN JSON: ${URL_JSON:-use --url_json FILE}" >&2
  echo "Obtain it from https://www.projectaria.com/datasets/ and pass --url_json FILE." >&2
  exit 2
fi
command -v python3 >/dev/null || { echo "Python 3 is required" >&2; exit 2; }
TARGET_DIR="${TARGET_DIR:-./data/Aria/$DATASET}"
SELECTED_JSON="$(mktemp "${TMPDIR:-/tmp}/aria-selected.XXXXXX")"
trap 'rm -f -- "$SELECTED_JSON"' EXIT
if [[ "$LIST_ONLY" -eq 1 ]]; then SELECT_ARGS+=(--list); fi
python3 "$SCRIPT_DIR/select_download_urls.py" --input "$URL_JSON" --output "$SELECTED_JSON" ${SELECT_ARGS[@]+"${SELECT_ARGS[@]}"}
if [[ "$LIST_ONLY" -eq 1 ]]; then exit 0; fi
python3 "$SCRIPT_DIR/download_aria_script.py" --url_json "$SELECTED_JSON" \
  --output_dir "$TARGET_DIR" --num_workers "$N_WORKERS"
