#!/usr/bin/env bash
# Buckets are linked from https://waymo.com/open/download/
set -euo pipefail
usage() {
  cat <<'EOF'
Usage: download_waymo.sh [--target_dir DIR] [--release NAME] [--prefix PATH]
                        [--list | --dry-run]
Defaults: ./data/Waymo, release=perception-v2, entire selected release.
Releases:
  perception-v1  Perception 1.4.3 (with maps, TFRecords)
  perception-v2  Perception 2.0.1 (modular, Parquet)
  motion         Motion 1.3.1
  end-to-end     End-to-End Driving 1.0.0
--prefix PATH   Restrict to an existing directory in the bucket, e.g.
                training/camera_image for perception-v2.
--list          List the selected bucket prefix; do not download.
--dry-run       Preview synchronization; do not download.
Requires Google Cloud CLI. First obtain access at https://waymo.com/open/download/
and run gcloud auth login yourself. The wrapper never logs in or accepts terms.
Only downloads; archives and compressed objects remain compressed.
EOF
}
die() { printf 'Error: %s\n' "$*" >&2; exit 2; }
target_dir="./data/Waymo"
release="perception-v2"
prefix=""
list_only=0
dry_run=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target_dir|--release|--prefix)
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || die "$1 requires a value"
      case "$1" in --target_dir) target_dir="$2";; --release) release="$2";; --prefix) prefix="$2";; esac
      shift 2;;
    --list) list_only=1; shift;;
    --dry-run) dry_run=1; shift;;
    -h|--help) usage; exit 0;;
    *) die "unknown argument: $1";;
  esac
done
case "$release" in
  perception-v1) bucket="waymo_open_dataset_v_1_4_3";;
  perception-v2) bucket="waymo_open_dataset_v_2_0_1";;
  motion) bucket="waymo_open_dataset_motion_v_1_3_1";;
  end-to-end) bucket="waymo_open_dataset_end_to_end_camera_v_1_0_0";;
  *) die "invalid release: $release";;
esac
case "/$prefix/" in *"/../"*|*"/./"*|*"//"*) [[ -z "$prefix" ]] || die "prefix must be a relative bucket directory";; esac
[[ "$prefix" != *"*"* && "$prefix" != *"?"* && "$prefix" != *"["* && "$prefix" != *$'\n'* ]] || die "prefix must not contain wildcards or newlines"
[[ ! ( "$list_only" == 1 && "$dry_run" == 1 ) ]] || die "--list and --dry-run are mutually exclusive"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../scripts/download_common.sh"
require_command gcloud
source_uri="gs://$bucket"
destination="$target_dir/$release"
if [[ -n "$prefix" ]]; then
  source_uri="$source_uri/$prefix"
  destination="$destination/$prefix"
fi
if [[ "$list_only" == 1 ]]; then
  exec gcloud storage ls "$source_uri/"
fi
mkdir -p -- "$destination"
args=(storage rsync "$source_uri" "$destination" --recursive --do-not-decompress)
[[ "$dry_run" == 0 ]] || args+=(--dry-run)
# No delete flag: unrelated local files are preserved. rsync skips matching files.
exec gcloud "${args[@]}"
