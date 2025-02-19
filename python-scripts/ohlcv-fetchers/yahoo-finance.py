#!/usr/bin/env python3

import argparse
import sys

from datetime import timedelta
from datetime import datetime as dt
from dateutil import parser as dup

import yfinance as yf
import pandas as pd


def is_aware(d: dt):
    '''
    Returns true if the datetime object `d` is timezone-aware, false otherwise.
    See https://docs.python.org/3/library/datetime.html#determining-if-an-object-is-aware-or-naive
    '''
    return d.tzinfo is not None and d.tzinfo.utcoffset(d) is not None


def main(argv=None):
    if argv is None:
        argv = sys.argv

    parser = argparse.ArgumentParser(
        description='Yahoo Finance OHLCV data downloader')

    parser.add_argument('symbol', metavar='SYMBOL', type=str,
                        help='Ticker symbol (example: ^GSPC)')

    parser.add_argument('-i', '--interval', type=str, default='1d',
                        help='Length of time each candle represents '
                        '(default: 1d)')

    parser.add_argument('-d', '--dt-start', type=lambda x: dup.parse(x),
                        default=dt.now().astimezone() - timedelta(days=30),
                        help='Start date and time (default: 30 days ago)')
    parser.add_argument('-D', '--dt-end', type=lambda x: dup.parse(x),
                        default=dt.now().astimezone(),
                        help='End date and time (default: now)')

    parser.add_argument('-f', '--format', type=str, default='',
                        help='If specified, formats the float values (such as '
                        'the asset prices) with this format string '
                        '(e.g. "{:.6f}")')

    args = parser.parse_args(argv[1:])

    if not is_aware(args.dt_start):
        args.dt_start = args.dt_start.astimezone()
    if not is_aware(args.dt_end):
        args.dt_end = args.dt_end.astimezone()

    ############################################################################

    print(f'Fetching {args.symbol} with yfinance', file=sys.stderr)

    # Equivalent of
    # https://query1.finance.yahoo.com/v8/finance/chart/...?interval=...&period1=...&period2=...
    # See https://finance.yahoo.com/quote/.../history
    data: pd.DataFrame = yf.download(
        args.symbol, args.dt_start, args.dt_end, interval=args.interval,
        auto_adjust=False)

    assert data.index.name == 'Date'

    assert data.columns.equals(pd.MultiIndex.from_tuples(
        [('Adj Close', args.symbol),
         ('Close', args.symbol),
         ('High', args.symbol),
         ('Low', args.symbol),
         ('Open', args.symbol),
         ('Volume', args.symbol)],
        names=['Price', 'Ticker']))
    data.columns = ['Adj Close', 'Close', 'High', 'Low', 'Open', 'Volume']
    data = data[['Open', 'High', 'Low', 'Close', 'Adj Close', 'Volume']]

    if args.format != '':
        data = data.apply(lambda col: col.map(
            lambda x: args.format.format(x) if isinstance(x, float) else x))

    data.to_csv(sys.stdout, lineterminator='\n')

    return 0


if __name__ == '__main__':
    sys.exit(main())
