#!/usr/bin/env bash
# Validate company HTML report: required sections and basic structure.
# Usage: scripts/validate_html.sh path/to/report.html
# Exit 0 if valid, non-zero otherwise.

set -e
FILE="${1:-}"
if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  echo "Usage: $0 <path-to-report.html>"
  exit 1
fi

MISSING=""
grep -q 'id="company-overview"' "$FILE" || MISSING="${MISSING} company-overview"
grep -q 'id="stock-data"' "$FILE" || MISSING="${MISSING} stock-data"
grep -q 'id="news"' "$FILE" || MISSING="${MISSING} news"
grep -q 'id="sources"' "$FILE" || MISSING="${MISSING} sources"
grep -qi '<!DOCTYPE html>' "$FILE" || MISSING="${MISSING} doctype"
grep -q '<html' "$FILE" || MISSING="${MISSING} html"
grep -q '</body>' "$FILE" || MISSING="${MISSING} body-close"

if [ -n "$MISSING" ]; then
  echo "VALIDATION FAILED — missing:$MISSING"
  echo ""
  echo "Fix: ensure the HTML file contains ALL of the following:"
  echo "  1. <!DOCTYPE html>  at the very top"
  echo "  2. <section id=\"company-overview\"> ... </section>"
  echo "  3. <section id=\"stock-data\"> ... </section>"
  echo "  4. <section id=\"news\"> ... </section>"
  echo "  5. <section id=\"sources\"> ... </section>"
  echo "  6. </body>  closing tag"
  echo ""
  echo "Edit the file to add the missing elements, then re-run this script."
  exit 2
fi

echo "OK: required sections and structure present."
exit 0
