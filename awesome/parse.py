#!/usr/bin/env python3

import json
import os
import re
import sys


def validate_https(url: str) -> bool:
    return url.startswith('https://')


LINK_VALIDATORS = {
    'website': validate_https,
    'docs': validate_https,
    'guide': validate_https,
    'tutorial': validate_https,
    'example': validate_https,
    'webapp': validate_https,
    'link': validate_https,

    'youtube': lambda x: any([
        re.match(r'^https://www\.youtube\.com/watch'
                 r'\?v=[0-9A-Za-z-_]{11}$', x),
        re.match(r'^https://www\.youtube\.com/playlist'
                 r'\?list=[0-9A-Za-z-_]{34}$', x),
        re.match(r'^https://www\.youtube\.com/watch'
                 r'\?v=[0-9A-Za-z-_]{11}'
                 r'&list=[0-9A-Za-z-_]{34}'
                 r'&index=[0-9]+$', x),
    ]),

    'github': lambda x: re.match(r'^https://github\.com/[0-9A-Za-z-]+'
                                 r'(/[0-9A-Za-z._-]+)?$', x),
    'gitlab': lambda x: re.match(r'^https://gitlab\.com/[0-9A-Za-z-]+'
                                 r'(/[0-9A-Za-z._-]+)?$', x),
    'sourceforge': lambda x: re.match(r'^https://sourceforge\.net/projects'
                                      r'/[0-9a-z-]+/$', x),

    'apt': lambda x: re.match(r'^https://packages\.debian\.org/bookworm'
                              r'/[0-9a-z-]+$', x),
    'choco': lambda x: re.match(r'^https://community\.chocolatey\.org/packages'
                                r'/[0-9A-Za-z.-]+$', x),

    'npm': lambda x: re.match(r'^https://www\.npmjs\.com/package'
                              r'(/@[0-9a-z-]+)?/[0-9a-z-]+$', x),
    'pypi': lambda x: re.match(r'^https://pypi\.org/project'
                               r'/[0-9A-Za-z-]+/$', x),

    'docker': lambda x: any([
        re.match(r'^https://hub\.docker\.com/r'
                 r'/[0-9a-z-]+/[0-9a-z-]+$', x),
        re.match(r'^https://hub\.docker\.com/_/[0-9a-z-]+$', x),
        re.match(r'^https://quay\.io/repository'
                 r'/[0-9a-z-]+/[0-9a-z-]+$', x),
    ]),

    'helm': validate_https,

    'fdroid': lambda x: re.match(r'^https://f-droid\.org/packages'
                                 r'/[0-9a-z._]+/$', x),
    'playstore': lambda x: re.match(r'^https://play\.google\.com/store/apps'
                                    r'/details\?id=[0-9A-Za-z._]+$', x),

    'chrome': lambda x: re.match(r'^https://chromewebstore\.google\.com/detail'
                                 r'/[0-9a-z-]+/[a-z]{32}$', x),
    'firefox': lambda x: re.match(r'^https://addons\.mozilla\.org/en-US'
                                  r'/firefox/addon/[0-9a-z-]+/$', x),

    'vsmarketplace': lambda x: re.match(
        r'^https://marketplace\.visualstudio\.com/items'
        r'\?itemName=[0-9A-Za-z.-]+$', x),

    'huggingface': lambda x: re.match(r'^https://huggingface\.co/[0-9A-Za-z-]+'
                                      r'(/[0-9A-Za-z.-]+)?$', x),
    'spaces': lambda x: re.match(r'^https://huggingface\.co/spaces'
                                 r'/[0-9A-Za-z-]+(/[0-9A-Za-z.-]+)?$', x),
}


def parse_link(s: str) -> dict:
    match = re.search(r'^\[([^\[\]]+)\]\(([^\(\)]+)\)$', s)
    if match is None:
        raise ValueError(f'Cannot parse link: {s}')

    label = match.group(1)
    url = match.group(2)

    if label not in LINK_VALIDATORS:
        raise ValueError(f'Invalid link label: {label}')

    validator = LINK_VALIDATORS[label]

    if not validator(url):
        raise ValueError(f'Invalid link URL: {url}')

    return {'label': label, 'url': url}


def parse_item(s: str) -> dict:
    match = re.search(r'^- \*\*([^\*]+)\*\* - ([^:]+): (.+)$', s)
    if match is None:
        raise ValueError(f'Cannot parse item: {s}')

    name = match.group(1)
    desc = match.group(2)

    if desc[0].isspace():
        raise ValueError(f'Leading whitespace in item description: {desc}')
    if desc[-1].isspace():
        raise ValueError(f'Trailing whitespace in item description: {desc}')

    raw_links = match.group(3).split(' ')

    if not all(raw_links[i] <= raw_links[i + 1]
               for i in range(len(raw_links) - 1)):
        raise ValueError(f'Links are not in alphabetical order for item: {s}')

    links = [parse_link(x) for x in raw_links]

    return {'name': name, 'desc': desc, 'links': links}


def parse_header(s: str) -> tuple[int, str]:
    match = re.search(r'^(#+) (.+)$', s)
    if match is None:
        raise ValueError(f'Cannot parse header: {s}')

    level = len(match.group(1))
    name = match.group(2)

    return level, name


def check_items_sorted(data: dict):
    prev_name = ''

    for child in data:
        if child['type'] == 'item':
            if child['name'] < prev_name:
                raise ValueError(f'Wrong items order: {child['name']} comes '
                                 f'after {prev_name}')
            prev_name = child['name']
        elif child['type'] == 'section':
            check_items_sorted(child['children'])


def main():
    data = []
    errors = []

    stack = []

    for line in sys.stdin:
        line = line.removesuffix('\n')

        if line.startswith('#'):
            level, name = parse_header(line)
            section = {'type': 'section', 'name': name, 'children': []}

            if level > len(stack) + 1:
                raise ValueError(f'Level too high: {line}')

            while len(stack) >= level:
                stack.pop()

            if len(stack) > 0:
                stack[-1]['children'].append(section)
            else:
                data.append(section)

            stack.append(section)

        elif line.startswith('- '):
            try:
                item = {'type': 'item'} | parse_item(line)

                if len(stack) > 0:
                    stack[-1]['children'].append(item)
                else:
                    data.append(item)
            except Exception as e:
                errors.append(e)

    check_items_sorted(data)

    ############################################################################

    output_data = os.getenv('OUTPUT_DATA', 'true') == 'true'
    output_errors = os.getenv('OUTPUT_ERRORS', 'true') == 'true'

    output = {}
    if output_data:
        output['data'] = data
    if output_errors:
        output['errors'] = errors

    json.dump(output, sys.stdout, indent=2, default=str)
    print()

    if len(errors) > 0:
        return 1

    return 0


if __name__ == '__main__':
    sys.exit(main())
