---
name: codex
description: Use when the user asks to run Codex CLI (codex exec, codex resume) or references OpenAI Codex for code analysis, refactoring, or automated editing
---

# Codex Skill Guide

## Default Configuration (Fixed)
- **Model**: `gpt-5.2`
- **Reasoning Effort**: `xhigh`
- **Sandbox**: `danger-full-access` (full read/write/network permissions)
- **Auto Mode**: `--full-auto` (enabled by default)

## Running a Task
1. Directly assemble the command with the following fixed options:
   - `-m gpt-5.2`
   - `--config model_reasoning_effort="xhigh"`
   - `--sandbox danger-full-access`
   - `--full-auto`
   - `--skip-git-repo-check`
   - `-C, --cd <DIR>` (if needed)
2. Always use --skip-git-repo-check.
3. When continuing a previous session, use `codex exec --skip-git-repo-check resume --last` via stdin. When resuming don't use any configuration flags unless explicitly requested by the user. Resume syntax: `echo "your prompt here" | codex exec --skip-git-repo-check resume --last 2>/dev/null`. All flags have to be inserted between exec and resume.
4. **IMPORTANT**: By default, append `2>/dev/null` to all `codex exec` commands to suppress thinking tokens (stderr). Only show stderr if the user explicitly requests to see thinking tokens or if debugging is needed.
5. Run the command, capture stdout/stderr (filtered as appropriate), and summarize the outcome for the user.
6. **After Codex completes**, inform the user: "You can resume this Codex session at any time by saying 'codex resume' or asking me to continue with additional analysis or changes."

### Quick Reference
| Use case | Command template |
| --- | --- |
| Standard execution | `codex exec -m gpt-5.2 --config model_reasoning_effort="xhigh" --sandbox danger-full-access --full-auto --skip-git-repo-check "prompt" 2>/dev/null` |
| Run from another directory | `codex exec -m gpt-5.2 --config model_reasoning_effort="xhigh" --sandbox danger-full-access --full-auto --skip-git-repo-check -C <DIR> "prompt" 2>/dev/null` |
| Resume recent session | `echo "prompt" \| codex exec --skip-git-repo-check resume --last 2>/dev/null` |

## Following Up
- After every `codex` command, immediately use `AskUserQuestion` to confirm next steps, collect clarifications, or decide whether to resume with `codex exec resume --last`.
- When resuming, pipe the new prompt via stdin: `echo "new prompt" | codex exec resume --last 2>/dev/null`. The resumed session automatically uses the same model, reasoning effort, and sandbox mode from the original session.

## Error Handling
- Stop and report failures whenever `codex --version` or a `codex exec` command exits non-zero; request direction before retrying.
- When output includes warnings or partial results, summarize them and ask how to adjust using `AskUserQuestion`.
