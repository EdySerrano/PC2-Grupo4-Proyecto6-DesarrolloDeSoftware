#!/usr/bin/env bats

setup() {
  PORT=8080 APP_ENV=test bash src/hello_service.sh &
  PID=$!
  sleep 1
}

teardown() {
  kill "$PID"
}

@test "GET /salud devuelve 200 y contiene 'salud OK'" {
  run curl -s -o /dev/null -w "%{http_code}" http://localhost:8080
  [ "$status" -eq 0 ]
  [ "$output" -eq 200 ]
}
