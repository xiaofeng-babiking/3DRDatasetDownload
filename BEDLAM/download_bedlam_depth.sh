#!/usr/bin/env bash
# Download BEDLAM's 30fps EXR depth archives without extracting them.
# Protocol and manifest: https://bedlam.is.tuebingen.mpg.de/media/upload/be_imagedata_download.zip
# bedlam_depth_checksums.xxh128 is an unchanged copy of b0_checksums_depth.xxh128.
# Compatible with macOS Bash 3.2 and Linux Bash.

set +x  # Credentials must not be printed, even when invoked with bash -x.
set -eo pipefail

usage() {
  cat <<'EOF'
Usage: ./download_bedlam_depth.sh [-s mpi|hf] [-o OUTPUT_ROOT] [-q SEQ_GLOB]
                                [-j WORKERS] [-n] [--verify]

Download 30 batches / 150 depth tar files (~4.09 TB), without extraction.
Output: OUTPUT_ROOT/BEDLAM-depth/<seq>/depth/<seq>_depth.N.tar

  -s SOURCE       mpi (default): official BEDLAM server; hf: Hugging Face mirror
  -o OUTPUT_ROOT  Parent directory (default: /Volumes/Expansion1/3DRDatasets/BEDLAM)
  -q SEQ_GLOB     Batch name or quoted glob (default: '*')
  -j WORKERS      Concurrent downloads (positive integer, default: 4)
  -n, --dry-run   List matching archive paths and URLs offline; no credentials needed
  --verify       Check XXH128 hashes, including existing archives (requires xxhsum)
  -h, --help      Show this help

MPI: register and accept the license at https://bedlam.is.tue.mpg.de/download.php.
Set BEDLAM_USERNAME to your registered email and BEDLAM_PASSWORD, or enter them
at the terminal prompts. Requires wget and file. Credentials use a private
temporary POST file, which is removed when the script exits.

HF: pip install -U huggingface_hub; accept access conditions at
https://huggingface.co/datasets/Intelligent-Systems/BEDLAM-depth and hf auth login
(or set HF_TOKEN). Requires hf and file. Keep .cache/huggingface for resuming.

MPI transfers resume <archive>.part files and rename only after success. Existing
tar files are skipped (and checked with --verify). Invalid response files are
kept as <archive>.part.rejected.*; no downloaded data is deleted.
EOF
}

fail() { printf '%s\n' "$*" >&2; exit 1; }
require_value() {
  [[ $# -ge 2 && -n "$2" && "$2" != -* ]] || fail "$1 requires a value. See --help."
}

OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/BEDLAM
SOURCE=mpi
SEQ='*'
WORKERS=4
DRY_RUN=0
VERIFY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -o) require_value "$@"; OUTPUT_ROOT="$2"; shift 2 ;;
    -s) require_value "$@"; SOURCE="$2"; shift 2 ;;
    -q) require_value "$@"; SEQ="$2"; shift 2 ;;
    -j) require_value "$@"; WORKERS="$2"; shift 2 ;;
    -n|--dry-run) DRY_RUN=1; shift ;;
    --verify) VERIFY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) fail "Unknown argument: $1. See --help." ;;
  esac
done
case "$SOURCE" in mpi|hf) ;; *) fail '-s must be mpi or hf.' ;; esac
[[ "$WORKERS" =~ ^[1-9][0-9]*$ ]] || fail '-j requires a positive integer.'
[[ "$SEQ" != */* ]] || fail '-q expects a batch name/glob without directory separators.'

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
MANIFEST="$SCRIPT_DIR/bedlam_depth_checksums.xxh128"
[[ -f "$MANIFEST" ]] || fail "Missing official checksum manifest: $MANIFEST"
DEST="$OUTPUT_ROOT/BEDLAM-depth"
HASHES=(); FILES=(); PATHS=()
while read -r digest filename extra || [[ -n "$digest" ]]; do
  [[ -n "$digest" ]] || continue
  [[ "$digest" =~ ^[0-9a-f]{32}$ && -z "$extra" &&
     "$filename" =~ ^[a-zA-Z0-9_-]+_depth\.[0-4]\.tar$ ]] || fail 'Invalid checksum manifest row.'
  batch=${filename%_depth.*.tar}
  [[ "$batch" == $SEQ ]] || continue
  HASHES+=("$digest"); FILES+=("$filename"); PATHS+=("$batch/depth/$filename")
done < "$MANIFEST"
[[ ${#FILES[@]} -gt 0 ]] || fail "No depth archives match batch pattern: $SEQ"

printf 'Output: %s | source: %s | archives: %s | workers: %s\n' \
  "$DEST" "$SOURCE" "${#FILES[@]}" "$WORKERS"
if [[ "$DRY_RUN" -eq 1 ]]; then
  for relative in "${PATHS[@]}"; do
    if [[ "$SOURCE" == mpi ]]; then
      url="https://download.is.tue.mpg.de/download.php?domain=bedlam&resume=1&sfile=b0/$relative"
    else
      url="https://huggingface.co/datasets/Intelligent-Systems/BEDLAM-depth/resolve/main/$relative"
    fi
    printf '%s\t%s\n' "$relative" "$url"
  done
  exit 0
fi

command -v file >/dev/null 2>&1 || fail 'Required command not found: file'
if [[ "$VERIFY" -eq 1 ]]; then
  command -v xxhsum >/dev/null 2>&1 || fail '--verify requires xxhsum 0.8.1 or newer.'
fi
archive_is_tar() {
  [[ -f "$1" && ! -L "$1" ]] || return 1
  case "$(LC_ALL=C file -b -- "$1")" in *'tar archive'*) return 0 ;; *) return 1 ;; esac
}
verify_archive() {
  local digest="$1" candidate="$2"
  archive_is_tar "$candidate" || { printf '[fail] Not a tar archive: %s\n' "$candidate" >&2; return 1; }
  if [[ "$VERIFY" -eq 1 ]]; then
    printf '%s  %s\n' "$digest" "$candidate" | xxhsum -c || return 1
  fi
}

if [[ "$SOURCE" == hf ]]; then
  command -v hf >/dev/null 2>&1 || fail 'hf CLI not found: pip install -U huggingface_hub'
  HF_FILES=(README.md LICENSE.md)
  for relative in "${PATHS[@]}"; do HF_FILES+=("$relative" "$relative.xxh128"); done
  if hf download Intelligent-Systems/BEDLAM-depth "${HF_FILES[@]}" --repo-type dataset \
      --local-dir "$DEST" --max-workers "$WORKERS"; then
    for ((i=0; i<${#PATHS[@]}; i++)); do
      verify_archive "${HASHES[i]}" "$DEST/${PATHS[i]}" || exit 1
    done
  else
    download_status=$?
    printf '%s\n' 'HF download failed. Check dataset access and hf auth login; re-run to resume.' >&2
    exit "$download_status"
  fi
else
  for dependency in wget xargs tee awk; do
    command -v "$dependency" >/dev/null 2>&1 || fail "Required command not found: $dependency"
  done
  bedlam_user=${BEDLAM_USERNAME:-}
  bedlam_pass=${BEDLAM_PASSWORD:-}
  if [[ -z "$bedlam_user" || -z "$bedlam_pass" ]]; then
    [[ -t 0 ]] || fail 'Set BEDLAM_USERNAME and BEDLAM_PASSWORD, or run from a terminal to enter them.'
    [[ -n "$bedlam_user" ]] || read -r -p 'BEDLAM registered email: ' bedlam_user
    if [[ -z "$bedlam_pass" ]]; then
      read -r -s -p 'BEDLAM password: ' bedlam_pass
      printf '\n'
    fi
  fi
  [[ -n "$bedlam_user" && -n "$bedlam_pass" ]] || fail 'BEDLAM email and password must not be empty.'
  TEMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/bedlam-depth.XXXXXX")
  trap 'rm -rf -- "$TEMP_DIR"' EXIT
  trap 'exit 130' INT
  trap 'exit 143' TERM
  POST_FILE=$(mktemp "$TEMP_DIR/post.XXXXXX")
  chmod 600 "$POST_FILE"
  url_encode() {
    local LC_ALL=C i c byte
    for ((i=0; i<${#1}; i++)); do
      c=${1:i:1}
      case "$c" in
        [a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
        *) printf -v byte '%d' "'$c"; printf '%%%02X' "$((byte & 255))" ;;
      esac
    done
  }
  { printf 'username='; url_encode "$bedlam_user"; printf '&password='; url_encode "$bedlam_pass"; } > "$POST_FILE"
  unset bedlam_user bedlam_pass BEDLAM_USERNAME BEDLAM_PASSWORD

  # Preserve invalid responses, so the next run starts a clean transfer.
  quarantine_partial() {
    local partial="$1" force="${2:-}" rejected
    if [[ -f "$partial" ]] && { [[ "$force" == force ]] || ! archive_is_tar "$partial"; }; then
      rejected=$(mktemp "$partial.rejected.XXXXXX") || return 1
      mv -- "$partial" "$rejected" || return 1
      printf '[saved invalid response] %s\n' "$rejected" >&2
    fi
  }
  fetch_mpi() {
    local digest="$1" relative="$2" destination partial url response_log content_type http_status transfer_status
    destination="$DEST/$relative"
    partial="$destination.part"
    if [[ -e "$destination" || -L "$destination" ]]; then
      if ! verify_archive "$digest" "$destination"; then
        printf '[fail] Inspect or move this existing file aside before retrying: %s\n' "$destination" >&2
        return 1
      fi
      printf '[skip] %s\n' "$destination"
      return 0
    fi
    [[ ! -L "$partial" && ( ! -e "$partial" || -f "$partial" ) ]] || {
      printf '[fail] Invalid partial-file destination: %s\n' "$partial" >&2; return 1;
    }
    mkdir -p -- "${destination%/*}" || return 1
    url="https://download.is.tue.mpg.de/download.php?domain=bedlam&resume=1&sfile=b0/$relative"
    response_log="$TEMP_DIR/${relative##*/}.response"
    printf '[download] %s\n' "$destination"
    if wget --continue --tries=5 --timeout=60 --server-response --show-progress \
        --progress=bar:force:noscroll --post-file "$POST_FILE" -O "$partial" -- "$url" 2>&1 |
        awk 'tolower($1) ~ /^(set-cookie2?|cookie|authorization|proxy-authorization|www-authenticate|proxy-authenticate):$/ { next }
             { print; fflush() }' | tee "$response_log"; then
      transfer_status=0
    else
      transfer_status=$?
    fi
    # The official server may send an authentication error as HTTP 200 HTML.
    # Only the final HTTP response's content type matters after redirects.
    content_type=$(awk '
      /^[[:space:]]*HTTP\// { type="" }
      tolower($1)=="content-type:" { type=tolower($2) }
      END { print type }
    ' "$response_log")
    http_status=$(awk '/^[[:space:]]*HTTP\// { code=$2 } END { print code }' "$response_log")
    # A complete .part left by an interruption before rename can yield HTTP 416.
    # Require its official hash before treating this as a completed transfer.
    if [[ "$http_status" == 416 ]]; then
      command -v xxhsum >/dev/null 2>&1 || {
        printf '[fail] HTTP 416: install xxhsum to verify this possibly complete .part, then re-run: %s\n' "$partial" >&2
        return 1
      }
      if ( VERIFY=1; verify_archive "$digest" "$partial" ); then
        mv -- "$partial" "$destination" || return 1
        printf '[done] Verified complete partial file: %s\n' "$destination"
        return 0
      fi
      quarantine_partial "$partial" force
      return 1
    fi
    case "$content_type" in
      text/*|application/json*|application/xhtml*)
        printf '[fail] Server returned %s; check BEDLAM account and license access.\n' "$content_type" >&2
        quarantine_partial "$partial"
        return 1 ;;
    esac
    if [[ "$transfer_status" -ne 0 ]]; then
      printf '[fail] %s; re-run to resume its .part file.\n' "$destination" >&2
      return 1
    fi
    if ! verify_archive "$digest" "$partial"; then
      quarantine_partial "$partial" force
      return 1
    fi
    mv -- "$partial" "$destination" || return 1
    printf '[done] %s\n' "$destination"
  }
  export DEST POST_FILE TEMP_DIR VERIFY
  export -f archive_is_tar verify_archive quarantine_partial fetch_mpi
  for ((i=0; i<${#PATHS[@]}; i++)); do
    printf '%s %s\n' "${HASHES[i]}" "${PATHS[i]}"
  done > "$TEMP_DIR/downloads"
  if ! xargs -n 2 -P "$WORKERS" bash -c 'set -o pipefail; fetch_mpi "$@"' _ < "$TEMP_DIR/downloads"; then
    fail 'Some BEDLAM-depth downloads failed; re-run the same command to resume.'
  fi
fi
printf 'BEDLAM-depth download completed: %s archives. No extraction performed.\n' "${#FILES[@]}"
