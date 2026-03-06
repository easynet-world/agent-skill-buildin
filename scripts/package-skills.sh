#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$ROOT_DIR/skills"
DIST_DIR="$ROOT_DIR/dist"
ARTIFACT_NAME="skills.zip"
ARTIFACT_PATH="$DIST_DIR/$ARTIFACT_NAME"
CHECKSUM_PATH="$DIST_DIR/$ARTIFACT_NAME.sha256"
SIGNATURE_PATH="$DIST_DIR/$ARTIFACT_NAME.sig"
SIGNING_KEY_PATH="${SIGNING_KEY_PATH:-}"

if [ ! -d "$SKILLS_DIR" ]; then
  echo "skills directory not found: $SKILLS_DIR" >&2
  exit 1
fi

mkdir -p "$DIST_DIR"
rm -f "$ARTIFACT_PATH" "$CHECKSUM_PATH" "$SIGNATURE_PATH" "$DIST_DIR/skills.tgz" "$DIST_DIR/skills.tgz.sha256" "$DIST_DIR/skills.tgz.sig"

# Package only the skills directory to keep artifact layout stable.
(cd "$ROOT_DIR" && zip -rq "$ARTIFACT_PATH" skills)

if command -v shasum >/dev/null 2>&1; then
  shasum -a 256 "$ARTIFACT_PATH" | awk '{print $1}' > "$CHECKSUM_PATH"
elif command -v sha256sum >/dev/null 2>&1; then
  sha256sum "$ARTIFACT_PATH" | awk '{print $1}' > "$CHECKSUM_PATH"
else
  echo "No SHA-256 tool found (shasum/sha256sum)." >&2
  exit 1
fi

if [ -z "$SIGNING_KEY_PATH" ]; then
  echo "SIGNING_KEY_PATH is required for signing." >&2
  echo "Example: SIGNING_KEY_PATH=/path/to/private.pem npm run build" >&2
  exit 1
fi

if [ ! -f "$SIGNING_KEY_PATH" ]; then
  echo "Signing key not found: $SIGNING_KEY_PATH" >&2
  exit 1
fi

openssl dgst -sha256 -sign "$SIGNING_KEY_PATH" -out "$SIGNATURE_PATH" "$ARTIFACT_PATH"

echo "Built artifact: $ARTIFACT_PATH"
echo "Checksum: $(cat "$CHECKSUM_PATH")"
echo "Signature: $SIGNATURE_PATH"
