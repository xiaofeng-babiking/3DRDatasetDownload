#!/usr/bin/env bash
# Access instructions: https://www.mapillary.com/dataset/metropolis
set -euo pipefail
usage() {
  cat <<'EOF'
Usage: download_mapillary_metropolis.sh [--target_dir DIR] [--manifest FILE]
       download_mapillary_metropolis.sh [--target_dir DIR] --url URL --filename NAME
Download-only entry point for Mapillary Metropolis.
Default output: ./data/MapillaryMetropolis
--manifest FILE      Defaults to download_links.txt beside this script.
                     Use one HTTP(S) file URL per line, or a TSV of
                     relative/output/path<TAB>URL to choose local filenames.
                     URL-only lists use the URL basename without the query or fragment.
                     Blank lines and # comments are allowed.
--url URL            One direct download URL obtained from the official portal.
--filename NAME      Relative output path for --url (required with --url).
-h, --help           Show help.
First obtain authorized download links from:
https://www.mapillary.com/dataset/metropolis
No built-in public links are available here. Portal/login pages are not data URLs.
The script does not register, accept terms, retrieve credentials, or extract files.
EOF
}
die() { printf 'Error: %s\n' "$*" >&2; exit 2; }
target_dir="./data/MapillaryMetropolis"
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
  download_link_list "${manifest:-$script_dir/download_links.txt}" "$target_dir"
fi
