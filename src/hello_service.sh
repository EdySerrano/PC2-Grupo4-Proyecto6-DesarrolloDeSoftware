#!/usr/bin/env bash
set -euo pipefail

PORT="${PORT:-8080}"
APP_ENV="${APP_ENV:-dev}"

trap 'echo "Servidor detenido"; exit 0' SIGINT SIGTERM
