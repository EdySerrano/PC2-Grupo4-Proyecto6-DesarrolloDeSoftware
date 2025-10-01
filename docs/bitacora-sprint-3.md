# Bitácora Sprint 3 - Integración, Empaquetado y Trazabilidad

## Objetivos del Sprint 3
- Completar integracion con caché incremental en Makefile
- Implementar empaquetado reproducible en dist/
- Validar idempotencia y trazabilidad (logs, bitacoras)
- Aplicar 12-Factor V (Build/Release/Run)
- Preparar documentacion YBIYRI y artefactos para demo

## Implementaciones Sprint 3

### Caché Incremental en Makefile
- **Build timestamps**: '$(OUT_DIR)/build.timestamp' para evitar rebuilds
- **Detección de cambios**: Solo rebuild si archivos fuente cambiaron
- **Analisis incremental**: Reglas patron con verificacion de timestamps
- **Hash de build**: Identificador unico para cada build

```bash
# Caché inteligente
$(OUT_DIR)/build.timestamp: src/*.sh makefile | $(OUT_DIR)
    # Solo ejecuta si hay cambios en fuentes
    @touch $@
```

### Empaquetado Reproducible
- **Artefactos deterministas**: tar con flags reproducibles
- **Manifest JSON**: Metadatos completos del build
- **Checksums**: SHA256 de todos los componentes
- **Versionado**: Release tags con informacion completa

```bash
# Empaquetado reproducible
tar --mtime='@0' --sort=name --owner=0 --group=0 --numeric-owner \
    --transform 's|^|$(PROJECT_NAME)-$(RELEASE)/|' \
    -czf $(DIST_DIR)/$(PROJECT_NAME)-$(RELEASE).tar.gz
```

### 12-Factor V (Build/Release/Run)
- **Build Stage**: Compilacion y verificacion (make build)
- **Release Stage**: Empaquetado con metadatos (make release)
- **Run Stage**: Ejecucion con configuracion runtime (make run)
- **Separación clara**: Cada etapa con responsabilidades especificas

### Validación de Idempotencia
- **Test automatizado**: make test (hay un carpeta especifica del test en tests/)
- **Verificación de caché**: Ejecuciones repetidas usan caché
- **Artefactos idénticos**: Builds deterministas
- **Métricas de tiempo**: Comparacion de duracion de builds

### Trazabilidad Completa
- **Bitacoras por sprint**: Documentacion detallada de cada fase
- **Logs estructurados**: Timestamps ISO-8601 consistentes
- **Manifests**: Metadatos JSON con checksums y dependencias
- **Releases versionados**: Artefactos trazables por version

## Evidencias Técnicas Sprint 3

### Manifest de Build (JSON)
```json
{
  "project": "hello-observabilidad-grupo4",
  "version": "v1.0.0",
  "build_date": "2025-09-30T...",
  "build_hash": "sha256:...",
  "environment": "dev",
  "components": {
    "scripts": 4,
    "tests": 1,
    "configs": 1
  },
  "checksums": {
    "src/hello_service.sh": "sha256:...",
    ...
  }
}
```

### Test de Idempotencia
```bash
$ make test-idempotent
=== TEST DE IDEMPOTENCIA ===
Primera ejecución (build completo)...
Segunda ejecución (debe usar caché)...
✓ IDEMPOTENCIA VALIDADA: Ejecuciones 2 y 3 usaron caché
✓ ARTEFACTOS IDÉNTICOS: Los builds son deterministas
```

### Separacion Build/Release/Run
```bash
# Build Stage
make build    # Genera artefactos en out/

# Release Stage  
make release  # Crea paquete versionado en dist/

# Run Stage
make run      # Ejecuta con configuración runtime
```

## Targets de Makefile Completos

| Target | Propósito | Status |
|--------|-----------|---------|
| tools | Verificacion de dependencias | OK |
| build | Build con caché incremental | OK |
| test | Suite de tests Bats | OK |
| run | Ejecución del servicio | OK |
| release | Etapa de release (12-Factor V) | OK |
| pack | Empaquetado reproducible | OK |
| analyze-logs | Analisis de logs | OK |
| clean | Limpieza de artefactos | OK |
| install-service | Instalacion systemd | OK |
| start/stop/status-service | Gestion del servicio | OK |
| help | Documentacion de uso | OK |

## Metricas Finales del Proyecto

| Sprint | Objetivos | Completado |
|--------|-----------|------------|
| Sprint 1 | Base + Config + Tests | SI |
| Sprint 2 | Bash Robusto + systemd | SI | 
| Sprint 3 | Integración + Empaquetado | SI |
| *Total* | *Proyecto Completo* | SI |

### Componentes Implementados
- **4 scripts** principales con Bash robusto
- **6 tests**Bats con metodologIa AAA/RGR
- **12 targets** de Makefile con caché incremental
- **3 etapas** 12-Factor V (Build/Release/Run)
- **Empaquetado** reproducible con checksums
- **5 funciones** de analisis de logs
- **4 metricas** de observabilidad
- **3 bitacoras** completas por sprint

## Video Sprint-3:
* **Link**:**[Sprint-3]().**

## Conclusión Sprint 3
**COMPLETADO** - Proyecto listo para demostracion end-to-end con integracion completa, empaquetado reproducible, validacion de idempotencia y trazabilidad completa.