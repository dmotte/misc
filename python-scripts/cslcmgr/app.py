#!/usr/bin/env python3

import os
import re
import requests
import sys

from types import SimpleNamespace
from flask import Flask, jsonify, send_file, redirect

GITHUB_API_VERSION = '2022-11-28'

CODESPACE_ID_REGEX = re.compile(r'^[0-9A-Za-z-]+$')


def get_config():
    cfg_lists = {
        k: [] if v is None else v.split(',')
        for k, v in {
            # Custom internal IDs of the codespaces. You can freely choose
            # these, but they have to be unique
            'ids': os.getenv('CSLCMGR_IDS', None),
            # Names of the codespaces
            'names': os.getenv('CSLCMGR_NAMES', None),
            # Tokens for each codespace
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

    return SimpleNamespace(
        # Logging level
        log_level=os.getenv('CSLCMGR_LOG_LEVEL', 'INFO'),
        # Whether or not to enable the Web UI (frontend)
        ui=os.getenv('CSLCMGR_UI', 'false') == 'true',

        codespaces={
            id: SimpleNamespace(
                name=cfg_lists['names'][i],
                token=cfg_lists['tokens'][i],
            )
            for i, id in enumerate(cfg_lists['ids'])
        },
    )


def github_api_call(cfg, app, req_method, url_suffix, id, callback):
    if id not in cfg.codespaces:
        return jsonify({'message': 'Codespace not found'}), 404

    resp = req_method(
        f'https://api.github.com/user/codespaces/{cfg.codespaces[id].name}{url_suffix}',
        headers={
            'Accept': 'application/vnd.github+json',
            'Authorization': f'Bearer {cfg.codespaces[id].token}',
            'X-GitHub-Api-Version': GITHUB_API_VERSION,
        })

    try:
        resp.raise_for_status()
        return callback(resp)
    except requests.exceptions.HTTPError as e:
        app.logger.error('HTTPError during GitHub API request: %s', e)
        return jsonify({'message': 'Server error'}), 500


def create_app():
    cfg = get_config()

    if cfg.ui:
        app = Flask(__name__)

        app.add_url_rule('/', 'root',
                         lambda: redirect('/static/'))
        app.add_url_rule('/static/', 'static_index',
                         lambda: send_file('static/index.html'))
    else:
        app = Flask(__name__, static_folder=None)

    app.logger.setLevel(cfg.log_level)

    app.logger.debug('Configuration: %s', cfg)

    @app.route('/list', endpoint='list')
    def route_list():
        return jsonify({'codespaces': list(cfg.codespaces.keys())}), 200

    @app.route('/state/<id>', endpoint='state')
    def route_state(id):
        return github_api_call(
            cfg, app, requests.get, '', id,
            lambda resp: (jsonify({
                'id': id,
                'state': resp.json()['state'],
            }), 200)
        )

    @app.route('/start/<id>', methods=['POST'], endpoint='start')
    def route_start(id):
        return github_api_call(
            cfg, app, requests.post, '/start', id,
            lambda resp: (jsonify({'message': 'OK'}), 200)
        )

    @app.route('/stop/<id>', methods=['POST'], endpoint='stop')
    def route_stop(id):
        return github_api_call(
            cfg, app, requests.post, '/stop', id,
            lambda resp: (jsonify({'message': 'OK'}), 200)
        )

    return app


def main():
    # Run the Flask local development server if the script is executed directly
    create_app().run()

    return 0


if __name__ == '__main__':
    sys.exit(main())
