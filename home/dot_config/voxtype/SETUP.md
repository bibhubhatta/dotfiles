# VoxType + Ollama post-processing setup

Configures VoxType (push-to-talk voice-to-text) to route the raw transcript
through a local LLM that fixes punctuation, removes filler words, and
restores software-engineering terms that speech-to-text tends to mangle.

Optimized for dictating instructions to Claude Code on Linux.

---

## What you get

- **Transcription**: Parakeet TDT 0.6B (GPU, ~1.2 GB VRAM) — built into VoxType.
- **Cleanup**: `voxtype-cleanup`, a derived model from `gemma4:e4b` (8B
  Matformer, ~11 GB VRAM resident with 2048 ctx) with a system prompt tuned
  for dev-instruction dictation. Thinking disabled.
- **Latency**: ~430 ms end-to-end after warmup. Cold start ~5–8 s; mitigated
  by `OLLAMA_KEEP_ALIVE=24h` so the model stays resident.
- **Total VRAM**: ~12 GB. Fits easily on a 24 GB card; may not fit on 12 GB.

---

## Requirements

| Component               | Notes                                                     |
| ----------------------- | --------------------------------------------------------- |
| Linux + systemd         | Tested on Arch (Omarchy). Adjust paths on other distros.  |
| NVIDIA GPU, ≥16 GB VRAM | A5500 24 GB used here. CUDA via Ollama's bundled libs.    |
| Ollama ≥ 0.20           | Required for `gemma4:e4b` and `--think=false`.            |
| VoxType                 | Already installed; `voxtype.service` runs as a user unit. |

---

## Setup (5 minutes)

### 1. Pull the base model

```bash
ollama pull gemma4:e4b
```

### 2. Write the Modelfile

Save to `~/.config/voxtype/cleanup.Modelfile` — see [Modelfile](#modelfile)
section below for full contents.

### 3. Build the derived model

```bash
ollama create voxtype-cleanup -f ~/.config/voxtype/cleanup.Modelfile
```

Verify:

```bash
ollama list                           # voxtype-cleanup:latest should appear
ollama show voxtype-cleanup --system  # should print the system prompt
```

### 4. Configure Ollama keep-alive (systemd drop-in)

Without this, Ollama unloads idle models after 5 minutes — first dictation
after any pause pays a 5–8 s cold-start. The drop-in pins it for 24 h
(timer resets on every request).

```bash
sudo mkdir -p /etc/systemd/system/ollama.service.d && \
printf '[Service]\nEnvironment="OLLAMA_KEEP_ALIVE=24h"\n' | \
  sudo tee /etc/systemd/system/ollama.service.d/keep-alive.conf > /dev/null && \
sudo systemctl daemon-reload && \
sudo systemctl restart ollama
```

Verify:

```bash
systemctl show ollama --property=Environment | grep OLLAMA_KEEP_ALIVE
```

### 5. Enable VoxType post-processing

Add this block to `~/.config/voxtype/config.toml` (replaces the commented
example near `[output]`):

```toml
[output.post_process]
command = "ollama run --nowordwrap --think=false voxtype-cleanup"
timeout_ms = 8000
trim = true
fallback_on_empty = true
```

### 6. Restart VoxType and warm the model

```bash
systemctl --user restart voxtype
echo "warmup" | ollama run --nowordwrap --think=false voxtype-cleanup > /dev/null
```

### 7. Verify

```bash
journalctl --user -u voxtype --since "10 seconds ago" | grep -i post-processing
# Expect: INFO Post-processing enabled: command="ollama run --nowordwrap --think=false voxtype-cleanup", timeout=8000ms

ollama ps
# Expect: voxtype-cleanup ... 100% GPU ... UNTIL: 24 hours from now
```

Hold your VoxType hotkey (default `SCROLLLOCK`) and dictate something like:
_"um so add a c l i flag to the python script that takes a j s o n config"_
→ should appear at cursor as _"Add a CLI flag to the Python script that
takes a JSON config."_

---

## Files

### Modelfile

`~/.config/voxtype/cleanup.Modelfile`:

```dockerfile
FROM gemma4:e4b

PARAMETER temperature 0.2
PARAMETER num_ctx 2048
PARAMETER top_p 0.9

SYSTEM """
You are a post-processor for voice-dictated text. The user dictates instructions to an AI coding assistant (Claude Code) running on Linux, so the transcript contains software engineering vocabulary: programming languages, frameworks, libraries, command-line tools, file paths, APIs, and shell commands.

Your job is to emit a cleaned version of the input. Apply these fixes:

1. Restore acronyms that speech-to-text spaced out:
   "a p i" -> "API", "j s o n" -> "JSON", "c s s" -> "CSS", "s q l" -> "SQL",
   "u r l" -> "URL", "h t t p" -> "HTTP", "u i" -> "UI", "i d" -> "ID",
   "a w s" -> "AWS", "g c p" -> "GCP", "c l i" -> "CLI", "s d k" -> "SDK".

2. Restore compound technical terms split into separate words:
   "type script" -> "TypeScript", "java script" -> "JavaScript",
   "git hub" / "get hub" -> "GitHub", "post gres" / "post grays" -> "Postgres",
   "node js" -> "Node.js", "next js" -> "Next.js", "kuber netes" -> "Kubernetes",
   "my sequel" -> "MySQL", "redis" stays "Redis", "dock er" -> "Docker".

3. Fix homophones in command context:
   "get" -> "git" before clone, push, pull, commit, merge, branch, rebase,
     fetch, log, status, diff, checkout, stash, blame, reset, revert.
   "pseudo" / "soodo" -> "sudo" before any command name.
   Preserve tool names literally: npm, pnpm, uv, jj, ssh, scp, rsync, curl, wget, kubectl.

4. Fix punctuation, capitalization, and basic grammar. Remove filler words:
   um, uh, like, you know, basically, sort of, kind of -- but only when used
   as filler. Do NOT remove "I think", "actually", "really" -- they carry meaning.

5. Preserve the speaker exact wording, imperative voice, and intent.
   Do not paraphrase, summarize, restructure sentences, or soften commands.
   "add a function" stays imperative -- do not turn it into "could you add a function".

6. Do NOT add any of these to the output:
   - Quotes, backticks, or code blocks
   - Markdown formatting of any kind
   - Preambles like "Here is the cleaned text:" or "Sure, here you go:"
   - Commentary, explanations, or notes
   - Trailing remarks or follow-up questions

Output ONLY the cleaned text. No prefix. No suffix. Nothing else.

Example:
Input: um so add a like a function to fix the get clone command in the j s o n config and uh make sure it handles the type script case
Output: Add a function to fix the git clone command in the JSON config and make sure it handles the TypeScript case.
"""
```

### VoxType config snippet

In `~/.config/voxtype/config.toml`, under the `[output]` section:

```toml
[output.post_process]
command = "ollama run --nowordwrap --think=false voxtype-cleanup"
timeout_ms = 8000           # 8 s; generous for an 8B model
trim = true                 # strip leading/trailing whitespace
fallback_on_empty = true    # use raw transcript if LLM returns empty
```

### systemd drop-in

`/etc/systemd/system/ollama.service.d/keep-alive.conf`:

```ini
[Service]
Environment="OLLAMA_KEEP_ALIVE=24h"
```

---

## Tuning the cleanup model

When you spot a recurring transcription error the prompt doesn't fix:

```bash
# 1. Edit the system prompt — add a new bullet under the relevant rule
$EDITOR ~/.config/voxtype/cleanup.Modelfile

# 2. Rebuild (fast; just writes a new manifest)
ollama create voxtype-cleanup -f ~/.config/voxtype/cleanup.Modelfile

# 3. No voxtype restart needed. Next dictation uses the new prompt.
#    Brief cold-start hit on that first dictation as the new manifest loads.
```

The Modelfile is the single source of truth. The voxtype config never
needs to change once it points at `voxtype-cleanup`.

---

## Smoke tests

These cover the main fix categories. Run after setup to confirm everything
works on a new machine.

```bash
test_input() {
  local input="$1"
  local out=$(echo "$input" | ollama run --nowordwrap --think=false voxtype-cleanup 2>/dev/null)
  printf 'IN : %s\nOUT: %s\n\n' "$input" "$out"
}

test_input "um so add a like a function to fix the get clone command in the j s o n config"
test_input "refactor the type script code to use post grays instead of my sequel and add a get hub action"
test_input "okay so basically uh i need you to add a c l i flag to the python script that takes a u r l and posts j s o n to it"
test_input "i think we should actually refactor the auth module before the deadline you know"
```

Expected: filler words gone, acronyms restored (API, JSON, CLI, URL),
compound terms restored (TypeScript, Postgres, MySQL, GitHub), `get` →
`git`, hedge words ("I think", "actually") preserved.

---

## Troubleshooting

| Symptom                                                                                                   | Cause / fix                                                                                                                                                                            |
| --------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| First dictation each session is slow (~5–8 s)                                                             | Model not resident. Check `ollama ps` shows `UNTIL: 24 hours from now`, not `5 minutes`. If wrong, the systemd drop-in didn't take — re-run step 4.                                    |
| Output contains `<think>` or extra commentary                                                             | The `--think=false` flag isn't being passed. Re-check the `command =` line in voxtype config.                                                                                          |
| Post-processing silently does nothing                                                                     | Falling back to raw transcript on timeout/error. Run `journalctl --user -u voxtype -f` while dictating to see the actual error.                                                        |
| Ollama uses CPU instead of GPU                                                                            | `nvidia-smi` should show ollama process. If not, CUDA libs aren't being found — reinstall Ollama or check `/usr/local/lib/ollama/`.                                                    |
| VRAM exhausted, model evicted                                                                             | Another large model (e.g. `gemma4:31b`) was invoked and pushed `voxtype-cleanup` out. Either `ollama rm` the unused model or accept occasional cold starts.                            |
| TOML parse error on voxtype restart                                                                       | `journalctl --user -u voxtype` shows the line. Most common: missing closing quote in `command =`.                                                                                      |
| Output is broken across multiple lines, with stray `[K`, `[5D` fragments and doubled words at line breaks | `ollama run` is doing word-wrap with ANSI escapes; ESC bytes get stripped by the typing layer leaving the bracket fragments visible. Ensure `--nowordwrap` is in the `command =` line. |

---

## Decision log

Why each choice was made — useful when you want to retune.

### Why gemma4:e4b (and not a smaller model)

We considered llama3.2:3b (~250 ms warm) and gemma3:4b. Picked `gemma4:e4b`
because of its **Matformer architecture**: 8B total weights with a nested
4B subset that activates per-token. Result: near-4B speed with richer 8B
domain knowledge. On an A5500, the latency penalty over a true 3B is
small (~430 ms vs ~250 ms) and the cleanup quality is noticeably better
on technical terms.

### Why a derived model with a Modelfile (and not a CLI prompt)

Earlier iteration passed the prompt as a CLI argument:
`ollama run gemma4:e4b 'Fix punctuation...'`. Worked, but: (1) prompt is
treated as user input rather than system instruction, which gives weaker
adherence; (2) voxtype config gets cluttered with a 200-token shell
string; (3) iterating on the prompt requires editing voxtype config and
restarting the daemon.

The derived model puts the prompt in `SYSTEM`, where Gemma weights it
more heavily. Voxtype config stays one line. Prompt iteration is a
single `ollama create` away.

### Why temperature 0.2

Default is 1.0. Cleanup is a deterministic edit task — same input should
produce same output. 0.2 is low enough for consistency without making
the model brittle on edge cases. 0.0 risks repetition / loops on weird
input.

### Why num_ctx 2048

Default is 32k. Voxtype dictations are ≤60 s of audio ≈ ≤300 tokens.
2048 is 6–7× headroom. Cutting context shrinks the KV cache linearly,
saving ~3–5 GB of VRAM on this model.

### Why OLLAMA_KEEP_ALIVE=24h

Default is 5 min. Means every dictation after a 5-min pause pays a
5–8 s cold-start. 24 h pins the model for any reasonable usage pattern;
on long idle (vacation), it eventually evicts naturally. `-1` would
keep forever, but 24 h is the right balance.

### Why --think=false (not --hidethinking)

Gemma4 has reasoning capability. `--think=false` _short-circuits_ the
reasoning phase — saves wall time. `--hidethinking` still computes
reasoning, just suppresses display. For deterministic text editing,
reasoning adds 1–2 s of latency and no quality gain.

### Why --nowordwrap

`ollama run` does word-wrap by emitting ANSI cursor-positioning escapes
(`ESC[<n>D` to move back, `ESC[K` to clear-EOL) so it can re-render the
wrapped word on a new line. When stdout is piped into voxtype's typing
layer, the ESC bytes get stripped/dropped but the bracket sequences
(`[5D`, `[K`) remain as literal characters, and doubled words appear at
each wrap point because the rewind-and-redo never actually rewinds.
`--nowordwrap` emits tokens as a single uninterrupted stream — no
cursor games, no escape leakage. Required for any non-TTY consumer of
`ollama run` output.

- **Did not instruct the model to expand `slash` → `/` or `dot` → `.`**
  in file paths. The risk of false positives (when the user actually
  said "slash" as a word) outweighs the benefit. Interestingly, gemma4
  often does this correctly anyway from context — but it's not
  guaranteed.
- **Did not strip `I think`, `actually`, `really`, or other hedge
  words.** These carry meaning ("I think we should X" is hedged advice;
  "we should X" is a directive). Stripping them changes intent.
- **Did not capitalize identifiers** beyond known brand names. The
  model can't reliably know if "user auth" was meant as `userAuth`,
  `user_auth`, or two words.
- **Did not use few-shot examples beyond one anchor case.** More
  examples would slightly improve adherence at the cost of latency.
  The single example in the system prompt is enough for an 8B model.
