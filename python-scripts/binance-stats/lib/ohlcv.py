#!/usr/bin/env python3

import csv
import pathlib
import re

from collections import defaultdict
from datetime import datetime as dt
from datetime import timezone as tz
from datetime import timedelta
from decimal import Decimal
from enum import StrEnum
from typing import TextIO


def nest() -> defaultdict:
    return defaultdict(nest)


_STRING_TO_TIMEDELTA = {
    '1s': timedelta(seconds=1),

    '1m': timedelta(minutes=1),
    '3m': timedelta(minutes=3),
    '5m': timedelta(minutes=5),
    '15m': timedelta(minutes=15),
    '30m': timedelta(minutes=30),

    '1h': timedelta(hours=1),
    '2h': timedelta(hours=2),
    '4h': timedelta(hours=4),
    '6h': timedelta(hours=6),
    '8h': timedelta(hours=8),
    '12h': timedelta(hours=12),

    '1d': timedelta(days=1),
    '3d': timedelta(days=3),

    '1w': timedelta(weeks=1),
}

_TIMEDELTA_TO_STRING = {td: s for s, td in _STRING_TO_TIMEDELTA.items()}


class Interval(StrEnum):
    '''
    Represents an OHLCV candle's length of time.
    See https://developers.binance.com/docs/binance-spot-api-docs/rest-api#klinecandlestick-data
    '''
    SEC01 = '1s'

    MIN01 = '1m'
    MIN03 = '3m'
    MIN05 = '5m'
    MIN15 = '15m'
    MIN30 = '30m'

    H01 = '1h'
    H02 = '2h'
    H04 = '4h'
    H06 = '6h'
    H08 = '8h'
    H12 = '12h'

    DAY01 = '1d'
    DAY03 = '3d'

    WEEK01 = '1w'

    def from_timedelta(td: timedelta) -> 'Interval':
        s = _TIMEDELTA_TO_STRING.get(td)
        if s is None:
            raise ValueError(f'Invalid Interval: {td}')
        return Interval(s)

    def timedelta(self) -> timedelta:
        return _STRING_TO_TIMEDELTA[self]


class OHLCV:
    '''
    Represents a data structure for storing OHLCV (Open, High, Low, Close,
    Volume) candlestick data for a trading pair
    '''

    def __init__(self, base: str, quote: str, candles: list[dict]):
        if len(candles) < 2:
            raise ValueError('Not enough candles. Minimum required: 2')

        numtype = type(candles[0]['open'])
        if numtype not in (float, Decimal):
            raise ValueError(f'Invalid number type: {numtype}')
        self._numtype = numtype

        self._base = base
        self._quote = quote
        self._candles = candles

        td_interval = candles[1]['datetime'] - candles[0]['datetime']
        self._interval = Interval.from_timedelta(td_interval)

        self._start = candles[0]['datetime']
        self._end = candles[-1]['datetime'] + td_interval

        # Sanity checks

        prev_datetime = self._start - td_interval
        for candle in candles:
            candle_datetime = candle['datetime']
            td_found = candle_datetime - prev_datetime
            if td_found != td_interval:
                raise ValueError('Interval mismatch for candle at '
                                 f'{candle_datetime}. Expected {td_interval}, '
                                 f'but found {td_found}')
            prev_datetime = candle_datetime

    @property
    def numtype(self) -> type[float | Decimal]:
        '''
        The type used for numbers
        '''
        return self._numtype

    @property
    def base(self) -> str:
        '''
        Base currency of the pair
        '''
        return self._base

    @property
    def quote(self) -> str:
        '''
        Quote currency of the pair
        '''
        return self._quote

    @property
    def interval(self) -> Interval:
        '''
        Length of time of each candle
        '''
        return self._interval

    @property
    def start(self) -> dt:
        '''
        Start datetime of the OHLCV data, inclusive
        '''
        return self._start

    @property
    def end(self) -> dt:
        '''
        End datetime of the OHLCV data, exclusive
        '''
        return self._end

    def load(base: str, quote: str, file: TextIO,
             numtype: type[float | Decimal] = float) -> 'OHLCV':
        '''
        Loads OHLCV data from a CSV file
        '''
        if numtype not in (float, Decimal):
            raise ValueError(f'Invalid number type: {numtype}')

        candles = []

        for x in list(csv.DictReader(file)):
            candles.append({
                'datetime': dt.fromtimestamp(float(x['Timestamp']) / 1000,
                                             tz=tz.utc),
                'open': numtype(x['Open']),
                'high': numtype(x['High']),
                'low': numtype(x['Low']),
                'close': numtype(x['Close']),
                'volume': numtype(x['Volume']),
            })

        return OHLCV(base, quote, candles)

    def val(self, d: dt) -> float | Decimal:
        '''
        Estimates the value of the asset at a given datetime `d` using linear
        interpolation
        '''
        if d < self._candles[0]['datetime']:
            raise LookupError(f'No valid candle for datetime {d} '
                              '(it\'s too early)')

        for i, candle in enumerate(self._candles):
            if candle['datetime'] + self._interval.timedelta() > d:
                # Linear interpolation
                return candle['open'] + (candle['close'] - candle['open']) * \
                    self._numtype(
                        (d - candle['datetime']) / self._interval.timedelta())

        raise LookupError(f'No valid candle for datetime {d} (it\'s too late)')


class OHLCVDir:
    '''
    Represents a set of multiple OHLCV objects containing candlestick data for
    many different trading pairs
    '''

    def __init__(self, dir: str, year_first: int, year_last: int,
                 numtype: type[float | Decimal] = float):
        if numtype not in (float, Decimal):
            raise ValueError(f'Invalid number type: {numtype}')
        self._numtype = numtype

        self._dir = dir
        self._year_first = year_first
        self._year_last = year_last

        self._ohlcvs = nest()  # Levels: pair -> interval -> year

        for file in pathlib.Path(dir).glob('*.csv'):
            match = re.search(
                r'^([0-9]+)-([0-9A-Z]+)-([0-9A-Z]+)-([0-9A-Za-z]+)\.csv$',
                file.name)

            year = int(match.group(1))
            base = match.group(2)
            quote = match.group(3)
            interval = Interval(match.group(4))

            if year < year_first or year > year_last:
                continue

            if file.stat().st_size == 0:
                continue

            with open(file, 'r') as f:
                ohlcv: OHLCV = OHLCV.load(base, quote, f, numtype)

            if ohlcv.interval != interval:
                raise ValueError('Interval mismatch between OHLCV file name '
                                 f'({interval}) and content ({ohlcv.interval})')

            if ohlcv.start.year != year:
                raise ValueError('Year mismatch between OHLCV file name '
                                 f'({year}) and content ({ohlcv.start.year})')

            self._ohlcvs[f'{base}/{quote}'][interval][year] = ohlcv

    @property
    def numtype(self) -> type[float | Decimal]:
        '''
        The type used for numbers
        '''
        return self._numtype

    @property
    def dir(self) -> str:
        '''
        Directory from which the OHLCV data was loaded
        '''
        return self._dir

    @property
    def year_first(self) -> int:
        '''
        First year, inclusive
        '''
        return self._year_first

    @property
    def year_last(self) -> int:
        '''
        Last year, inclusive
        '''
        return self._year_last

    def val(self, base: str, quote: str, d: dt) -> float | Decimal:
        '''
        Estimates the value of an asset at a given datetime `d` using the best
        OHLCV object available in the set
        '''
        if base == quote:
            return self._numtype(1)

        pair_branch: defaultdict = self._ohlcvs[f'{base}/{quote}']
        ohlcv: OHLCV = pair_branch[min(pair_branch.keys())][d.year]
        return ohlcv.val(d)
