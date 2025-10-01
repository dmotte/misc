#!/usr/bin/env python3

import json
import os
import shlex
import subprocess

from collections.abc import Callable, Iterator
from contextlib import ExitStack
from typing import Any

from .sftp_details import SFTPDetails


class ResticInvoker:
    '''
    This class can be used to interact with a remote restic repo over SFTP.

    It supports locking/unlocking by renaming the remote repo folder
    '''

    def __init__(self, sftp_details: SFTPDetails,
                 restic_psw: str | Callable[[], str] = '',
                 prio_restic_psw_env_vars: bool = True,
                 ssh_cmd: str = 'ssh', sftp_cmd: str = 'sftp',
                 restic_cmd: str = 'restic') -> None:
        self.sftp_details: SFTPDetails = sftp_details
        'SFTP details'

        if self.sftp_details.psw != '':
            raise ValueError('Please do NOT put any password in the SFTP '
                             'details')

        if prio_restic_psw_env_vars and any((
            os.getenv('RESTIC_PASSWORD', '') != '',
            os.getenv('RESTIC_PASSWORD_COMMAND', '') != '',
            os.getenv('RESTIC_PASSWORD_FILE', '') != '',
        )):
            # Prioritize the restic password environment variables if set
            restic_psw = ''
        self.restic_psw: str | Callable[[], str] = restic_psw
        'Password of the restic repo, or function that returns it'

        self.ssh_cmd: str = ssh_cmd
        'SSH command'
        self.sftp_cmd: str = sftp_cmd
        'SFTP command'

        self.ssh_cmd_full: str = f'{ssh_cmd} {
            shlex.join(self.sftp_details.ssh_args)} -s sftp'
        'Full SSH command'
        self.sftp_cmd_full: str = f'{sftp_cmd} -b- {
            shlex.join(self.sftp_details.sftp_args)}'
        'Full SFTP command'

        self.restic_cmd = restic_cmd
        'Restic command'

        self.locked = False
        'Indicates whether the restic repo is locked'

    def __repr__(self) -> str:
        return f'{type(self).__name__}({', '.join((
            'sftp_details=' + repr(self.sftp_details),
            'ssh_cmd=' + repr(self.ssh_cmd),
            'sftp_cmd=' + repr(self.sftp_cmd),
            'restic_cmd=' + repr(self.restic_cmd),
            'locked=' + repr(self.locked),
        ))})'

    def lock(self) -> None:
        '''
        Locks the restic repo by adding the "-locked" suffix to the
        remote folder's name
        '''
        if self.locked:
            raise RuntimeError('The restic repo appears to be already locked')
        self.locked = True

        sftp_path = self.sftp_details.path

        subprocess.run(
            shlex.split(self.sftp_cmd_full),
            input=f'rename {sftp_path} {sftp_path}-locked',
            stdout=subprocess.DEVNULL, text=True, check=True)

    def unlock(self) -> None:
        '''
        Unlocks the restic repo by removing the "-locked" suffix from the
        remote folder's name
        '''
        if not self.locked:
            raise RuntimeError('The restic repo appears to be already unlocked')
        self.locked = False

        sftp_path = self.sftp_details.path

        subprocess.run(
            shlex.split(self.sftp_cmd_full),
            input=f'rename {sftp_path}-locked {sftp_path}',
            stdout=subprocess.DEVNULL, text=True, check=True)

    def _restic_popen(self, args: list[str] | str, stack: ExitStack,
                      add_env: dict[str, str] | None = None,
                      add_popen_kwargs: dict | None = None,
                      json_mode: bool = False) -> subprocess.Popen:
        '''
        Runs a restic command as a subprocess and returns the related
        subprocess.Popen instance.
        Any file descriptors passed to the subprocess will be closed at the end
        of the "with" statement of the stack ExitStack.
        If json_mode is True, it adds "--json" to the global restic flags
        '''
        args = shlex.split(args) if isinstance(args, str) \
            else [str(x) for x in args]
        if add_env is None:
            add_env = {}
        if add_popen_kwargs is None:
            add_popen_kwargs = {}

        add_global_args = []

        psw = self.restic_psw if isinstance(self.restic_psw, str) \
            else self.restic_psw()

        if psw != '':
            if os.name == 'nt':
                # Unfortunately we have to use the RESTIC_PASSWORD env
                # var in this case, as the file-descriptor-based approach
                # doesn't work on Windows
                add_env['RESTIC_PASSWORD'] = psw
            else:
                fds_psw = os.pipe()

                # To have fds_psw[0] automatically closed at the end of
                # the "with" statement of the stack ExitStack
                stack.enter_context(os.fdopen(fds_psw[0], 'r'))

                with os.fdopen(fds_psw[1], 'w') as fw:
                    fw.write(psw)

                add_popen_kwargs['pass_fds'] = (fds_psw[0],)
                add_global_args.append(f'-p/dev/fd/{fds_psw[0]}')

        if json_mode:
            add_global_args.append('--json')
            add_popen_kwargs |= {'stdout': subprocess.PIPE,
                                 'text': True, 'bufsize': 1}

        return subprocess.Popen(
            ['restic', f'-rsftp://-@-:0/{self.sftp_details.path}' +
                ('-locked' if self.locked else ''),
                f'-osftp.command={self.ssh_cmd_full}'] +
            add_global_args + args,
            env=None if len(add_env) == 0 else os.environ.copy() | add_env,
            **add_popen_kwargs)

    def restic(self, args: list[str] | str,
               add_env: dict[str, str] | None = None,
               add_popen_kwargs: dict | None = None) -> None:
        '''
        Runs a restic command
        '''
        with ExitStack() as stack:
            proc = self._restic_popen(args, stack,
                                      add_env, add_popen_kwargs, False)

            returncode = proc.wait()
            if returncode != 0:
                raise subprocess.CalledProcessError(returncode, proc.args)

    def restic_json(self, args: list[str] | str,
                    add_env: dict[str, str] | None = None,
                    add_popen_kwargs: dict | None = None) -> Iterator[Any]:
        '''
        Runs a restic command adding "--json" to the global flags, and returns
        the parsed JSON output lines
        '''
        with ExitStack() as stack:
            proc = self._restic_popen(args, stack,
                                      add_env, add_popen_kwargs, True)

            try:
                for line in proc.stdout:
                    yield json.loads(line)
            finally:
                # We need to consume the remaining lines if the generator is
                # closed early by the caller or due to an exception
                for _ in proc.stdout:
                    pass

                returncode = proc.wait()
                if returncode != 0:
                    raise subprocess.CalledProcessError(returncode, proc.args)

    def get_latest_snapshot_id(self) -> str:
        '''
        Gets the ID of the latest restic snapshot
        '''
        data = list(self.restic_json('snapshots latest'))

        return data[0][0]['id']
