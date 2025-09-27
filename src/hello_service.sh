#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-8080}"
APP_ENV="${APP_ENV:-dev}"
REQUEST_COUNT=0
START_TIME=$(date +%s)
LATENCY_THRESHOLD=${LATENCY_THRESHOLD:-1000} # En ms

log() {
  # Log estructurado con timestamp y nivel
  echo "$(date --iso-8601=seconds) [INFO] $1" >&2
}

cleanup() {
  echo "Servidor detenido. Total de peticiones: $REQUEST_COUNT" >&2
  exit 0
}
trap cleanup SIGINT SIGTERM

log "Servidor iniciado en puerto $PORT"

# Servidor HTTP simple, con metricas de tiempo
while true; do
  REQUEST_COUNT=$((REQUEST_COUNT + 1))
  start_time=$(date +%s%3N)
  uptime=$(($(date +%s) - START_TIME))
  
  # Simular parseo de endpoint basado en contador (para demo)
  remainder=$((REQUEST_COUNT % 2))
  
  case $remainder in
    1)
      # Endpoint /salud
      response="HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\nsalud OK - $APP_ENV"
      log "GET /salud - 200 OK"
      ;;
    0)
      # Simular 404 para rutas no encontradas
      response="HTTP/1.1 404 Not Found\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\nNot Found"
      log "GET /unknown - 404 Not Found"
      ;;
  esac
  
  echo -e "$response" | nc -l -p "$PORT" -q 1
done