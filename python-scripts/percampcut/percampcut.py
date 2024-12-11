#!/usr/bin/env python3

import argparse
import array
import math
import sys

from contextlib import ExitStack

from pydub import AudioSegment


def main(argv=None):
    if argv is None:
        argv = sys.argv

    parser = argparse.ArgumentParser(
        description='TODO'
    )

    parser.add_argument('file_in', metavar='FILE_IN', type=str,
                        nargs='?', default='-',
                        help='Input file. If set to "-" then stdin is used '
                        '(default: -)')
    parser.add_argument('file_out', metavar='FILE_OUT', type=str,
                        nargs='?', default='-',
                        help='Output file. If set to "-" then stdout is used '
                        '(default: -)')

    # TODO recheck the flags

    parser.add_argument('-p', '--perc-clipping', type=float, default=0.0001,
                        help='Percentage of audio samples that are allowed '
                        'to clip (default: 0.0001)')

    parser.add_argument('-l', '--min-level-start', type=float, default=0.0005,
                        help='TODO (default: 0.0005)')
    parser.add_argument('-L', '--min-level-end', type=float, default=0.0005,
                        help='TODO (default: 0.0005)')

    args = parser.parse_args(argv[1:])

    ############################################################################

    with ExitStack() as stack:
        file_in = (sys.stdin if args.file_in == '-'
                   else stack.enter_context(open(args.file_in, 'rb')))
        file_out = (sys.stdout if args.file_out == '-'
                    else stack.enter_context(open(args.file_out, 'wb')))

        p: float = args.perc_clipping  # TODO check that 0 <= p <= 1
        print('p', p)

        audio: AudioSegment = AudioSegment.from_file(file_in)

        max_possible_value = 2 ** (8 * audio.sample_width - 1)
        print('max_possible_value', max_possible_value)

        samples: array = audio.get_array_of_samples()

        len_samples = len(samples)
        print('len_samples', len_samples)

        samples_abs = [abs(s) for s in samples]

        # Similar to an ECDF (Empirical Cumulative Distribution Function)
        sorted_abs = samples_abs.copy()
        sorted_abs.sort()

        max_abs = sorted_abs[-1]
        print('max_abs', max_abs)

        v = sorted_abs[round((len_samples - 1) * (1 - p))]
        print('v', v)

        a = max_possible_value / v  # TODO prevent division by zero
        print('a', a)

        decibels = 20 * math.log(a, 10)
        print('decibels', decibels)

    return 0


if __name__ == '__main__':
    sys.exit(main())
