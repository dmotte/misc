#!/usr/bin/env python3

import sys
import time
from datetime import datetime as dt

from croniter import croniter


def main() -> int:
    iter = croniter('*/2 * * * *', ret_type=dt)  # every 2 minutes

    while True:
        dt_now = dt.now().astimezone()
        print('Now:', dt_now)

        dt_next = iter.get_next(start_time=dt_now)
        print('Sleeping until:', dt_next)
        time.sleep((dt_next - dt_now).total_seconds())

        dt_now = dt.now().astimezone()
        print('Now:', dt_now)

        print()
        print('Long task: started')
        time.sleep(3)
        print('Long task: finished')
        print()


if __name__ == '__main__':
    sys.exit(main())
