#!/usr/bin/env bash
# Download Mid-Air archives listed by https://midair.ulg.ac.be/download.html
#
# Usage: ./download_midair.sh [-c DOWNLOAD_CONFIG] [-o OUTPUT_ROOT] [-x] [-d]
#   -c DOWNLOAD_CONFIG   one URL per line (default: download_config.txt beside this script)
#   -o OUTPUT_ROOT       default: /Volumes/Expansion0/3DRDatasets/Mid-Air
#   -x                   unzip every downloaded archive in place (official extraction command)
#   -d                   delete each zip after a successful unzip (implies -x)
#
# Re-run the same command to resume interrupted downloads with wget -c.

if [[ "${1:-}" == --help || "${1:-}" == -h ]]; then
  sed -n '2,/^$/p' "$0"
  exit 0
fi

set -eu
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
CONFIG="$SCRIPT_DIR/download_config.txt"
OUTPUT_ROOT=/Volumes/Expansion1/3DRDatasets/Mid-Air
EXTRACT=0
DELETE=0
while getopts "c:o:xdh" opt; do
  case "$opt" in
    c) CONFIG="$OPTARG" ;;
    o) OUTPUT_ROOT="$OPTARG" ;;
    x) EXTRACT=1 ;;
    d) EXTRACT=1; DELETE=1 ;;
    h) sed -n '2,/^$/p' "$0"; exit 0 ;;
    *) sed -n '2,/^$/p' "$0" >&2; exit 1 ;;
  esac
done

shift "$((OPTIND - 1))"
[[ $# -eq 0 ]] || { echo "Unexpected argument: $1" >&2; exit 1; }
[[ -n "$OUTPUT_ROOT" ]] || { echo "-o requires an output directory." >&2; exit 1; }
[[ -f "$CONFIG" && -r "$CONFIG" ]] || {
  echo "Cannot read config: $CONFIG. Use -c FILE to select a Mid-Air download list." >&2
  exit 1
}
command -v wget >/dev/null || { echo "Missing required command: wget" >&2; exit 1; }
if [[ "$EXTRACT" -eq 1 ]]; then
  command -v unzip >/dev/null || { echo "Missing required command: unzip" >&2; exit 1; }
fi

FAILED=0
COUNT=0
while IFS= read -r url || [[ -n "$url" ]]; do
  url=${url%$'\r'}
  case "$url" in ''|'#'*) continue ;; esac
  # The query authorizes the request. Only the URL path belongs in the local filename.
  remote_path=${url%%[?#]*}
  if [[ ! "$remote_path" =~ ^https?://[^/[:space:]]+/(.+)$ ]]; then
    echo "Expected an HTTP(S) file URL in $CONFIG" >&2; exit 1
  fi
  relative=${BASH_REMATCH[1]}
  case "/$relative/" in
    *//*|*/../*|*/./*) echo "Invalid archive path in $CONFIG" >&2; exit 1 ;;
  esac
  archive="$OUTPUT_ROOT/$relative"
  directory=${archive%/*}
  mkdir -p -- "$directory"
  COUNT=$((COUNT + 1))
  printf '[download] %s\n' "$relative"
  if ! wget -c -q --show-progress -O "$archive" -i - <<< "$url"; then
    printf '[fail] %s (re-run to resume)\n' "$relative" >&2
    FAILED=1
    continue
  fi

  if [[ "$EXTRACT" -eq 1 && "$archive" == *.zip ]]; then
    if unzip -o -q "$archive" -d "$directory"; then
      if [[ "$DELETE" -eq 1 ]]; then rm -f -- "$archive"; fi
    else
      printf '[fail] unzip %s\n' "$relative" >&2
      FAILED=1
    fi
  fi
done < "$CONFIG"

[[ "$COUNT" -gt 0 ]] || { echo "No archive URLs in $CONFIG" >&2; exit 1; }
if [ "$FAILED" -ne 0 ]; then
  echo "Some archives failed. Re-run the script to retry." >&2
  exit 1
fi
printf 'Downloaded %d archives to %s\n' "$COUNT" "$OUTPUT_ROOT"
