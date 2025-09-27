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
  echo "Servidor detenido. Total de peticiones: $REQUEST_COUNT"
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
  remainder=$((REQUEST_COUNT % 3))
  
  case $remainder in
    1)
      # Simular /salud
      response="HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\nsalud OK - $APP_ENV"
      log "GET /salud - 200 OK"
      ;;
    2)
      # Simular /metrics con herramientas Unix
      latency=$(($(date +%s%3N) - start_time))
      threshold_status=$(echo "$latency $LATENCY_THRESHOLD" | awk '{print ($1 > $2) ? "HIGH" : "OK"}')
      metrics=$(printf "requests_total %d\nuptime_seconds %d\nlast_request_ms %d\nlatency_status %s" \
        "$REQUEST_COUNT" "$uptime" "$latency" "$threshold_status")
      response="HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\n$metrics"
      log "GET /metrics - 200 OK (latency: ${latency}ms, status: $threshold_status)"
      ;;
    0)
      # Simular 404
      response="HTTP/1.1 404 Not Found\r\nContent-Type: text/plain\r\nConnection: close\r\n\r\nNot Found"
      log "GET /unknown - 404 Not Found"
      ;;
  esac
  
  echo -e "$response" | nc -l -p "$PORT" -q 1
done