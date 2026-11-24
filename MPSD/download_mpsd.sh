#!/usr/bin/env bash
# Access instructions: https://www.mapillary.com/dataset/depth
set -euo pipefail
usage() {
  cat <<'EOF'
Usage: download_mpsd.sh [--target_dir DIR] [--manifest FILE]
       download_mpsd.sh [--target_dir DIR] --url URL --filename NAME
Download-only entry point for Mapillary Planet-Scale Depth (MPSD).
Default output: ./data/MPSD
--manifest FILE      Defaults to download_links.txt beside this script.
                     Use one authorized HTTP(S) URL per line. Each file is saved
                     under its URL basename, without the query string or fragment.
                     To choose names, use relative/output/path<TAB>URL on each line.
                     Blank lines and # comments are allowed in both formats.
--url URL            One direct download URL obtained from the official portal.
--filename NAME      Relative output path for --url (required with --url).
-h, --help           Show help.
Per-file transfer progress is displayed. Re-run with the same target directory
to resume .part files and skip completed files.
EOF
}
die() { printf 'Error: %s\n' "$*" >&2; exit 2; }

download_list() {
  local list="$1" dir="$2" line name i count=0 failed=0
  local -a urls names
  [[ -f "$list" && -r "$list" ]] || die "cannot read manifest: $list"
  while IFS= read -r line || [[ -n "$line" ]]; do
    line=${line%$'\r'}
    case "$line" in ''|'#'*) continue ;; esac
    if (( count == 0 )) && [[ "$line" == *$'\t'* ]]; then
      download_manifest "$list" "$dir"
      return
    fi
    [[ "$line" =~ ^https?://[^/?#[:space:]]+/[^[:space:]]+$ ]] ||
      die "expected one HTTP(S) file URL per line in $list"
    name=${line%%[?#]*}
    name=${name##*/}
    case "$name" in ''|.|..) die "URL has no usable filename in $list" ;; esac
    for ((i=0; i<count; i++)); do
      [[ "${names[i]}" != "$name" ]] || die "duplicate filename $name; use a TSV with distinct output paths"
    done
    urls[count]="$line"
    names[count]="$name"
    count=$((count + 1))
  done < "$list"
  (( count > 0 )) || die "manifest contains no downloadable files: $list"
  for ((i=0; i<count; i++)); do
    printf '[%d/%d] ' "$((i + 1))" "$count"
    download_file "${urls[i]}" "$dir/${names[i]}" || failed=1
  done
  return "$failed"
}

target_dir="./data/MPSD"
manifest=""
url=""
filename=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target_dir|--manifest|--url|--filename)
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || die "$1 requires a value"
      case "$1" in
        --target_dir) target_dir="$2";; --manifest) manifest="$2";;
        --url) url="$2";; --filename) filename="$2";;
      esac
      shift 2;;
    -h|--help) usage; exit 0;;
    *) die "unknown argument: $1";;
  esac
done
if [[ -n "$manifest" ]]; then
  [[ -z "$url" && -z "$filename" ]] || die "--manifest cannot be combined with --url/--filename"
elif [[ -n "$url" || -n "$filename" ]]; then
  [[ -n "$url" && -n "$filename" ]] || die "provide both --url and --filename"
  case "$url" in http://*|https://*) ;; *) die "--url must be HTTP(S)";; esac
  case "/$filename/" in *"/../"*|*"/./"*|*"//"*) die "--filename must be a relative file path";; esac
  [[ "$filename" != *$'\t'* && "$filename" != *$'\n'* ]] || die "invalid filename"
fi
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../scripts/download_common.sh"
if [[ -n "$url" ]]; then
  download_file "$url" "$target_dir/$filename"
else
  download_list "${manifest:-$script_dir/download_links.txt}" "$target_dir"
fi
