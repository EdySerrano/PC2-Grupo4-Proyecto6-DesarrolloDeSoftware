# Bitácora Sprint 2 - Bash Robusto y Observabilidad

## Objetivos del Sprint 2
- Implementar Bash robusto (manejo de errores, trap, pipelines Unix)
- Agregar systemd/journalctl para gestion de servicios
- Implementar señales y metricas con thresholds simples
- Ampliar suite Bats

## Implementaciones Completadas

### Bash Robusto
- **Manejo de errores**: set -euo pipefail en todos los scripts
  - set -e: Exit en caso de error
  - set -u: Error en variables no definidas
  - set -o pipefail: Error en pipelines fallidos
- **Trap para limpieza**: trap cleanup SIGINT SIGTERM
- **Pipelines Unix complejos**: En analyze_logs.sh con multiples filtros y agregaciones

### systemd/journalctl Integration
- Servicio systemd completo: hello.service
- Configuracion de logging: StandardOutput=journal, StandardError=journal
- Targets de Makefile para gestion de servicios:
  - install-service - Instalacion automatica
  - start-service / stop-service - Control de estado
  - status-service - Monitoreo con journalctl
- Verificacion de journalctl en make tools

### Señales y Manejo Graceful
- **SIGINT/SIGTERM**: Capturados en hello_service.sh y analyze_logs.sh
- **Cleanup funcion**: Limpieza de estado y logs de finalizacion
- **Logs estructurados**: Timestamps ISO-8601 con niveles

### Métricas y Thresholds
- **Métricas implementadas**:
  - requests_total - Contador de peticiones
  - uptime_seconds - Tiempo de funcionamiento
  - last_request_ms - Latencia de ultima peticion
  - latency_status - Estado del threshold (OK/HIGH)
- **Threshold configurable**: LATENCY_THRESHOLD=${LATENCY_THRESHOLD:-1000}
- **Analisis de logs avanzado**: 5 funciones de analisis con herramientas Unix

### Suite Bats Ampliada
- **Casos positivos**: 
  - /salud retorna 200 OK
  - /metrics retorna métricas válidas
  - Headers HTTP correctos
- **Casos negativos**:
  - 404 Not Found para endpoints desconocidos
  - Validación de timeout con --max-time 5
- **Validaciones robustas**:
  - Latency status (OK/HIGH)
  - Uptime creciente
  - Formato de metricas

## Evidencias Técnicas

### Manejo de Errores y Trap
```bash
#!/usr/bin/env bash
set -euo pipefail

cleanup() {
    echo "Servidor detenido. Total de peticiones: $REQUEST_COUNT"
    exit 0
}
trap cleanup SIGINT SIGTERM
```

### Pipeline Unix Complejo (analyze_logs.sh)
```bash
grep "latency:" "$LOGFILE" 2>/dev/null | \
    sed 's/.*latency: \([0-9]*\)ms.*/\1/' | \
    awk 'BEGIN {sum=0; count=0; max=0; min=999999} 
         {sum+=$1; count++; if($1>max) max=$1; if($1<min) min=$1} 
         END {if(count>0) print "Latencia promedio:", sum/count "ms"}'
```

### Configuración systemd
```
ini
[Unit]
Description=Servicio Hello para observabilidad minima
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/bash src/hello_service.sh
Restart=on-failure
Environment=PORT=8080 APP_ENV=prod LATENCY_THRESHOLD=1000
StandardOutput=journal
StandardError=journal
```

### Métricas con Threshold
```bash
latency=$(($(date +%s%3N) - start_time))
threshold_status=$(echo "$latency $LATENCY_THRESHOLD" | awk '{print ($1 > $2) ? "HIGH" : "OK"}')
metrics=$(printf "requests_total %d\nuptime_seconds %d\nlast_request_ms %d\nlatency_status %s" \
  "$REQUEST_COUNT" "$uptime" "$latency" "$threshold_status")
```

## Análisis de Logs Implementado

### Funciones de Análisis
1. *analyze_latencies()* - Estadísticas de latencia
2. *analyze_response_codes()* - Distribucion de codigos HTTP
3. *analyze_temporal_activity()* - Patrones temporales por hora
4. *analyze_endpoints()* - Uso de endpoints más frecuentes
5. *generate_summary_report()* - Reporte consolidado

### Herramientas Unix Utilizadas
- grep + regex para filtrado
- sed para extracción de patrones
- awk para cálculos estadísticos
- sort + uniq -c para agregaciones
- cut + tr para transformaciones

## Métricas del Sprint 2

| Métrica | Valor |
|---------|-------|
| Scripts con set -euo pipefail | 4/4 |
| Scripts con trap | 2 |
| Funciones de analisis | 5 |
| Targets systemd | 5 |
| Tests con casos negativos | 3 |

## Video Sprint-2:
* **Link**:**[Sprint-2](https://www.youtube.com/watch?v=P5ZuKGg8qxc).**

## Conclusion Sprint 2
**COMPLETADO** - Implementacion robusta de Bash defensivo, integracion completa con systemd/journalctl, metricas avanzadas con thresholds y analisis de logs sofisticado usando herramientas Unix.