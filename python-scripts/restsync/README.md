# restsync

This script can be used to **synchronize a folder** between multiple hosts using a **[restic](https://restic.net/)** repo over **SFTP** as intermediate storage.

:warning: **Caution**: this project is **highly experimental**. **Not suitable for production use**.

:warning: **Warning**: this project does NOT implement any "_local locking_" system. Therefore, if you want to be sure that no applications are accessing your local data directory while synchronizing it (pulling or pushing), you should rely on some sort of **external locking** mechanism. An example could be mounting/unmounting your data directory with `rclone mount`, or serving it via `rclone serve` and stopping the server while synchronizing.

## Usage

> **Important**: this has been tested with **restic v0.18.0** and **Python 3.12.4** on **Windows 10**.

For instructions on how to use this script, you can refer to the help message:

```bash
python3 main.py --help
```
