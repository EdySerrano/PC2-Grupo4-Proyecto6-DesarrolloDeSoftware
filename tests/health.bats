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

@test "Primera request devuelve /salud" {
  # Arrange
  local url="http://localhost:8080"

  # Act
  run curl -s "$url"

  # Assert
  [ "$status" -eq 0 ]
  [[ "$output" =~ "salud OK" ]]
}

@test "Segunda request devuelve /metrics" {
  # Arrange
  local url="http://localhost:8080"
  curl -s "$url" >/dev/null  # primera request para preparar estado
  sleep 2

  # Act
  run curl -s --max-time 5 "$url"

  # Assert
  [ "$status" -eq 0 ]
  [[ "$output" =~ "requests_total" ]]
}


@test "Tercera request devuelve 404" {
  # Arrange
  local url="http://localhost:8080"
  curl -s "$url" >/dev/null  # primera request
  sleep 2
  curl -s --max-time 5 "$url" >/dev/null  # segunda request
  sleep 2

  # Act
  run curl -s --max-time 5 "$url"

  # Assert
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Not Found" ]]
}


@test "Headers HTTP correctos en todas las respuestas" {
  # Arrange
  local url="http://localhost:8080"

  # Act
  run curl -s -I "$url"

  # Assert
  [ "$status" -eq 0 ]
  [[ "$output" =~ "HTTP/1.1 200 OK" ]]
  [[ "$output" =~ "Content-Type: text/plain" ]]
}

