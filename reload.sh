#!/bin/sh
# Apply config changes without restarting Caddy. A config with errors is rejected and the
# running config stays in place, so a typo can't take the other sites down.
set -e
cd "$(dirname "$0")"
git pull --ff-only 2>/dev/null || true
docker exec edge-caddy caddy validate --config /etc/caddy/Caddyfile --adapter caddyfile
docker exec edge-caddy caddy reload --config /etc/caddy/Caddyfile --adapter caddyfile
echo "Caddy reloaded."
