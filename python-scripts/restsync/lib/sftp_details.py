#!/usr/bin/env python3

from dataclasses import dataclass
from urllib.parse import urlparse


@dataclass
class SFTPDetails:
    '''
    SFTP connection details
    '''

    user: str
    'Username'
    psw: str
    'Password'
    host: str
    'Hostname'
    port: int
    'Port number'
    path: str
    'Path'

    def _get_args(self, upper_p: bool = False) -> list[str]:
        '''
        Returns the arguments that can be used with the ssh or sftp command to
        connect to the host
        '''
        return ([f'-P{self.port}' if upper_p
                 else f'-p{self.port}'] if self.port != 22 else []
                ) + [(f'{self.user}@' if self.user != '' else '') + self.host]

    @property
    def sftp_args(self) -> list[str]:
        '''
        Returns the arguments that can be used with the sftp command to
        connect to the host
        '''
        return self._get_args(True)

    @property
    def ssh_args(self) -> list[str]:
        '''
        Returns the arguments that can be used with the ssh command to
        connect to the host
        '''
        return self._get_args(False)

    def parse(url: str, allow_psw: bool = False) -> 'SFTPDetails':
        '''
        Parses an SFTP URL
        '''
        parsed = urlparse(url)

        if parsed.scheme != 'sftp':
            raise ValueError(f'Unexpected URL scheme: {parsed.scheme}. Only '
                             'sftp is allowed')

        if not allow_psw and parsed.password is not None:
            raise ValueError('Password in SFTP URL not allowed')

        return SFTPDetails(
            user='' if parsed.username is None else parsed.username,
            psw='' if parsed.password is None else parsed.password,
            host='' if parsed.hostname is None else parsed.hostname,
            port=22 if parsed.port is None else parsed.port,
            path=parsed.path.removeprefix('/'),
        )
