#!/usr/bin/env python3

import json
import sys
from typing import TextIO


def xmlescape(x: str) -> str:
    x = x.replace('&', '&amp;')
    x = x.replace('<', '&lt;')
    x = x.replace('>', '&gt;')
    x = x.replace('"', '&quot;')
    x = x.replace("'", '&apos;')
    return x


def print_item(file: TextIO, item: dict, indent: int = 0) -> None:
    str_indent = '    ' * indent

    esc_name = xmlescape(item['name'])

    pf = lambda *args, **kwargs: print(*args, file=file, **kwargs)

    if item['type'] == 'folder':
        pf(f'{str_indent}<DT><H3>{esc_name}</H3>')
        pf(f'{str_indent}<DL><p>')
        for subitem in item['children']:
            print_item(file, subitem, indent + 1)
        pf(f'{str_indent}</DL><p>')
    elif item['type'] == 'url':
        esc_url = xmlescape(item['url'])
        pf(f'{str_indent}<DT><A HREF="{esc_url}">{esc_name}</A>')
    else:
        raise ValueError('Unsupported item type: ' + str(item['type']))


def main() -> int:
    input = json.load(sys.stdin)

    print('<!DOCTYPE NETSCAPE-Bookmark-file-1>')
    print('<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8" />')
    print('<TITLE>Bookmarks</TITLE>')
    print('<H1>Bookmarks</H1>')

    print('<DL><p>')

    if isinstance(input, list):
        for item in input:
            print_item(sys.stdout, item, 1)
    else:
        print_item(sys.stdout, input, 1)

    print('</DL><p>')

    return 0


if __name__ == '__main__':
    sys.exit(main())
