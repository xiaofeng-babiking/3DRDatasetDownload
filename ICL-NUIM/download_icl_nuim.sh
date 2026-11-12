#!/usr/bin/env bash
# Download ICL-NUIM (living room + office room, kt0-kt3) from
# https://www.doc.ic.ac.uk/~ahanda/VaFRIC/iclnuim.html (see README.md).
#
# Usage: ./download_icl_nuim.sh [-o OUTPUT_ROOT] [-x] [FORMAT ...]
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/ICL-NUIM
#   -x               extract the archives after downloading
#   FORMAT           any of: tum tum_noise icl gt all   (default: tum gt)
#                      tum        TUM RGB-D compatible PNGs (noise-free)
#                      tum_noise  TUM RGB-D compatible PNGs with simulated Kinect noise
#                      icl        original ICL-NUIM PNGs (+ per-frame pose files)
#                      gt         ground-truth trajectories (*.gt.freiburg, living room *.gt.sim)
#
# Downloads are resumable (wget -c): re-run the same command to continue.

OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/ICL-NUIM
EXTRACT=0
while getopts "o:xh" opt; do
  case "$opt" in
    o) OUTPUT_ROOT="$OPTARG" ;;
    x) EXTRACT=1 ;;
    *) sed -n '2,15p' "$0"; exit 1 ;;
  esac
done
shift $((OPTIND - 1))
FORMATS=("$@")
[ ${#FORMATS[@]} -eq 0 ] && FORMATS=(tum gt)

BASE=http://www.doc.ic.ac.uk/~ahanda

mkdir -p "$OUTPUT_ROOT" || exit 1
cd "$OUTPUT_ROOT" || exit 1
echo "Output: $(pwd) | formats: ${FORMATS[*]} | extract: $EXTRACT"

FAILED=0
fetch() {  # fetch <url> <subdir>
  local dir="$2" f name
  mkdir -p "$dir"
  wget -c -P "$dir" "$1" || { echo "[fail] $1" >&2; FAILED=1; return 1; }
  if [ "$EXTRACT" -eq 1 ]; then
    f="$dir/$(basename "$1")"
    case "$f" in
      *.tar.gz|*.tgz)
        name=$(basename "$f"); name=${name%.tar.gz}; name=${name%.tgz}
        mkdir -p "$dir/$name" && tar -xzf "$f" -C "$dir/$name" ;;
    esac
  fi
}

get_format() {
  local i
  case "$1" in
    tum)
      for i in 0 1 2 3; do
        fetch "$BASE/living_room_traj${i}_frei_png.tar.gz" living_room
        fetch "$BASE/traj${i}_frei_png.tar.gz" office_room
      done ;;
    tum_noise)
      for i in 0 1 2 3; do
        fetch "$BASE/living_room_traj${i}n_frei_png.tar.gz" living_room
        fetch "$BASE/traj${i}n_frei_png.tar.gz" office_room
      done ;;
    icl)
      for i in 0 1 2 3; do
        fetch "$BASE/living_room_traj${i}_loop.tgz" living_room
        fetch "$BASE/office_room_traj${i}_loop.tgz" office_room
      done ;;
    gt)
      for i in 0 1 2 3; do
        fetch "$BASE/VaFRIC/livingRoom${i}.gt.freiburg" living_room
        fetch "$BASE/VaFRIC/livingRoom${i}n.gt.sim" living_room
        fetch "$BASE/VaFRIC/traj${i}.gt.freiburg" office_room
      done ;;
    all)
      for f in tum tum_noise icl gt; do get_format "$f"; done ;;
    *) echo "Unknown format: $1 (expected: tum tum_noise icl gt all)" >&2; FAILED=1 ;;
  esac
}

for f in "${FORMATS[@]}"; do
  echo "=== $f"
  get_format "$f"
done

if [ "$FAILED" -ne 0 ]; then
  echo "Some downloads failed; re-run this script to resume." >&2
  exit 1
fi
echo "All files downloaded."
