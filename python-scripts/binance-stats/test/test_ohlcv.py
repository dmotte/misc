#!/usr/bin/env python3

import textwrap
import io

import pytest

from datetime import datetime as dt
from datetime import timezone as tz
from datetime import timedelta
from decimal import Decimal

from lib.ohlcv import Interval, OHLCV


def test_interval() -> None:
    cases = [
        (Interval.SEC01, '1s', timedelta(seconds=1)),
        (Interval.MIN01, '1m', timedelta(minutes=1)),
        (Interval.MIN03, '3m', timedelta(minutes=3)),
        (Interval.MIN05, '5m', timedelta(minutes=5)),
        (Interval.MIN15, '15m', timedelta(minutes=15)),
        (Interval.MIN30, '30m', timedelta(minutes=30)),
        (Interval.H01, '1h', timedelta(hours=1)),
        (Interval.H02, '2h', timedelta(hours=2)),
        (Interval.H04, '4h', timedelta(hours=4)),
        (Interval.H06, '6h', timedelta(hours=6)),
        (Interval.H08, '8h', timedelta(hours=8)),
        (Interval.H12, '12h', timedelta(hours=12)),
        (Interval.DAY01, '1d', timedelta(days=1)),
        (Interval.DAY03, '3d', timedelta(days=3)),
        (Interval.WEEK01, '1w', timedelta(weeks=1)),
    ]

    for interval, s, td in cases:
        assert interval == Interval(s)
        assert interval == Interval.from_timedelta(td)
        assert td == interval.timedelta()


def test_ohlcv() -> None:
    with pytest.raises(ValueError) as exc_info:
        OHLCV('BASE', 'QUOTE', [
            {
                'datetime': dt(2020, 1, 1, 0, tzinfo=tz.utc),
                'open': 1, 'high': 2, 'low': 0, 'close': 1,
                'volume': 1,
            },
            {
                'datetime': dt(2020, 1, 1, 1, tzinfo=tz.utc),
                'open': 1, 'high': 2, 'low': 0, 'close': 1,
                'volume': 1,
            },
        ])
    assert exc_info.value.args == ('Invalid number type: <class \'int\'>',)

    with pytest.raises(ValueError) as exc_info:
        OHLCV('BASE', 'QUOTE', [])
    assert exc_info.value.args == ('Not enough candles. Minimum required: 2',)

    with pytest.raises(ValueError) as exc_info:
        OHLCV('BASE', 'QUOTE', [
            {
                'datetime': dt(2020, 1, 1, 0, tzinfo=tz.utc),
                'open': 1.0, 'high': 2.0, 'low': 0.0, 'close': 1.5,
                'volume': 1.0,
            },
        ])
    assert exc_info.value.args == ('Not enough candles. Minimum required: 2',)

    with pytest.raises(ValueError) as exc_info:
        OHLCV('BASE', 'QUOTE', [
            {
                'datetime': dt(2020, 1, 1, 0, tzinfo=tz.utc),
                'open': 1.0, 'high': 2.0, 'low': 0.0, 'close': 1.5,
                'volume': 1.0,
            },
            {
                'datetime': dt(2020, 1, 1, 1, tzinfo=tz.utc),
                'open': 1.5, 'high': 2.0, 'low': 0.0, 'close': 1.0,
                'volume': 1.0,
            },
            {
                'datetime': dt(2020, 1, 1, 3, tzinfo=tz.utc),
                'open': 1.0, 'high': 2.0, 'low': 0.0, 'close': 1.5,
                'volume': 1.0,
            },
        ])
    assert exc_info.value.args == (
        'Interval mismatch for candle at 2020-01-01 03:00:00+00:00. '
        'Expected 1:00:00, but found 2:00:00',)

    ohlcv01 = OHLCV('BASE', 'QUOTE', [
        {
            'datetime': dt(2020, 1, 1, 0, tzinfo=tz.utc),
            'open': 1.0, 'high': 2.0, 'low': 0.0, 'close': 1.5,
            'volume': 1.0,
        },
        {
            'datetime': dt(2020, 1, 1, 1, tzinfo=tz.utc),
            'open': 1.5, 'high': 2.0, 'low': 0.0, 'close': 1.0,
            'volume': 1.0,
        },
    ])

    assert ohlcv01.numtype == float
    assert ohlcv01.base == 'BASE'
    assert ohlcv01.quote == 'QUOTE'
    assert ohlcv01.interval == Interval.H01
    assert ohlcv01.start == dt(2020, 1, 1, 0, tzinfo=tz.utc)
    assert ohlcv01.end == dt(2020, 1, 1, 2, tzinfo=tz.utc)

    ohlcv02 = OHLCV('BASE', 'QUOTE', [
        {
            'datetime': dt(2020, 1, 1, 0, tzinfo=tz.utc),
            'open': Decimal(1), 'high': Decimal(2),
            'low': Decimal(0), 'close': Decimal(1.5),
            'volume': 1.0,
        },
        {
            'datetime': dt(2020, 1, 1, 1, tzinfo=tz.utc),
            'open': Decimal(1.5), 'high': Decimal(2),
            'low': Decimal(0), 'close': Decimal(1),
            'volume': 1.0,
        },
    ])

    assert ohlcv02.numtype == Decimal

    assert ohlcv02.val(dt(2020, 1, 1, 0, 30, tzinfo=tz.utc)) == Decimal(1.25)

    csv01 = textwrap.dedent('''\
        Timestamp,Open,High,Low,Close,Volume
        1577836800000,7195.24,7255.0,7175.15,7200.85,16792.388165
        1577923200000,7200.77,7212.5,6924.74,6965.71,31951.483932
        1578009600000,6965.49,7405.0,6871.04,7344.96,68428.500451
        1578096000000,7345.0,7404.0,7272.21,7354.11,29987.974977
        1578182400000,7354.19,7495.0,7318.0,7358.75,38331.085604
    ''')

    with pytest.raises(ValueError) as exc_info:
        OHLCV.load('BTC', 'USDT', io.StringIO(csv01), int)
    assert exc_info.value.args == ('Invalid number type: <class \'int\'>',)

    ohlcv03: OHLCV = OHLCV.load('BTC', 'USDT', io.StringIO(csv01), Decimal)
    assert ohlcv03.numtype == Decimal

    ohlcv04: OHLCV = OHLCV.load('BTC', 'USDT', io.StringIO(csv01))

    assert ohlcv04.numtype == float
    assert ohlcv04.base == 'BTC'
    assert ohlcv04.quote == 'USDT'
    assert ohlcv04.interval == Interval.DAY01
    assert ohlcv04.start == dt.fromtimestamp(1577836800, tz=tz.utc)
    assert ohlcv04.end == dt.fromtimestamp(1578182400, tz=tz.utc) + \
        ohlcv04.interval.timedelta()

    ts1 = 1577923200
    ts2 = 1578009600

    # Start of a candle
    d = dt.fromtimestamp(ts1, tz=tz.utc)
    assert ohlcv04.val(d) == 7200.77
    # A third of a candle
    d = dt.fromtimestamp(ts1 + (ts2 - ts1) / 3, tz=tz.utc)
    assert round(ohlcv04.val(d), 2) == 7122.42
    # Central point of a candle
    d = dt.fromtimestamp((ts1 + ts2) / 2, tz=tz.utc)
    assert ohlcv04.val(d) == 7083.24

    # Central point of the last candle
    d = ohlcv04.end - ohlcv04.interval.timedelta() / 2
    assert ohlcv04.val(d) == (7354.19 + 7358.75) / 2

    with pytest.raises(LookupError) as exc_info:
        ohlcv04.val(dt.fromtimestamp(1000000000, tz=tz.utc))
    assert exc_info.value.args == (
        'No valid candle for datetime 2001-09-09 01:46:40+00:00 '
        '(it\'s too early)',)

    with pytest.raises(LookupError) as exc_info:
        ohlcv04.val(dt.fromtimestamp(2000000000, tz=tz.utc))
    assert exc_info.value.args == (
        'No valid candle for datetime 2033-05-18 03:33:20+00:00 '
        '(it\'s too late)',)
