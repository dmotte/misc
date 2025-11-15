# ohlcv-fetchers

Set of scripts that can be used to **download [OHLCV data](https://en.wikipedia.org/wiki/Open-high-low-close_chart)** from various sources (e.g. [_Binance_](https://binance.com/), [_Yahoo Finance_](https://finance.yahoo.com/)).

## Usage

> **Important**: this has been tested with **Python 3.12.4** on **Windows 10**.

Set up a **Python venv** (virtual environment) and install some packages inside it:

```bash
python3 -mvenv venv
venv/bin/python3 -mpip install -r requirements.txt
```

Then you can use the scripts:

```bash
venv/bin/python3 yahoo-finance.py --help
```

You can also invoke them from any other directory on your system using the `invoke.sh` script:

```bash
bash invoke.sh yahoo-finance --help
```
