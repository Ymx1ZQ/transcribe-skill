---
name: transcribe
description: Transcribe an audio file using Gemini 3.1 Flash Lite via OpenRouter. Auto-invoke when an audio attachment arrives from a connected channel (Discord, Telegram, etc.) without other accompanying instructions; or when the user explicitly asks to transcribe an audio file.
---

# transcribe — Audio Transcription

This skill takes an audio file path on disk and returns the transcription as plain text. Internally it converts the file to mp3 16 kHz mono with `ffmpeg`, base64-encodes it, and posts it to the OpenRouter Chat Completions API using `google/gemini-3.1-flash-lite-preview` with `input_audio` content.

## TRIGGER when

1. **Channel audio attachment with no other instruction.** An audio file (`audio/*` MIME type) arrives via an external channel (`<channel source="..."` block — Discord voice message, Telegram audio note, etc.) and the user did not include other instructions for what to do with it. → Download the attachment, then invoke this skill on the resulting file path.

2. **Explicit transcription request.** The user explicitly asks to transcribe, "trascrivi", "what does this audio say", "convert this voice message to text", or similar — and provides or references an audio file path.

## SKIP when

- The user provides explicit alternative instructions for the audio (e.g. "convert this to wav", "extract metadata", "show the spectrogram", "trim the silence"). Don't transcribe — do what they asked.
- The attachment is not audio (image, video, document, etc.). Other skills / tools handle those.
- The user is asking how to use the skill (meta-question), not asking it to run.

## Invocation contract

The skill is exposed as a single shell script, `transcribe.sh`, stored in this skill's own folder next to `SKILL.md`. Run it from that folder: `<skill-dir>` below is the directory this `SKILL.md` was loaded from (for example `~/.claude/skills/transcribe`).

```
transcribe.sh <audio_file> [--prompt "<custom prompt>"] [--json]
```

**Inputs:**
- `<audio_file>` — absolute path to a local audio file (any format `ffmpeg` can read: `ogg`, `mp3`, `wav`, `m4a`, `opus`, `flac`, …)
- `--prompt "<text>"` — optional custom instruction (default: faithful transcription in source language)
- `--json` — return a JSON object with `transcription`, `model`, `cost`, `audio_tokens`, `completion_tokens`

**Output (default):** transcription text on stdout.

**Output (`--json`):** JSON object on stdout.

**Exit codes:** `0` success, `1` bad input / missing dep / missing key, `2` API error.

**Required env:** `OPENROUTER_API_KEY` must be set in the environment.

**Required deps on PATH:** `ffmpeg`, `curl`, `jq`, `base64`.

## Examples

**Auto-invocation on Discord voice message:**

```
# 1. Discord delivers an attachment-only message:
#    <channel source="discord" ... attachment_count="1" attachments="voice-message.ogg, audio/ogg, 22KB">
# 2. Download it:
download_attachment(chat_id, message_id) → /home/.../inbox/abc.ogg
# 3. Invoke this skill:
<skill-dir>/transcribe.sh /home/.../inbox/abc.ogg
# 4. Use the returned text as the user's spoken intent and respond accordingly.
```

**Explicit user request from CLI:**

```
<skill-dir>/transcribe.sh ~/Downloads/recording.m4a --json
```

## Notes

- The skill does not download attachments — the caller is expected to materialize the file first.
- The skill does not act on the transcription — Claude reads the output and decides how to respond to the user.
- Cost: ~$0.0001–$0.001 per audio depending on duration. Free for most practical use.
- Model is fixed (`google/gemini-3.1-flash-lite-preview`) by design in v0.1; quality/cost tier flags will land in a later version if the use case requires it.
