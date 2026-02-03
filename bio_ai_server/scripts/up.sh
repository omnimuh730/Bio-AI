#!/usr/bin/env bash
set -euo pipefail

# Load .env if present
if [ -f .env ]; then
  export $(grep -v '^#' .env | xargs)
fi

ENV=${ENV:-dev}
if [ "$ENV" = "dev" ]; then
  echo "Starting in dev mode (hot-reload)..."
  COMPOSE_PROFILES=dev docker compose up --build
else
  echo "Starting in $ENV mode (detached)..."
  docker compose up --build -d
fi
