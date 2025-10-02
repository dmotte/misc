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

    def resolve_ctl_path(self) -> str:
        '''
        Resolves self.ctl_path to full path
        '''
        ssh_gen_cfg = subprocess.check_output(
            self.ssh_args + [f'-GS{self.ctl_path}'], text=True)

        for line in ssh_gen_cfg.splitlines():
            match1 = re.fullmatch(r'^ControlPath\s+(.+)$', line, re.IGNORECASE)
            if match1 is not None:
                return match1.group(1)

        raise ValueError('ControlPath not found in generated SSH config')

    def start(self) -> tuple[bool, str]:
        '''
        Starts the control master process, but only if self.ctl_path doesn't
        exist yet. Returns a tuple consisting of:

        - A bool indicating if self.ctl_path already exists
        - A string containing the resolved path of self.ctl_path
        '''
        ctl_path_full = self.resolve_ctl_path()

        if os.path.exists(ctl_path_full):
            return True, ctl_path_full

        subprocess.check_call(self.ssh_args + [f'-NfMS{self.ctl_path}'])

        return False, ctl_path_full

    @contextmanager
    def setup(self) -> Iterator[str]:
        '''
        Sets up SSH multiplexing, but only if self.ctl_path doesn't exist yet
        '''
        ctl_path_exists, ctl_path_full = self.start()

        if ctl_path_exists:
            yield ctl_path_full
            return

        try:
            yield ctl_path_full
        finally:
            subprocess.check_call(
                self.ssh_args + [f'-S{self.ctl_path}', '-Oexit'])
