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

    parser.add_argument('-d', '--debug', action='store_true',
                        help='Enable debug mode')

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
    parser.add_argument('-f', '--disk-free-mb', type=float, default=10240,
                        help='Threshold for the minimum free disk space on '
                        'normal partitions (in megabytes) (default: 10240)')

    parser.add_argument('-k', '--disk-io-kbps', type=float, default=1024,
                        help='Threshold for the maximum disk I/O throughput '
                        '(in kilobytes per second) (default: 1024)')
    parser.add_argument('-n', '--net-io-kbps', type=float, default=1024,
                        help='Threshold for the maximum network I/O throughput '
                        '(in kilobytes per second) (default: 1024)')

    parser.add_argument('-t', '--temp', type=float, default=50,
                        help='Threshold for the maximum temperature '
                        '(in degrees Celsius) (default: 50)')

    args = parser.parse_args(argv[1:])
    args.ignore_partitions = [] if args.ignore_partitions == '' \
        else args.ignore_partitions.split(',')

    if args.interval <= 0:
        print('Interval must be > 0', file=sys.stderr)
        return 1

    ############################################################################

    msgs = []

    def add_msg_if_any(*fargs):
        if args.debug:
            print('Evaluating', fargs)
        msg = eval_alert(*fargs)
        if msg is not None:
            msgs.append(msg)

    old_disk_io_bytes = -1
    old_net_io_bytes = -1

    print(f'Perfmon started. Args: {args}')

    while True:
        msgs = []

        add_msg_if_any('load05', psutil.getloadavg()[1], '>=', args.load05)
        add_msg_if_any('mem_avail_mb',
                       round(psutil.virtual_memory().available / 1024**2, 3),
                       '<=', args.mem_avail_mb)
        add_msg_if_any('swap_free_mb',
                       round(psutil.swap_memory().free / 1024**2, 3),
                       '<=', args.swap_free_mb)

        for part in psutil.disk_partitions():
            if part.mountpoint in args.ignore_partitions:
                continue
            threshold = args.boot_free_mb \
                if part.mountpoint in ['/boot', '/boot/efi'] \
                else args.disk_free_mb
            add_msg_if_any(f'disk_free_mb:{part.mountpoint}',
                           round(psutil.disk_usage(part.mountpoint).free
                                 / 1024**2, 3), '<=', threshold)

        disk_io = psutil.disk_io_counters()
        disk_io_bytes = disk_io.read_bytes + disk_io.write_bytes
        if old_disk_io_bytes != -1:
            add_msg_if_any('disk_io_kbps',
                           round((disk_io_bytes - old_disk_io_bytes)
                                 / args.interval / 1024, 3), '>=',
                           args.disk_io_kbps)
        old_disk_io_bytes = disk_io_bytes

        net_io = psutil.net_io_counters()
        net_io_bytes = net_io.bytes_sent + net_io.bytes_recv
        if old_net_io_bytes != -1:
            add_msg_if_any('net_io_kbps',
                           round((net_io_bytes - old_net_io_bytes)
                                 / args.interval / 1024, 3), '>=',
                           args.net_io_kbps)
        old_net_io_bytes = net_io_bytes

        for unit_name, unit in psutil.sensors_temperatures().items():
            for sensor in unit:
                sensor_label = sensor.label.replace(' ', '_')
                add_msg_if_any(f'temp:{unit_name}:{sensor_label}',
                               sensor.current, '>=', args.temp)

        ########################################################################

        if len(msgs) > 0:
            print(', '.join(msgs))

        time.sleep(args.interval)


if __name__ == '__main__':
    sys.exit(main())
