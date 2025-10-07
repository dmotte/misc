# restsync

This project can be used to **synchronize a folder** between multiple hosts using a **[restic](https://restic.net/)** repo over **SFTP** as intermediate storage.

:warning: **Caution**: this project is **highly experimental**. **Not suitable for production use**.

:warning: **Warning**: this project does NOT implement any "_local locking_" system. Therefore, if you want to be sure that no applications are accessing your local data directory while synchronizing it (pulling or pushing), you should rely on some sort of **external locking** mechanism, such as mounting/unmounting your data directory with `rclone mount`, or serving it via `rclone serve` and stopping the server while synchronizing.

## Usage

> **Important**: this has been tested with **restic v0.18.0** and **Python 3.12.4** on **Windows 10**.

For instructions on how to use the [`main.py`](main.py) script, you can refer to its help message:

```bash
python3 main.py --help
```

In addition to that, there is an example [`plus.sh`](plus.sh) script, which is an **experiment** that extends (wraps) _Restsync_ and adds **additional features**, such as using a directory for the metadata, support for running in _Git Bash_, and a very simple _GPG_ integration. You can read it to get inspiration and develop your own customized solution.
