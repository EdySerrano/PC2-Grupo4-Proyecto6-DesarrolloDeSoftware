#!/usr/bin/env bats

setup() {
  PORT=8080 bash src/hello_service.sh &
  PID=$!
  sleep 2  # esperar a que el servicio inicie completamente
}

teardown() {
  kill "$PID" 2>/dev/null || true
  wait "$PID" 2>/dev/null || true
}
