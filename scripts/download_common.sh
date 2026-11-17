#!/usr/bin/env bash
# Shared download-only helpers. Compatible with macOS Bash 3.2 and Linux Bash.
# Source this file; it does not change the caller's shell options or directory.

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    return 1
  fi
}

# download_file URL DEST
# A final filename means a previous download completed. Interrupted transfers
# remain in DEST.part. No extraction, checksum assumption, or dependency install.
download_file() {
  local url="$1" destination="$2"
  case "$url" in
    http://*|https://*) ;;
    *) printf 'Expected an HTTP(S) download URL.\n' >&2; return 1 ;;
  esac
  if [[ -f "$destination" ]]; then
    printf '[skip] %s\n' "$destination"
    return 0
  fi
  if [[ -e "$destination" ]]; then
    printf 'Destination exists and is not a regular file: %s\n' "$destination" >&2
    return 1
  fi
  mkdir -p -- "$(dirname -- "$destination")" || return 1
  printf '[download] %s\n' "$destination"
  if command -v wget >/dev/null 2>&1; then
    if ! wget -c --tries=5 --timeout=60 --show-progress --progress=bar:force:noscroll \
      -O "$destination.part" -- "$url"; then
      printf '[fail] %s; re-run to resume its .part file.\n' "$destination" >&2
      return 1
    fi
  elif command -v curl >/dev/null 2>&1; then
    if ! curl --fail --location --retry 5 --connect-timeout 30 \
      --continue-at - --output "$destination.part" -- "$url"; then
      printf '[fail] %s; re-run to resume its .part file.\n' "$destination" >&2
      return 1
    fi
  else
    printf 'Install wget or curl to download files.\n' >&2
    return 1
  fi
  mv -- "$destination.part" "$destination" || return 1
  printf '[done] %s\n' "$destination"
}

# download_manifest TSV TARGET_DIR
# UTF-8 rows: relative/output/path<TAB>https://official-host/file
# Blank lines and lines starting with # are ignored. No header row.
download_manifest() {
  local manifest="$1" target_dir="$2"
  local relative url extra failed=0 count=0
  if [[ ! -f "$manifest" ]]; then
    printf 'Manifest not found: %s\n' "$manifest" >&2
    return 1
  fi
  while IFS=$'\t' read -r relative url extra || [[ -n "$relative" ]]; do
    relative=${relative%$'\r'}
    url=${url%$'\r'}
    case "$relative" in ''|'#'*) continue ;; esac
    if [[ -z "$url" || -n "$extra" ]]; then
      printf 'Invalid manifest row: expected relative-path<TAB>URL.\n' >&2
      return 1
    fi
    case "$relative" in
      /*|..|../*|*/../*|*/..|.|./*|*/./*|*/.)
        printf 'Unsafe manifest output path: %s\n' "$relative" >&2
        return 1 ;;
    esac
    count=$((count + 1))
    download_file "$url" "$target_dir/$relative" || failed=1
  done < "$manifest"
  if [[ "$count" -eq 0 ]]; then
    printf 'Manifest contains no downloadable files.\n' >&2
    return 1
  fi
  if [[ "$failed" -ne 0 ]]; then
    printf 'Some downloads failed; re-run the same command to resume.\n' >&2
    return 1
  fi
  printf 'Downloaded/skipped %s files. Archives were not extracted.\n' "$count"
}
