# bash-source-from-web

This is an example of a **Bash script** that **sources** another one **from the web**, possibly making some modifications to it before running.

The **checksum verification** part is an additional step needed to ensure that the script is the one we expect.

```bash
#!/bin/bash

set -e

script_url='https://.../myscript.sh'
script_content="$(curl -fsSL "$script_url")"

if [ "$(echo "$script_content" | sha256sum | cut -d' ' -f1)" \
    != '1a2b3c4d1a2b3c4d1a2b3c4d1a2b3c4d1a2b3c4d1a2b3c4d1a2b3c4d1a2b3c4d' ]
    then
    echo "Checksum verification failed for remote script $script_url" >&2
    exit 1
fi

script_content="$(echo "$script_content" | sed 's/my-old-text/my-new-text/')"

. <(echo "$script_content")
```
