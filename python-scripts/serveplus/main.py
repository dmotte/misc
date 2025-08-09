#!/usr/bin/env python3

import argparse
import contextlib
import http.server
import os
import random
import socket
import string
import sys

from http import HTTPStatus, cookies
from io import BytesIO
from typing import BinaryIO


# Inspired by
# https://github.com/python/cpython/blob/27ed64575d34f04029ba1d353810f3db4f4f045b/Lib/http/server.py


def pair_items_to_dict(items: list[str]) -> dict[str, str]:
    len_items = len(items)

    if len_items % 2 != 0:
        raise ValueError('The length of pair items must be an even number')

    return {items[i]: items[i + 1] for i in range(0, len_items, 2)}


def main(argv: list[str] = None) -> int:
    if argv is None:
        argv = sys.argv

    parser = argparse.ArgumentParser(description='Serve a directory via HTTP, '
                                     'with support for some additional '
                                     'features')

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

    parser.add_argument('-t', '--token-auth', action='store_true',
                        help='Protect the webserver with a token-based '
                        'mechanism')
    parser.add_argument('-l', '--token-len', type=int, default=64,
                        help='Length for the token-based authentication, if '
                        'enabled (default: %(default)s)')
    parser.add_argument('-c', '--cookie-attr', type=str, nargs='*', default=[],
                        help='Attributes for the token cookie. Example: '
                        '["HttpOnly", "Path=/"]')

    parser.add_argument('aliases', metavar='ALIASES', type=str, nargs='*',
                        help='List of path translations, i.e. (served path, '
                        'real path) pairs, as array of items (e.g. '
                        '/img static/img /asset static/asset)')

    args = parser.parse_args(argv[1:])

    args.aliases = {k.rstrip('/'): v.rstrip('/')
                    for k, v in pair_items_to_dict(args.aliases).items()}

    debug_mode = os.getenv('SERVEPLUS_DEBUG', 'false') == 'true'

    ############################################################################

    if debug_mode:
        print('args:', args)

    TOKEN_COOKIE_NAME = 'serveplus-token'

    token_query, token_cookie = None, None
    if args.token_auth:
        sysrand = random.SystemRandom()
        token_query = ''.join(sysrand.choices(
            string.ascii_letters + string.digits, k=args.token_len))
        token_cookie = ''.join(sysrand.choices(
            string.ascii_letters + string.digits, k=args.token_len))

    class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
        def translate_path(self, path: str) -> str:
            for k, v in args.aliases.items():
                if path == k or path.startswith((k + '?', k + '#')):
                    # This should trigger a redirect when the alias root is
                    # requested without trailing slash in the path
                    return v

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

        def send_head(self) -> BytesIO | BinaryIO | None:
            nonlocal token_query, token_cookie

            if token_query is not None:
                if self.path == f'/auth?token={token_query}':
                    if debug_mode:
                        print('Received query token. Switching to '
                              'cookie-based authentication')

                    token_query = None

                    cookie_attrs = ''.join(f'; {x}' for x in args.cookie_attr)

                    self.send_response(HTTPStatus.FOUND)
                    self.send_header('Location', '/')
                    self.send_header('Set-Cookie', TOKEN_COOKIE_NAME + '=' +
                                     token_cookie + cookie_attrs)
                    self.end_headers()
                    self.wfile.write(b'Found')
                    return None
                else:
                    self.send_response(HTTPStatus.UNAUTHORIZED)
                    self.end_headers()
                    self.wfile.write(b'Unauthorized')
                    return None

            if token_cookie is not None:
                parsed_cookies = cookies.SimpleCookie(
                    self.headers.get('Cookie', ''))
                parsed_cookie = parsed_cookies.get(TOKEN_COOKIE_NAME)
                cookie_value = None if parsed_cookie is None \
                    else parsed_cookie.value

                if token_cookie != cookie_value:
                    self.send_response(HTTPStatus.UNAUTHORIZED)
                    self.end_headers()
                    self.wfile.write(b'Unauthorized')
                    return None

            return super().send_head()

    class DualStackServer(http.server.ThreadingHTTPServer):
        def server_bind(self) -> None:
            # Suppress exception when protocol is IPv4
            with contextlib.suppress(Exception):
                self.socket.setsockopt(
                    socket.IPPROTO_IPV6, socket.IPV6_V6ONLY, 0)
            return super().server_bind()

        def serve_forever(self, *fargs, **fkwargs) -> None:
            if args.token_auth:
                host, port = self.socket.getsockname()[:2]
                url_host = f'[{host}]' if ':' in host else host

                print('URL with token: '
                      f'http://{url_host}:{port}/auth?token={token_query}')

            return super().serve_forever(*fargs, **fkwargs)

        def finish_request(self, request, client_address) -> None:
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
