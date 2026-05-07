# mottekit

**MotteKit** is a **multi-purpose** "Swiss Army knife" **CLI tool**.

## Installation

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/mottekit/install.sh)
```

Or with custom directory:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/mottekit/install.sh) ~/mydir
```

## Additional requirements

In order to make the **Python scripts** work, you also need to install the following packages:

```bash
sudo apt-get update && sudo apt-get install -y python3-pip python3-venv
```

## Usage

```bash
mottekit help
```

To update:

```bash
mottekit update
```

## Advanced usage

Example of how to create a **wrapper** for a Python-based CLI tool (e.g. `yq` in this case):

```bash
mkdir -v ~/apps

python3 -mvenv ~/apps/venv-yq
~/apps/venv-yq/bin/python3 -mpip install yq

mkdir -v ~/.ghdmotte/misc/scripts/mottekit/overrides
echo -e '#!/bin/bash\nexec ~/apps/venv-yq/bin/python3 -myq "$@"' > ~/.ghdmotte/misc/scripts/mottekit/overrides/yq.sh
```

Then you can invoke it like this:

```bash
mottekit yq --help
```
