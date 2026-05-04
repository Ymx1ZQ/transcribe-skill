#!/usr/bin/env bash
# M2 — No args → exit 1 + usage on stderr
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

set +e
out=$(bash "$SCRIPT_DIR/transcribe.sh" 2>&1 1>/dev/null)
ec=$?
set -e

if [ "$ec" -eq 0 ]; then
  echo "FAIL: expected non-zero exit, got 0" >&2; exit 1
fi
if [ "$ec" -ne 1 ]; then
  echo "FAIL: expected exit 1, got $ec" >&2; exit 1
fi
if ! echo "$out" | grep -qi "usage"; then
  echo "FAIL: stderr should contain 'usage', got:" >&2
  echo "$out" >&2; exit 1
fi

echo "PASS: no-args → exit 1 + usage"
