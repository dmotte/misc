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

        - A bool indicating if a new control master process was started
        - A string containing the resolved path of self.ctl_path
        '''
        ctl_path_full = self.resolve_ctl_path()

        if os.path.exists(ctl_path_full):
            return False, ctl_path_full

        subprocess.check_call(self.ssh_args + [f'-NfMS{self.ctl_path}'])
        return True, ctl_path_full

    def stop(self) -> tuple[bool, str]:
        '''
        Stops the control master process, but only if self.ctl_path exists.
        Returns a tuple consisting of:

        - A bool indicating if the control master process was stopped
        - A string containing the resolved path of self.ctl_path
        '''
        ctl_path_full = self.resolve_ctl_path()

        if not os.path.exists(ctl_path_full):
            return False, ctl_path_full

        subprocess.check_call(self.ssh_args + [f'-S{self.ctl_path}', '-Oexit'])
        return True, ctl_path_full

    @contextmanager
    def setup(self) -> Iterator[tuple[bool, str]]:
        '''
        Sets up SSH multiplexing using a context manager, but it actually
        starts and stops the control master process only if self.ctl_path
        doesn't exist yet. Returns a tuple consisting of:

        - A bool indicating if a new control master process was actually
          started (and will be stopped at the end)
        - A string containing the resolved path of self.ctl_path
        '''
        started, ctl_path_full = self.start()

        if not started:
            yield started, ctl_path_full
            return

        try:
            yield started, ctl_path_full
        finally:
            self.stop()
