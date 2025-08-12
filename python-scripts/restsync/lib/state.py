#!/usr/bin/env python3

import re


def state_read(state_file: str) -> dict:
    '''
    Reads a state file and returns its data as a Python object
    '''
    data = {}

    with open(state_file, 'r') as f:
        for line in f:
            match1 = re.fullmatch(r'^latest-snapshot-id:\s+(.+)\n$', line)
            if match1 is not None:
                data['latest-snapshot-id'] = match1.group(1)

    return data


def state_write(state_file: str, data: dict) -> None:
    '''
    Writes a Python object to a state file
    '''
    with open(state_file, 'w') as f:
        f.write('---\n')
        f.write(f'latest-snapshot-id: {data['latest-snapshot-id']}\n')
