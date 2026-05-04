#!/usr/bin/env bash
# Transcribe an audio file via Gemini 3.1 Flash Lite (OpenRouter).
#
# Usage:
#   transcribe.sh <audio_file> [--prompt "<custom prompt>"] [--json]
#
# Exit codes: 0 success, 1 bad input / missing dep / missing key, 2 API error.
set -uo pipefail

MODEL="google/gemini-3.1-flash-lite-preview"
DEFAULT_PROMPT="Trascrivi questo audio fedelmente. Restituisci solo la trascrizione, senza commenti."

usage() {
    cat >&2 <<EOF
Usage: $(basename "$0") <audio_file> [--prompt "<text>"] [--json]

Transcribe an audio file using Gemini 3.1 Flash Lite via OpenRouter.

Required:
  OPENROUTER_API_KEY env var must be set.

Options:
  --prompt "<text>"  Custom transcription prompt
  --json             Output JSON with transcription, model, cost, tokens

Supported audio formats: ogg, mp3, wav, m4a, opus, flac (any ffmpeg input)
EOF
}

# ── Argument parsing ────────────────────────────────────────────────
audio_file=""
prompt="$DEFAULT_PROMPT"
json_output=false

while [ $# -gt 0 ]; do
    case "$1" in
        --prompt)
            shift
            [ $# -eq 0 ] && { echo "Error: --prompt requires a value" >&2; usage; exit 1; }
            prompt="$1"
            ;;
        --json)
            json_output=true
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        -*)
            echo "Error: unknown option $1" >&2
            usage
            exit 1
            ;;
        *)
            if [ -z "$audio_file" ]; then
                audio_file="$1"
            else
                echo "Error: only one audio file argument allowed" >&2
                usage
                exit 1
            fi
            ;;
    esac
    shift
done

if [ -z "$audio_file" ]; then
    echo "Error: missing audio file argument" >&2
    usage
    exit 1
fi

# ── Validation ──────────────────────────────────────────────────────
if [ ! -f "$audio_file" ]; then
    echo "Error: audio file not found: $audio_file" >&2
    exit 1
fi

if [ -z "${OPENROUTER_API_KEY:-}" ]; then
    echo "Error: OPENROUTER_API_KEY environment variable is not set" >&2
    exit 1
fi

for dep in ffmpeg curl jq base64; do
    if ! command -v "$dep" >/dev/null 2>&1; then
        echo "Error: required dependency '$dep' not found in PATH" >&2
        exit 1
    fi
done

# ── Transcription pipeline (M3) ─────────────────────────────────────
echo "transcribe.sh: pipeline not implemented yet" >&2
exit 1
