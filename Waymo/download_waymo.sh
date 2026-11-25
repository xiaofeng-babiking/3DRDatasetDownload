#!/usr/bin/env bash
# Buckets are linked from https://waymo.com/intl/en-ca/open/download/
# Default: the three requested releases (E2E 1.0.0, Motion 1.3.1, Perception 2.0.1).
set -euo pipefail
usage() {
  cat <<'EOF'
Usage: download_waymo.sh [--target_dir DIR] [--release NAME ...] [--prefix PATH]
                        [--list | --dry-run]
Defaults: /Volumes/Expansion1/3DRDatasets/Waymo, release=all, all data for the three releases below.
Releases:
  all            end-to-end + motion + perception-v2 (default)
  end-to-end     End-to-End Driving 1.0.0 (camera)
  motion         Motion 1.3.1
  perception-v2  Perception 2.0.1 (modular, Parquet)
  perception-v1  Legacy Perception 1.4.3 (with maps, TFRecords; excluded from all)
Repeat --release to select multiple releases, e.g. --release motion --release end-to-end.
--prefix PATH   Restrict to an existing directory in the bucket, e.g.
                training/camera_image for perception-v2. Requires one release.
--list          List the selected bucket prefixes; do not download.
--dry-run       Preview synchronization; do not download.
Files are saved under DIR/<release>/<bucket-relative-path>.
Whole-bucket sync uses gsutil from the Google Cloud CLI. First obtain access at https://waymo.com/open/download/
and run gcloud auth login yourself. The wrapper never logs in or accepts terms.
Dataset archives are not unpacked.

Examples:
  bash Waymo/download_waymo.sh --list
  bash Waymo/download_waymo.sh --target_dir /path/to/Waymo --dry-run
  bash Waymo/download_waymo.sh --target_dir /path/to/Waymo
  bash Waymo/download_waymo.sh --release motion
  bash Waymo/download_waymo.sh --release perception-v2 --release end-to-end
  bash Waymo/download_waymo.sh --release motion --release end-to-end
  bash Waymo/download_waymo.sh --release perception-v2 --prefix training/camera_image
EOF
}
die() { printf 'Error: %s\n' "$*" >&2; exit 2; }
target_dir="/Volumes/Expansion1/3DRDatasets/Waymo"
releases=()
prefix=""
list_only=0
dry_run=0

add_release() {
  local candidate="$1" existing
  # Bash 3.2 treats an empty array as unset with set -u.
  for existing in ${releases[@]+"${releases[@]}"}; do
    [[ "$existing" != "$candidate" ]] || return 0
  done
  releases+=("$candidate")
}

select_release() {
  case "$1" in
    all) add_release end-to-end; add_release motion; add_release perception-v2 ;;
    end-to-end|motion|perception-v2|perception-v1) add_release "$1" ;;
    *) die "invalid release: $1" ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target_dir|--release|--prefix)
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || die "$1 requires a value"
      case "$1" in --target_dir) target_dir="$2";; --release) select_release "$2";; --prefix) prefix="$2";; esac
      shift 2;;
    --list) list_only=1; shift;;
    --dry-run) dry_run=1; shift;;
    -h|--help) usage; exit 0;;
    *) die "unknown argument: $1";;
  esac
done
[[ ${#releases[@]} -gt 0 ]] || select_release all
[[ "$prefix" != /* ]] || die "prefix must be a relative bucket directory"
prefix=${prefix%/}
case "/$prefix/" in *"/../"*|*"/./"*|*"//"*) [[ -z "$prefix" ]] || die "prefix must be a relative bucket directory";; esac
[[ "$prefix" != *"*"* && "$prefix" != *"?"* && "$prefix" != *"["* && "$prefix" != *$'\n'* && "$prefix" != *$'\r'* ]] || die "prefix must not contain wildcards or newlines"
[[ -z "$prefix" || ${#releases[@]} -eq 1 ]] || die "--prefix requires exactly one --release; bucket directory layouts differ"
[[ ! ( "$list_only" == 1 && "$dry_run" == 1 ) ]] || die "--list and --dry-run are mutually exclusive"
[[ "$target_dir" != *://* ]] || die "--target_dir must be a local directory"
# An absolute destination keeps names beginning with '-' from becoming CLI flags.
[[ "$target_dir" == /* ]] || target_dir="$PWD/$target_dir"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../scripts/download_common.sh"
require_command gcloud

rsync_flags=(--recursive)
bucket_sync=(gsutil -o 'GSUtil:use_gcloud_storage=False')
preview_dir=""
if [[ "$list_only" == 0 && -n "$prefix" ]]; then
  rsync_help=$(CLOUDSDK_PAGER=cat gcloud storage rsync --help) || die 'cannot read gcloud storage rsync help'
  if [[ "$rsync_help" == *--do-not-decompress* ]]; then
    rsync_flags+=(--do-not-decompress)
  fi
  [[ "$dry_run" == 0 ]] || rsync_flags+=(--dry-run)
elif [[ "$list_only" == 0 ]]; then
  # gcloud rsync requests storage.buckets.get at bucket roots. Native gsutil
  # rsync enumerates objects, including files stored directly at the root.
  require_command gsutil
  if [[ "$OSTYPE" == darwin* ]]; then bucket_sync+=(-o 'GSUtil:parallel_process_count=1'); fi
  bucket_sync+=(-m rsync -r -e)
  [[ "$dry_run" == 0 ]] || bucket_sync+=(-n)
fi

failed_releases=()
for release in "${releases[@]}"; do
  case "$release" in
    end-to-end) bucket="waymo_open_dataset_end_to_end_camera_v_1_0_0" ;;
    motion) bucket="waymo_open_dataset_motion_v_1_3_1" ;;
    perception-v2) bucket="waymo_open_dataset_v_2_0_1" ;;
    perception-v1) bucket="waymo_open_dataset_v_1_4_3" ;;
  esac
  source_uri="gs://$bucket"
  destination="$target_dir/$release"
  if [[ -n "$prefix" ]]; then
    source_uri="$source_uri/$prefix"
    destination="$destination/$prefix"
  fi
  printf '\n=== %s: %s -> %s\n' "$release" "$source_uri" "$destination"
  if [[ "$list_only" == 1 ]]; then
    cmd=(gcloud storage ls "$source_uri/")
  else
    if [[ "$dry_run" == 0 ]]; then
      if ! mkdir -p -- "$destination"; then
        failed_releases+=("$release")
        continue
      fi
    fi
    if [[ -n "$prefix" ]]; then
      cmd=(gcloud storage rsync "$source_uri" "$destination" "${rsync_flags[@]}")
    else
      if [[ "$dry_run" == 1 && ! -e "$destination" && ! -L "$destination" ]]; then
        # gsutil needs an existing directory even in preview mode. Compare
        # against an empty temp directory without creating the requested target.
        if [[ -z "$preview_dir" ]]; then
          preview_dir=$(mktemp -d "${TMPDIR:-/tmp}/waymo-preview.XXXXXXXX")
          trap 'rmdir -- "$preview_dir"' EXIT
        fi
        printf 'Previewing new destination %s using empty directory %s\n' "$destination" "$preview_dir"
        destination="$preview_dir"
      fi
      cmd=("${bucket_sync[@]}" "$source_uri/" "$destination")
    fi
  fi
  if "${cmd[@]}"; then
    printf '[done] %s\n' "$release"
  else
    download_status=$?
    [[ "$download_status" != 130 && "$download_status" != 143 ]] || exit "$download_status"
    printf '[fail] %s (%s exit %s)\n' "$release" "${cmd[0]}" "$download_status" >&2
    failed_releases+=("$release")
  fi
done
if [[ ${#failed_releases[@]} -gt 0 ]]; then
  printf 'Failed releases: %s\n' "${failed_releases[*]}" >&2
  printf '%s\n' 'For 401/403, check Waymo access and gcloud auth login. Re-run to resume downloads.' >&2
  exit 1
fi
