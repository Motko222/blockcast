#!/bin/bash
set -e

COMPOSE_DIR="$HOME/.blockcast/compose"

echo "=== Pulling latest blockcast image ==="
docker pull blockcast/cdn_gateway_go:stable

echo "=== Stopping and removing old containers ==="
docker stop blockcastd beacond control-proxy 2>/dev/null || true
docker rm blockcastd beacond control-proxy 2>/dev/null || true

echo "=== Verifying compose file location ==="
if [ ! -f "$COMPOSE_DIR/docker-compose.yml" ]; then
  echo "Compose file not found in $COMPOSE_DIR — running migration..."
  docker run -d --name blockcastd \
    -v "$HOME/.blockcast/certs:/var/opt/magma/certs" \
    -v "$HOME/.blockcast/snowflake:/etc/snowflake" \
    -v "$HOME/.blockcast/compose:/etc/magma/compose" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    --restart unless-stopped \
    blockcast/cdn_gateway_go:stable \
    /usr/bin/blockcastd -logtostderr=true -v=0

  echo "Waiting for blockcastd to migrate compose file..."
  for i in $(seq 1 30); do
    [ -f "$COMPOSE_DIR/docker-compose.yml" ] && break
    sleep 2
  done

  docker stop blockcastd && docker rm blockcastd

  if [ ! -f "$COMPOSE_DIR/docker-compose.yml" ]; then
    echo "ERROR: Migration failed — $COMPOSE_DIR/docker-compose.yml still not found"
    exit 1
  fi
  echo "Migration complete."
fi

echo "=== Starting all blockcast services ==="
cd "$COMPOSE_DIR"
docker compose --profile managed up -d

echo "=== Status ==="
docker compose --profile managed ps

echo "=== Waiting 10 seconds for containers to settle ==="
sleep 10

echo "=== blockcastd logs (last 20 lines) ==="
docker logs blockcastd --tail 20 2>&1

echo ""
echo "Done. Check that blockcastd, beacond, and control-proxy are all Up."
