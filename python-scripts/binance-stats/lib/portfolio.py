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
        self.__numtype = numtype

        self.allow_negative = allow_negative

        balances = {coin: numtype(balance)
                    for coin, balance in balances.items()}
        self.__balances = {coin: balance for coin, balance in balances.items()
                           if not self.is_zero(balance)}

    def is_zero(self, value: float | Decimal) -> bool:
        '''
        Returns True if value is equal to zero, False otherwise
        '''
        if self.__numtype == Decimal:
            return value.is_zero()
        else:
            return value == 0

    @property
    def numtype(self) -> type[float | Decimal]:
        '''
        The type used for numbers
        '''
        return self.__numtype

    def change(self, coin: str, amount: float | Decimal) -> 'Portfolio':
        '''
        Changes the balance of a specific coin in the portfolio by the
        specified amount
        '''
        amount = self.__numtype(amount)

        if self.is_zero(amount):
            return self

        if coin in self.__balances:
            balance = self.__balances[coin] + amount
        else:
            balance = amount

        if balance < 0 and not self.allow_negative:
            raise ValueError(f'Coin {coin} would go negative ({balance}) ' +
                             f'after change by {amount}')

        if self.is_zero(balance):
            del self.__balances[coin]
        else:
            self.__balances[coin] = balance

        return self

    def get(self, coin: str) -> float | Decimal:
        '''
        Retrieves the balance of a specific coin in the portfolio
        '''
        return self.__balances.get(coin, self.__numtype(0))

    def copy(self) -> 'Portfolio':
        '''
        Returns a copy of the portfolio
        '''
        copy = Portfolio(numtype=self.__numtype,
                         allow_negative=self.allow_negative)
        copy.__balances = self.__balances.copy()
        return copy

    def composition(self, reverse: bool = False) -> dict[str, float | Decimal]:
        '''
        Returns a dictionary representation of the portfolio, sorted by coin
        symbol
        '''
        return dict(
            sorted(
                self.__balances.items(),
                key=lambda x: x[0],
                reverse=reverse))

    def diff(self, other: 'Portfolio') -> 'Portfolio':
        '''
        Compares the current portfolio with another one, and returns the
        differences in balances for each coin
        '''
        coins = sorted(set(self.__balances.keys()) |
                       set(other.__balances.keys()))

        portfolio = Portfolio(numtype=self.__numtype, allow_negative=True)

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
