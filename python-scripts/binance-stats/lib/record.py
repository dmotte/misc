#!/usr/bin/env python3

import csv

from datetime import datetime as dt
from datetime import timezone as tz
from decimal import Decimal
from typing import TextIO


def load_records(file: TextIO) -> list[dict]:
    '''
    Loads Binance transaction records from a CSV file or a concatenation of
    multiple CSV files
    '''
    records_raw = list(csv.DictReader(file))
    records = []

    userid = records_raw[0]['User_ID']
    prev_datetime = dt(1970, 1, 1, tzinfo=tz.utc)

    for x in records_raw:
        # If all the values are equal to the keys, then this is just a header
        # line (probably resulting from the concatenation of multiple CSV files)
        # and it should be skipped
        if all(k == v for k, v in x.items()):
            continue

        if x['Account'] != 'Spot':
            raise ValueError('Invalid Account: ' + x['Account'])

        if x['User_ID'] != userid:
            raise ValueError('Invalid User_ID: ' + x['User_ID'])

        y = {}

        y['datetime'] = dt.strptime(x['UTC_Time'], '%Y-%m-%d %H:%M:%S') \
            .replace(tzinfo=tz.utc)

        if y['datetime'] < prev_datetime:
            raise ValueError('Datetime ' + str(y['datetime']) +
                             ' is less than the previous one ' +
                             str(prev_datetime))
        prev_datetime = y['datetime']

        y['operation'] = x['Operation']
        y['coin'] = x['Coin']
        y['change'] = Decimal(x['Change'])
        y['remark'] = x['Remark']

        records.append(y)

    return records


def records_before(records: list[dict], dt_end: dt):
    '''
    Returns only the records before a specific datetime.
    Warning: it assumes that the records are already sorted in ascending order!
    '''
    for x in records:
        if x['datetime'] >= dt_end:
            break
        yield x
