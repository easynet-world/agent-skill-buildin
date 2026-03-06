#!/usr/bin/env bash
set -euo pipefail

MODE=""
PROJECT=""
INSTRUCTION=""

usage() {
  cat <<'EOF'
Usage: build_prompt.sh --mode <create|update|query|question> --project <path> --instruction <text>
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --project)
      PROJECT="${2:-}"
      shift 2
      ;;
    --instruction)
      INSTRUCTION="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$MODE" || -z "$PROJECT" || -z "$INSTRUCTION" ]]; then
  usage >&2
  exit 2
fi

case "$MODE" in
  create)
    MODE_RULE="Create new code/files as requested. Keep scope strictly inside project and wire minimal required integration points."
    ;;
  update)
    MODE_RULE="Update existing code with minimal safe diffs. Preserve unrelated behavior and avoid broad refactors."
    ;;
  query)
    MODE_RULE="Read and analyze only. Do not modify files. Return concrete findings with file path references."
    ;;
  question)
    MODE_RULE="Answer the technical question directly. Do not modify files unless explicitly requested."
    ;;
  *)
    echo "Invalid mode: $MODE" >&2
    exit 2
    ;;
esac

cat <<EOF
You are running in ${MODE} mode for a single project.

Project path:
${PROJECT}

User instruction:
${INSTRUCTION}

Rules:
- ${MODE_RULE}
- Stay within the specified project path.
- Avoid destructive operations unless explicitly requested.
- Keep response concise and implementation-focused.
- If editing is performed (create/update), include a short validation result.

Output format:
- Mode: ${MODE}
- Summary:
- Details:
- Validation:
- Risks: (omit if none)
EOF
