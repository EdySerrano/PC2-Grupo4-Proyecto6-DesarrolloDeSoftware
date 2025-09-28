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
