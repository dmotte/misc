#!/usr/bin/env python3

import io

import pytest

from datetime import datetime as dt
from datetime import timezone as tz
from datetime import timedelta
from decimal import Decimal

from lib.ohlcv import Interval, OHLCV


def test_interval():
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


def test_ohlcv():
    with pytest.raises(ValueError):  # Invalid number type
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

    with pytest.raises(ValueError):  # Not enough candles
        OHLCV('BASE', 'QUOTE', [])

    with pytest.raises(ValueError):  # Not enough candles
        OHLCV('BASE', 'QUOTE', [
            {
                'datetime': dt(2020, 1, 1, 0, tzinfo=tz.utc),
                'open': 1.0, 'high': 2.0, 'low': 0.0, 'close': 1.5,
                'volume': 1.0,
            },
        ])

    with pytest.raises(ValueError):  # Interval mismatch
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

    csv01 = '''Timestamp,Open,High,Low,Close,Volume
        1577836800000,7195.24,7255.0,7175.15,7200.85,16792.388165
        1577923200000,7200.77,7212.5,6924.74,6965.71,31951.483932
        1578009600000,6965.49,7405.0,6871.04,7344.96,68428.500451
        1578096000000,7345.0,7404.0,7272.21,7354.11,29987.974977
        1578182400000,7354.19,7495.0,7318.0,7358.75,38331.085604
    '''.replace(' ', '')

    with pytest.raises(ValueError):  # Invalid number type
        OHLCV.load('BTC', 'USDT', io.StringIO(csv01), int)

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

    with pytest.raises(LookupError):  # No valid candle (too early)
        ohlcv04.val(dt.fromtimestamp(1000000000, tz=tz.utc))

    with pytest.raises(LookupError):  # No valid candle (too late)
        ohlcv04.val(dt.fromtimestamp(2000000000, tz=tz.utc))
