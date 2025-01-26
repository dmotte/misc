# shellmind

**Shellmind** (**shell** re**mind**er) is a simple Bash script that you can use to **remind yourself** to do something on a **recurring** basis.

## Installation

Here is an example of how to set up the script to remind yourself to **perform system updates every 30 days**:

```bash
install -DT shellmind.sh ~/.shellmind/main.sh

cat << 'EOF' >> ~/.shellmind/message.txt
Kind reminder to keep your system up-to-date! Please run the following commands:
- sudo apt update
- sudo apt upgrade
- touch ~/.shellmind/main.sh (to reschedule this reminder)
EOF

echo "~/.shellmind/main.sh $((30*24*60*60))" >> ~/.bashrc
```
