#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-8080}"
APP_ENV="${APP_ENV:-dev}"

trap 'echo "Servidor detenido"; exit 0' SIGINT SIGTERM

# Servidor HTTP simple usando netcat
while true; do
  { echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\nsalud OK - $APP_ENV"; } \
    | nc -l -p "$PORT" -q 1
done