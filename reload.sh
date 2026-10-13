#!/bin/sh
# Pull the latest config from GitHub into the running Caddy. Caddy applies it within a second
# (--watch); a config with errors is rejected and the running one stays in place.
set -e
docker start -a edge-caddy-config
sleep 2
docker logs edge-caddy --since 5s 2>&1 | grep -iE 'error|load' || echo "Caddy config applied."
