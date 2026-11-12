#!/usr/bin/env bash
# Download BEHAVIOR-1K data (see README.md).
#
# Usage: ./download_behavior_1k.sh [-o OUTPUT_ROOT] [-t TASKS] [-m MODALITIES] [-c CAMERAS] PART ...
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/BEHAVIOR-1K
#   -t TASKS         (demos/rawdata) comma-separated task ids 0-49, e.g. 0,1,2 (default: all 50)
#   -m MODALITIES    (demos) comma-separated subset of rgb,depth,seg_instance_id (default: all)
#   -c CAMERAS       (demos) comma-separated subset of head,left_wrist,right_wrist (default: all)
#   PART             one or more of:
#     demos        2025 BEHAVIOR Challenge teleoperated demos, LeRobot v2.1 format
#                  (behavior-1k/2025-challenge-demos): 10,000 episodes, 50 tasks, R1Pro robot,
#                  RGB / depth / instance-seg videos of 3 cameras + states/actions/annotations,
#                  ~1.57 TB in total
#     rawdata      raw HDF5 episodes of the same demos (behavior-1k/2025-challenge-rawdata), ~793 GB
#     assets       scenes + 3D object assets for the OmniGibson simulator, installed with the
#                  official OmniGibson functions (shows the BEHAVIOR data license and asks you to
#                  accept it, downloads the decryption key). Needs OmniGibson installed, see README.
#     assets_zip   only fetch the (encrypted) asset archives from behavior-1k/zipped-datasets
#                  (behavior-1k-assets-3.9.0.zip ~31.5 GB, omnigibson-robot-assets-3.8.2.zip,
#                  2025/2026 challenge task instances); they are usable only after `assets`
#                  has installed the key.
#
# Hugging Face downloads (hf CLI, pip install -U huggingface_hub) skip completed files, so
# re-running the same command resumes.

OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/BEHAVIOR-1K
TASKS=""
MODS="rgb,depth,seg_instance_id"
CAMS="head,left_wrist,right_wrist"
while getopts "o:t:m:c:h" opt; do
  case "$opt" in
    o) OUTPUT_ROOT="$OPTARG" ;;
    t) TASKS="$OPTARG" ;;
    m) MODS="$OPTARG" ;;
    c) CAMS="$OPTARG" ;;
    *) sed -n '2,27p' "$0"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
[ $# -eq 0 ] && { sed -n '2,27p' "$0"; exit 1; }

mkdir -p "$OUTPUT_ROOT" || exit 1
cd "$OUTPUT_ROOT" || exit 1

need_hf() { command -v hf >/dev/null || { echo "hf CLI not found: pip install -U huggingface_hub" >&2; exit 1; }; }

# task-folder globs: "task-0000" ... or "task-*"
task_globs() {
  if [ -z "$TASKS" ]; then echo "task-*"; return; fi
  local t
  for t in ${TASKS//,/ }; do
    [[ "$t" =~ ^[0-9]+$ ]] && [ "$t" -le 49 ] || { echo "Invalid task id: $t (expected 0-49)" >&2; exit 1; }
    printf 'task-%04d\n' "$t"
  done
}

FAILED=0
for part in "$@"; do
  echo "=== $part"
  case "$part" in
    demos)
      need_hf
      INC=(--include 'README.md' --include 'meta/info.json' --include 'meta/tasks.jsonl'
           --include 'meta/episodes.jsonl' --include 'meta/episodes_stats.jsonl')
      for tg in $(task_globs); do
        INC+=(--include "data/$tg/*" --include "annotations/$tg/*" --include "meta/episodes/$tg/*")
        for m in ${MODS//,/ }; do
          case "$m" in rgb|depth|seg_instance_id) ;; *) echo "Invalid modality: $m" >&2; exit 1 ;; esac
          for c in ${CAMS//,/ }; do
            case "$c" in head|left_wrist|right_wrist) ;; *) echo "Invalid camera: $c" >&2; exit 1 ;; esac
            INC+=(--include "videos/$tg/observation.images.$m.$c/*")
          done
        done
      done
      hf download behavior-1k/2025-challenge-demos --repo-type dataset \
        --local-dir 2025-challenge-demos "${INC[@]}" || FAILED=1 ;;
    rawdata)
      need_hf
      INC=(--include 'README.md')
      for tg in $(task_globs); do INC+=(--include "$tg/*"); done
      hf download behavior-1k/2025-challenge-rawdata --repo-type dataset \
        --local-dir 2025-challenge-rawdata "${INC[@]}" || FAILED=1 ;;
    assets_zip)
      need_hf
      hf download behavior-1k/zipped-datasets --repo-type dataset --local-dir zipped-datasets \
        behavior-1k-assets-3.9.0.zip omnigibson-robot-assets-3.8.2.zip \
        2025-challenge-task-instances.zip 2026-challenge-task-instances.zip || FAILED=1 ;;
    assets)
      python3 -c "import omnigibson" 2>/dev/null || {
        echo "OmniGibson is not importable. Install it first (see README.md):" >&2
        echo "  git clone https://github.com/StanfordVL/BEHAVIOR-1K && cd BEHAVIOR-1K && ./setup.sh --new-env --omnigibson --bddl" >&2
        FAILED=1; continue; }
      # OmniGibson stores the data in its configured data path (OMNIGIBSON_DATA_PATH);
      # point it at OUTPUT_ROOT/omnigibson-data unless the user already set it.
      export OMNIGIBSON_DATA_PATH="${OMNIGIBSON_DATA_PATH:-$OUTPUT_ROOT/omnigibson-data}"
      export OMNI_KIT_ACCEPT_EULA=YES
      echo "OMNIGIBSON_DATA_PATH=$OMNIGIBSON_DATA_PATH"
      python3 -c "from omnigibson.utils.asset_utils import download_omnigibson_robot_assets; download_omnigibson_robot_assets()" &&
      python3 -c "from omnigibson.utils.asset_utils import download_behavior_1k_assets; download_behavior_1k_assets()" &&
      python3 -c "from omnigibson.utils.asset_utils import download_2026_challenge_task_instances; download_2026_challenge_task_instances()" \
        || FAILED=1 ;;
    *) echo "Unknown part: $part (expected demos rawdata assets assets_zip)" >&2; FAILED=1 ;;
  esac
done

if [ "$FAILED" -ne 0 ]; then
  echo "Some downloads failed; re-run this script to resume." >&2
  exit 1
fi
echo "All files downloaded."
