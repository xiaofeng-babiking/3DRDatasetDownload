#!/usr/bin/env bash
# Download BlendedMVS / BlendedMVS+ / BlendedMVS++ / high-res set / supplementaries
# from the GitHub releases of https://github.com/YoYo000/BlendedMVS (see README.md).
#
# Usage: ./download_blended_mvs.sh [-o OUTPUT_ROOT] [-u] [SUBSET ...]
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/BlendedMVS
#   -u               after downloading, join the split zips and unzip them
#   SUBSET           any of: mvs mvs+ mvs++ highres supp all   (default: all)
#                      mvs     BlendedMVS   low-res  (768x576)   ~27.5 GB
#                      mvs+    BlendedMVS+  low-res  (768x576)   ~81.5 GB
#                      mvs++   BlendedMVS++ low-res  (768x576)   ~80.0 GB
#                      highres BlendedMVS   high-res (2048x1536) ~156 GB
#                      supp    textured meshes (~9.42 GB) + other images (~7.56 GB)
#
# Downloads are resumable (wget -c): re-run the same command to continue.

OUTPUT_ROOT=/Volumes/Expansion1/3DRDatasets/BlendedMVS
UNZIP=0
while getopts "o:uh" opt; do
  case "$opt" in
    o) OUTPUT_ROOT="$OPTARG" ;;
    u) UNZIP=1 ;;
    *) sed -n '2,15p' "$0"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
SUBSETS=("${@:-all}")

BASE_URL="https://github.com/YoYo000/BlendedMVS/releases/download"

mkdir -p "$OUTPUT_ROOT" || exit 1
cd "$OUTPUT_ROOT" || exit 1
echo "Output: $(pwd) | subsets: ${SUBSETS[*]} | unzip: $UNZIP"

# download <release tag> <name> <number of split files>
# Fetches <name>.z01 .. <name>.zNN and the final <name>.zip descriptor.
download() {
  local url="${BASE_URL}/$1" i
  for i in $(seq 1 "$3"); do
    wget -c "${url}/$2.z$(printf %02d "$i")" || return 1
  done
  wget -c "${url}/$2.zip" || return 1
  if [ "$UNZIP" -eq 1 ]; then
    zip -s 0 "$2.zip" --out "$2_joined.zip" && unzip -n "$2_joined.zip" && rm -f "$2_joined.zip"
  fi
}

get_subset() {
  case "$1" in
    # Note: upstream README shows a single BlendedMVS.zip, but the v1.0.0 release
    # is actually split into BlendedMVS.z01..z15 + BlendedMVS.zip.
    mvs)     download v1.0.0 BlendedMVS 15 ;;
    mvs+)    download v1.0.1 BlendedMVS1 42 ;;
    mvs++)   download v1.0.2 BlendedMVS2 42 ;;
    highres)
      download v1.0.3 dataset_full_res_0-29 46 &&
      download v1.0.3 dataset_full_res_30-59 9 &&
      download v1.0.3 dataset_full_res_60-89 13 &&
      download v1.0.3 dataset_full_res_90-112 12 ;;
    supp)
      download v1.0.4 dataset_textured_meshes 4 &&
      download v1.0.4 BlendedMVS_supp 3 ;;
    all)
      for s in mvs mvs+ mvs++ highres supp; do get_subset "$s" || return 1; done ;;
    *) echo "Unknown subset: $1 (expected: mvs mvs+ mvs++ highres supp all)"; return 2 ;;
  esac
}

for s in "${SUBSETS[@]}"; do
  echo "=== $s"
  get_subset "$s" || { echo "Failed: $s"; exit 1; }
done
echo "All files downloaded."
