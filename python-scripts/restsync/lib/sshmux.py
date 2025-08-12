#!/usr/bin/env python3

import os
import re
import subprocess

from collections.abc import Iterator
from contextlib import contextmanager


@contextmanager
def ssh_mux(ssh_args: list[str],
            ctl_path: str = '~/.ssh/cm-%C') -> Iterator[str]:
    '''
    Sets up SSH multiplexing, but only if ctl_path doesn't exist yet
    '''
    ssh_gen_cfg = subprocess.check_output(ssh_args + [f'-GS{ctl_path}'],
                                          text=True)

    ctl_path_full = ''
    for line in ssh_gen_cfg.splitlines():
        match1 = re.fullmatch(r'^ControlPath\s+(.+)$', line, re.IGNORECASE)
        if match1 is not None:
            ctl_path_full = match1.group(1)
            break
    if ctl_path_full == '':
        raise ValueError('ControlPath not found in the generated SSH config')

    if os.path.exists(ctl_path_full):
        yield ctl_path_full
        return

    subprocess.check_call(ssh_args + [f'-NfMS{ctl_path}'])
    try:
        yield ctl_path_full
    finally:
        subprocess.check_call(ssh_args + [f'-S{ctl_path}', '-Oexit'])
