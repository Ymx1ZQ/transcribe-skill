# transcribe

Claude Code skill that transcribes audio files using Gemini 3.1 Flash Lite (preview) via OpenRouter.

## Install

```bash
./install.sh --force
```

Deploys `SKILL.md` and `transcribe.sh` to `~/.claude/skills/transcribe/`.

## Requirements

- `ffmpeg`, `curl`, `jq`
- `OPENROUTER_API_KEY` environment variable

## Usage

```bash
transcribe.sh <audio_file> [--prompt "<custom prompt>"] [--json]
```

The skill is auto-invoked by Claude when an audio attachment arrives from a channel (e.g. Discord) without other instructions.

## Tests

```bash
./run_tests.sh
```
