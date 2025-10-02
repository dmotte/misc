#!/usr/bin/env python3

import argparse
import sys

from lib.record import load_records


def main(argv: list[str] | None = None) -> int:
    if argv is None:
        argv = sys.argv

    parser = argparse.ArgumentParser(
        description='Returns the list of all the coins that appear in the '
        'transaction records')

    parser.parse_args(argv[1:])

    ############################################################################

    records = load_records(sys.stdin)

    for coin in sorted({x['coin'] for x in records}):
        print(coin)

    return 0


if __name__ == '__main__':
    sys.exit(main())
