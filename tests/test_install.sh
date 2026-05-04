#!/usr/bin/env bash
# M1 — Verify install.sh deploys SKILL.md to the right place.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET="$HOME/.claude/skills/transcribe/SKILL.md"

# Pre-cleanup so we test a real install
rm -f "$TARGET"

bash "$SCRIPT_DIR/install.sh" --force >/dev/null

if [ ! -f "$TARGET" ]; then
  echo "FAIL: $TARGET does not exist after install" >&2
  exit 1
fi

if ! cmp -s "$SCRIPT_DIR/SKILL.md" "$TARGET"; then
  echo "FAIL: $TARGET differs from source SKILL.md" >&2
  exit 1
fi

echo "PASS: install.sh deployed SKILL.md correctly"
