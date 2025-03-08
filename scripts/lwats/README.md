# lwats

**L**ocal **Wats**on.

You can use this script to interact with the [Watson](https://github.com/TailorDev/Watson) command line utility, saving all the data into the directory where the script is located.

- Website: https://tailordev.github.io/Watson/
- GitHub: https://github.com/TailorDev/Watson
- PyPI: https://pypi.org/project/td-watson/

## Usage

> **Important**: this has been tested with **Python 3.12.8** in **Termux** on **Android**.

```bash
python3 -mvenv venv
venv/bin/python3 -mpip install -r requirements.txt
```

Then you can invoke the `lwats.sh` script like this:

```bash
./lwats.sh start myproj
./lwats.sh start myproj +mytag --at 08:00
./lwats.sh stop

./lwats.sh add myproj -f2020-01-01T08:00 -t2020-01-01T16:00

./lwats.sh log -GRac
./lwats.sh report -Gac
./lwats.sh report -Gdc
```

Or **without parameters**, to get a **REPL** prompt:

```bash
./lwats.sh
LWATS_STARTUP_REPORT=true ./lwats.sh
```
