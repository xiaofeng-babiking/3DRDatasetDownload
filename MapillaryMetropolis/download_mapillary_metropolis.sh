#!/usr/bin/env bash
# Access instructions: https://www.mapillary.com/dataset/metropolis
set -euo pipefail
usage() {
  cat <<'EOF'
Usage: download_mapillary_metropolis.sh [--target_dir DIR] --manifest FILE.tsv
       download_mapillary_metropolis.sh [--target_dir DIR] --url URL --filename NAME
Download-only entry point for Mapillary Metropolis.
Default output: ./data/MapillaryMetropolis
--manifest FILE.tsv  Local list: relative/output/path<TAB>authorized HTTP(S) URL.
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
  [[ -f "$manifest" ]] || die "manifest not found: $manifest"
else
  [[ -n "$url" && -n "$filename" ]] || { usage >&2; die "provide --manifest or both --url and --filename after obtaining official access"; }
  case "$url" in http://*|https://*) ;; *) die "--url must be HTTP(S)";; esac
  case "/$filename/" in *"/../"*|*"/./"*|*"//"*) die "--filename must be a relative file path";; esac
  [[ "$filename" != *$'\t'* && "$filename" != *$'\n'* ]] || die "invalid filename"
fi
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source "$script_dir/../scripts/download_common.sh"
if [[ -n "$manifest" ]]; then
  download_manifest "$manifest" "$target_dir"
else
  download_file "$url" "$target_dir/$filename"
fi
