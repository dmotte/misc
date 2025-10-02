#!/usr/bin/env python3

import argparse
import json
import sys

from datetime import datetime as dt
from datetime import timezone as tz
from dateutil import parser as dup
from decimal import Decimal

from lib.ohlcv import OHLCVDir
from lib.portfolio import Portfolio
from lib.record import load_records, records_before


def compute_portfolios(records: list[dict]) -> dict[str, Portfolio]:
    '''
    Computes the composition of the Spot and Earn portfolios starting from the
    transaction records
    '''
    spot, earn = Portfolio(), Portfolio()

    for x in records:
        spot.change(x['coin'], x['change'])

        if x['operation'] in (
            'Simple Earn Flexible Redemption',
            'Simple Earn Flexible Subscription',
            'Simple Earn Locked Redemption',
            'Simple Earn Locked Subscription',
            'Staking Purchase',
            'Staking Redemption',
        ):
            earn.change(x['coin'], -x['change'])

    return {'spot': spot, 'earn': earn}


def compute_fiats(pin: Portfolio, d: dt, fiat: str,
                  ohlcvdir: OHLCVDir, quote: str) -> Portfolio:
    '''
    Computes the equivalent values in fiat currency of all the coins in the
    porfolio
    '''
    pout = Portfolio()

    for coin, balance in pin.composition().items():
        rate_coin = ohlcvdir.val(coin, quote, d)
        rate_fiat = ohlcvdir.val(fiat, quote, d)
        pout.change(coin, balance * rate_coin / rate_fiat)

    return pout


def main(argv: list[str] | None = None) -> int:
    if argv is None:
        argv = sys.argv

    DEFAULT_KCOIN = 'Coin'
    DEFAULT_KAMOUNT = 'Amount'

    parser = argparse.ArgumentParser(description='Binance Stats')

    parser.add_argument('-d', '--dt-start', type=lambda x: dup.parse(x),
                        default=dt(1970, 1, 1, tzinfo=tz.utc),
                        help='Start date and time, inclusive '
                        '(default: 1970-01-01T00Z)')
    parser.add_argument('-D', '--dt-end', type=lambda x: dup.parse(x),
                        default=dt.now(tz.utc),
                        help='End date and time, exclusive '
                        '(default: now)')

    parser.add_argument('-s', '--real-spot', type=str, default='',
                        help='If specified, checks the computed Spot '
                        'composition at --dt-end against the data loaded from '
                        'this CSV file. You can provide just a file name, or '
                        'a comma-separated tuple consisting of file name, '
                        'column name for the coin symbol (default: "' +
                        DEFAULT_KCOIN + '"), and column name for the amount '
                        '(default: "' + DEFAULT_KAMOUNT + '"). Example: '
                        '"myspot.csv,Coin,Total"')
    parser.add_argument('-e', '--real-earn', type=str, default='',
                        help='Like --real-spot, but for Earn')

    parser.add_argument('-o', '--ohlcv-dir', type=str, default='ohlcv',
                        help='Directory containing OHLCV data that can be '
                        'used by the script')
    parser.add_argument('-r', '--ref-quote', type=str, default='USDT',
                        help='Reference quote currency')
    parser.add_argument('-f', '--fiat', type=str, default='USDT',
                        help='Fiat currency')

    args = parser.parse_args(argv[1:])

    args.dt_start = args.dt_start.astimezone(tz.utc)
    args.dt_end = args.dt_end.astimezone(tz.utc)

    ############################################################################

    records = load_records(sys.stdin)
    records_before_start = records_before(records, args.dt_start)
    records_before_end = records_before(records, args.dt_end)

    ohlcvdir = OHLCVDir(args.ohlcv_dir, args.dt_start.year, args.dt_end.year,
                        Decimal)

    result = {}

    ############################################################################

    portfolios_start = compute_portfolios(records_before_start)
    comp_spot_start = portfolios_start['spot']
    comp_earn_start = portfolios_start['earn']
    result['comp_spot_start'] = comp_spot_start.composition()
    result['comp_earn_start'] = comp_earn_start.composition()

    portfolios_end = compute_portfolios(records_before_end)
    comp_spot_end = portfolios_end['spot']
    comp_earn_end = portfolios_end['earn']
    result['comp_spot_end'] = comp_spot_end.composition()
    result['comp_earn_end'] = comp_earn_end.composition()

    ############################################################################

    comp_spot_start_fiat = compute_fiats(comp_spot_start, args.dt_start,
                                         args.fiat, ohlcvdir, args.ref_quote)
    comp_earn_start_fiat = compute_fiats(comp_earn_start, args.dt_start,
                                         args.fiat, ohlcvdir, args.ref_quote)
    result['comp_spot_start_fiat'] = comp_spot_start_fiat.composition()
    result['comp_earn_start_fiat'] = comp_earn_start_fiat.composition()

    comp_spot_end_fiat = compute_fiats(comp_spot_end, args.dt_end,
                                       args.fiat, ohlcvdir, args.ref_quote)
    comp_earn_end_fiat = compute_fiats(comp_earn_end, args.dt_end,
                                       args.fiat, ohlcvdir, args.ref_quote)
    result['comp_spot_end_fiat'] = comp_spot_end_fiat.composition()
    result['comp_earn_end_fiat'] = comp_earn_end_fiat.composition()

    ############################################################################

    if args.real_spot != '':
        pieces = args.real_spot.split(',')

        filename = pieces[0]
        kcoin = pieces[1] if len(pieces) > 1 else DEFAULT_KCOIN
        kamount = pieces[2] if len(pieces) > 2 else DEFAULT_KAMOUNT

        with open(filename, 'r') as f:
            real_spot = Portfolio.load(f, kcoin, kamount)
        result['real_spot'] = real_spot.composition()

        diff_spot = comp_spot_end.diff(real_spot)
        result['diff_spot'] = diff_spot.composition()

    if args.real_earn != '':
        pieces = args.real_earn.split(',')

        filename = pieces[0]
        kcoin = pieces[1] if len(pieces) > 1 else DEFAULT_KCOIN
        kamount = pieces[2] if len(pieces) > 2 else DEFAULT_KAMOUNT

        with open(filename, 'r') as f:
            real_earn = Portfolio.load(f, kcoin, kamount)
        result['real_earn'] = real_earn.composition()

        diff_earn = comp_earn_end.diff(real_earn)
        result['diff_earn'] = diff_earn.composition()

    ############################################################################

    json.dump(result, sys.stdout, indent=2, default=str)
    print()

    return 0


if __name__ == '__main__':
    sys.exit(main())
