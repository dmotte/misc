# webauthn-proxy-portmap

This is an example of how to protect services with **WebAuthn** using [**WebAuthn Proxy**](https://github.com/Quiq/webauthn_proxy) and [Traefik](https://traefik.io/), and expose the resulting stack through an **SSH reverse port forwarding tunnel** using [dmotte/docker-portmap-client](https://github.com/dmotte/docker-portmap-client).

Note that this is meant to be run behind an **HTTPS &rarr; HTTP** reverse proxy.

## Setup

### portmap-client

First of all, you need to set up everything for the `portmap-client` docker-compose service. Basically you need to create the missing files into the [`portmap-client`](portmap-client) directory (see instructions in the [official repo](https://github.com/dmotte/docker-portmap-client)) and adjust the `command` field of the `portmap-client` service in the [`docker-compose.yml`](docker-compose.yml) file with the right values.

### webauthn-proxy

Then you need to replace `example.com` with the right target **domain name** inside [`webauthn-proxy-config/config.yml`](webauthn-proxy-config/config.yml).

Create the `webauthn-proxy-config/credentials.yml` file starting from [`webauthn-proxy-config/credentials.sample.yml`](webauthn-proxy-config/credentials.sample.yml):

- It's important to generate and set a **cookie session secret** there, to avoid the following error after _WebAuthn Proxy_ restart:

  ```
  Error getting session from session store during user auth handler: securecookie: the value is not valid
  ```

  You can use the following command to **generate** a cookie session secret:

  ```bash
  docker run -it --rm docker.io/quiq/webauthn_proxy:0.1 -generate-secret
  ```

- As for the `user_credentials` dictionary, you can leave it empty (`{}`) for now, and you'll populate it later, once someone **registers** in your _WebAuthn Proxy_ instance.

### Final steps

Finally, you may want to **further customize** the configuration files, so make sure to take one last look and check that everything is OK. When you are ready:

```bash
docker-compose up -d
```

Then you can visit the **public URL** of your exposed service and check that everything is working fine.
