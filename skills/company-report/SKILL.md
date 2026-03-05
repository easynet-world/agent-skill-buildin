---
name: company-report
description: Create a single-file HTML company report with a strict, step-locked workflow. Use when the user asks for a company report, stock summary, or investor-style overview.
---

# Company Report (HTML, Strict Workflow)

Produce exactly one file: `output/company-report.html`.
The workflow below is mandatory and sequential. Do not skip, reorder, or add extra steps.

## Inputs

- `COMPANY`: required
- `SYMBOL`: optional but preferred

If `COMPANY` is missing, ask exactly one question to obtain it.

## Required Reads (must happen before any data-fetch tool call)

1. `skills/company-report/references/HTML_TEMPLATE.md`
2. `skills/company-report/references/CONVENTIONS.md`

## Allowed Tool Set (whitelist)

Only these `agent-tool` tools are allowed for data collection:

1. `http.yahooFinance` (or `core.http.yahooFinance`): stock quote data
2. `http.duckduckgoSearch` (or `core.http.duckduckgoSearch`): company news/overview search
3. `http.yahooFinanceNews` (or `core.http.yahooFinanceNews`): optional fallback Yahoo Finance news
4. `http.fetchText` (or `core.http.fetchText`): optional last-resort fallback fetch
5. `read_file` / `write_file` / `edit_file`: required file I/O for references and report output

No shell script command under `skills/company-report/scripts/` is allowed.
No `execute`-based `curl` fetch command is allowed.

Tool-call arguments must be strict JSON.

## Mandatory Step Sequence (do not deviate)

1. Resolve identifiers.
- Use user-provided `COMPANY` and `SYMBOL` directly.
- If `SYMBOL` missing, infer from context once and continue.

2. Read required references.
- Read both required files listed above.

3. Fetch stock data.
- Call `http.yahooFinance` exactly once with `symbol` (or `symbols`) for `SYMBOL`.

4. Fetch news data.
- Call `http.duckduckgoSearch` exactly once using a query equivalent to `"COMPANY news"`.

5. Conditional fallback for news only.
- If step 4 yields no usable items, call `http.yahooFinanceNews` exactly once with `symbol` (or `query`) for `SYMBOL`.
- If Yahoo Finance news still yields no usable items, optionally call `http.fetchText` once as last resort with Yahoo search/news URL and extract usable items from response text.

6. Optional overview lookup.
- Only if company overview content is still weak after steps 2-5.
- At most once via `http.duckduckgoSearch` with a query equivalent to `"COMPANY company overview"`.

7. Write report file.
- Write full static HTML to `output/company-report.html` in one complete document.

8. Validate report.
- Validate by reading `output/company-report.html` and checking all required structure/section rules in this SKILL.
- If validation fails: edit file, then re-check until pass.

9. Final response.
- Include:
  - exact output path
  - validation result
  - whether fallback/optional lookup was used

## Output Requirements

- Must include `<!DOCTYPE html>`
- Must use Bootstrap 5 CDN
- Must include exactly these section ids:
  - `company-overview`
  - `stock-data`
  - `news`
  - `sources`
- Must follow `HTML_TEMPLATE.md` and `CONVENTIONS.md`
- Must contain:
  - 2-4 paragraph company overview (for detailed requests)
  - stock metrics table
  - news list with links
  - explicit sources section
- Output must be static HTML only

## Prohibited Actions

- Do not use `glob`
- Do not use `grep`
- Do not use ad-hoc `search`/`inspect` exploration unrelated to required inputs
- Do not call `execute` for network fetching (`curl`, `wget`, etc.)
- Do not use shell wrappers such as `bash -lc`
- Do not call non-whitelisted fetch tools

## Failure Policy

- If stock fetch fails: still produce report and mark stock data as unavailable.
- If all news fetches fail or return empty: show `No recent news found.`
- Never skip report generation due to partial data failure.
