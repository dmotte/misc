#!/bin/bash

set -e

# Usage example:
#   ./fetch.sh ../ohlcv-fetchers/binance.py BTC/USDT 1d 2020

fetcher=${1:?} symbol=${2:?} interval=${3:?} year=${4:?}

nextyear=$((year + 1))

if [[ "$(uname)" = MINGW* ]]
    then py=$(dirname "$fetcher")/venv/Scripts/python
    else py=$(dirname "$fetcher")/venv/bin/python3
fi

# We separately invoke the fetcher script in advance, to avoid masking its
# return value
data=$("$py" "$fetcher" \
    "$symbol" -i"$interval" -d"$year-01-01T00Z" -D"$nextyear-01-01T00Z")
data=$(echo "$data" | tr -d '\r' | head -n-1)

# Make sure there are at least 2 candles (headers line + 2 candle lines)
[ "$(echo "$data" | wc -l)" -ge 3 ] || { echo 'Not enough data' >&2; exit 1; }

echo "$data"
