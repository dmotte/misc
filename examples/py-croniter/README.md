# py-croniter

Simple example of how to use the **croniter** Python library.

- PyPI: https://pypi.org/project/croniter/
- GitHub: https://github.com/kiorky/croniter
- Debian package: https://packages.debian.org/bookworm/python3-croniter

> **Important**: this has been tested on **Debian 12** (_bookworm_) and depends only on **system packages** (from APT). If you want to double-check the versions of the Python libraries used, see [`requirements.txt`](requirements.txt).

To run the example:

```bash
sudo apt-get update && sudo apt-get install -y python3-croniter
python3 main.py
```

Output example:

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
