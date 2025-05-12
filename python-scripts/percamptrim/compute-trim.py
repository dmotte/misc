#!/usr/bin/env python3

import argparse
import sys

from contextlib import ExitStack
from typing import TextIO

from pydub import AudioSegment


def compute_values(audio: AudioSegment,
                   level_start: float = 0, level_end: float = 0) -> dict:
    if level_start < 0 or level_start > 1:
        raise ValueError(f'Invalid level_start value: {level_start}. It '
                         'must be between 0 and 1, inclusive')
    if level_end < 0 or level_end > 1:
        raise ValueError(f'Invalid level_end value: {level_end}. It '
                         'must be between 0 and 1, inclusive')

    frame_rate = audio.frame_rate
    channels = audio.channels

    # Maximum possible (absolute) value of a sample
    max_poss = 2 ** (8 * audio.sample_width - 1)

    samples = audio.get_array_of_samples()
    len_samples = len(samples)

    samples_abs = [abs(s) for s in samples]

    sample_start = 0  # First sample, inclusive
    if level_start > 0:
        threshold = max_poss * level_start
        for i in range(0, len_samples):
            if samples_abs[i] >= threshold:
                sample_start = i
                break

    sample_end = len_samples  # Last sample, exclusive
    if level_end > 0:
        threshold = max_poss * level_end
        for i in range(len_samples - 1, -1, -1):
            if samples_abs[i] >= threshold:
                sample_end = i + 1
                break

    # Time of the first sample, in seconds. If < 0, the audio doesn't need to
    # be trimmed at the start
    time_start = -1 if sample_start == 0 \
        else sample_start / (frame_rate * channels)
    # Time of the last sample, in seconds. If < 0, the audio doesn't need to
    # be trimmed at the end
    time_end = -1 if sample_end == len_samples \
        else sample_end / (frame_rate * channels)

    return {
        'frame_rate': frame_rate,
        'channels': channels,
        'len_samples': len_samples,

        'level_start': level_start, 'level_end': level_end,

        'sample_start': sample_start, 'sample_end': sample_end,
        'time_start': time_start, 'time_end': time_end,
    }


def print_values(values: dict, file: TextIO, fmt_float: str = ''):
    func_float = str if fmt_float == '' else lambda x: fmt_float.format(x)

    for k, v in values.items():
        print(f'{k}={func_float(v) if isinstance(v, float) else v}', file=file)


def main(argv=None):
    if argv is None:
        argv = sys.argv

    parser = argparse.ArgumentParser(
        description='Computes the values needed to trim an audio track '
        'based on thresholds for minimum allowed signal levels'
    )

    parser.add_argument('file_in', metavar='FILE_IN', type=str,
                        nargs='?', default='-',
                        help='Input file. If set to "-" then stdin is used '
                        '(default: %(default)s)')
    parser.add_argument('file_out', metavar='FILE_OUT', type=str,
                        nargs='?', default='-',
                        help='Output file. If set to "-" then stdout is used '
                        '(default: %(default)s)')

    parser.add_argument('-l', '--level-start', type=float, default=0.0005,
                        help='Threshold (from 0 to 1) for trimming the start '
                        'of the audio. If 0, the start will not be trimmed '
                        '(default: %(default)s)')
    parser.add_argument('-L', '--level-end', type=float, default=0.0005,
                        help='Threshold (from 0 to 1) for trimming the end '
                        'of the audio. If 0, the end will not be trimmed '
                        '(default: %(default)s)')

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

        values = compute_values(audio, args.level_start, args.level_end)

        print_values(values, file_out, args.format)

    return 0


if __name__ == '__main__':
    sys.exit(main())
