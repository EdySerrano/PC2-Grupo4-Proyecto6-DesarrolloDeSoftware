# Bitácora Sprint 1 - Base de Código y Configuración

## Objetivos del Sprint 1
- Establecer base de código (12-Factor I) 
- Configuración por variables de entorno (12-Factor III)
- Implementar chequeos iniciales (HTTP /salud)
- Makefile con targets básicos (tools, build, test, run)
- Una prueba Bats representativa (caso rojo -> verde)

## Implementaciones Completadas

### 12-Factor I - Base de Código
- Repositorio Git estructurado con separacion de responsabilidades
- Directorio src/ para scripts principales
- Directorio tests/ para pruebas automatizadas
- Directorio systemd/ para configuracion de servicio
- Directorio docs/ para documentacion

### 12-Factor III - Configuración
- Variables de entorno en hello_service.sh:
  - PORT="${PORT:-8080}" - Puerto de escucha configurable
  - APP_ENV="${APP_ENV:-dev}" - Entorno de ejecucion
  - LATENCY_THRESHOLD=${LATENCY_THRESHOLD:-1000} - Umbral de latencia
- Configuracion propagada desde Makefile y systemd

### Chequeos Iniciales
- *HTTP /salud*: Endpoint implementado con respuesta "salud OK - $APP_ENV"

### Makefile Básico
- make tools - Verificacion de dependencias (nc, curl, dig, bats, ss, journalctl)
- make build - Generacion de artefactos
- make test - Ejecucion de suite de tests Bats
- make run - Ejecucion del servicio con variables configurables

### Pruebas Bats
- 1 tests implementados siguiendo metodología AAA (Arrange-Act-Assert)
- Setup/teardown para manejo de estado del servicio
- Validaciones de endpoints /salud.


## Evidencias Técnicas

### Logs Estructurados
bash

- 2025-09-27T10:15:30+00:00 [INFO] Servidor iniciado en puerto 8080
- 2025-09-27T10:16:45+00:00 [INFO] GET /salud - 200 OK


### Configuración de Variables
```bash
# En hello_service.sh
PORT="${PORT:-8080}"
APP_ENV="${APP_ENV:-dev}" 
LATENCY_THRESHOLD=${LATENCY_THRESHOLD:-1000}
```
# En Makefile
PORT ?= 8080
APP_ENV ?= dev


### Tests Ejecutados
```bash
$ make test
✓ Primera request devuelve /salud
```


## Métricas del Sprint

| Métrica | Valor |
|---------|-------|
| Scripts implementados | 2 |
| Tests automatizados | 2 |
| Targets de Makefile | 4 básicos |
| Variables de entorno | 3 |
| Cobertura de endpoints | 100% (/salud) |

## Conclusión Sprint 1
**COMPLETADO** - Todos los objetivos del Sprint 1 fueron implementados exitosamente.
La base de código está establecida siguiendo 12-Factor, con configuración por variables de entorno y chequeos iniciales funcionando correctamente.