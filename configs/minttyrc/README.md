# minttyrc

Custom `.minttyrc` file for _Git Bash_.

You just have to put this file at `~/.minttyrc` to get a nice _Git Bash_ terminal with nice settings.

> :warning: **Warning**: please make a backup of your existing `.minttyrc` before, if you don't know what you're doing.

In alternative, you can use the following _Bash_ command:

```bash
curl -o ~/.minttyrc https://raw.githubusercontent.com/dmotte/utils/main/configs/minttyrc/.minttyrc
```

## Git Bash installation advice

My favourite way of installing _Git Bash_ on _Windows 10_ is using the **Chocolatey** package manager:

1. [Install _Chocolatey_](https://chocolatey.org/install);
2. Open an elevated shell prompt;
3. Type the following command:
   ```cmd
   choco install -y gsudo git
   ```
   > **Note:** the `gsudo` package is useful whenever you want to execute privileged commands from a normal _Git Bash_ shell (but it actually works also in other shells) (e.g. `sudo choco install -y otherpackage`)
