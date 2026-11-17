#!/usr/bin/env bash
# Official Taskonomy distribution: https://github.com/StanfordVL/taskonomy/tree/master/data
# CLI: https://docs.omnidata.vision/starter_dataset_download.html
set -euo pipefail
usage() {
  cat <<'EOF'
Usage: download_taskonomy.sh [--target_dir DIR] [--domains LIST]
       [--subset debug|tiny|medium|full|fullplus] [--split train|val|test|all]
       [--n_workers N] [--connections_total N] [--dry-run]
Downloads only the Taskonomy component distributed by Omnidata.
Defaults: ./data/Taskonomy, domains=all, subset=fullplus, split=all, workers=8.
--domains LIST  Comma-separated modalities, e.g. rgb,depth_zbuffer,point_info.
--dry-run       Let the official downloader list work without fetching archives.
Requires omnidata-tools (omnitools.download) and aria2c.
The official license prompts remain interactive; this wrapper does not accept them.
Archives are retained and never extracted.
EOF
}
die() { printf 'Error: %s\n' "$*" >&2; exit 2; }
target_dir="./data/Taskonomy"
domains="all"
subset="fullplus"
split="all"
workers=8
connections=8
dry_run=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target_dir|--domains|--subset|--split|--n_workers|--connections_total)
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || die "$1 requires a value"
      case "$1" in
        --target_dir) target_dir="$2";; --domains) domains="$2";;
        --subset) subset="$2";; --split) split="$2";;
        --n_workers) workers="$2";; --connections_total) connections="$2";;
      esac
      shift 2;;
    --dry-run) dry_run=1; shift;;
    -h|--help) usage; exit 0;;
    *) die "unknown argument: $1";;
  esac
done
case "$subset" in debug|tiny|medium|full|fullplus) ;; *) die "invalid subset: $subset";; esac
case "$split" in train|val|test|all) ;; *) die "invalid split: $split";; esac
[[ "$workers" =~ ^[1-9][0-9]*$ && "$connections" =~ ^[1-9][0-9]*$ ]] || die "worker/connection counts must be positive integers"
IFS=',' read -r -a domain_args <<< "$domains"
for domain in "${domain_args[@]}"; do
  [[ "$domain" =~ ^[a-zA-Z0-9_]+$ ]] || die "invalid domain: $domain"
done
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../scripts/download_common.sh"
require_command omnitools.download
require_command aria2c
mkdir -p -- "$target_dir"
args=("${domain_args[@]}" --components taskonomy --subset "$subset" --split "$split"
      --dest "$target_dir" --dest_compressed "$target_dir"
      --only_download True --keep_compressed True
      --n_workers "$workers" --connections_total "$connections")
[[ "$dry_run" == 0 ]] || args+=(--dryrun)
exec omnitools.download "${args[@]}"
