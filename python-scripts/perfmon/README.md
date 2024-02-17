# perfmon

This is a very simple **perf**ormance **mon**itor script written in _Python_. It monitors only some basic metrics, so it's not suitable for production use.

```bash
sudo PERFMON_RESTART='true' bash install.sh -rmainuser -- --disk-free-mb=2048

sudo systemctl status perfmon
```

:information_source: For more details on how to use this script, you can also refer to its help message (`--help`).
