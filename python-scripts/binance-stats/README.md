# binance-stats

Scripts to compute some **statistics** starting from **Binance transaction records** CSV files.

:warning: **Disclaimer**: I am not responsible for any wrong results or any possible damage caused by the use of these scripts.

> **Note**: this project contains **fake data** useful for testing (e.g. directories [`transactions`](transactions) and [`statements`](statements))

## Usage

Set up a **Python venv** (virtual environment) and install some packages inside it:

```bash
python3 -mvenv venv
venv/bin/python3 -mpip install -r requirements.txt
```

Then download the necessary **OHLCV data**:

```bash
mkdir ohlcv

mapfile -t coins < <(cat transactions/records-*.csv |
    venv/bin/python3 coins.py | tr -d '\r')
echo "${coins[@]@Q}"

mapfile -t years < <(find transactions -name 'records-*.csv' \
    -printf '%P\n' | tr -cd '0-9\n')
echo "${years[@]@Q}"

i=0; for year in "${years[@]}"; do for coin in "${coins[@]}"; do
    echo "$((++i)): fetching year $year coin $coin"
    bash fetch.sh ../ohlcv-fetchers/binance.py \
        "$coin/USDT" 1d "$year" > "ohlcv/$year-$coin-USDT-1d.csv"
    sleep 2 # Just to be on the safe side
done; done

for file in ohlcv/*.csv; do
    if [ ! -s "$file" ]; then
        echo "Removing empty CSV file: $file"
        rm "$file"
    fi
done
```

Finally, you can **compute the statistics**:

```bash
cat transactions/records-*.csv |
    venv/bin/python3 stats.py -d2021-01-01T00Z -D2021-12-31T23:59Z \
        --real-spot=statements/spot-2021.csv,Coin,Total \
        --real-earn=statements/earn-2021.csv,Token,Amount \
        --ohlcv-dir=ohlcv --fiat=EUR
```

## Unit tests

If you want to run the unit tests:

```bash
venv/bin/python3 -mpip install pytest
venv/bin/python3 -mpytest test
```
