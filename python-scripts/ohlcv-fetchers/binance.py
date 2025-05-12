#!/usr/bin/env python3

import argparse
import sys

from datetime import timedelta
from datetime import datetime as dt
from datetime import timezone as tz
from dateutil import parser as dup

import ccxt


def main(argv=None):
    if argv is None:
        argv = sys.argv

    parser = argparse.ArgumentParser(
        description='Binance OHLCV data downloader')

    parser.add_argument('symbol', metavar='SYMBOL', type=str,
                        help='Ticker symbol (example: BTC/USDT)')

    parser.add_argument('-i', '--interval', type=str, default='5m',
                        help='Length of time each candle represents '
                        '(default: %(default)s)')

    parser.add_argument('-d', '--dt-start', type=lambda x: dup.parse(x),
                        default=dt.now(tz.utc) - timedelta(hours=1),
                        help='Start date and time (default: 1 hour ago)')
    parser.add_argument('-D', '--dt-end', type=lambda x: dup.parse(x),
                        default=dt.now(tz.utc),
                        help='End date and time (default: now)')

    parser.add_argument('-f', '--format', type=str, default='',
                        help='If specified, formats the float values (such as '
                        'the asset prices) with this format string '
                        '(e.g. "{:.6f}")')

    args = parser.parse_args(argv[1:])

    args.dt_start = args.dt_start.astimezone(tz.utc)
    args.dt_end = args.dt_end.astimezone(tz.utc)

    ############################################################################

    print(f'Fetching {args.symbol} with CCXT', file=sys.stderr)

    exchange = ccxt.binance()

    # Equivalent of
    # https://api.binance.com/api/v3/klines?symbol=...&interval=...&startTime=...&endTime=...
    # See
    # https://developers.binance.com/docs/binance-spot-api-docs/rest-api#klinecandlestick-data
    data = exchange.fetch_ohlcv(
        args.symbol,
        args.interval,
        int(args.dt_start.timestamp() * 1000),
        params={
            'until': int(args.dt_end.timestamp() * 1000),
            'paginate': True,
        }
    )

    if args.format != '':
        for candle in data:
            for i, v in enumerate(candle):
                if isinstance(v, float):
                    candle[i] = args.format.format(v)

    print('Timestamp,Open,High,Low,Close,Volume')
    for candle in data:
        print(','.join(str(x) for x in candle))

    return 0


if __name__ == '__main__':
    sys.exit(main())
