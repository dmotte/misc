#!/usr/bin/env python3

import argparse
import sys

from lib import codespaces_api
from lib.config import Config, get_config


def subcmd_list(cfg: Config, args: argparse.Namespace) -> None:
    for id in cfg.codespaces:
        print(id)


def subcmd_state(cfg: Config, args: argparse.Namespace) -> None:
    codespace = cfg.codespaces[args.id]

    resp = codespaces_api.request('get', codespace.name, codespace.token, '')

    print(resp.json()['state'])


def subcmd_start(cfg: Config, args: argparse.Namespace) -> None:
    codespace = cfg.codespaces[args.id]

    codespaces_api.request('post', codespace.name, codespace.token, '/start')


def subcmd_stop(cfg: Config, args: argparse.Namespace) -> None:
    codespace = cfg.codespaces[args.id]

    codespaces_api.request('post', codespace.name, codespace.token, '/stop')


def main(argv: list[str] | None = None) -> int:
    if argv is None:
        argv = sys.argv

    parser = argparse.ArgumentParser(description='Codespace lifecycle manager')

    subparsers = parser.add_subparsers(metavar='SUBCMD', required=True)

    subparser = subparsers.add_parser('list', help='List codespaces')
    subparser.set_defaults(func=subcmd_list)

    subparser = subparsers.add_parser('state', help='Get codespace state')
    subparser.add_argument('id', metavar='ID', type=str, help='Codespace ID')
    subparser.set_defaults(func=subcmd_state)

    subparser = subparsers.add_parser('start', help='Start codespace')
    subparser.add_argument('id', metavar='ID', type=str, help='Codespace ID')
    subparser.set_defaults(func=subcmd_start)

    subparser = subparsers.add_parser('stop', help='Stop codespace')
    subparser.add_argument('id', metavar='ID', type=str, help='Codespace ID')
    subparser.set_defaults(func=subcmd_stop)

    args = parser.parse_args(argv[1:])

    ############################################################################

    cfg = get_config()

    args.func(cfg, args)

    return 0


if __name__ == '__main__':
    sys.exit(main())
