#!/usr/bin/env python3

import os
import stat

from collections.abc import Iterator
from datetime import datetime as dt
from itertools import zip_longest

from .restic_invoker import ResticInvoker


def tree_snapshot(rinv: ResticInvoker, snapshot_id: str) -> Iterator[str]:
    '''
    Builds the CSV tree of the contents of a restic snapshot
    '''
    for entry in rinv.restic_json(['ls', snapshot_id]):
        if not all(k in entry for k in ('type', 'path', 'mtime')):
            continue

        entry['path'] = entry['path'].removeprefix('/')

        if entry['type'] == 'dir':
            yield f'{entry['path']}/;-1;DIR\n'
            continue

        entry['size'] = str(entry['size'])
        entry['mtime'] = str(int(dt.fromisoformat(entry['mtime']).timestamp()))

        yield f'{entry['path']};{entry['size']};{entry['mtime']}\n'


def tree_local(root_path: str, path_prefix: str = '') -> Iterator[str]:
    '''
    Builds the CSV tree of a local directory
    '''
    entries = list(os.scandir(root_path))
    entries.sort(key=lambda x: x.name)

    for entry in entries:
        rel_path = f'{path_prefix}{entry.name}'

        st = entry.stat(follow_symlinks=False)

        if stat.S_ISDIR(st.st_mode):
            yield f'{rel_path}/;-1;DIR\n'
            yield from tree_local(os.path.join(root_path, entry.name),
                                  f'{rel_path}/')
        else:
            yield f'{rel_path};{st.st_size};{int(st.st_mtime)}\n'


def trees_equal(tree_a: Iterator[str], tree_b: Iterator[str]) -> bool:
    '''
    Returns True if two trees are equal, False otherwise
    '''
    return all(a == b for a, b in zip_longest(
        tree_a, tree_b, fillvalue=object()))
