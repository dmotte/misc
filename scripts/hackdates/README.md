# hackdates

**Hackdates** (**Hack**y up**dates**) is a simple Bash-based tool that you can use to automate _hacky_, _non-standardized_ **updates**, or just check if **new versions** are available (without performing an actual update).

For example, some tools (such as `kubectl`) need to be installed as a standalone binary. In such cases, the right way to perform an update is to download the new version of the tool to the same location, overwriting the existing binary locally. To automate such process, you can write a simple Bash script for each tool like that, and then use _Hackdates_ to execute all of them at once.

## Installation

Here is an example of how to set this up, with some predefined **jobs**:

```bash
install -DT <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/hackdates/main.sh) ~/.hackdates/main.sh
mkdir ~/.hackdates/jobs

for i in kubectl helm; do
    echo "Installing Hackdates job $i"
    install -T <(curl -fsSL "https://raw.githubusercontent.com/dmotte/misc/main/scripts/hackdates/jobs/$i.sh") "$HOME/.hackdates/jobs/$i.sh"
done
```

## Usage

You can leverage **[Shellmind](../shellmind)** to periodically ask the user to run this command:

```bash
time ~/.hackdates/main.sh; echo $?
```
