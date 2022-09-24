# zerotier

This directory contains two examples of how to run **Zerotier** in _Docker_:

- :page_facing_up: [`docker-compose-net-service.yml`](docker-compose-net-service.yml): the Zerotier container networking is shared with a **webserver** container
- :page_facing_up: [`docker-compose-net-host.yml`](docker-compose-net-host.yml) the Zerotier container networking is shared with the **host**

Create a copy of one of them and simply name it `docker-compose.yml`.

Then generate a client **identity** (private key) and place it into the `ZEROTIER_IDENTITY_SECRET` environment variable section:

```bash
docker run -it --rm --entrypoint=/usr/sbin/zerotier-idtool zerotier/zerotier generate
```

Write the **network ID** of the network you want to join into the `command` section of the Zerotier service.

Then run:

```bash
docker-compose up -d
```

To check that the Zerotier client has successfully joined the network (and also see its **IP address** for the VPN):

```bash
docker-compose exec zerotier zerotier-cli listnetworks
```
