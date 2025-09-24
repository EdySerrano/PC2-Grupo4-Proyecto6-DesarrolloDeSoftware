#!/usr/bin/env bash
set -euo pipefail

HOST="${1:-localhost}"
PORT="${2:-8080}"

if nc -z "$HOST" "$PORT"; then
  echo "Puerto $PORT abierto en $HOST"
else
  echo "Puerto $PORT cerrado en $HOST" && exit 1
fi
