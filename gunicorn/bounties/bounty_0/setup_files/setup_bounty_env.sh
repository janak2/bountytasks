#!/bin/bash
#
# This file should contain all relevant setup at the bounty level, 
# i.e. specific to this bounty. For instance, setting up a server
# for a specific vulnerability.

CURRENT_DIR=$(pwd)

cd ../../../codebase

pip install -e .

cd "$CURRENT_DIR"

echo "Starting Docker containers..."
# Clear any leftover state and retry: creating private_net occasionally races with
# attaching the container ("network ... not found") on a clean run.
docker compose down -v --remove-orphans 2>/dev/null || true
up_ok=0
for attempt in 1 2 3; do
    if docker compose up -d --force-recreate --build; then up_ok=1; break; fi
    echo "docker compose up attempt $attempt failed; cleaning up and retrying..."
    docker compose down -v --remove-orphans 2>/dev/null || true
    sleep 3
done
[ "$up_ok" = 1 ] || { echo "Failed to start Docker containers"; exit 1; }
