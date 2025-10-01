# PC2-Grupo4-Proyecto6-DesarrolloDeSoftware

## Equipo 4:

| Miembro del Equipo | Codigo |
| :----------------- | :-------------------- |
| **Choquecambi Germain** | `20211360A` |
| **Serrano Edy** | `20211229B` | 
| **Hinojosa Frank** | `20210345I`  | 

## Descripción

**Observabilidad mínima de un servicio "hello"** - Nuestro objetivo es construir un servicio HTTP minimalista con capacidades completas de observabilidad utilizando Makefile como herramienta principal de orquestacion. Integramos conceptos de redes, análisis de logs con herramientas Unix, principios 12-Factor App (I, III, V), y metodología YBIYRI (You Build It, You Run It), garantizando que el mismo equipo sea responsable tanto del desarrollo como de la operacion del servicio en produccion.

### Estructura del proyecto
```
PC2-Grupo4-Proyecto6-DesarrolloDeSoftware/
├── docs/                           # Documentación y bitácoras por sprint
│   ├── README.md                   # Documentación técnica inicial
│   ├── bitacora-sprint-1.md        # Base de código y configuración
│   ├── bitacora-sprint-2.md        # Bash robusto y systemd
│   └── bitacora-sprint-3.md        # Integración y empaquetado
│
├── src/                            # Scripts en Bash con manejo robusto
│   ├── hello_service.sh            # Servicio HTTP principal (/salud, /metrics)
│   ├── analyze_logs.sh             # Análisis de logs con herramientas Unix
│   ├── build.sh                    # Construye el servicio
│   ├── package.sh                  # Empaqueta
│   └── sample.log                  
│
├── systemd/                        # Integración systemd completa
│   └── hello.service               # Unidad de servicio con journalctl
│
├── tests/                          # Pruebas automatizadas AAA/RGR
│   ├── idempotency.bats
│   ├── incremental_cache.bats
│   └── health.bats                 
│
├── out/                            # Artefactos intermedios y releases
│   ├── build.env                   # Metadatos de build
│   ├── build.timestamp             # Control de caché incremental
│   └── releases/                   # Releases versionados (12-Factor V)
│
├── dist/                           # Empaquetado reproducible
│   ├── *.tar.gz                    # Paquetes deterministas
│   ├── *.sha256                    # Checksums de verificación
│   └── *-manifest.json             # Metadatos completos
│
├── makefile                        # Flujo completo con 12 targets
└── .gitignore                      # Exclusión de temporales
```

## Variables de entorno (contrato)
Las siguientes variables controlan el comportamiento del sistema siguiendo 12-Factor III.

|Variable	|Descripción	|Efecto observable |
|-----------|---------------|------------------|
| `PORT`	|Puerto HTTP de escucha	| El servicio se inicia en ese puerto (default: 8080).|
| `APP_ENV`	|Entorno de ejecucion	|Se refleja en respuesta /salud y logs (dev/prod).|
| `LATENCY_THRESHOLD`	|Umbral de latencia en ms | Matricas muestran status OK/HIGH segun threshold.|
| `RELEASE`	|Version del release	|Nombrado de paquetes en dist (hello-*-$(RELEASE).tar.gz).|
| `MESSAGE`	|Mensaje personalizado	|Banner en instalacian de servicio systemd.|
| `OUTPUT_DIR`	|Directorio de salida	|Analisis de logs genera archivos en este directorio.|



## Instrucciones de uso:

| Target | Descripcion |
|--------|-------------|
| make tools | Verifica las dependencias necesarias (nc, curl, dig, bats, ss, journalctl) |
| make build | Build incremental con caché en out/ |
| make test | Ejecuta suite de tests Bats (6 tests con metodologia AAA) |
| make run | Ejecuta el servicio Hello |
| make analyze-logs | Analisis de logs con herramientas Unix |
| make pack | Genera paquete reproducible con checksums en dist/ |
| make release | Release completo con metadatos (12-Factor V) |
| make clean | Elimina out/ y dist/ |
| | |
| **Gestión de servicio systemd** | |
| make install-service | Instala el servicio en systemd |
| make uninstall-service | Desinstala el servicio de systemd |
| make start-service | Inicia el servicio systemd |
| make stop-service | Detiene el servicio systemd |
| make status-service | Muestra estado y logs del servicio con journalctl |
| | |
| **Ayuda** | |
| make help | Documentación completa de todos los targets |


---




## Ramas:
*Sprint-1:*
- *Hinojosa Frank:* [Frank-Hinojosa/dns-networking](https://github.com/EdySerrano/PC2-Grupo4-Proyecto6-DesarrolloDeSoftware/tree/Frank-Hinojosa/dns-networking)
- *Choquecambi Germain:* [Germain-Choquechambi/automatizacion-test](https://github.com/EdySerrano/PC2-Grupo4-Proyecto6-DesarrolloDeSoftware/tree/Germain-Choquechambi/automatizacion-test)
- *Serrano Edy:* [Edy-Serrano/servicio-HTTP](https://github.com/EdySerrano/PC2-Grupo4-Proyecto6-DesarrolloDeSoftware/tree/Edy-Serrano/servicio-HTTP)

*Sprint-2:*
- *Hinojosa Frank:* [Frank-hinojosa/package-systemd](https://github.com/EdySerrano/PC2-Grupo4-Proyecto6-DesarrolloDeSoftware/tree/Frank-Hinojosa/package-systemd)
- *Choquecambi Germain:* [Germain-Choquechambi/analyze-logs](https://github.com/EdySerrano/PC2-Grupo4-Proyecto6-DesarrolloDeSoftware/tree/Germain-Choquechambi/analyze-logs)
- *Serrano Edy:* [Edy-Serrano/servicio-metricas](https://github.com/EdySerrano/PC2-Grupo4-Proyecto6-DesarrolloDeSoftware/tree/Edy-Serrano/servicio-metricas)

*Sprint-3:*
- *Hinojosa Frank:* [frank-hinojosa/modular-build-package-scripts](https://github.com/EdySerrano/PC2-Grupo4-Proyecto6-DesarrolloDeSoftware/tree/Frank-Hinojosa/modular-build-package-scripts)
- *Choquecambi Germain:* [Germain-Choquechambi/test-incremental-cache-idempotency](https://github.com/EdySerrano/PC2-Grupo4-Proyecto6-DesarrolloDeSoftware/tree/Germain-Choquechambi/test-incremental-cache-idempotency)
- *Serrano Edy:* [Edy-Serrano/Documentacion-bitacoras](https://github.com/EdySerrano/PC2-Grupo4-Proyecto6-DesarrolloDeSoftware/tree/Edy-Serrano/Documentacion-bitacoras)

## Tablero Kanban:
En este proyecto de utilizo el Tablero Kanban lo que facilito el registro y procedimiento en cada etapa del desarrollo el proyecto, en donde se registraron [Las historias de usuario](https://github.com/EdySerrano/PC2-Grupo4-Proyecto6-DesarrolloDeSoftware/issues?q=is%3Aissue%20state%3Aclosed) especificando lo que se va implementar y luego de eso realizar el [Pull Request](https://github.com/EdySerrano/PC2-Grupo4-Proyecto6-DesarrolloDeSoftware/pulls?q=is%3Apr+is%3Aclosed) para la revision de los demas integrantes y asi practicar una metodologia Agil.

Link Tablero Kanban : [PC2-Proyecto 6: Observabilidad mínima de un servicio "hello"](https://github.com/users/EdySerrano/projects/5)
