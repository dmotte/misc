# cslcmgr

**C**ode**S**pace **L**ife**C**ycle **M**ana**g**e**r**: a **Web API server** (with optional **Web UI frontend**) that can be used to **start and stop GitHub Codespaces**.

This is meant to be run locally on your PC, or behind a reverse proxy with **authentication**.

## Usage

> **Important**: this has been tested with **Python 3.13.5** on **Debian 13** (_trixie_).

First of all you need to generate one or more **GitHub PATs** (_Personal Access Tokens_) to be able to control your Codespaces using the GitHub API. The tokens must have the following **permissions**:

- "**Codespaces**" repository permissions (**read**)
- "**Codespaces lifecycle admin**" repository permissions (**write**)

> **Note**: for more information on why these permissions are needed, see https://docs.github.com/en/rest/codespaces/codespaces?apiVersion=2022-11-28

Set up a **Python venv** (virtual environment) and install some packages inside it:

```bash
python3 -mvenv venv
venv/bin/python3 -mpip install -r requirements.txt
```

Then set the necessary configuration **environment variables**. Example:

```bash
export CSLCMGR_UI=true \
    CSLCMGR_IDS=mycs01,mycs02 \
    CSLCMGR_NAMES=happy-ananas-a1b2c3d4,yellow-wrench-a1b2c3d4 \
    CSLCMGR_TOKENS=github_pat_XXXXX,github_pat_XXXXX
```

> **Note**: for more details about the supported environment variables, see the `get_config` function [in the code](app.py).

Then you can run the app either in a **development** or **production** configuration.

**Development**:

```bash
CSLCMGR_LOG_LEVEL=DEBUG venv/bin/python3 app.py
```

**Production**:

```bash
venv/bin/python3 -mgunicorn --access-logfile=- -w4 -b127.0.0.1:8000 'app:create_app()'
```

> **Note**: for more information about running a _Flask_ application with _Gunicorn_, see https://flask.palletsprojects.com/en/3.0.x/deploying/gunicorn/
