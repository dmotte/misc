# bookmarks-file-gen

This Python script can be used to convert a **JSON** (`*.json`) file into a **NETSCAPE Bookmark** (`*.html`) **file** that can be imported into almost any major browser, such as _Google Chrome_, _Chromium_, _Mozilla Firefox_, etc.

The **accepted JSON input format** is more or less the same format used by the **Google Chrome / Chromium bookmarks file**. If you want to see an example of that file, you can find it at one of the following locations, based on the OS and browser you're using:

| Operating System     | Browser       | Bookmarks file path                                                     |
| -------------------- | ------------- | ----------------------------------------------------------------------- |
| Debian 12 (Bookworm) | Chromium      | `~/.config/chromium/Default/Bookmarks`                                  |
| Debian 12 (Bookworm) | Google Chrome | `~/.config/google-chrome/Default/Bookmarks`                             |
| Windows 10           | Google Chrome | `%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\Bookmarks` |

Or you can take a look at the `input-*.json` files inside this directory.

## Usage

> **Important**: this has been tested with **Python 3.9.1** on **Windows 10**.

```bash
python3 main.py < input.json > output.html
```

Or with _Docker_:

```bash
docker run -i --rm -v "$PWD:/v" -u "$(id -u):$(id -g)" --log-driver=none python:3 python3 /v/main.py < input.json > output.html
```

If you want to run the script without downloading it:

```bash
python3 <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/python-scripts/bookmarks-file-gen/main.py) < input.json > output.html
```

You can also run the script on the content of your _Google Chrome_ / _Chromium_ `Bookmarks` file like this:

```bash
jq 'def simplify: {type, name} + (.children? | if . then {children: map(simplify)} else {} end) + if .url then {url} else {} end; .roots | [.bookmark_bar, .other, .synced] | map(simplify)' ~/.config/chromium/Default/Bookmarks > input-chrome.json
python3 main.py < input-chrome.json > output.html
```
