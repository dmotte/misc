# dwats

**D**irectory-based **Wats**on.

You can use this script to interact with the [Watson](https://github.com/TailorDev/Watson) command line utility, storing all data in a **custom directory** (defaulting to the **working directory**).

- Website: https://tailordev.github.io/Watson/
- GitHub: https://github.com/TailorDev/Watson
- PyPI: https://pypi.org/project/td-watson/

## Usage

> **Important**: this has been tested with **Python 3.12.8** in **Termux** on **Android**.

```bash
python3 -mvenv venv
venv/bin/python3 -mpip install -r requirements.txt
```

Then you can **move to your custom data directory** and invoke the `dwats.sh` script from there, like this:

```bash
dwats=$(realpath dwats.sh)

cd ~/my/custom/dwats/data

"$dwats" start myproj
"$dwats" start myproj +mytag --at 08:00
"$dwats" stop

"$dwats" add myproj -f2020-01-01T08:00 -t2020-01-01T16:00

"$dwats" log -GRac
"$dwats" report -Gac
"$dwats" report -Gdc
```

Alternatively, you can invoke the script from anywhere you want, and specify the Watson data directory via the **`WATSON_DIR` environment variable**:

```bash
WATSON_DIR="$HOME/my/custom/dwats/data" "$dwats" report -Gac
```

Or even create an **`lwats.sh`** (**L**ocal **Wats**on) script that always invokes `dwats.sh` with the same data directory:

```bash
cd ~/my/custom/dwats/data

install -T <(echo -e '#!/bin/bash\ncd "$(dirname "$0")"\nexec bash '"${dwats@Q}"' "$@"') lwats.sh
```

You can also invoke the script **without parameters**, to get a **REPL** prompt:

```bash
"$dwats"
DWATS_DEBUG=true DWATS_STARTUP_REPORT=true "$dwats"
```
