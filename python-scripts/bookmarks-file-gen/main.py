#!/usr/bin/env python3

import json
import sys
from typing import TextIO


def xmlescape(x: str):
    x = x.replace('&', '&amp;')
    x = x.replace('<', '&lt;')
    x = x.replace('>', '&gt;')
    x = x.replace('"', '&quot;')
    x = x.replace("'", '&apos;')
    return x


def print_item(file: TextIO, item: dict, indent: int = 0):
    str_indent = '    ' * indent

    esc_name = xmlescape(item['name'])

    if item['type'] == 'folder':
        print(f'{str_indent}<DT><H3>{esc_name}</H3>', file=file)
        print(f'{str_indent}<DL><p>', file=file)
        for subitem in item['children']:
            print_item(file, subitem, indent + 1)
        print(f'{str_indent}</DL><p>', file=file)
    elif item['type'] == 'url':
        esc_url = xmlescape(item['url'])
        print(f'{str_indent}<DT><A HREF="{esc_url}">{esc_name}</A>', file=file)
    else:
        raise ValueError('Unsupported item type: ' + str(item['type']))


def main():
    input = json.load(sys.stdin)

    print('<!DOCTYPE NETSCAPE-Bookmark-file-1>')
    print('<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8" />')
    print('<TITLE>Bookmarks</TITLE>')
    print('<H1>Bookmarks</H1>')

    if isinstance(input, list):
        for item in input:
            print_item(sys.stdout, item)  # TODO test well
    else:
        print('<DL><p>')
        print_item(sys.stdout, input, 1)  # TODO test well
        print('</DL><p>')

    return 0


if __name__ == '__main__':
    sys.exit(main())
