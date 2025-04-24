# podman-gui-app

This guide explains how to run a **GUI application** in a **Podman** container.

> **Important**: this has been tested on **Debian 12** (_bookworm_) with **GNOME 43.9**.

Start a _Podman_ **container** with the proper "X11 forwarding" options, using the following command:

```bash
podman run -it --rm -eDISPLAY -eXAUTHORITY -v/tmp/.X11-unix:/tmp/.X11-unix:ro -v"$XAUTHORITY:$XAUTHORITY:ro" docker.io/library/debian:12
```

Inside the container, you can **install** and **run** your GUI application. Example:

```bash
apt update && apt install -y x11-apps
xclock
```

## Links

- [How to run a GUI app in a podman container - #3 by beroset - Fedora Discussion](https://discussion.fedoraproject.org/t/how-to-run-a-gui-app-in-a-podman-container/72970)
