#!/usr/bin/env bash
# Download Mid-Air from a download_config.txt generated on https://midair.ulg.ac.be/download.html
# (see README.md). The site only hands out archive links through its download form, so this
# script needs that link list; it then runs the official wget + unzip commands with resume.
#
# Usage: ./download_midair.sh -c DOWNLOAD_CONFIG [-o OUTPUT_ROOT] [-x] [-d]
#   -c DOWNLOAD_CONFIG   text file with one archive URL per line (from the download form)
#   -o OUTPUT_ROOT       default: /Volumes/Expansion0/3DRDatasets/Mid-Air
#   -x                   unzip every downloaded archive in place (official extraction command)
#   -d                   delete each zip after a successful unzip (implies -x)
#
# Re-running the same command resumes partial downloads (wget -c) and skips finished ones.

CONFIG=""
OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/Mid-Air
EXTRACT=0
DELETE=0
while getopts "c:o:xdh" opt; do
  case "$opt" in
    c) CONFIG="$OPTARG" ;;
    o) OUTPUT_ROOT="$OPTARG" ;;
    x) EXTRACT=1 ;;
    d) EXTRACT=1; DELETE=1 ;;
    *) sed -n '2,13p' "$0"; exit 1 ;;
  esac
done

[ -n "$CONFIG" ] || { echo "Missing -c DOWNLOAD_CONFIG (generate it at https://midair.ulg.ac.be/download.html)" >&2; exit 1; }
[ -f "$CONFIG" ] || { echo "Config not found: $CONFIG" >&2; exit 1; }
CONFIG=$(cd "$(dirname "$CONFIG")" && pwd)/$(basename "$CONFIG")

mkdir -p "$OUTPUT_ROOT" || exit 1
cd "$OUTPUT_ROOT" || exit 1
echo "Output: $(pwd) | links: $(grep -c . "$CONFIG") | unzip: $EXTRACT | delete zip: $DELETE"

# Official command: wget --content-disposition -x -nH -i download_config.txt
#   -x -nH keeps the server-side directory layout (without the host name), which must match
#   the relative paths encoded in the sensor_records.hdf5 files.
FAILED=0
wget -c --content-disposition -x -nH -i "$CONFIG" || FAILED=1

if [ "$EXTRACT" -eq 1 ]; then
  # Official command:
  #   find . -name "*.zip" | while read filename; do unzip -o -d $(dirname "$filename") "$filename"; done;
  find . -name "*.zip" | while read -r f; do
    if unzip -o -q -d "$(dirname "$f")" "$f"; then
      [ "$DELETE" -eq 1 ] && rm -f "$f"
    else
      echo "[fail] unzip $f" >&2
    fi
  done
fi

if [ "$FAILED" -ne 0 ]; then
  echo "Some downloads failed; re-run this script to resume." >&2
  exit 1
fi
echo "All files downloaded."
