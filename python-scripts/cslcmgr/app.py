#!/usr/bin/env python3

import sys

from flask import Flask, jsonify, send_file, redirect
from flask.typing import ResponseReturnValue
from werkzeug.exceptions import HTTPException, InternalServerError

from lib import codespaces_api
from lib.config import get_config


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

    @app.errorhandler(Exception)
    def handle_exception(e: Exception) -> ResponseReturnValue:
        if isinstance(e, HTTPException):
            return e
        app.logger.error('Unhandled Exception: %s', e)
        return InternalServerError(original_exception=e)

    @app.route('/list', endpoint='list')
    def route_list() -> ResponseReturnValue:
        return jsonify({'codespaces': list(cfg.codespaces.keys())}), 200

    @app.route('/state/<id>', endpoint='state')
    def route_state(id: str) -> ResponseReturnValue:
        try:
            codespace = cfg.codespaces[id]
        except KeyError:
            return jsonify({'message': 'Codespace not found'}), 404

        resp = codespaces_api.request(
            'get', codespace.name, codespace.token, '')

        return jsonify({'id': id, 'state': resp.json()['state']}), 200

    @app.route('/start/<id>', methods=['POST'], endpoint='start')
    def route_start(id: str) -> ResponseReturnValue:
        try:
            codespace = cfg.codespaces[id]
        except KeyError:
            return jsonify({'message': 'Codespace not found'}), 404

        codespaces_api.request(
            'post', codespace.name, codespace.token, '/start')

        return jsonify({'message': 'OK'}), 200

    @app.route('/stop/<id>', methods=['POST'], endpoint='stop')
    def route_stop(id: str) -> ResponseReturnValue:
        try:
            codespace = cfg.codespaces[id]
        except KeyError:
            return jsonify({'message': 'Codespace not found'}), 404

        codespaces_api.request(
            'post', codespace.name, codespace.token, '/stop')

        return jsonify({'message': 'OK'}), 200

    return app


def main() -> int:
    # Run the Flask local development server if the script is executed directly
    create_app().run()

    return 0


if __name__ == '__main__':
    sys.exit(main())
