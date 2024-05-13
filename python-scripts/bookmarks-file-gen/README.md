# bookmarks-file-gen

This Python script can be used to convert a **JSON** (`*.json`) file (that is more or less compatible with the **Google Chrome / Chromium bookmarks file format**) into a **NETSCAPE Bookmark** (`*.html`) **file** that can be imported into almost any major browser, such as _Google Chrome_, _Chromium_, _Mozilla Firefox_, etc.

Tested with **Python 3.9.1** on _Windows 10_.

## Usage

```bash
python3 main.py < input.json > output.html
```

Or with _Docker_:

```bash
docker run -i --rm -v "$PWD:/v" -u "$(id -u):$(id -g)" python:3 python3 /v/main.py < input.json > output.html
```

If you want to run the script without downloading it:

```bash
python3 <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/python-scripts/bookmarks-file-gen/main.py) < input.json > output.html
```

## Additional notes

The **accepted format** of the input is more or less the same format used by the **Google Chrome / Chromium bookmarks file**. If you want to see an example of that file, you can find it for example at one of the following locations, based on the OS and browser you're using:

| Operating System     | Browser       | Bookmarks file path                                                     |
| -------------------- | ------------- | ----------------------------------------------------------------------- |
| Windows 10           | Google Chrome | `%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\Bookmarks` |
| Debian 12 (Bookworm) | Chromium      | `~/.config/chromium/Default/Bookmarks`                                  |

Or you can take a look at the `input-*.json` files inside this directory.
