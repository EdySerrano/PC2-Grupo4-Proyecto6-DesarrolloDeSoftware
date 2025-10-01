#!/usr/bin/env bats

setup() {
  make clean >/dev/null 2>&1
  cp src/hello_service.sh /tmp/hello_service_backup.sh
  cp /tmp/hello_service_backup.sh src/hello_service.sh
}

teardown() {
  mv /tmp/hello_service_backup.sh src/hello_service.sh
}

@test "Cache incremental detecta cambios y reconstruye" {
  run make build
  [ "$status" -eq 0 ]
  timestamp1=$(stat -c %Y out/build.timestamp 2>/dev/null || echo "0")

  sleep 1

  sed -i '1i# Cambio de test '"$(date +%s)" src/hello_service.sh

  run make build
  [ "$status" -eq 0 ]
  timestamp2=$(stat -c %Y out/build.timestamp 2>/dev/null || echo "0")

  [ "$timestamp2" -gt "$timestamp1" ]
}

@test "Cache incremental usa cache cuando no hay cambios" {
  run make build
  [ "$status" -eq 0 ]
  timestamp1=$(stat -c %Y out/build.timestamp 2>/dev/null || echo "0")

  sleep 1

  run make build
  [ "$status" -eq 0 ]
  timestamp2=$(stat -c %Y out/build.timestamp 2>/dev/null || echo "0")

  [ "$timestamp2" -eq "$timestamp1" ]
}
