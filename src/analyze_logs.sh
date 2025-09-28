#!/usr/bin/env bash
set -euo pipefail

LOGFILE="${1:-/dev/stdin}"
OUTPUT_DIR="${OUTPUT_DIR:-out}"

log() {
    echo "$(date --iso-8601=seconds) [ANALYZER] $1" >&2
}

cleanup() {
    log "Analisis completado"
    exit 0
}
trap cleanup SIGINT SIGTERM

mkdir -p "$OUTPUT_DIR"

log "Iniciando el analisis de logs del servicio Hello"
