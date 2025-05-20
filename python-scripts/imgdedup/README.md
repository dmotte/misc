# imgdedup

Simple Python script to detect **exact and near duplicates** in an image collection, using the **[imagededup](https://idealo.github.io/imagededup/)** library. It is basically just a **wrapper** around such library.

Inspired by PR [idealo/imagededup#47](https://github.com/idealo/imagededup/pull/47) on 2025-05-16.

## Usage

> **Important**: this has been tested with **Python 3.12.4** on **Windows 10**.

Set up a **Python venv** (virtual environment) and install some packages inside it:

```bash
python3 -mvenv venv
venv/bin/python3 -mpip install -r requirements.txt
```

Then you can use the script like this:

```bash
time venv/bin/python3 main.py -mPHash images/
time venv/bin/python3 main.py -mCNN -Ss.8 images/

time venv/bin/python3 main.py -mCNN -Ss-1 images/ output.json
```
