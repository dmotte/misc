#!/usr/bin/env python3

import csv
import json

from decimal import Decimal
from typing import TextIO


class Portfolio:
    '''
    Represents a portfolio of cryptocurrencies or other assets
    '''

    def __init__(self, balances: dict[str, float | Decimal] = {},
                 numtype: type[float | Decimal] = Decimal,
                 allow_negative: bool = False):
        if numtype not in (float, Decimal):
            raise ValueError(f'Invalid number type: {numtype}')
        self._numtype = numtype

        self.allow_negative = allow_negative

        balances = {coin: numtype(balance)
                    for coin, balance in balances.items()}
        self._balances = {coin: balance for coin, balance in balances.items()
                           if not self.is_zero(balance)}

    def is_zero(self, value: float | Decimal) -> bool:
        '''
        Returns True if value is equal to zero, False otherwise
        '''
        if self._numtype == Decimal:
            return value.is_zero()
        else:
            return value == 0

    @property
    def numtype(self) -> type[float | Decimal]:
        '''
        The type used for numbers
        '''
        return self._numtype

    def change(self, coin: str, amount: float | Decimal) -> 'Portfolio':
        '''
        Changes the balance of a specific coin in the portfolio by the
        specified amount
        '''
        amount = self._numtype(amount)

        if self.is_zero(amount):
            return self

        if coin in self._balances:
            balance = self._balances[coin] + amount
        else:
            balance = amount

        if balance < 0 and not self.allow_negative:
            raise ValueError(f'Coin {coin} would go negative ({balance}) ' +
                             f'after change by {amount}')

        if self.is_zero(balance):
            del self._balances[coin]
        else:
            self._balances[coin] = balance

        return self

    def get(self, coin: str) -> float | Decimal:
        '''
        Retrieves the balance of a specific coin in the portfolio
        '''
        return self._balances.get(coin, self._numtype(0))

    def copy(self) -> 'Portfolio':
        '''
        Returns a copy of the portfolio
        '''
        copy = Portfolio(numtype=self._numtype,
                         allow_negative=self.allow_negative)
        copy._balances = self._balances.copy()
        return copy

    def composition(self, reverse: bool = False) -> dict[str, float | Decimal]:
        '''
        Returns a dictionary representation of the portfolio, sorted by coin
        symbol
        '''
        return dict(
            sorted(
                self._balances.items(),
                key=lambda x: x[0],
                reverse=reverse))

    def diff(self, other: 'Portfolio') -> 'Portfolio':
        '''
        Compares the current portfolio with another one, and returns the
        differences in balances for each coin
        '''
        coins = sorted(set(self._balances.keys()) |
                       set(other._balances.keys()))

        portfolio = Portfolio(numtype=self._numtype, allow_negative=True)

        balances = {coin: self.get(coin) - other.get(coin) for coin in coins}

        for coin, balance in balances.items():
            portfolio.change(coin, balance)

        return portfolio

    def load(file: TextIO, kcoin: str, kamount: str, **kwargs) -> 'Portfolio':
        '''
        Loads a portfolio from a CSV file
        '''
        portfolio = Portfolio(**kwargs)

        for x in list(csv.DictReader(file)):
            portfolio.change(x[kcoin], x[kamount])

        return portfolio

    def save(self, file: TextIO, kcoin: str, kamount: str) -> 'Portfolio':
        '''
        Saves the portfolio into a CSV file
        '''
        print(f'{kcoin},{kamount}', file=file)

        for coin, amount in self.composition().items():
            print(f'{coin},{amount}', file=file)

        return self

    def __str__(self) -> str:
        return json.dumps(self.composition(), default=str)
