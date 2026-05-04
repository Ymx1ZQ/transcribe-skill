#!/usr/bin/env bash
# M3 — --json flag produces valid JSON with key "transcription".
# Skips if no key in env.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE="$SCRIPT_DIR/tests/fixtures/prova.ogg"

if [ -z "${OPENROUTER_API_KEY:-}" ]; then
  echo "SKIP: OPENROUTER_API_KEY not set"
  exit 0
fi

set +e
out=$(bash "$SCRIPT_DIR/transcribe.sh" --json "$FIXTURE" 2>/dev/null)
ec=$?
set -e

if [ "$ec" -ne 0 ]; then
  echo "FAIL: expected exit 0, got $ec" >&2; exit 1
fi
if ! echo "$out" | jq -e '.transcription' >/dev/null 2>&1; then
  echo "FAIL: output is not JSON with 'transcription' key. Got:" >&2
  echo "$out" >&2; exit 1
fi
if ! echo "$out" | jq -e '.model' >/dev/null 2>&1; then
  echo "FAIL: missing 'model' field in JSON output" >&2; exit 1
fi

echo "PASS: --json produces valid JSON with required fields"
