#!/usr/bin/env bash
# Fetch news for a ticker from Yahoo Finance (search API returns JSON with news array).
# Usage: scripts/fetch_yahoo_news.sh SYMBOL
# Example: skills/company-report/scripts/fetch_yahoo_news.sh WDAY

set -e
SYMBOL="${1:-}"
if [ -z "$SYMBOL" ]; then
  echo "Usage: $0 SYMBOL"
  exit 1
fi

URL="https://query2.finance.yahoo.com/v1/finance/search?q=${SYMBOL}&quotesCount=1&newsCount=10"
JSON=$(curl -sL --max-time 15 -A "Mozilla/5.0 (compatible; CompanyReport/1.0)" "$URL" 2>/dev/null || true)

if [ -z "$JSON" ]; then
  echo "News for $SYMBOL: (fetch failed)"
  exit 0
fi

echo "News for $SYMBOL (Yahoo Finance)"
echo "---"
# Titles and links alternate in JSON; extract in order and pair
titles=()
links=()
while IFS= read -r line; do
  if [[ "$line" == '"title":'* ]]; then
    titles+=("$(echo "$line" | sed 's/"title":"//;s/"$//')")
  elif [[ "$line" == '"link":'* ]]; then
    links+=("$(echo "$line" | sed 's/"link":"//;s/"$//')")
  fi
done < <(echo "$JSON" | grep -oE '"title":"[^"]+"|"link":"https://[^"]+"')

for i in "${!titles[@]}"; do
  echo "- ${titles[$i]}"
  echo "  ${links[$i]:-(no link)}"
done
exit 0
