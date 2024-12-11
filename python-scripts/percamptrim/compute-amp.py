#!/usr/bin/env python3

import argparse
import math
import sys

from contextlib import ExitStack
from typing import TextIO

from pydub import AudioSegment


def compute_values(audio: AudioSegment, perc_clipping: float = 0) -> dict:
    if perc_clipping < 0 or perc_clipping > 1:
        raise ValueError(f'Invalid perc_clipping value: {perc_clipping}. It '
                         'must be between 0 and 1, inclusive')

    # Maximum possible (absolute) value of a sample
    max_poss = 2 ** (8 * audio.sample_width - 1)

    samples = audio.get_array_of_samples()
    len_samples = len(samples)

    samples_abs = [abs(s) for s in samples]

    # Similar to an ECDF (Empirical Cumulative Distribution Function)
    sorted_abs = samples_abs.copy()
    sorted_abs.sort()

    # Value of the sample(s) that will be the new maximum(s) after the track
    # will be amplified
    target_max = sorted_abs[round((len_samples - 1) * (1 - perc_clipping))]

    if target_max == 0:
        raise ValueError('The computed target_max is zero. Maybe '
                         'perc_clipping is too high, or the track is silent')

    # Gain expressed as multiplication factor (e.g. 2.0 -> 2x)
    gain_factor = max_poss / target_max
    # Gain expressed in decibels
    gain_db = 20 * math.log(gain_factor, 10)

    return {
        'max_poss': max_poss,
        'len_samples': len_samples,

        'target_max': target_max,
        'gain_factor': gain_factor,
        'gain_db': gain_db,
    }


def print_values(values: dict, file: TextIO, fmt_float: str = ''):
    func_float = str if fmt_float == '' else lambda x: fmt_float.format(x)

    for k, v in values.items():
        print(f'{k}={func_float(v) if isinstance(v, float) else v}', file=file)


def main(argv=None):
    if argv is None:
        argv = sys.argv

    parser = argparse.ArgumentParser(
        description='Computes the values needed to amplify an audio track '
        'based on an allowed clipping samples percentage'
    )

    parser.add_argument('file_in', metavar='FILE_IN', type=str,
                        nargs='?', default='-',
                        help='Input file. If set to "-" then stdin is used '
                        '(default: -)')
    parser.add_argument('file_out', metavar='FILE_OUT', type=str,
                        nargs='?', default='-',
                        help='Output file. If set to "-" then stdout is used '
                        '(default: -)')

    parser.add_argument('-p', '--perc-clipping', type=float, default=0.0001,
                        help='Percentage (from 0 to 1) of samples of the '
                        'trimmed audio that are allowed to clip '
                        '(default: 0.0001)')

    parser.add_argument('-f', '--format', type=str, default='',
                        help='If specified, formats the float values with this '
                        'format string (e.g. "{:.6f}")')

    args = parser.parse_args(argv[1:])

    ############################################################################

    with ExitStack() as stack:
        file_in = (sys.stdin if args.file_in == '-'
                   else stack.enter_context(open(args.file_in, 'rb')))
        file_out = (sys.stdout if args.file_out == '-'
                    else stack.enter_context(open(args.file_out, 'wb')))

        audio: AudioSegment = AudioSegment.from_file(file_in)

        values = compute_values(audio, args.perc_clipping)

        print_values(values, file_out, args.format)

    return 0


if __name__ == '__main__':
    sys.exit(main())
