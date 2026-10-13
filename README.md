# edge-caddy

The server's single Caddy proxy (`edge-caddy`). It owns ports 80/443 and HTTPS for every app:
Doclin, Doclin staging, CA Platform, SchoolMS and standalone websites such as dratiyasana.com.

```
config/Caddyfile        global options + internal on-demand TLS check, imports everything below
config/sites/*.caddy    one file per app or website
reload.sh               pull, validate and apply changes with no restart
```

## Add a new site or domain

1. Run the site's container on the `doclin-net` network:
   ```yaml
   networks:
     default:
       name: doclin-net
       external: true
   ```
2. Copy `config/sites/_template.caddy.example` to `config/sites/<name>.caddy` and fill it in.
3. Commit and push, then on the server:
   ```
   cd /path/to/edge-caddy && ./reload.sh
   ```
4. Point the domain's DNS A record at the server. Caddy gets the certificate on its own.

No app is redeployed, nothing restarts, and other sites stay up. If the new file has an error,
`reload.sh` stops and the running config is left untouched.

To remove a site, delete its file and run `./reload.sh`.

## Logs

```
docker logs edge-caddy --tail 100
```

## One-time move out of the Doclin project

Caddy used to be the `caddy` service inside Doclin's `docker-compose.yml`. This project takes over
the same container name, network and certificate volumes, so no certificates are re-issued.
Expect about 10–20 seconds of downtime for all sites during step 4.

1. Clone this repository onto the server.
2. Check the certificate volume names:
   ```
   docker volume ls | grep caddy
   ```
   The defaults are `doclin_caddy-data` and `doclin_caddy-config`. If yours differ, put them in a
   `.env` file next to `docker-compose.yml`:
   ```
   CADDY_DATA_VOLUME=<name>_caddy-data
   CADDY_CONFIG_VOLUME=<name>_caddy-config
   ```
3. In the Doclin folder, pull the version of `docker-compose.yml` without the `caddy` service:
   `git pull origin main`. Don't run `docker compose down -v` there — it would delete the
   app's volumes.
4. Swap the containers:
   ```
   docker stop edge-caddy && docker rm edge-caddy
   cd /path/to/edge-caddy && docker compose up -d
   docker logs edge-caddy --tail 50
   ```
5. Open a couple of sites to confirm they load over HTTPS.
