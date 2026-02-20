# perfmon

This is a very simple **perf**ormance **mon**itor script written in _Python_. It monitors only some basic metrics, so it's not suitable for production use.

## Usage

> **Important**: this has been tested on **Debian 13** (_trixie_) and depends only on **system packages** (from APT). See [`install.sh`](install.sh) for further details. If you want to double-check the versions of the Python libraries used, see [`requirements.txt`](requirements.txt).

```bash
sudo PERFMON_RESTART=when-changed bash install.sh -rmainuser -- --disk-free-mb=2048

sudo systemctl status perfmon
```

For more details on how to use this script, you can also refer to its help message (`--help`).
