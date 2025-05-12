#!/usr/bin/env python3

import argparse
import contextlib
import http.server
import os
import socket
import sys

# Inspired by
# https://github.com/python/cpython/blob/27ed64575d34f04029ba1d353810f3db4f4f045b/Lib/http/server.py


def pair_items_to_dict(items: list[str]) -> dict[str, str]:
    len_items = len(items)

    if len_items % 2 != 0:
        raise ValueError('The length of pair items must be an even number')

    return {items[i]: items[i + 1] for i in range(0, len_items, 2)}


def main(argv=None):
    if argv is None:
        argv = sys.argv

    parser = argparse.ArgumentParser(description='Serve a directory via HTTP, '
                                     'with optional path translations')

    parser.add_argument('-b', '--bind', type=str, default=None,
                        help='Bind to this address (default: all interfaces)')
    parser.add_argument('-P', '--port', type=int, default=8000,
                        help='Bind to this port (default: %(default)s)')

    parser.add_argument('-p', '--protocol', type=str, default='HTTP/1.0',
                        help='Conform to this HTTP version (default: '
                             '%(default)s)')

    parser.add_argument('-d', '--directory', type=str, default=os.getcwd(),
                        help='Serve this directory (default: current '
                        'directory)')

    parser.add_argument('aliases', metavar='ALIASES', type=str, nargs='*',
                        help='List of path translations, i.e. (served path, '
                        'real path) pairs, as array of items (e.g. '
                        '/img static/img /asset static/asset)')

    args = parser.parse_args(argv[1:])

    args.aliases = {k.rstrip('/'): v.rstrip('/')
                    for k, v in pair_items_to_dict(args.aliases).items()}

    debug_mode = os.getenv('MULTISERVE_DEBUG', 'false') == 'true'

    ############################################################################

    if debug_mode:
        print('args:', args)

    class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
        def translate_path(self, path):
            for k, v in args.aliases.items():
                if path.startswith(k + '/'):
                    if debug_mode:
                        print(f'Translating path {path} based on prefix {k}')

                    self.directory = v
                    path = path.removeprefix(k)

                    if debug_mode:
                        print(f'New self.directory and path:',
                              (self.directory, path))

                    break

            return super().translate_path(path)

    class DualStackServer(http.server.ThreadingHTTPServer):
        def server_bind(self):
            # Suppress exception when protocol is IPv4
            with contextlib.suppress(Exception):
                self.socket.setsockopt(
                    socket.IPPROTO_IPV6, socket.IPV6_V6ONLY, 0)
            return super().server_bind()

        def finish_request(self, request, client_address):
            self.RequestHandlerClass(request, client_address, self,
                                     directory=args.directory)

    http.server.test(
        HandlerClass=CustomHTTPRequestHandler,
        ServerClass=DualStackServer,
        bind=args.bind,
        port=args.port,
        protocol=args.protocol,
    )

    return 0


if __name__ == '__main__':
    sys.exit(main())
