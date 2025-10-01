#!/usr/bin/env bash
set -euo pipefail

# Variables del entorno
PROJECT_NAME="${PROJECT_NAME:-hello-oservabilidad-grupo4}"
RELEASE="${RELEASE:-v1.0.0}"
APP_ENV="${APP_ENV:-dev}"
OUT_DIR="${OUT_DIR:-out}"
DIST_DIR="${DIST_DIR:-dist}"

create_manifest() {
    local manifest_file="$1"
    
    echo "Generando manifest de build..."
    cat > "$manifest_file" << EOF
{
  "project": "$PROJECT_NAME",
  "version": "$RELEASE",
  "build_date": "$(date --iso-8601=seconds)",
  "build_hash": "$(grep BUILD_HASH "$OUT_DIR/build.env" | cut -d'=' -f2)",
  "environment": "$APP_ENV",
  "components": {
    "scripts": $(find src/ -name '*.sh' | wc -l),
    "tests": $(find tests/ -name '*.bats' | wc -l),
    "configs": $(find systemd/ -name '*.service' | wc -l)
  },
  "checksums": {
$(find src/ tests/ systemd/ -type f | while read -r file; do
    echo "    \"$file\": \"$(sha256sum "$file" | cut -d' ' -f1)\","
done | sed '$s/,$//')
  }
}
EOF
}

create_package() {
    echo "Empaquetando $PROJECT_NAME-$RELEASE..."
    tar --mtime='@0' --sort=name --owner=0 --group=0 --numeric-owner \
        --transform "s|^|$PROJECT_NAME-$RELEASE/|" \
        -czf "$DIST_DIR/$PROJECT_NAME-$RELEASE.tar.gz" \
        src/ tests/ systemd/ makefile README.md docs/ "$OUT_DIR/" \
        "$DIST_DIR/$PROJECT_NAME-$RELEASE-manifest.json"
}

generate_checksums() {
    echo "Generando checksums y firmas..."
    (
        cd "$DIST_DIR" || exit 1
        sha256sum "$PROJECT_NAME-$RELEASE.tar.gz" > "$PROJECT_NAME-$RELEASE.sha256"
        sha256sum "$PROJECT_NAME-$RELEASE-manifest.json" >> "$PROJECT_NAME-$RELEASE.sha256"
    )
}

main() {
    echo "=== PACKAGE STAGE ==="
    mkdir -p "$DIST_DIR"
    
    local manifest_file="$DIST_DIR/$PROJECT_NAME-$RELEASE-manifest.json"
    
    create_manifest "$manifest_file"
    create_package
    generate_checksums
    
    echo "Paquete creado: $DIST_DIR/$PROJECT_NAME-$RELEASE.tar.gz"
    ls -lah "$DIST_DIR/"
}

main "$@"