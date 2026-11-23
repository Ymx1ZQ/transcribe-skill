# transcribe

Claude Code skill that transcribes audio files using Gemini 3.1 Flash Lite (preview) via OpenRouter.

## Install

`transcribe/` is the whole skill: a folder holding `SKILL.md` and `transcribe.sh`. Put a
copy where your assistant reads skills.

```bash
git clone <repository-url> transcribe-skill
cp -r transcribe-skill/transcribe ~/.claude/skills/transcribe            # Claude Code
cp -r transcribe-skill/transcribe ~/.gemini/skills/transcribe            # Gemini CLI
cp -r transcribe-skill/transcribe ~/.config/opencode/skills/transcribe   # opencode
```

For Codex, its skill installer takes the GitHub path directly; pin a tag or a commit
instead of `main`, because a moving branch changes the instructions the assistant follows:

```
$skill-installer install <owner>/<repository>/tree/<tag-or-commit>/transcribe
```

A manual Codex copy goes in `~/.agents/skills/transcribe`. Keep one active copy per
assistant. Check that `transcribe.sh` is executable in the copy (`chmod +x`).

**Update.** Save any local edits, then replace the whole installed folder with the new
one. `diff -r transcribe-skill/transcribe <installed folder>` shows whether a copy has
drifted from the source.

**Layout.** The payload is the `transcribe/` folder. `README.md`, `DEVPLAN*.md`,
`run_tests.sh` and `tests/` stay in the repository and are not installed.

**Not provided.** There is no installer script (`install.sh`, `--force`, `--uninstall`);
earlier versions had one.

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
