#!/usr/bin/env python3

import argparse
import operator
import sys
import time

import psutil


def eval_alert(name: str, value, op: str, threshold):
    '''
    Returns a message (string) if the condition is satisfied and the alert
    should be triggered, None otherwise
    '''
    opfunc = {'<': operator.lt, '<=': operator.le,
              '==': operator.eq, '!=': operator.ne,
              '>=': operator.ge, '>': operator.gt}[op]

    if opfunc(value, threshold):
        return f'{name} is {value} ({op} {threshold})'

    return None


def main(argv=None):
    if argv is None:
        argv = sys.argv

    parser = argparse.ArgumentParser(description='Performance monitor')

    parser.add_argument('-i', '--interval', type=int, default=5 * 60,
                        help='Interval for the main loop (in seconds) '
                        '(default: 5 * 60)')

    parser.add_argument('-m', '--mem-avail-mb', type=int, default=1024,
                        help='Threshold for the minimum available memory '
                        '(in megabytes) (default: 1024)')
    parser.add_argument('-s', '--swap-free-mb', type=int, default=1024,
                        help='Threshold for the minimum free swap memory '
                        '(in megabytes) (default: 1024)')
    parser.add_argument('-d', '--disk-free-mb', type=int, default=10240,
                        help='Threshold for the minimum free disk space '
                        '(in megabytes) (default: 10240)')

    # TODO more args to be able to set more thresholds
    # TODO debug mode to print the records

    args = vars(parser.parse_args(argv[1:]))

    print(f'Perfmon started. Interval: {args['interval']} seconds')

    while True:
        records = []

        # TODO

        ########################################################################

        msgs = [eval_alert(*x) for x in records]
        msgs = [x for x in msgs if x is not None]

        if len(msgs) > 0:
            print(', '.join(msgs))

        time.sleep(args['interval'])


if __name__ == '__main__':
    sys.exit(main())
