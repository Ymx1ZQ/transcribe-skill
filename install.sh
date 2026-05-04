#!/usr/bin/env bash
set -euo pipefail

# Transcribe — Installer
# Deploys the skill files to ~/.claude/skills/transcribe/

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$HOME/.claude/skills/transcribe"

if [ -t 1 ]; then
    GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
else
    GREEN=''; YELLOW=''; RED=''; NC=''
fi

info()  { echo -e "${GREEN}OK${NC} $1"; }
warn()  { echo -e "${YELLOW}!!${NC} $1"; }
error() { echo -e "${RED}XX${NC} $1" >&2; }

FORCE=false
case "${1:-}" in
    --force) FORCE=true ;;
    --uninstall)
        rm -rf "$SKILL_DIR"
        info "Uninstalled $SKILL_DIR"
        exit 0
        ;;
    --help|-h)
        echo "Usage: install.sh [--force | --uninstall]"
        exit 0
        ;;
    "") ;;
    *) error "Unknown option: $1"; exit 1 ;;
esac

for f in SKILL.md transcribe.sh; do
    if [ ! -f "$SCRIPT_DIR/$f" ]; then
        error "$f missing in $SCRIPT_DIR"
        exit 1
    fi
done

mkdir -p "$SKILL_DIR"

if [ "$FORCE" = true ]; then
    cp -f "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/SKILL.md"
    cp -f "$SCRIPT_DIR/transcribe.sh" "$SKILL_DIR/transcribe.sh"
else
    cp -n "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/SKILL.md"
    cp -n "$SCRIPT_DIR/transcribe.sh" "$SKILL_DIR/transcribe.sh"
fi
chmod +x "$SKILL_DIR/transcribe.sh"

info "Installed to $SKILL_DIR"

for dep in ffmpeg curl jq; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        warn "$dep not found in PATH — install before using the skill"
    fi
done

if [ -z "${OPENROUTER_API_KEY:-}" ]; then
    warn "OPENROUTER_API_KEY not set — set it before invoking the skill"
fi
