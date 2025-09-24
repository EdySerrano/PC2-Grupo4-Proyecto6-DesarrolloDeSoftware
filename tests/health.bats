#!/usr/bin/env bats

setup() {
  PORT=8080 APP_ENV=test bash src/hello_service.sh &
  PID=$!
  sleep 1
}

teardown() {
  kill "$PID"
}