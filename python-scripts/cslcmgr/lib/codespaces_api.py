#!/usr/bin/env python3

import requests

GITHUB_API_VERSION = '2026-03-10'


def request(method: str, codespace_name: str, github_token: str,
            url_suffix: str) -> requests.Response:
    'Performs a request to the GitHub Codespaces API'

    resp = requests.request(
        method,
        f'https://api.github.com/user/codespaces/{codespace_name}{url_suffix}',
        headers={
            'Accept': 'application/vnd.github+json',
            'Authorization': f'Bearer {github_token}',
            'X-GitHub-Api-Version': GITHUB_API_VERSION,
        })

    resp.raise_for_status()

    return resp
