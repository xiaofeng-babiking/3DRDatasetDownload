#!/usr/bin/env bash
# Download TartanAir (v1) training data — see README.md.
# File list: download_training_zipfiles.txt (copied from
# https://github.com/castacks/tartanair_tools, "<env>/<Easy|Hard>/<type>.zip <size GB>").
#
# Usage: ./download_tartanair.sh [-o OUTPUT_ROOT] [-s SOURCE] [-x] [-n] [FILTER ...]
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/TartanAir
#   -s SOURCE        airlab (default; AirLab Ceph/Swift server, plain HTTPS, resumable)
#                    hf     Hugging Face mirror theairlabcmu/tartanair
#   -x               unzip after downloading (zips unpack to <env>/<Easy|Hard>/P0xx/...)
#   -n               dry run: only print the selected files and their total size
#   FILTER           keywords that select files; a file is kept when it matches every
#                    given group. Groups:
#                      modality: image depth seg flow_flow flow_mask
#                      camera:   left right
#                      level:    easy hard
#                      env:      any environment name, e.g. abandonedfactory office
#                    Default (no filter): everything, ~1.1 TB.
#   Examples:
#     ./download_tartanair.sh image left            # all left RGB images
#     ./download_tartanair.sh depth hard            # depth, both cameras, hard level
#     ./download_tartanair.sh -n office image depth # show size of office RGB+depth

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
LIST="$SCRIPT_DIR/download_training_zipfiles.txt"

OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/TartanAir
SOURCE=airlab
EXTRACT=0
DRYRUN=0
while getopts "o:s:xnh" opt; do
  case "$opt" in
    o) OUTPUT_ROOT="$OPTARG" ;;
    s) SOURCE="$OPTARG" ;;
    x) EXTRACT=1 ;;
    n) DRYRUN=1 ;;
    *) sed -n '2,25p' "$0"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

MODS=(); CAMS=(); LEVELS=(); ENVS=()
for a in "$@"; do
  case "$a" in
    image|depth|seg|flow_flow|flow_mask) MODS+=("$a") ;;
    flow) MODS+=(flow_flow flow_mask) ;;
    left|right) CAMS+=("$a") ;;
    easy) LEVELS+=(Easy) ;;
    hard) LEVELS+=(Hard) ;;
    *) ENVS+=("$a") ;;
  esac
done

in_list() { local x="$1"; shift; [ $# -eq 0 ] && return 0; local y; for y in "$@"; do [ "$x" = "$y" ] && return 0; done; return 1; }

[ -f "$LIST" ] || { echo "Missing $LIST" >&2; exit 1; }
FILES=(); TOTAL=0
while read -r path size; do
  [ -z "$path" ] && continue
  env=${path%%/*}; rest=${path#*/}; level=${rest%%/*}; name=${rest#*/}; name=${name%.zip}
  case "$name" in
    image_left|image_right|depth_left|depth_right|seg_left|seg_right)
      mod=${name%_*}; cam=${name##*_} ;;
    flow_flow|flow_mask) mod=$name; cam="" ;;
    *) mod=$name; cam="" ;;
  esac
  in_list "$env" "${ENVS[@]}" || continue
  in_list "$level" "${LEVELS[@]}" || continue
  in_list "$mod" "${MODS[@]}" || continue
  [ -n "$cam" ] && { in_list "$cam" "${CAMS[@]}" || continue; }
  FILES+=("$path")
  TOTAL=$(awk -v a="$TOTAL" -v b="$size" 'BEGIN {print a + b}')
done < "$LIST"

echo "Selected ${#FILES[@]} file(s), ~${TOTAL} GB | source: $SOURCE | output: $OUTPUT_ROOT"
[ ${#FILES[@]} -eq 0 ] && { echo "Nothing matched." >&2; exit 1; }
if [ "$DRYRUN" -eq 1 ]; then printf '%s\n' "${FILES[@]}"; exit 0; fi

mkdir -p "$OUTPUT_ROOT" || exit 1
cd "$OUTPUT_ROOT" || exit 1

FAILED=0
case "$SOURCE" in
  airlab)
    BASE=https://airlab-cloud.andrew.cmu.edu:8080/swift/v1/AUTH_ac8533a83cff4d48bc8c608ad222d330/tartanair
    for f in "${FILES[@]}"; do
      echo "=== $f"
      mkdir -p "$(dirname "$f")"
      wget -c -O "$f" "$BASE/$f" || { echo "[fail] $f" >&2; FAILED=1; }
    done ;;
  hf)
    command -v hf >/dev/null || { echo "hf CLI not found: pip install -U huggingface_hub" >&2; exit 1; }
    hf download theairlabcmu/tartanair --repo-type dataset --local-dir . "${FILES[@]}" || FAILED=1 ;;
  *) echo "Unknown source: $SOURCE (expected airlab or hf)" >&2; exit 1 ;;
esac

if [ "$EXTRACT" -eq 1 ]; then
  for f in "${FILES[@]}"; do
    [ -f "$f" ] || continue
    # archives already contain the <env>/<level>/P0xx/... prefix
    unzip -n -q "$f" -d . || { echo "[fail] unzip $f" >&2; FAILED=1; }
  done
fi

if [ "$FAILED" -ne 0 ]; then
  echo "Some downloads failed; re-run this script to resume." >&2
  exit 1
fi
echo "All files downloaded."
