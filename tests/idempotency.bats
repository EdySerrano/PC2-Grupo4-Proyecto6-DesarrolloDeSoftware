#!/usr/bin/env bats

setup() {
  make clean >/dev/null 2>&1
}

@test "Build es idempotente y determinista" {
  run make build
  [ "$status" -eq 0 ]
  hash1=$(find out/ -type f -exec sha256sum {} \; | sort | sha256sum)

  run make build
  [ "$status" -eq 0 ]
  hash2=$(find out/ -type f -exec sha256sum {} \; | sort | sha256sum)

  run make build
  [ "$status" -eq 0 ]
  hash3=$(find out/ -type f -exec sha256sum {} \; | sort | sha256sum)

  [ "$hash1" = "$hash2" ]
  [ "$hash2" = "$hash3" ]
}
