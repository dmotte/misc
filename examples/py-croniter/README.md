# py-croniter

Simple example of how to use the **croniter** Python library.

- GitHub: https://github.com/pallets-eco/croniter
- PyPI: https://pypi.org/project/croniter/

> **Important**: this has been tested with **Python 3.13.5** on **Debian 13** (_trixie_).

```bash
python3 -mvenv venv
venv/bin/python3 -mpip install -r requirements.txt

venv/bin/python3 main.py
```

Example output:

```
Now: 2022-04-20 18:37:21.154167+02:00
Sleeping until: 2022-04-20 18:38:00+02:00
Now: 2022-04-20 18:38:00.009624+02:00

Long task: started
Long task: finished

Now: 2022-04-20 18:38:03.026457+02:00
Sleeping until: 2022-04-20 18:40:00+02:00
Now: 2022-04-20 18:40:00.003208+02:00

Long task: started
Long task: finished

Now: 2022-04-20 18:40:03.006366+02:00
Sleeping until: 2022-04-20 18:42:00+02:00
... and so on ...
```
