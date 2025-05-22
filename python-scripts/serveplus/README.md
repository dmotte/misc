# serveplus

This script can be used to **serve a directory via HTTP**, like `python3 -mhttp.server`, but with support for some **additional features**.

## Usage

> **Important**: this has been tested with **Python 3.11.2** on **Debian 12** (_bookworm_).

Examples:

```bash
python3 main.py -b127.0.0.1 -P8080 -dwww /img www-img

SERVEPLUS_DEBUG=true python3 main.py -b127.0.0.1 -dwww -tl16 -c HttpOnly Path=/ -- /img www-img
```
