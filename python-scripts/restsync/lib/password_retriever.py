#!/usr/bin/env python3

import os
import subprocess

from getpass import getpass


class PasswordRetriever:
    '''
    This class can be used to retrieve a password, either by using special
    environment variables or by asking the user
    '''

    def __init__(self, env_var_name_psw: str = '', env_var_name_cmd: str = '',
                 env_var_name_file: str = '', ask_user: bool = True) -> None:
        self.env_var_name_psw: str = env_var_name_psw
        'Name of the environment variable that contains the password itself'
        self.env_var_name_cmd: str = env_var_name_cmd
        'Name of the environment variable that contains a command that' \
            'can be run to retrieve the password'
        self.env_var_name_file: str = env_var_name_file
        'Name of the environment variable that contains the path to the file' \
            'containing the password'
        self.ask_user: bool = ask_user
        'Whether we can ask the user interactively for the password'

        self._psw: str | None = None
        'The retrieved password, or None if it hasn\'t been retrieved yet'

    def __repr__(self) -> str:
        return f'{type(self).__name__}({', '.join((
            'env_var_name_psw=' + repr(self.env_var_name_psw),
            'env_var_name_cmd=' + repr(self.env_var_name_cmd),
            'env_var_name_file=' + repr(self.env_var_name_file),
            'ask_user=' + repr(self.ask_user),
        ))})'

    def reset(self, psw: str | None = None) -> None:
        '''
        Resets the password to a specific value
        '''
        self._psw = psw

    def get(self) -> str | None:
        '''
        Retrieves and returns the password, or None if it couldn't be retrieved
        '''
        if self._psw is not None:
            return self._psw

        if self.env_var_name_psw != '':
            psw = os.getenv(self.env_var_name_psw, '')
            if psw != '':
                del os.environ[self.env_var_name_psw]
                self._psw = psw
                return self._psw

        if self.env_var_name_cmd != '':
            cmd = os.getenv(self.env_var_name_cmd, '')
            if cmd != '':
                self._psw = subprocess.check_output(cmd, text=True)
                return self._psw

        if self.env_var_name_file != '':
            filename = os.getenv(self.env_var_name_file, '')
            if filename != '':
                with open(filename, 'r') as f:
                    self._psw = f.read()
                return self._psw

        if self.ask_user:
            self._psw = getpass('Restic password: ')
            return self._psw

        return None
