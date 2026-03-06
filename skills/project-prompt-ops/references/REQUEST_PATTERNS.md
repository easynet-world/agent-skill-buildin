# Request Patterns

Use this file only when the user instruction is broad, mixed, or does not provide explicit mode labels.

## Canonical Instruction Shape

Normalize incoming instruction into:

- `project`: absolute or repo-relative path
- `mode`: create | update | query | question
- `provider`: codex | claude | cursor
- `goal`: one-sentence expected outcome
- `constraints`: tests, style, compatibility, forbidden operations
- `deliverable`: patch, answer, or findings format

## Mode Heuristics

- Mentions "add/new/build/implement" -> `create`
- Mentions "fix/change/modify/refactor/adjust" -> `update`
- Mentions "where/what/find/list/show" -> `query`
- Mentions "why/how/should/explain/compare" -> `question`

When multiple verbs appear, prioritize the user's final explicit ask.

## Provider Heuristics

- User explicitly says `codex` -> provider `codex`
- User explicitly says `claude` -> provider `claude`
- User explicitly says `cursor` -> provider `cursor`
- If omitted -> default provider `codex`

## Execution Command Template

```bash
skills/project-prompt-ops/scripts/run_prompt_mode.sh \
  --provider "<provider>" \
  --mode "<mode>" \
  --project "<project>" \
  --instruction "<goal>"
```

## Output Template

Use this response shape:

```text
Mode: <mode>
Project: <project>
Changes|Findings:
- ...
Validation:
- command: <cmd or N/A>
- result: <pass/fail/not run>
Open Risks:
- ... (omit section when empty)
```
