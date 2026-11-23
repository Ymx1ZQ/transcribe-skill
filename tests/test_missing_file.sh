#!/usr/bin/env bash
# M2 — Audio file does not exist → exit 1 + clear error
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

set +e
out=$(OPENROUTER_API_KEY=stub bash "$SCRIPT_DIR/transcribe/transcribe.sh" /nonexistent/path.mp3 2>&1 1>/dev/null)
ec=$?
set -e

if [ "$ec" -ne 1 ]; then
  echo "FAIL: expected exit 1, got $ec" >&2; exit 1
fi
if ! echo "$out" | grep -qiE "not found|does not exist|no such"; then
  echo "FAIL: stderr should explain missing file, got:" >&2
  echo "$out" >&2; exit 1
fi

echo "PASS: missing file → exit 1 + clear error"
