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
