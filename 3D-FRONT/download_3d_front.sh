#!/usr/bin/env bash
# Download 3D-FRONT / 3D-FUTURE from the links you receive after your Tianchi application
# is approved (see README.md). There are no public links, so this script needs them as a
# text file: one URL per line (lines starting with # are ignored).
#
# Usage: ./download_3d_front.sh -l LINK_LIST [-o OUTPUT_ROOT] [-x]
#   -l LINK_LIST     text file with the approved download URLs (required)
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/3D-FRONT
#   -x               unzip into the folder layout expected by the official toolbox,
#                    BlenderProc, ATISS, SceneZoo, ...:
#                      3D-FRONT/          house layouts (<house_id>.json)
#                      3D-FUTURE-model/   furniture models (<model_id>/raw_model.obj, ...)
#                      3D-FRONT-texture/  wall / floor textures
#
# Plain HTTP(S) links (e.g. Aliyun OSS) are fetched with wget -c (resumable; signed links
# expire, so request new ones if they stop working). Multi-part zips (*.zip + *.z01 ...)
# are joined with `zip -s 0` before unzipping.

LIST=""
OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/3D-FRONT
EXTRACT=0
while getopts "l:o:xh" opt; do
  case "$opt" in
    l) LIST="$OPTARG" ;;
    o) OUTPUT_ROOT="$OPTARG" ;;
    x) EXTRACT=1 ;;
    *) sed -n '2,18p' "$0"; exit 1 ;;
  esac
done

[ -n "$LIST" ] || { echo "Missing -l LINK_LIST (apply at https://tianchi.aliyun.com/dataset/dataDetail?dataId=65347)" >&2; exit 1; }
[ -f "$LIST" ] || { echo "Link list not found: $LIST" >&2; exit 1; }
LIST=$(cd "$(dirname "$LIST")" && pwd)/$(basename "$LIST")

mkdir -p "$OUTPUT_ROOT/downloads" || exit 1
cd "$OUTPUT_ROOT" || exit 1
echo "Output: $(pwd) | links: $(grep -cvE '^\s*(#|$)' "$LIST") | unzip: $EXTRACT"

FAILED=0
while read -r url; do
  url=$(echo "$url" | tr -d '\r' | xargs)
  [ -z "$url" ] && continue
  case "$url" in \#*) continue ;; esac
  # strip the query string (signed OSS parameters) to get a clean file name
  name=$(basename "${url%%\?*}")
  echo "=== $name"
  wget -c -O "downloads/$name" "$url" || { echo "[fail] $name" >&2; FAILED=1; }
done < "$LIST"

if [ "$EXTRACT" -eq 1 ]; then
  for z in downloads/*.zip; do
    [ -f "$z" ] || continue
    [ -f "$z.extracted" ] && continue
    src="$z"
    if ls "${z%.zip}".z[0-9][0-9] >/dev/null 2>&1; then
      src="${z%.zip}_joined.zip"
      zip -s 0 "$z" --out "$src" || { echo "[fail] join $z" >&2; FAILED=1; continue; }
    fi
    # Archives normally contain a top-level 3D-FRONT/, 3D-FUTURE-model/ or 3D-FRONT-texture/ folder.
    if unzip -n -q "$src" -d .; then
      touch "$z.extracted"
    else
      echo "[fail] unzip $z" >&2; FAILED=1
    fi
    [ "$src" != "$z" ] && rm -f "$src"
  done
  for d in 3D-FRONT 3D-FUTURE-model 3D-FRONT-texture; do
    [ -d "$d" ] && echo "[ok] $d/ ($(find "$d" -maxdepth 1 | wc -l | xargs) entries)" || echo "[missing] $d/ — check the archive layout"
  done
fi

if [ "$FAILED" -ne 0 ]; then
  echo "Some downloads failed; re-run this script to resume." >&2
  exit 1
fi
echo "All files downloaded."
