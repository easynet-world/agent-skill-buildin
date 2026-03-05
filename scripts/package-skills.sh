#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$ROOT_DIR/skills"
DIST_DIR="$ROOT_DIR/dist"
ARTIFACT_NAME="skills.tgz"
ARTIFACT_PATH="$DIST_DIR/$ARTIFACT_NAME"
CHECKSUM_PATH="$DIST_DIR/$ARTIFACT_NAME.sha256"

if [ ! -d "$SKILLS_DIR" ]; then
  echo "skills directory not found: $SKILLS_DIR" >&2
  exit 1
fi

mkdir -p "$DIST_DIR"
rm -f "$ARTIFACT_PATH" "$CHECKSUM_PATH"

# Package only the skills directory to keep artifact layout stable.
tar -czf "$ARTIFACT_PATH" -C "$ROOT_DIR" skills

if command -v shasum >/dev/null 2>&1; then
  shasum -a 256 "$ARTIFACT_PATH" | awk '{print $1}' > "$CHECKSUM_PATH"
elif command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$ARTIFACT_PATH" | awk '{print $1}' > "$CHECKSUM_PATH"
else
  echo "No SHA-256 tool found (shasum/sha256sum)." >&2
  exit 1
fi

echo "Built artifact: $ARTIFACT_PATH"
echo "Checksum: $(cat "$CHECKSUM_PATH")"
