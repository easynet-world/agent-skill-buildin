#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PROVIDER=""
MODE=""
PROJECT=""
INSTRUCTION=""
MODEL=""
OUTPUT=""
DRY_RUN="false"

usage() {
  cat <<'EOF'
Usage:
  run_prompt_mode.sh \
    --provider <codex|claude|cursor> \
    --mode <create|update|query|question> \
    --project <path> \
    --instruction <text> \
    [--model <model>] \
    [--output <file>] \
    [--dry-run]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --provider)
      PROVIDER="${2:-}"
      shift 2
      ;;
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
    --model)
      MODEL="${2:-}"
      shift 2
      ;;
    --output)
      OUTPUT="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN="true"
      shift
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

if [[ -z "$PROVIDER" || -z "$MODE" || -z "$PROJECT" || -z "$INSTRUCTION" ]]; then
  usage >&2
  exit 2
fi

if [[ ! -d "$PROJECT" ]]; then
  echo "Project path not found: $PROJECT" >&2
  exit 2
fi

PROJECT_ABS="$(cd "$PROJECT" && pwd)"

PROMPT="$("$SCRIPT_DIR/build_prompt.sh" \
  --mode "$MODE" \
  --project "$PROJECT_ABS" \
  --instruction "$INSTRUCTION")"

if [[ "$DRY_RUN" == "true" ]]; then
  echo "provider: $PROVIDER"
  echo "mode: $MODE"
  echo "project: $PROJECT_ABS"
  if [[ -n "$MODEL" ]]; then
    echo "model: $MODEL"
  fi
  echo "----- prompt begin -----"
  echo "$PROMPT"
  echo "----- prompt end -----"
  exit 0
fi

run_and_capture() {
  if [[ -n "$OUTPUT" ]]; then
    mkdir -p "$(dirname "$OUTPUT")"
    "$@" | tee "$OUTPUT"
  else
    "$@"
  fi
}

case "$PROVIDER" in
  codex)
    if ! command -v codex >/dev/null 2>&1; then
      echo "codex command not found" >&2
      exit 127
    fi
    CMD=(codex exec --cd "$PROJECT_ABS")
    if [[ -n "$MODEL" ]]; then
      CMD+=(--model "$MODEL")
    fi
    CMD+=("$PROMPT")
    run_and_capture "${CMD[@]}"
    ;;
  claude)
    if ! command -v claude >/dev/null 2>&1; then
      echo "claude command not found" >&2
      exit 127
    fi
    CMD=(claude -p)
    if [[ -n "$MODEL" ]]; then
      CMD+=(--model "$MODEL")
    fi
    CMD+=("$PROMPT")
    (
      cd "$PROJECT_ABS"
      run_and_capture "${CMD[@]}"
    )
    ;;
  cursor)
    if ! command -v cursor-agent >/dev/null 2>&1; then
      echo "cursor-agent command not found" >&2
      exit 127
    fi
    CMD=(cursor-agent -p --workspace "$PROJECT_ABS" --output-format text)
    if [[ -n "$MODEL" ]]; then
      CMD+=(--model "$MODEL")
    fi
    CMD+=("$PROMPT")
    run_and_capture "${CMD[@]}"
    ;;
  *)
    echo "Unsupported provider: $PROVIDER" >&2
    exit 2
    ;;
esac
