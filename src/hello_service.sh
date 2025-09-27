#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-8080}"
APP_ENV="${APP_ENV:-dev}"
REQUEST_COUNT=0
START_TIME=$(date +%s)
LATENCY_THRESHOLD=${LATENCY_THRESHOLD:-1000} # En ms

cleanup() {
  echo "Servidor detenido. Total de peticiones: $REQUEST_COUNT" >&2
  exit 0
}
trap cleanup SIGINT SIGTERM

echo "Servidor iniciado en puerto $PORT" >&2

# Servidor HTTP simple, estructura basica
while true; do
  REQUEST_COUNT=$((REQUEST_COUNT + 1))
  
  # Respuesta basica temporal
  response="HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\nHello World"
  echo -e "$response" | nc -l -p "$PORT" -q 1
done