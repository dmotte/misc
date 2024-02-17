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

    parser.add_argument('-l', '--load05', type=float, default=1.0,
                        help='Threshold for the maximum load in the last 5 '
                        'minutes (default: 1.0)')
    parser.add_argument('-m', '--mem-avail-mb', type=float, default=1024,
                        help='Threshold for the minimum available memory '
                        '(in megabytes) (default: 1024)')
    parser.add_argument('-s', '--swap-free-mb', type=float, default=1024,
                        help='Threshold for the minimum free swap memory '
                        '(in megabytes) (default: 1024)')

    parser.add_argument('-p', '--ignore-partitions', type=str, default='',
                        help='Comma-separated list of partitions to skip '
                        'during the minimum free disk space check '
                        '(default: none)')
    parser.add_argument('-b', '--boot-free-mb', type=float, default=100,
                        help='Threshold for the minimum free disk space on '
                        'boot partitions (in megabytes) (default: 100)')
    parser.add_argument('-d', '--disk-free-mb', type=float, default=10240,
                        help='Threshold for the minimum free disk space on '
                        'normal partitions (in megabytes) (default: 10240)')

    # TODO debug mode to print the records
    # TODO function inside main to build msgs without records

    args = parser.parse_args(argv[1:])
    ignore_partitions = args.ignore_partitions.split(',')

    ############################################################################

    print(f'Perfmon started. Interval: {args.interval} seconds')

    old_disk_io_bytes = -1
    old_net_io_bytes = -1

    while True:
        records = [
            ['load05', psutil.getloadavg()[1], '>=', args.load05],
            ['mem_avail_mb', round(psutil.virtual_memory().available
                                   / 1024**2, 3), '<=', args.mem_avail_mb],
            ['swap_free_mb', round(psutil.swap_memory().free
                                   / 1024**2, 3), '<=', args.swap_free_mb],
        ]

        for part in psutil.disk_partitions():
            if part.mountpoint in ignore_partitions:
                continue
            threshold = args.boot_free_mb \
                if part.mountpoint in ['/boot', '/boot/efi'] \
                else args.disk_free_mb
            records.append([f'disk_free_mb:{part.mountpoint}',
                            round(psutil.disk_usage(part.mountpoint).free
                                  / 1024**2, 3), '<=', threshold])

        disk_io = psutil.disk_io_counters()
        disk_io_bytes = disk_io.read_bytes + disk_io.write_bytes
        if old_disk_io_bytes != -1:
            records.append(['disk_io_kbps',
                            round((disk_io_bytes - old_disk_io_bytes)
                                  / args.interval / 1024, 3), '>=', TODO])
        old_disk_io_bytes = disk_io_bytes

        net_io = psutil.net_io_counters()
        net_io_bytes = net_io.bytes_sent + net_io.bytes_recv
        if old_net_io_bytes != -1:
            records.append(['net_io_kbps',
                            round((net_io_bytes - old_net_io_bytes)
                                  / args.interval / 1024, 3), '>=', TODO])
        old_net_io_bytes = net_io_bytes

        for unit_name, unit in psutil.sensors_temperatures().items():
            for sensor in unit:
                sensor_label = sensor.label.replace(' ', '_')
                records.append([f'temp:{unit_name}:{sensor_label}',
                                sensor.current, '>=', TODO])

        ########################################################################

        msgs = [eval_alert(*x) for x in records]
        msgs = [x for x in msgs if x is not None]

        if len(msgs) > 0:
            print(', '.join(msgs))

        time.sleep(args.interval)


if __name__ == '__main__':
    sys.exit(main())
