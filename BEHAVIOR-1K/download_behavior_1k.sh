#!/usr/bin/env bash
# Download BEHAVIOR-1K data — wrapper around download_behavior_1k.py (see README.md).
#
# Usage: ./download_behavior_1k.sh [-o OUTPUT_ROOT] [-t TASKS] [-m MODALITIES] [-c CAMERAS] [-n] PART ...
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/BEHAVIOR-1K
#   -t TASKS         (demos/rawdata) comma-separated task ids 0-49, e.g. 0,1,2 (default: all 50)
#   -m MODALITIES    (demos) comma-separated subset of rgb,depth,seg_instance_id (default: all)
#   -c CAMERAS       (demos) comma-separated subset of head,left_wrist,right_wrist (default: all)
#   -n               dry run: only list the selected files (HF parts)
#   PART             one or more of: demos rawdata assets assets_zip
#                      demos       2025 Challenge demo videos + states/actions (LeRobot), ~1.57 TB
#                      rawdata     raw HDF5 episodes of the same demos, ~793 GB
#                      assets      OmniGibson scenes/objects via the official installer functions
#                                  (license prompt + decryption key; needs OmniGibson)
#                      assets_zip  only the encrypted asset archives, ~32 GB
#
# Environment:
#   PYTHON   interpreter to use (default: python3). For `assets`, point it at the Python of the
#            conda env where OmniGibson is installed, e.g. PYTHON=~/miniconda3/envs/behavior/bin/python
#
# Missing packages from requirements.txt are installed into that interpreter automatically.
# Re-running the same command resumes (completed files are skipped).

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PYTHON=${PYTHON:-python3}

OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/BEHAVIOR-1K
ARGS=()
while getopts "o:t:m:c:nh" opt; do
  case "$opt" in
    o) OUTPUT_ROOT="$OPTARG" ;;
    t) ARGS+=(--tasks ${OPTARG//,/ }) ;;
    m) ARGS+=(--modalities ${OPTARG//,/ }) ;;
    c) ARGS+=(--cameras ${OPTARG//,/ }) ;;
    n) ARGS+=(--dry-run) ;;
    *) sed -n '2,23p' "$0"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
[ $# -eq 0 ] && { sed -n '2,23p' "$0"; exit 1; }

command -v "$PYTHON" >/dev/null || { echo "Python not found: $PYTHON" >&2; exit 1; }
if ! "$PYTHON" -c "import huggingface_hub" 2>/dev/null; then
  echo "Installing requirements into $("$PYTHON" -c 'import sys; print(sys.executable)') ..."
  "$PYTHON" -m pip install -r "$SCRIPT_DIR/requirements.txt" || exit 1
fi

# PART names go first: the list-valued options would otherwise swallow them.
exec "$PYTHON" "$SCRIPT_DIR/download_behavior_1k.py" "$@" -o "$OUTPUT_ROOT" "${ARGS[@]}"
