# Transcribe Skill — DEVPLAN v0.1

A Claude Code skill that transcribes audio files using **Gemini 3.1 Flash Lite (preview)** via OpenRouter.

Auto-invoked when an audio attachment arrives from a connected channel (Discord, etc.) without other accompanying text — Claude downloads the file, the skill transcribes it, Claude can then respond to the spoken content.

## Goals

- One-shot transcription of any common audio format (`.ogg`, `.mp3`, `.wav`, `.m4a`, `.opus`, `.flac`)
- Cheap, fast, "good enough" quality even for technical/Italian speech
- Clear auto-trigger contract so Claude reliably invokes the skill on channel audio

## Out of scope (v0.1)

- Multi-model selection or `--quality` flags — fixed to `google/gemini-3.1-flash-lite-preview`
- Auto-fallback if the preview model is deprecated
- Streaming output, batch directory processing, speaker diarization
- Built-in audio answer/action (the skill returns text only; Claude decides what to do)

## Dependencies

- `ffmpeg` — audio format normalization
- `curl`, `jq`
- `OPENROUTER_API_KEY` env var

## Layout

```
skills/transcribe/
├── SKILL.md              # trigger description for Claude
├── README.md             # short user-facing doc
├── install.sh            # deploys to ~/.claude/skills/transcribe/
├── transcribe.sh         # main CLI script
├── run_tests.sh          # entry point for tests
└── tests/
    ├── fixtures/
    │   └── hello.mp3     # tiny sample audio (synthesized via ffmpeg sine + checked-in)
    ├── test_missing_key.sh
    ├── test_missing_file.sh
    └── test_basic.sh
```

## Interface (CLI)

```
transcribe.sh <audio_file> [--prompt "<custom prompt>"] [--json]
```

- Default prompt: *"Trascrivi questo audio fedelmente. Restituisci solo la trascrizione, senza commenti."*
- Without `--json`: prints transcription on stdout
- With `--json`: prints `{"transcription": "...", "model": "...", "cost": 0.0002, "audio_tokens": 175, "duration_s": 6.26}`

Exit codes: `0` success, `1` bad input / missing dep / missing key, `2` API error.

## Milestones (TDD)

For each milestone: **(a) write the test first, (b) confirm it fails, (c) implement, (d) confirm it passes.**

Archived: M1-M6, all closed and shipped — see [DEVPLAN_ARCHIVE.md](DEVPLAN_ARCHIVE.md).

## Deviations / notes

- The skill repo has no remote configured — milestone commits are local only. If a remote is added later, run `git push -u origin main` once.
- The auto-trigger contract is enforced by the SKILL.md `description:` and the `TRIGGER`/`SKIP` clauses — actual auto-invocation behavior is governed by the Claude Code harness, which selects skills based on description match.
