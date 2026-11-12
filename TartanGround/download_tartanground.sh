#!/usr/bin/env bash
# Download TartanGround — wrapper around download_tartanground.py (see README.md).
#
# Usage: ./download_tartanground.sh [-o OUTPUT_ROOT] [OPTIONS ...]
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/TartanGround
#   OPTIONS          passed through to download_tartanground.py; run with --help to list them
#
# Environment:
#   PYTHON   interpreter to use (default: python3)
#
# Missing packages from requirements.txt are installed into that interpreter automatically.
# Re-running the same command resumes (completed files are skipped).

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PYTHON=${PYTHON:-python3}

OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/TartanGround
if [ "${1:-}" = "-o" ]; then OUTPUT_ROOT="$2"; shift 2; fi

command -v "$PYTHON" >/dev/null || { echo "Python not found: $PYTHON" >&2; exit 1; }
if ! "$PYTHON" -c "import huggingface_hub" 2>/dev/null; then
  echo "Installing requirements into $("$PYTHON" -c 'import sys; print(sys.executable)') ..."
  "$PYTHON" -m pip install -r "$SCRIPT_DIR/requirements.txt" || exit 1
fi

exec "$PYTHON" "$SCRIPT_DIR/download_tartanground.py" -o "$OUTPUT_ROOT" "$@"
