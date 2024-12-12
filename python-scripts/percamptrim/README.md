# percamptrim

**Perc**entile-based audio **amp**lifier and **trim**mer.

- Using the "**amplifier**" algorithm ([`compute-amp.py`](compute-amp.py)), you can **normalize** the audio track based on an **allowed clipping** samples percentage
- Using the "**trimmer**" algorithm ([`compute-trim.py`](compute-trim.py)), you can **cut** the **start** and **end** of the audio track based on thresholds for **minimum allowed signal levels**

## Usage

> **Important**: this has been tested with **Python 3.12.4** and **ffmpeg 4.3.1** on **Windows 10**.

Set up a **Python venv** (virtual environment) and install some packages inside it:

```bash
python3 -mvenv venv
venv/bin/python3 -mpip install -r requirements.txt
```

Then you can **process an audio file** using the [`process.sh`](process.sh) Bash script:

```bash
./process.sh -c {input,output}.mp3
```
