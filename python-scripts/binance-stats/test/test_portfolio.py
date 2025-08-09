#!/usr/bin/env python3

import io
import textwrap

import pytest

from decimal import Decimal

from lib.portfolio import Portfolio


def test_portfolio() -> None:
    with pytest.raises(ValueError) as exc_info:
        Portfolio(numtype=int)
    assert exc_info.value.args == ('Invalid number type: <class \'int\'>',)

    p = Portfolio({'AAA': 5, 'BBB': 7})

    assert p.numtype == Decimal
    assert not p.allow_negative

    assert isinstance(p.get('AAA'), Decimal)

    assert p.is_zero(Decimal(0))
    assert not p.is_zero(Decimal(3))

    assert p.is_zero(p.get('XXX'))
    assert not p.is_zero(p.get('AAA'))


def test_portfolio_negative() -> None:
    p = Portfolio({'AAA': 5, 'BBB': 7}, allow_negative=True)

    assert p.numtype == Decimal
    assert p.allow_negative

    p.change('AAA', -6)
    assert p.get('AAA') == Decimal(-1)


def test_portfolio_float() -> None:
    p = Portfolio({'AAA': 5, 'BBB': 7}, numtype=float)

    assert p.numtype == float
    assert not p.allow_negative

    assert isinstance(p.get('AAA'), float)

    assert p.is_zero(0)
    assert not p.is_zero(3)

    with pytest.raises(ValueError) as exc_info:
        p.change('AAA', -6)
    assert exc_info.value.args == (
        'Coin AAA would go negative (-1.0) after change by -6.0',)
    assert p.get('AAA') == 5

    pcopy = p.copy()

    assert pcopy.numtype == float
    assert not pcopy.allow_negative

    p.change('CCC', 3)
    p.change('CCC', -2)
    p.change('CCC', -1)

    p.change('DDD', 0)

    assert str(p) == '{"AAA": 5.0, "BBB": 7.0}'
    assert str(p) == str(pcopy)

    assert str(p.composition()) == "{'AAA': 5.0, 'BBB': 7.0}"
    assert str(p.composition(reverse=True)) == "{'BBB': 7.0, 'AAA': 5.0}"

    assert str(p.copy().change('CCC', 2).diff(p)) == '{"CCC": 2.0}'
    assert str(p.copy().change('AAA', -1).diff(p)) == '{"AAA": -1.0}'


def test_portfolio_load() -> None:
    csv01 = textwrap.dedent('''\
        Coin,Amount
        AAA,123
        BBB,456
    ''')

    p = Portfolio.load(io.StringIO(csv01), 'Coin', 'Amount', numtype=float)

    assert str(p) == '{"AAA": 123.0, "BBB": 456.0}'
