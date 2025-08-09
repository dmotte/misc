#!/usr/bin/env python3

import argparse
import importlib
import json
import sys

from contextlib import ExitStack


def main(argv: list[str] = None) -> int:
    if argv is None:
        argv = sys.argv

    parser = argparse.ArgumentParser(
        description='Detect exact and near duplicates in an image collection')

    parser.add_argument('images_dir', metavar='IMAGES_DIR', type=str,
                        nargs='?', default='.',
                        help='Directory containing the image files '
                        '(default: %(default)s)')

    parser.add_argument('file_out', metavar='FILE_OUT', type=str,
                        nargs='?', default='-',
                        help='Output file. If set to "-" then stdout is used '
                        '(default: %(default)s)')

    parser.add_argument('-m', '--method', type=str, default='PHash',
                        help='The imagededup method to be used '
                        '(default: %(default)s)')

    parser.add_argument('-s', '--min-sim-thresh', type=float, default=0.9,
                        help='min_similarity_threshold value (only for the '
                        'CNN method) (default: %(default)s)')
    parser.add_argument('-d', '--max-dist-thresh', type=int, default=10,
                        help='max_distance_threshold value (only for the '
                        '*Hash methods) (default: %(default)s)')

    parser.add_argument('-S', '--scores', action='store_true',
                        help='Include scores in the output')

    args = parser.parse_args(argv[1:])

    ############################################################################

    instance = getattr(importlib.import_module('imagededup.methods'),
                       args.method)()

    encodings = instance.encode_images(args.images_dir)

    if args.method == 'CNN':
        duplicates = instance.find_duplicates(
            encoding_map=encodings,
            min_similarity_threshold=args.min_sim_thresh,
            scores=args.scores)
    else:
        duplicates = instance.find_duplicates(
            encoding_map=encodings,
            max_distance_threshold=args.max_dist_thresh,
            scores=args.scores)

    duplicates = {k: v for k, v in duplicates.items() if len(v) > 0}

    with ExitStack() as stack:
        file_out = (sys.stdout if args.file_out == '-'
                    else stack.enter_context(open(args.file_out, 'w')))

        json.dump(duplicates, file_out, indent=2, default=str)
        print(file=file_out)

    return 0


if __name__ == '__main__':
    sys.exit(main())
