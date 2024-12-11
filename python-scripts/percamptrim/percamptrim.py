#!/usr/bin/env python3

import argparse
import math
import sys

from contextlib import ExitStack
from typing import TextIO

from pydub import AudioSegment


def compute_values(audio: AudioSegment,
                   level_start: float = 0, level_end: float = 0,
                   perc_clipping: float = 0) -> dict:
    if level_start < 0 or level_start > 1:
        raise ValueError(f'Invalid level_start value: {level_start}. It '
                         'must be between 0 and 1, inclusive')
    if level_end < 0 or level_end > 1:
        raise ValueError(f'Invalid level_end value: {level_end}. It '
                         'must be between 0 and 1, inclusive')
    if perc_clipping < 0 or perc_clipping > 1:
        raise ValueError(f'Invalid perc_clipping value: {perc_clipping}. It '
                         'must be between 0 and 1, inclusive')

    ############################################################################

    frame_rate = audio.frame_rate

    # Maximum possible (absolute) value of a sample
    max_poss = 2 ** (8 * audio.sample_width - 1)

    samples = audio.get_array_of_samples()
    len_samples = len(samples)

    samples_abs = [abs(s) for s in samples]

    ############################################################################

    sample_start = 0  # First sample, inclusive
    if level_start > 0:
        for i in range(0, len_samples):
            if samples_abs[i] >= level_start:
                sample_start = i
                break

    sample_end = len_samples  # Last sample, exclusive
    if level_end > 0:
        for i in range(len_samples - 1, -1, -1):
            if samples_abs[i] >= level_end:
                sample_end = i + 1
                break

    # Time of the first sample, in seconds. If < 0, the audio doesn't need to
    # be trimmed at the start
    time_start = -1 if sample_start == 0 else sample_start / frame_rate
    # Time of the last sample, in seconds. If < 0, the audio doesn't need to
    # be trimmed at the end
    time_end = -1 if sample_end == len_samples else sample_end / frame_rate

    ############################################################################

    samples_abs_cut = samples_abs[sample_start:sample_end]
    len_samples_cut = len(samples_abs_cut)

    # Similar to an ECDF (Empirical Cumulative Distribution Function)
    sorted_abs_cut = samples_abs_cut.copy()
    sorted_abs_cut.sort()

    # Value of the sample(s) that will be the new maximum(s) after the track
    # will be amplified
    target_max = sorted_abs_cut[round(
        (len_samples_cut - 1) * (1 - perc_clipping))]

    if target_max == 0:
        raise ValueError('The computed target_max is zero. Maybe '
                         'perc_clipping is too high, or the track is silent')

    # Gain expressed as multiplication factor (e.g. 2.0 -> 2x)
    gain_factor = max_poss / target_max
    # Gain expressed in decibels
    gain_db = 20 * math.log(gain_factor, 10)

    ############################################################################

    return {
        'frame_rate': frame_rate,
        'max_poss': max_poss,
        'len_samples': len_samples,

        'sample_start': sample_start, 'sample_end': sample_end,
        'time_start': time_start, 'time_end': time_end,
        'len_samples_cut': len_samples_cut,

        'target_max': target_max,
        'gain_factor': gain_factor,
        'gain_db': gain_db,
    }


def print_values(values: dict, file: TextIO):
    '''
    Prints the values to the specified file
    '''
    for k, v in values.items():
        print(f'{k}={v}', file=file)


def main(argv=None):
    if argv is None:
        argv = sys.argv

    parser = argparse.ArgumentParser(
        description='Percentile-based audio amplifier and trimmer'
    )

    parser.add_argument('file_in', metavar='FILE_IN', type=str,
                        nargs='?', default='-',
                        help='Input file. If set to "-" then stdin is used '
                        '(default: -)')
    parser.add_argument('file_out', metavar='FILE_OUT', type=str,
                        nargs='?', default='-',
                        help='Output file. If set to "-" then stdout is used '
                        '(default: -)')

    # TODO change the order of the params and cli flags to make it clear that the trimming is considered in the amp calc
    # TODO write in the flags that, if levels are zero, trimming is not
    # performed

    parser.add_argument('-p', '--perc-clipping', type=float, default=0.0001,
                        help='Percentage (from 0 to 1) of audio samples that '
                        'are allowed to clip (default: 0.0001)')

    parser.add_argument('-l', '--level-start', type=float, default=0.0005,
                        help='Threshold (from 0 to 1) for trimming the start '
                        'of the audio (default: 0.0005)')
    parser.add_argument('-L', '--level-end', type=float, default=0.0005,
                        help='Threshold (from 0 to 1) for trimming the end '
                        'of the audio (default: 0.0005)')

    # TODO use it
    parser.add_argument('-f', '--format', type=str, default='',
                        help='If specified, formats the float values (such as '
                        'the gain factor) with this format string '
                        '(e.g. "{:.6f}")')

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
