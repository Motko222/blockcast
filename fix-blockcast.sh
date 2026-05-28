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
  echo "ERROR: $COMPOSE_DIR/docker-compose.yml not found"
  echo "Run 'docker exec blockcastd blockcastd init' after starting blockcastd manually first"
  exit 1
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
