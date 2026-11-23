#!/usr/bin/env bash
# M4 — SKILL.md must declare TRIGGER and SKIP clauses,
# reference audio attachments / channels, and document the invocation contract.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILL="$SCRIPT_DIR/transcribe/SKILL.md"

if [ ! -f "$SKILL" ]; then
  echo "FAIL: $SKILL missing" >&2; exit 1
fi

required_patterns=(
  "TRIGGER"
  "SKIP"
  "audio"
  "channel"
  "transcribe.sh"
  "OPENROUTER_API_KEY"
)

failed=0
for p in "${required_patterns[@]}"; do
  if ! grep -qi "$p" "$SKILL"; then
    echo "FAIL: SKILL.md missing required pattern: '$p'" >&2
    failed=1
  fi
done

# Frontmatter must declare name and description (used by the harness).
if ! grep -q "^name: transcribe" "$SKILL"; then
  echo "FAIL: SKILL.md missing 'name: transcribe' in frontmatter" >&2
  failed=1
fi
if ! grep -q "^description:" "$SKILL"; then
  echo "FAIL: SKILL.md missing 'description:' in frontmatter" >&2
  failed=1
fi

[ "$failed" -eq 0 ] || exit 1
echo "PASS: SKILL.md contains the trigger contract"
