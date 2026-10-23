#!/usr/bin/env python3

import os
import re

from dataclasses import dataclass

CODESPACE_ID_REGEX = re.compile(r'\A[0-9A-Za-z-]+\Z')


@dataclass(frozen=True)
class Codespace:
    id: str
    '''
    Custom internal ID of the codespace. You can choose this freely, but it
    has to be unique
    '''

    name: str
    'Name of the codespace'

    token: str
    'GitHub PAT (Personal Access Token)'


@dataclass(frozen=True)
class Config:
    log_level: str
    'Logging level'

    ui: bool
    'Enable the Web UI (frontend)'

    codespaces: dict[str, Codespace]


def get_config() -> Config:
    cfg_lists = {
        k: [] if v is None else v.split(',')
        for k, v in {
            'ids': os.getenv('CSLCMGR_IDS', None),
            'names': os.getenv('CSLCMGR_NAMES', None),
            'tokens': os.getenv('CSLCMGR_TOKENS', None),
        }.items()
    }

    len_ids = len(cfg_lists['ids'])
    len_tokens = len(cfg_lists['tokens'])

    if len_ids <= 0:
        raise ValueError('No codespaces defined')
    if len(cfg_lists['names']) != len_ids:
        raise ValueError('IDs and names lists length mismatch')
    if len_tokens <= 0:
        raise ValueError('No tokens defined')
    if len_tokens > len_ids:
        raise ValueError('Too many tokens defined')

    if cfg_lists['tokens'][0] == '':
        raise ValueError('The first token cannot be empty')

    for i, id in enumerate(cfg_lists['ids']):
        if not CODESPACE_ID_REGEX.fullmatch(id):
            raise ValueError('Invalid codespace ID: ' + id)

        if i >= len_tokens:
            cfg_lists['tokens'].append(cfg_lists['tokens'][-1])
        elif cfg_lists['tokens'][i] == '':
            cfg_lists['tokens'][i] = cfg_lists['tokens'][i - 1]

    return Config(
        os.getenv('CSLCMGR_LOG_LEVEL', 'INFO'),
        os.getenv('CSLCMGR_UI', 'false') == 'true',
        {id: Codespace(id, cfg_lists['names'][i], cfg_lists['tokens'][i])
         for i, id in enumerate(cfg_lists['ids'])},
    )
