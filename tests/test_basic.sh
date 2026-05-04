#!/usr/bin/env bash
# M3 — Real pipeline test (requires OPENROUTER_API_KEY + network).
# Fixture: short voice message saying "Questa è una prova".
# Asserts exit 0, non-empty stdout, and that the word "prova" appears in the
# transcription (case-insensitive). Skips if no key in env.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE="$SCRIPT_DIR/tests/fixtures/prova.ogg"

if [ -z "${OPENROUTER_API_KEY:-}" ]; then
  echo "SKIP: OPENROUTER_API_KEY not set (test requires real key + network)"
  exit 0
fi

if [ ! -f "$FIXTURE" ]; then
  echo "FAIL: fixture missing at $FIXTURE" >&2; exit 1
fi

set +e
out=$(bash "$SCRIPT_DIR/transcribe.sh" "$FIXTURE" 2>&1)
ec=$?
set -e

if [ "$ec" -ne 0 ]; then
  echo "FAIL: expected exit 0, got $ec. Output:" >&2
  echo "$out" >&2; exit 1
fi
if [ -z "$out" ]; then
  echo "FAIL: stdout was empty" >&2; exit 1
fi
if ! echo "$out" | grep -qi "prova"; then
  echo "FAIL: transcription does not contain 'prova'. Got:" >&2
  echo "$out" >&2; exit 1
fi

echo "PASS: real audio transcribed (contains 'prova')"
