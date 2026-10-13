# edge-caddy

The server's single Caddy proxy (`edge-caddy`). It owns ports 80/443 and HTTPS for every app:
Doclin, Doclin staging, CA Platform, SchoolMS and standalone websites such as dratiyasana.com.

```
docker-compose.yml      deploy this from its raw GitHub URL
config/Caddyfile        global options + internal on-demand TLS check, imports everything below
config/sites/*.caddy    one file per app or website
```

On deploy, the `edge-caddy-config` container copies `config/` from this repository into a volume
and exits; `edge-caddy` then serves it and watches it for changes.

The repository must be public (it holds no secrets), or set `CONFIG_REPO` to
`https://<user>:<token>@github.com/shahid25june/Caddy-Server.git` with a read-only token.

## Add a new site or domain

1. Run the site's container on the `doclin-net` network:
   ```yaml
   networks:
     default:
       name: doclin-net
       external: true
   ```
2. Copy `config/sites/_template.caddy.example` to `config/sites/<name>.caddy`, fill it in, push.
3. Apply it — either redeploy this stack from the compose URL, or on the server run:
   ```
   docker start -a edge-caddy-config
   ```
   Caddy picks up the change within a second, without restarting. If the new file has an
   error, Caddy logs it and keeps running the previous config.
4. Point the domain's DNS A record at the server. Caddy gets the certificate on its own.

To remove a site, delete its file, push, and repeat step 3.

## Logs

```
docker logs edge-caddy --tail 100
```

## First deploy (moving Caddy out of the Doclin project)

Only one container can use ports 80/443 and the name `edge-caddy`, so the old one must go first.
All sites are down for the minute or so between steps 2 and 3.

1. Make this repository public (or set `CONFIG_REPO` as above). Check that
   `https://raw.githubusercontent.com/shahid25june/Caddy-Server/main/docker-compose.yml` opens in a
   private browser window.
2. Remove the old Caddy on the server:
   ```
   docker stop edge-caddy && docker rm edge-caddy
   ```
3. Deploy this stack from the compose URL above.
4. Check it:
   ```
   docker ps --filter name=edge-caddy -a
   docker logs edge-caddy-config
   docker logs edge-caddy --tail 50
   ```

Certificates are issued fresh into the new volume on first use, so each site's first visit after
the move can take a few extra seconds.
