#!/usr/bin/env python3

import requests
import sys

from collections.abc import Callable
from flask import Flask, jsonify, send_file, redirect
from flask.typing import ResponseReturnValue
from requests import Response

from lib import codespaces_api
from lib.config import Config, get_config


def codespaces_api_request(
        app: Flask, cfg: Config, id: str, method: str, url_suffix: str,
        callback: Callable[[Response], ResponseReturnValue],
) -> ResponseReturnValue:
    if id not in cfg.codespaces:
        return jsonify({'message': 'Codespace not found'}), 404

    try:
        resp = codespaces_api.request(method, cfg.codespaces[id].name,
                                      cfg.codespaces[id].token, url_suffix)
        return callback(resp)
    except requests.exceptions.HTTPError as e:
        app.logger.error('HTTPError during GitHub API request: %s', e)
        return jsonify({'message': 'Server error'}), 500


def create_app() -> Flask:
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
    def route_list() -> ResponseReturnValue:
        return jsonify({'codespaces': list(cfg.codespaces.keys())}), 200

    @app.route('/state/<id>', endpoint='state')
    def route_state(id: str) -> ResponseReturnValue:
        return codespaces_api_request(
            app, cfg, id, 'get', '',
            lambda resp: (jsonify({
                'id': id,
                'state': resp.json()['state'],
            }), 200)
        )

    @app.route('/start/<id>', methods=['POST'], endpoint='start')
    def route_start(id: str) -> ResponseReturnValue:
        return codespaces_api_request(
            app, cfg, id, 'post', '/start',
            lambda resp: (jsonify({'message': 'OK'}), 200)
        )

    @app.route('/stop/<id>', methods=['POST'], endpoint='stop')
    def route_stop(id: str) -> ResponseReturnValue:
        return codespaces_api_request(
            app, cfg, id, 'post', '/stop',
            lambda resp: (jsonify({'message': 'OK'}), 200)
        )

    return app


def main() -> int:
    # Run the Flask local development server if the script is executed directly
    create_app().run()

    return 0


if __name__ == '__main__':
    sys.exit(main())
