#!/usr/bin/env bash
# Download BEHAVIOR-1K datasets with hf download (see README.md).
#
# Usage: ./download_behavior_1k.sh [-o OUTPUT_ROOT] [-t TASKS] [-m MODALITIES] [-c CAMERAS] [-n] PART ...
#   -o OUTPUT_ROOT   default: /Volumes/Expansion1/3DRDatasets/BEHAVIOR-1K
#   -t TASKS         (demos/rawdata) comma-separated task ids 0-49, e.g. 0,1,2 (default: all 50)
#   -m MODALITIES    (demos) comma-separated subset of rgb,depth,seg_instance_id (default: all)
#   -c CAMERAS       (demos) comma-separated subset of head,left_wrist,right_wrist (default: all)
#   -n               dry run: only list the selected files
#   PART             one or more of: demos rawdata assets assets_zip
#                      demos       2025 Challenge demo videos + states/actions (LeRobot), ~1.57 TB
#                      rawdata     raw HDF5 episodes of the same demos, ~793 GB
#                      assets      download the four asset ZIPs into OUTPUT_ROOT/zipped-datasets, ~32 GB
#                      assets_zip  alias for assets
#
# The Hugging Face CLI (hf) must be on PATH.
# Re-running the same command resumes (completed files are skipped).

set -e

usage() { sed -n '2,/^$/p' "$0"; }
die() { echo "$*" >&2; exit 1; }

if [[ "${1:-}" == --help ]]; then
  usage
  exit 0
fi

OUTPUT_ROOT=/Volumes/Expansion1/3DRDatasets/BEHAVIOR-1K
tasks=('task-*')
modalities=(rgb depth seg_instance_id)
cameras=(head left_wrist right_wrist)
hf_args=(--repo-type dataset)
while getopts "o:t:m:c:nh" opt; do
  case "$opt" in
    o) OUTPUT_ROOT="$OPTARG" ;;
    t)
      IFS=', ' read -r -a ids <<< "$OPTARG"
      [[ ${#ids[@]} -gt 0 ]] || die "Expected task IDs 0-49."
      tasks=()
      for id in "${ids[@]}"; do
        [[ $id =~ ^0*[0-4]?[0-9]$ ]] || die "Invalid task ID: $id (expected 0-49)"
        printf -v task 'task-%04d' "$((10#$id))"
        tasks+=("$task")
      done
      ;;
    m)
      IFS=', ' read -r -a modalities <<< "$OPTARG"
      [[ ${#modalities[@]} -gt 0 ]] || die "Expected at least one modality."
      for modality in "${modalities[@]}"; do
        case "$modality" in
          rgb|depth|seg_instance_id) ;;
          *) die "Invalid modality: $modality" ;;
        esac
      done
      ;;
    c)
      IFS=', ' read -r -a cameras <<< "$OPTARG"
      [[ ${#cameras[@]} -gt 0 ]] || die "Expected at least one camera."
      for camera in "${cameras[@]}"; do
        case "$camera" in
          head|left_wrist|right_wrist) ;;
          *) die "Invalid camera: $camera" ;;
        esac
      done
      ;;
    n) hf_args+=(--dry-run) ;;
    h) usage; exit 0 ;;
    *) usage >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
[[ $# -gt 0 ]] || { usage >&2; exit 1; }

for part in "$@"; do
  case "$part" in
    demos|rawdata|assets|assets_zip) ;;
    *) die "Unknown part: $part (expected demos, rawdata, assets or assets_zip)" ;;
  esac
done
command -v hf >/dev/null || die "Hugging Face CLI (hf) is required. Install it with: pip install -U huggingface_hub"

for part in "$@"; do
  case "$part" in
    demos)
      repo=2025-challenge-demos
      files=(--include README.md --include meta/info.json --include meta/tasks.jsonl
             --include meta/episodes.jsonl --include meta/episodes_stats.jsonl)
      for task in "${tasks[@]}"; do
        files+=(--include "data/$task/*" --include "annotations/$task/*" --include "meta/episodes/$task/*")
        for modality in "${modalities[@]}"; do
          for camera in "${cameras[@]}"; do
            files+=(--include "videos/$task/observation.images.$modality.$camera/*")
          done
        done
      done
      ;;
    rawdata)
      repo=2025-challenge-rawdata
      files=(--include README.md)
      for task in "${tasks[@]}"; do
        files+=(--include "$task/*")
      done
      ;;
    assets|assets_zip)
      repo=zipped-datasets
      files=(behavior-1k-assets-3.9.0.zip omnigibson-robot-assets-3.8.2.zip
             2025-challenge-task-instances.zip 2026-challenge-task-instances.zip)
      ;;
  esac
  hf download "behavior-1k/$repo" "${hf_args[@]}" --local-dir "$OUTPUT_ROOT/$repo" "${files[@]}"
done
