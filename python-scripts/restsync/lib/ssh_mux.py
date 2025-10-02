#!/usr/bin/env python3

import os
import re
import subprocess

from collections.abc import Iterator
from contextlib import contextmanager
from dataclasses import dataclass


@dataclass
class SSHMux:
    '''
    SSH multiplexing manager
    '''

    ssh_args: list[str]
    'SSH arguments'
    ctl_path: str = '~/.ssh/cm-%C'
    'Control path'

    @contextmanager
    def setup(self) -> Iterator[str]:
        '''
        Sets up SSH multiplexing, but only if self.ctl_path doesn't exist yet
        '''
        ssh_gen_cfg = subprocess.check_output(
            self.ssh_args + [f'-GS{self.ctl_path}'], text=True)

        ctl_path_full = ''
        for line in ssh_gen_cfg.splitlines():
            match1 = re.fullmatch(r'^ControlPath\s+(.+)$', line, re.IGNORECASE)
            if match1 is not None:
                ctl_path_full = match1.group(1)
                break
        if ctl_path_full == '':
            raise ValueError('ControlPath not found in generated SSH config')

        if os.path.exists(ctl_path_full):
            yield ctl_path_full
            return

        subprocess.check_call(self.ssh_args + [f'-NfMS{self.ctl_path}'])
        try:
            yield ctl_path_full
        finally:
            subprocess.check_call(
                self.ssh_args + [f'-S{self.ctl_path}', '-Oexit'])
