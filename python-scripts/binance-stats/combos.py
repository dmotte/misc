#!/usr/bin/env python3

import argparse
import sys

from lib.record import load_records


def main(argv=None):
    if argv is None:
        argv = sys.argv

    parser = argparse.ArgumentParser(
        description='Returns the unique combinations of (operation, remark) '
        'in the transaction records, as CSV')

    parser.parse_args(argv[1:])

    ############################################################################

    records = load_records(sys.stdin)

    print('Operation,Remark')

    for operation, remark in sorted(
            {(x['operation'], x['remark']) for x in records}):
        print(f'{operation},{remark}')

    return 0


if __name__ == '__main__':
    sys.exit(main())
