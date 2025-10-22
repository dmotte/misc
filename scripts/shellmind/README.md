# shellmind

**Shellmind** (**shell** re**mind**er) is a simple Bash script that you can use to **remind yourself** to do something on a **recurring** basis.

## Installation

Here is an example of how to set up the script to remind yourself to **perform system updates every 30 days**:

```bash
install -DTv <(curl -fsSL https://raw.githubusercontent.com/dmotte/misc/main/scripts/shellmind/main.sh) ~/.shellmind/main.sh

cat << 'EOF' >> ~/.shellmind/message.txt
Kind reminder to keep your system up-to-date! Please do the following:
- Run "sudo apt update && sudo apt upgrade" (or do the equivalent via the system UI)
- Run "touch ~/.shellmind/main.sh" (to reschedule this reminder)
EOF

echo "~/.shellmind/main.sh $((30*24*60*60))" >> ~/.bashrc
```
