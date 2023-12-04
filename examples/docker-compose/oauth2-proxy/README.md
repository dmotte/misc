# oauth2-proxy

This is an example of how to run **OAuth2 Proxy** with the **Google Auth Provider**.

The first thing you need is a **cookie secret** for the `OAUTH2_PROXY_COOKIE_SECRET` variable. You can generate it with:

```bash
dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64 | tr -d -- '\n' | tr -- '+/' '-_'; echo
```

> **Note**: command copied from https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/overview/#generating-a-cookie-secret

Then you need the right values for the `OAUTH2_PROXY_CLIENT_*` variables. See the official guide:

https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/oauth_provider/#google-auth-provider

> **Note**: even if your Google Cloud App **publishing status** is set to `Testing`, you'll be able to use OAuth2 to authenticate all Google users

Finally:

```bash
docker-compose up -d
```

Then you can visit http://localhost:4180/

If you want to configure _OAuth2 Proxy_ as a forwardauth middleware instead:

https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/overview#configuring-for-use-with-the-traefik-v2-forwardauth-middleware

## Links

- https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/oauth_provider/#google-auth-provider
- https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/overview/
