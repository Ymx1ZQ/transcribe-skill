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

### M1 — Scaffolding ✅

- [x] Create `SKILL.md`, `README.md`, `install.sh`, `transcribe.sh` (stub), `run_tests.sh`, `tests/`
- [x] `install.sh` follows the convention used by `social-scraper/install.sh` (cp + `--force`)
- [x] Smoke test (`tests/test_install.sh`): `./install.sh --force` then `ls ~/.claude/skills/transcribe/SKILL.md`

### M2 — Argument parsing & validation ✅

- [x] **Test first**: `tests/test_missing_key.sh` — unset `OPENROUTER_API_KEY`, expect exit 1 + clear error
- [x] **Test first**: `tests/test_missing_file.sh` — pass `/nonexistent.mp3`, expect exit 1 + clear error
- [x] **Test first**: `tests/test_no_args.sh` — call with no args, expect exit 1 + usage on stderr
- [x] Implement argument parsing, dependency checks, env var check in `transcribe.sh`
- [x] All three tests pass

### M3 — Core transcription pipeline ⬜

- [ ] **Test first**: `tests/test_basic.sh` — pass `tests/fixtures/hello.mp3`, expect exit 0 and non-empty stdout (and the output should contain at least one alphabetic character — a real transcription, not whitespace)
- [ ] **Test first**: `tests/test_json_output.sh` — pass `--json`, expect output to be valid JSON with key `transcription`
- [ ] Implement: ffmpeg conversion → base64 → OpenRouter POST → response parsing → stdout (or JSON)
- [ ] Cleanup of temp files even on failure (`trap`)
- [ ] Both tests pass

### M4 — SKILL.md trigger semantics ⬜

- [ ] Write `SKILL.md` with explicit `TRIGGER` and `SKIP` clauses:
  - **TRIGGER when**: an audio attachment (`audio/*` MIME type) arrives via channel (e.g., Discord) without other meaningful text from the user; OR the user explicitly asks to transcribe an audio file
  - **SKIP when**: the user gives explicit alternative instructions for the audio (e.g., "convert this to wav", "extract metadata"); the attachment is not audio
- [ ] Include invocation contract: skill receives the **absolute path** to the audio file (already downloaded by the caller); returns transcription on stdout
- [ ] Include 2 examples of typical invocation

### M5 — Install + manual verify ⬜

- [ ] Run `./install.sh --force`
- [ ] Confirm Claude Code lists `transcribe` among available skills
- [ ] Manual smoke test: send a new Discord voice message; verify the skill is invoked and the transcription is returned to the user
