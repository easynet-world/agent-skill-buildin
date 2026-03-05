#!/usr/bin/env bash
# Fetch Yahoo Finance stock data via chart API (quoteSummary requires crumb). Output: plain text summary.
# Usage: scripts/fetch_yahoo.sh SYMBOL
# Example: skills/company-report/scripts/fetch_yahoo.sh WDAY

set -e
SYMBOL="${1:-}"
if [ -z "$SYMBOL" ]; then
  echo "Usage: $0 SYMBOL"
  exit 1
fi

# Chart API works without crumb; returns meta with price, volume, day range
URL="https://query1.finance.yahoo.com/v8/finance/chart/${SYMBOL}?interval=1d&range=1d"
JSON=$(curl -sL --max-time 15 -A "Mozilla/5.0 (compatible; CompanyReport/1.0)" "$URL" 2>/dev/null || true)

if [ -z "$JSON" ] || echo "$JSON" | grep -q '"result":null'; then
  echo "Error: Could not fetch data for $SYMBOL"
  exit 2
fi

# Extract from chart result meta (grep/sed, no jq)
longName=$(echo "$JSON" | grep -o '"longName":"[^"]*"' | head -1 | sed 's/"longName":"//;s/"//')
shortName=$(echo "$JSON" | grep -o '"shortName":"[^"]*"' | head -1 | sed 's/"shortName":"//;s/"//')
regularMarketPrice=$(echo "$JSON" | grep -o '"regularMarketPrice":[0-9.]*' | head -1 | sed 's/"regularMarketPrice"://')
regularMarketDayLow=$(echo "$JSON" | grep -o '"regularMarketDayLow":[0-9.]*' | head -1 | sed 's/"regularMarketDayLow"://')
regularMarketDayHigh=$(echo "$JSON" | grep -o '"regularMarketDayHigh":[0-9.]*' | head -1 | sed 's/"regularMarketDayHigh"://')
regularMarketVolume=$(echo "$JSON" | grep -o '"regularMarketVolume":[0-9]*' | head -1 | sed 's/"regularMarketVolume"://')
chartPreviousClose=$(echo "$JSON" | grep -o '"chartPreviousClose":[0-9.]*' | head -1 | sed 's/"chartPreviousClose"://')
fiftyTwoWeekHigh=$(echo "$JSON" | grep -o '"fiftyTwoWeekHigh":[0-9.]*' | head -1 | sed 's/"fiftyTwoWeekHigh"://')
fiftyTwoWeekLow=$(echo "$JSON" | grep -o '"fiftyTwoWeekLow":[0-9.]*' | head -1 | sed 's/"fiftyTwoWeekLow"://')

# Compute change % if we have price and previous close
changePct="N/A"
if [ -n "$regularMarketPrice" ] && [ -n "$chartPreviousClose" ]; then
  changePct=$(echo "scale=2; ($regularMarketPrice - $chartPreviousClose) / $chartPreviousClose * 100" | bc 2>/dev/null || echo "N/A")
fi

echo "Symbol: $SYMBOL"
echo "Name: ${longName:-${shortName:-$SYMBOL}}"
echo "Price: ${regularMarketPrice:-N/A}"
echo "Previous Close: ${chartPreviousClose:-N/A}"
echo "Change: ${changePct}%"
echo "Day Range: ${regularMarketDayLow:-N/A} - ${regularMarketDayHigh:-N/A}"
echo "52-Week Range: ${fiftyTwoWeekLow:-N/A} - ${fiftyTwoWeekHigh:-N/A}"
echo "Volume: ${regularMarketVolume:-N/A}"
echo "Source: Yahoo Finance (chart API)"
exit 0
