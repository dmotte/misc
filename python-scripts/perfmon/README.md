# perfmon

This is a very simple **perf**ormance **mon**itor script written in _Python_. It monitors only some basic metrics, so it's not suitable for production use.

Tested on **Debian 12** (_bookworm_) with **Python 3** and package versions as in [`requirements.txt`](requirements.txt).

```bash
sudo PERFMON_RESTART=when-changed bash install.sh -rmainuser -- --disk-free-mb=2048

sudo systemctl status perfmon
```

For more details on how to use this script, you can also refer to its help message (`--help`).
