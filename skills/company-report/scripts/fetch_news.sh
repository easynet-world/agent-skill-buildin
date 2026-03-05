#!/usr/bin/env bash
# Fetch recent news headlines for a company (plain text list).
# Tries DuckDuckGo HTML first; if bot detection (captcha) is shown, falls back to Bing News RSS.
# Usage: scripts/fetch_news.sh "Company Name"
# Example: skills/company-report/scripts/fetch_news.sh "Workday"

set -e
QUERY="${1:-}"
if [ -z "$QUERY" ]; then
  echo "Usage: $0 \"Company Name\""
  exit 1
fi

# URL-encode the query (basic: space -> +)
ENCODED=$(echo "$QUERY" | sed 's/ /+/g')
UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

echo "News search: $QUERY"
echo "---"

# 1) Try DuckDuckGo HTML with browser-like headers (avoids some bot blocks)
DDG_URL="https://html.duckduckgo.com/html/?q=${ENCODED}+news"
HTML=$(curl -sL --max-time 15 \
  -A "$UA" \
  -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" \
  -H "Accept-Language: en-US,en;q=0.9" \
  -H "Referer: https://html.duckduckgo.com/" \
  "$DDG_URL" 2>/dev/null || true)

USE_BING=""
if [ -z "$HTML" ]; then
  USE_BING=1
elif echo "$HTML" | grep -q "anomaly-modal\|challenge-form\|Unfortunately, bots"; then
  # DuckDuckGo returned captcha/bot challenge
  USE_BING=1
fi

if [ "$USE_BING" != "1" ]; then
  # Parse DDG: result links (class result__url or similar; href with external URL)
  LINKS=$(echo "$HTML" | grep -oE 'href="https://[^"]+' | sed 's/href="//' | grep -v -E 'duckduckgo\.com|duck\.co|yastatic' | head -10)
  if [ -n "$LINKS" ]; then
    echo "$LINKS" | while read -r u; do echo "- $u"; done
    exit 0
  fi
  # No links found from DDG (e.g. structure changed)
  USE_BING=1
fi

# 2) Fallback: Bing News RSS (no captcha, returns title + link per item)
BING_URL="https://www.bing.com/news/search?q=${ENCODED}+news&format=rss"
RSS=$(curl -sL --max-time 15 -A "$UA" -H "Accept-Language: en-US,en;q=0.9" "$BING_URL" 2>/dev/null || true)

if [ -z "$RSS" ]; then
  echo "No news results (network error). Try: search '${QUERY} news' or visit finance.yahoo.com."
  exit 0
fi

# Parse RSS: <item><title>...</title><link>...</link> (Bing uses single-line items)
# Extract title and link from each <item>; handle titles with &amp; etc.
COUNT=0
while IFS= read -r line; do
  [ -z "$line" ] && continue
  title=$(echo "$line" | sed -n 's/.*<title>\([^<]*\)<\/title>.*/\1/p' | sed 's/&amp;/\&/g; s/&lt;/</g; s/&gt;/>/g; s/&quot;/"/g')
  link=$(echo "$line" | sed -n 's/.*<link>\([^<]*\)<\/link>.*/\1/p')
  if [ -n "$title" ] && [ -n "$link" ] && [ "$link" != "https://www.bing.com/news/search?q=${ENCODED}+news" ]; then
    # Decode XML entities for cleaner output
    link=$(echo "$link" | sed 's/&amp;/\&/g')
    echo "- $title"
    echo "  $link"
    COUNT=$((COUNT + 1))
    [ "$COUNT" -ge 10 ] && break
  fi
done < <(echo "$RSS" | sed 's/<\/item>/\n/g' | grep -oE '<item>.*' | head -15)

if [ "$COUNT" -eq 0 ]; then
  echo "No items from Bing RSS. Try: search '${QUERY} news' or finance.yahoo.com."
fi
exit 0
