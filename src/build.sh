#!/usr/bin/env bash
set -euo pipefail

OUT_DIR="${OUT_DIR:-out}"
RELEASE="${RELEASE:-v1.0.0}"
PROJECT_NAME="${PROJECT_NAME:-hello-oservabilidad-grupo4}"

echo "=== BUILD STAGE ==="
echo "Detectando cambios en el código fuente..."
mkdir -p "$OUT_DIR"

echo "Verificando sintaxis de scripts..."
for script in src/*.sh; do
    echo "Verificando $script..."
    bash -n "$script" || exit 1
done

echo "Generando metadatos de build..."
{
    echo "BUILD_DATE=$(date --iso-8601=seconds)"
    echo "RELEASE=$RELEASE"
    echo "PROJECT_NAME=$PROJECT_NAME"
    echo "BUILD_HASH=$(find src/ -type f -name '*.sh' -exec sha256sum {} \; | sort | sha256sum | cut -d' ' -f1)"
} > "$OUT_DIR/build.env"

echo "Build completado: $(date --iso-8601=seconds)"