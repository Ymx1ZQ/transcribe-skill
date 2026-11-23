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
├── README.md             # short user-facing doc, install by copying transcribe/
├── transcribe/           # the payload: the only folder an assistant installs
│   ├── SKILL.md          # trigger description for Claude
│   └── transcribe.sh     # main CLI script
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

### M7 — The repo distributes the skill as a plain folder ✅

**Why:** the payload was the repository root and `install.sh` copied two named files into `~/.claude/skills/`, which served one assistant and wrote outside the repo. A folder named like the skill can be copied by hand or fetched by the Codex skill installer into any assistant's skills directory.

**Approach:** move `SKILL.md` and `transcribe.sh` into `transcribe/`, point the tests and `SKILL.md` at the new paths, delete the installer and its test, and rewrite the README Install section as a copy procedure with an update step.

**Tasks:**
- [x] `git mv` `SKILL.md` and `transcribe.sh` into `transcribe/`, keeping the executable bit
- [x] Update the test scripts and `SKILL.md` (script is run from the skill's own folder)
- [x] Remove `install.sh` and `tests/test_install.sh`
- [x] Rewrite the README Install section and the layout tree

**Done when:** `bash run_tests.sh` passes every test that does not need the network, no live file mentions `install.sh`, and the README documents the copy route for Claude Code, Codex, Gemini CLI and opencode.

## Deviations / notes

- The skill repo has no remote configured — milestone commits are local only. If a remote is added later, run `git push -u origin main` once.
- The auto-trigger contract is enforced by the SKILL.md `description:` and the `TRIGGER`/`SKIP` clauses — actual auto-invocation behavior is governed by the Claude Code harness, which selects skills based on description match.
