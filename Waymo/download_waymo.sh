#!/usr/bin/env bash
# Buckets are linked from https://waymo.com/intl/en-ca/open/download/
# Default: the three requested releases (E2E 1.0.0, Motion 1.3.1, Perception 2.0.1).
set -euo pipefail
usage() {
  cat <<'EOF'
Usage: download_waymo.sh [--target_dir DIR] [--release NAME ...] [--prefix PATH]
                        [--list | --dry-run]
Defaults: ./data/Waymo, release=all, entire buckets for the three releases below.
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
Requires Google Cloud CLI. First obtain access at https://waymo.com/open/download/
and run gcloud auth login yourself. The wrapper never logs in or accepts terms.
Only downloads; archives and compressed objects remain compressed.

Examples:
  bash Waymo/download_waymo.sh --list
  bash Waymo/download_waymo.sh --target_dir /path/to/Waymo --dry-run
  bash Waymo/download_waymo.sh --target_dir /path/to/Waymo
  bash Waymo/download_waymo.sh --release motion --release end-to-end
  bash Waymo/download_waymo.sh --release perception-v2 --prefix training/camera_image
EOF
}
die() { printf 'Error: %s\n' "$*" >&2; exit 2; }
target_dir="./data/Waymo"
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
if [[ "$list_only" == 0 ]]; then
  rsync_help=$(CLOUDSDK_PAGER=cat gcloud storage rsync --help) || die 'cannot read gcloud storage rsync help'
  # CLI 576.0.0 introduced this flag and changed the default to decompress.
  # Older versions already preserve gzip objects and reject the new flag.
  if [[ "$rsync_help" == *--do-not-decompress* ]]; then
    rsync_flags+=(--do-not-decompress)
  fi
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
    args=(storage ls "$source_uri/")
  else
    if [[ "$dry_run" == 0 ]]; then
      if ! mkdir -p -- "$destination"; then
        failed_releases+=("$release")
        continue
      fi
    fi
    args=(storage rsync "$source_uri" "$destination" "${rsync_flags[@]}")
    [[ "$dry_run" == 0 ]] || args+=(--dry-run)
  fi
  # Releases run in order; gcloud parallelizes file transfers within each release.
  if gcloud "${args[@]}"; then
    printf '[done] %s\n' "$release"
  else
    download_status=$?
    [[ "$download_status" != 130 && "$download_status" != 143 ]] || exit "$download_status"
    printf '[fail] %s (gcloud exit %s)\n' "$release" "$download_status" >&2
    failed_releases+=("$release")
  fi
done
if [[ ${#failed_releases[@]} -gt 0 ]]; then
  printf 'Failed releases: %s\n' "${failed_releases[*]}" >&2
  printf '%s\n' 'For 401/403, check Waymo access and gcloud auth login. Re-run to resume downloads.' >&2
  exit 1
fi
