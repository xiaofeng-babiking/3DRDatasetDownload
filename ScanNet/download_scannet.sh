#!/usr/bin/env bash
# Access instructions: https://github.com/ScanNet/ScanNet#scannet-data
set -euo pipefail
usage() {
  cat <<'EOF'
Usage: download_scannet.sh [--target_dir DIR] --manifest FILE.tsv
       download_scannet.sh [--target_dir DIR] --url URL --filename NAME
       download_scannet.sh [--target_dir DIR] --official_script FILE.py
                           [--python COMMAND] [--id SCENE] [--type EXT] [--v1]
Download-only entry point for ScanNet.
Default output: ./data/ScanNet
--manifest FILE.tsv  Local list: relative/output/path<TAB>authorized HTTP(S) URL.
                     Blank lines and # comments are allowed.
--url URL            One direct download URL obtained from the official portal.
--filename NAME      Relative output path for --url (required with --url).
--official_script    Official download-scannet.py obtained after approval.
--python COMMAND    Interpreter for the supplied script (default: python3).
--id / --type / --v1 Select a scene/file type/version in official-script mode.
-h, --help           Show help.
First obtain authorized download links from:
https://github.com/ScanNet/ScanNet#scannet-data
No built-in public links are available here. Portal/login pages are not data URLs.
The script does not register, accept terms, retrieve credentials, or extract files.
EOF
}
die() { printf 'Error: %s\n' "$*" >&2; exit 2; }
target_dir="./data/ScanNet"
manifest=""
url=""
filename=""
official_script=""
python_command="python3"
official_args=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target_dir|--manifest|--url|--filename|--official_script|--python|--id|--type)
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || die "$1 requires a value"
      case "$1" in
        --target_dir) target_dir="$2";; --manifest) manifest="$2";;
        --url) url="$2";; --filename) filename="$2";;
        --official_script) official_script="$2";; --python) python_command="$2";;
        --id|--type) official_args+=("$1" "$2");;
      esac
      shift 2;;
    --v1) official_args+=(--v1); shift;;
    -h|--help) usage; exit 0;;
    *) die "unknown argument: $1";;
  esac
done
if [[ -n "$official_script" ]]; then
  [[ -z "$manifest" && -z "$url" && -z "$filename" ]] || die "--official_script cannot be combined with URL/manifest mode"
  [[ -f "$official_script" ]] || die "official script not found: $official_script"
  command -v "$python_command" >/dev/null 2>&1 || die "interpreter not found: $python_command"
  mkdir -p -- "$target_dir"
  # The official downloader stores .sens/ZIP files; SensReader is a separate step.
  # Preserve its interactive license prompts instead of accepting them silently.
  if [[ ${#official_args[@]} -gt 0 ]]; then
    exec "$python_command" "$official_script" -o "$target_dir" "${official_args[@]}"
  else
    exec "$python_command" "$official_script" -o "$target_dir"
  fi
fi
[[ ${#official_args[@]} -eq 0 ]] || die "--id, --type and --v1 require --official_script"
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
