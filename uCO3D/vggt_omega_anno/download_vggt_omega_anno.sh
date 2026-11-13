#!/usr/bin/env bash
# Download uCO3D vggt_omega_anno (facebook/uco3d on Hugging Face, ~7.59 TB, 228 tar shards)
# with the hf CLI (pip install -U huggingface_hub; no login needed) — see README.md.
#
# Usage: ./download_vggt_omega_anno.sh [-o OUTPUT_ROOT] [-x] [SHARD_PATTERN ...]
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/uCO3D
#   -x               extract each shard after downloading (into OUTPUT_ROOT/vggt_omega_anno/)
#   SHARD_PATTERN    optional glob(s) on shard names to download a subset, e.g. '0*' '1a*'
#                    (default: all shards)
#
# Downloads are resumable: re-run the same command; finished files are skipped.

OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/uCO3D
EXTRACT=0
while getopts "o:xh" opt; do
  case "$opt" in
    o) OUTPUT_ROOT="$OPTARG" ;;
    x) EXTRACT=1 ;;
    *) sed -n '2,12p' "$0"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
PATTERNS=("$@")
[ ${#PATTERNS[@]} -eq 0 ] && PATTERNS=("*")

command -v hf >/dev/null || { echo "hf CLI not found: pip install -U huggingface_hub" >&2; exit 1; }

INCLUDE=()
for p in "${PATTERNS[@]}"; do INCLUDE+=(--include "vggt_omega_anno/${p%.tar}.tar"); done

mkdir -p "$OUTPUT_ROOT" || exit 1
cd "$OUTPUT_ROOT" || exit 1
echo "Output: $(pwd)/vggt_omega_anno | shards: ${PATTERNS[*]} | extract: $EXTRACT"

if ! hf download facebook/uco3d --repo-type dataset "${INCLUDE[@]}" --local-dir .; then
  echo "Download failed; re-run this script to resume." >&2
  exit 1
fi

if [ "$EXTRACT" -eq 1 ]; then
  cd vggt_omega_anno || exit 1
  for f in *.tar; do
    [ -f "$f" ] || continue
    match=0
    for p in "${PATTERNS[@]}"; do
      # shellcheck disable=SC2254
      case "$f" in ${p%.tar}.tar) match=1 ;; esac
    done
    [ "$match" -eq 1 ] || continue
    [ -f ".$f.extracted" ] && continue
    echo "=== extract $f"
    tar -xf "$f" && touch ".$f.extracted" || { echo "[fail] extract $f" >&2; exit 1; }
  done
fi
echo "All files downloaded."
