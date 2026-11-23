#!/usr/bin/env bash
# M2 — Missing OPENROUTER_API_KEY → exit 1 + clear error
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Prepare a real existing file so the only failure cause is the missing key
tmp=$(mktemp --suffix=.mp3)
trap "rm -f $tmp" EXIT
echo "stub" > "$tmp"

set +e
out=$(env -u OPENROUTER_API_KEY bash "$SCRIPT_DIR/transcribe/transcribe.sh" "$tmp" 2>&1 1>/dev/null)
ec=$?
set -e

if [ "$ec" -ne 1 ]; then
  echo "FAIL: expected exit 1, got $ec" >&2; exit 1
fi
if ! echo "$out" | grep -qi "OPENROUTER_API_KEY"; then
  echo "FAIL: stderr should mention OPENROUTER_API_KEY, got:" >&2
  echo "$out" >&2; exit 1
fi

echo "PASS: missing key → exit 1 + clear error"
