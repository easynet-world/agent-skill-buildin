---
name: project-prompt-ops
description: Execute project-scoped instructions by calling Codex, Claude, or Cursor shell CLI in prompt mode. Use when the user asks to create, update, query, or question a specific project through codex/claude/cursor command-line workflows.
---

# Project Prompt Ops

Use shell prompt mode with exactly one provider and one mode per request.
Allowed providers: `codex`, `claude`, `cursor`.
Allowed modes: `create`, `update`, `query`, `question`.

## Inputs

- `PROJECT`: required project path
- `INSTRUCTION`: required task instruction
- `MODE`: optional explicit mode; infer if omitted
- `PROVIDER`: optional explicit provider; infer if omitted

If `PROJECT` is missing, ask one concise question and stop.

## Required Reads

1. `references/REQUEST_PATTERNS.md`

## Selection Rules

### Mode

- `create`: add new files or new behavior
- `update`: change existing behavior
- `query`: inspect codebase without edits
- `question`: answer technical question without edits

When ambiguous, prefer lower-risk mode in this order:

1. `query`
2. `question`
3. `update`
4. `create`

### Provider

- If user explicitly names provider, use it.
- Else default to `codex`.

## Mandatory Execution Path

Always invoke the script below. Do not directly call `codex`, `claude`, or `cursor-agent` in free-form.

```bash
skills/project-prompt-ops/scripts/run_prompt_mode.sh \
  --provider <codex|claude|cursor> \
  --mode <create|update|query|question> \
  --project <project-path> \
  --instruction "<user-instruction>"
```

Optional:

- `--model <model-name>`
- `--output <path>`
- `--dry-run` (preview assembled command and prompt only)

The script internally:

1. Builds normalized prompt text with mode-specific constraints.
2. Calls provider shell CLI in prompt mode:
- `codex exec`
- `claude -p`
- `cursor-agent -p`
3. Returns provider output.

## Post-Run Requirements

- For `create` and `update`, run a relevant local validation command in `PROJECT` when possible.
- For `query` and `question`, do not edit project files.

## Response Structure

- `Mode`
- `Provider`
- `Project`
- `Changes` or `Findings`
- `Validation`
- `Open Risks` (only when non-empty)

## Constraints

- Do not perform destructive operations unless explicitly requested.
- Do not expand scope outside `PROJECT` unless asked.
- Do not skip the wrapper script.
- Keep output concise and implementation-focused.
