#!/usr/bin/env python3

import argparse
import array
import math
import sys

from contextlib import ExitStack

from pydub import AudioSegment


def compute_values(audio: AudioSegment, perc_clipping: float = 0.0001,
                   level_start: float = 0.0005,
                   level_end: float = 0.0005) -> dict:
    if perc_clipping < 0 or perc_clipping > 1:
        raise ValueError(f'Invalid perc_clipping value: {perc_clipping}. It '
                         'must be between 0 and 1, inclusive')
    if level_start < 0 or level_start > 1:
        raise ValueError(f'Invalid level_start value: {level_start}. It '
                         'must be between 0 and 1, inclusive')
    if level_end < 0 or level_end > 1:
        raise ValueError(f'Invalid level_end value: {level_end}. It '
                         'must be between 0 and 1, inclusive')

    ############################################################################

    # Maximum possible (absolute) value of a sample
    max_poss = 2 ** (8 * audio.sample_width - 1)

    samples = audio.get_array_of_samples()
    len_samples = len(samples)

    samples_abs = [abs(s) for s in samples]

    # Similar to an ECDF (Empirical Cumulative Distribution Function)
    sorted_abs = samples_abs.copy()
    sorted_abs.sort()

    # Maximum sample value in the audio track
    max_abs = sorted_abs[-1]

    # Value of the sample(s) that will be the new maximum after the track will
    # be amplified
    target_max = sorted_abs[round((len_samples - 1) * (1 - perc_clipping))]

    if target_max == 0:
        raise ValueError('The computed target_max is zero (maybe '
                         'perc_clipping is a little bit too high?)')

    # Gain expressed as multiplication factor (e.g. 2.0 -> 2x)
    gain_factor = max_poss / target_max
    # Gain expressed in decibels
    gain_db = 20 * math.log(gain_factor, 10)

    ############################################################################

    # TODO calculate start and end

    ############################################################################

    return {
        'max_poss': max_poss,
        'len_samples': len_samples,
        'max_abs': max_abs,
        'target_max': target_max,
        'gain_factor': gain_factor,
        'gain_db': gain_db,
    }


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

    parser.add_argument('-l', '--level-start', type=float, default=0.0005,
                        help='TODO (default: 0.0005)')
    parser.add_argument('-L', '--level-end', type=float, default=0.0005,
                        help='TODO (default: 0.0005)')

    args = parser.parse_args(argv[1:])

    ############################################################################

    with ExitStack() as stack:
        file_in = (sys.stdin if args.file_in == '-'
                   else stack.enter_context(open(args.file_in, 'rb')))
        file_out = (sys.stdout if args.file_out == '-'
                    else stack.enter_context(open(args.file_out, 'wb')))

        audio: AudioSegment = AudioSegment.from_file(file_in)

        # TODO fix this
        print(compute_values(audio, args.perc_clipping, args.level_start,
                             args.level_end), file=file_out)

    return 0


if __name__ == '__main__':
    sys.exit(main())
