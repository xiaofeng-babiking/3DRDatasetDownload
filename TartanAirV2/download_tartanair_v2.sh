#!/usr/bin/env bash
# Download TartanAir V2 — wrapper around download_tartanair_v2.py (see README.md).
#
# Usage: ./download_tartanair_v2.sh [-o OUTPUT_ROOT] [OPTIONS ...]
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/TartanAirV2
#   OPTIONS          passed through to download_tartanair_v2.py; run with --help to list them
#
# Environment:
#   PYTHON   interpreter to use (default: python3)
#
# Missing packages from requirements.txt are installed into that interpreter automatically.
# Re-running the same command resumes (completed files are skipped).

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PYTHON=${PYTHON:-python3}

OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/TartanAirV2
if [ "${1:-}" = "-o" ]; then OUTPUT_ROOT="$2"; shift 2; fi

command -v "$PYTHON" >/dev/null || { echo "Python not found: $PYTHON" >&2; exit 1; }
if ! "$PYTHON" -c "import huggingface_hub" 2>/dev/null; then
  echo "Installing requirements into $("$PYTHON" -c 'import sys; print(sys.executable)') ..."
  "$PYTHON" -m pip install -r "$SCRIPT_DIR/requirements.txt" || exit 1
fi

exec "$PYTHON" "$SCRIPT_DIR/download_tartanair_v2.py" -o "$OUTPUT_ROOT" "$@"
