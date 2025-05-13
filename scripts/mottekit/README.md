# mottekit

**MotteKit** is a **multi-purpose** "Swiss Army knife" **CLI tool**.

## Standard installation

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/mottekit/install.sh)
```

## Installation with all the repos

```bash
git clone https://github.com/dmotte/misc.git ~/.ghdmotte/misc
bash ~/.ghdmotte/misc/scripts/mottekit/install.sh ~/.ghdmotte/misc
mottekit github-bak-all-repos users/dmotte ~/.ghdmotte
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
