#!/usr/bin/env bash
set -euo pipefail

LOGFILE="${1:-/dev/stdin}"
OUTPUT_DIR="${OUTPUT_DIR:-out}"

log() {
    echo "$(date --iso-8601=seconds) [ANALYZER] $1" >&2
}

cleanup() {
    log "Analisis completado"
    exit 0
}
trap cleanup SIGINT SIGTERM

mkdir -p "$OUTPUT_DIR"

log "Iniciando el analisis de logs del servicio Hello"

# Analizar latencias usando herramientas Unix
analyze_latencies() {
    log "Analizando latencias"
    
    grep "latency:" "$LOGFILE" 2>/dev/null | \
        sed 's/.*latency: \([0-9]*\)ms.*/\1/' | \
        awk 'BEGIN {sum=0; count=0; max=0; min=999999} 
             {
                sum+=$1; 
                count++; 
                if($1>max) max=$1; 
                if($1<min) min=$1
             } 
             END {
                if(count>0) {
                    avg=sum/count;
                    print "Latencia promedio:", avg "ms";
                    print "Latencia maxima:", max "ms"; 
                    print "Latencia minima:", min "ms";
                    print "Total requests:", count
                } else {
                    print "No se encontraron datos de latencia"
                }
             }' | tee "$OUTPUT_DIR/latency_analysis.txt"
}


# Analisis de codigos de respuesta de HTTP
analyze_response_codes() {
    log "Analizando los codoigos de respuesta HTTP"
    
    # Extraer codigos HTTP, contar y ordenar
    grep -E "(200 OK|404 Not Found)" "$LOGFILE" 2>/dev/null | \
        sed 's/.*- \([0-9]*\) \([A-Za-z ]*\).*/\1 \2/' | \
        cut -d' ' -f1 | \
        sort | \
        uniq -c | \
        sort -nr | \
        awk '{print "Codigo " $2 ": " $1 " requests"}' | \
        tee "$OUTPUT_DIR/response_codes.txt"
}


# Analisis temporal de actividad
analyze_temporal_activity() {
    log "Analizando patrones temporales..."
    
    # Extraer horas de los logs y agrupar por hora
    grep "\[INFO\]" "$LOGFILE" 2>/dev/null | \
        sed 's/^\([0-9-]*T[0-9][0-9]\):[0-9][0-9]:[0-9][0-9].*/\1/' | \
        cut -d'T' -f2 | \
        sort | \
        uniq -c | \
        awk '{print "Hora " $2 ":XX - " $1 " eventos"}' | \
        tee "$OUTPUT_DIR/hourly_activity.txt"
}


# Analisis de endpoints mas utilizados
analyze_endpoints() {
    log "Analizando endpoints..."
    
    # Extraer tipos de endpoint de los logs
    grep -E "(GET /(salud|metrics|unknown))" "$LOGFILE" 2>/dev/null | \
        sed 's/.*GET \/\([a-z]*\) .*/\1/' | \
        tr '[:lower:]' '[:upper:]' | \
        sort | \
        uniq -c | \
        sort -nr | \
        awk '{
            if ($2 == "SALUD") endpoint = "/salud";
            else if ($2 == "METRICS") endpoint = "/metrics"; 
            else if ($2 == "UNKNOWN") endpoint = "404_endpoints";
            else endpoint = $2;
            print endpoint ": " $1 " requests"
        }' | \
        tee "$OUTPUT_DIR/endpoint_usage.txt"
}

# Generar reporte consolidado
generate_summary_report() {
    log "Generando reporte consolidado"
    
    {
        echo "# Reporte de Analisis del Servicio Hello"
        echo "Generado: $(date --iso-8601=seconds)"
        echo ""
        
        echo "## Analisis de Latencias"
        cat "$OUTPUT_DIR/latency_analysis.txt" 2>/dev/null || echo "No hay datos de latencia"
        echo ""
        
        echo "## Codigos de Respuesta HTTP"  
        cat "$OUTPUT_DIR/response_codes.txt" 2>/dev/null || echo "No hay datos de respuesta"
        echo ""
        
        echo "## Actividad por Hora"
        cat "$OUTPUT_DIR/hourly_activity.txt" 2>/dev/null || echo "No hay datos temporales"
        echo ""
        
        echo "## Uso de Endpoints"
        cat "$OUTPUT_DIR/endpoint_usage.txt" 2>/dev/null || echo "No hay datos de endpoints"
        echo ""
        
        echo "## Resumen de Archivos Generados"
        find "$OUTPUT_DIR" -name "*.txt" | sort | while read -r file; do
            lines=$(wc -l < "$file")
            size=$(du -h "$file" | cut -f1)
            echo "- $(basename "$file"): $lines lineas, $size"
        done
        
    } | tee "$OUTPUT_DIR/summary_report.md"
}


# Funcion principal
main() {
    if [[ "$LOGFILE" != "/dev/stdin" && ! -f "$LOGFILE" ]]; then
        log "ERROR: Archivo de log no encontrado: $LOGFILE"
        exit 1
    fi
    
    log "Procesando logs desde: $LOGFILE"
    log "Directorio de salida: $OUTPUT_DIR"
    
    analyze_latencies
    analyze_response_codes  
    analyze_temporal_activity
    analyze_endpoints
    generate_summary_report
    
    log "Analisis completado. Archivos generados en $OUTPUT_DIR/"
    ls -la "$OUTPUT_DIR"/*.txt "$OUTPUT_DIR"/*.md 2>/dev/null || true
}

# Ejecutar analisis si el script se llama directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
