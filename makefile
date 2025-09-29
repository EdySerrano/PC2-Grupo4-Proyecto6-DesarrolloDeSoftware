# Variables de configuración
PORT ?= 8080
MESSAGE ?= Hola_desde_systemd
RELEASE ?= v1.0.0
PROJECT_NAME = hello-oservabilidad-grupo4
APP_ENV ?= dev

# Directorios	|
OUT_DIR = out
DIST_DIR = dist

.PHONY: tools build test run pack clean help install-service uninstall-service start-service stop-service status-service

tools:
	@echo "Verificando herramientas requeridas..."
	@command -v nc >/dev/null || (echo "ERROR: nc no instalado" && exit 1)
	@command -v curl >/dev/null || (echo "ERROR: curl no instalado" && exit 1)  
	@command -v dig >/dev/null || (echo "ERROR: dig no instalado" && exit 1)
	@command -v bats >/dev/null || (echo "ERROR: bats no instalado" && exit 1)
	@command -v ss >/dev/null || (echo "ERROR: ss no instalado" && exit 1)
	@command -v journalctl >/dev/null || (echo "ERROR: journalctl no instalado" && exit 1)
	@echo "Todas las herramientas están disponibles"

# Regla patrón para generar artefactos de análisis
$(OUT_DIR)/%.analysis: src/%.sh | $(OUT_DIR)
	@echo "Generando análisis para $<..."
	@bash -n $< && echo "✓ Sintaxis válida" > $@
	@echo "Líneas de código: $$(wc -l < $<)" >> $@
	@echo "Funciones definidas: $$(grep -c '^[a-zA-Z_][a-zA-Z0-9_]*()' $< || echo 0)" >> $@

build: tools $(OUT_DIR)
	@echo "Generando artefactos intermedios..."
	@mkdir -p $(OUT_DIR)
	@echo "Verificando sintaxis de scripts..."
	@for script in src/*.sh; do \
		echo "Verificando $$script..."; \
		bash -n $$script || exit 1; \
	done
	@echo "Creando archivo de configuración de build..."
	@echo "BUILD_DATE=$$(date --iso-8601=seconds)" > $(OUT_DIR)/build.env
	@echo "RELEASE=$(RELEASE)" >> $(OUT_DIR)/build.env  
	@echo "PROJECT_NAME=$(PROJECT_NAME)" >> $(OUT_DIR)/build.env
	@echo "Build completado exitosamente"

$(OUT_DIR):
	@mkdir -p $(OUT_DIR)

test: build
	@echo "Ejecutando suite de tests Bats..."
	@bats tests/ || (echo "ERROR: Tests fallaron" && exit 1)
	@echo "Todos los tests pasaron"

run: build
	@echo "Iniciando servicio Hello en puerto $(PORT)..."
	@echo "Variables: PORT=$(PORT) APP_ENV=$(APP_ENV)"
	PORT=$(PORT) APP_ENV=$(APP_ENV) LATENCY_THRESHOLD=1000 bash src/hello_service.sh


analyze-logs: build
	@echo "Ejecutando analisis de logs..."
	@if [ -f "src/sample.log" ]; then \
		bash src/analyze_logs.sh src/sample.log; \
	else \
		echo "No se encontro archivo de log. Creando ejemplo"; \
		bash src/hello_service.sh & \
		SERVICE_PID=$$!; \
		sleep 2; \
		kill $$SERVICE_PID 2>/dev/null || true; \
		bash src/analyze_logs.sh /var/log/syslog 2>/dev/null || echo "Usando logs por defecto"; \
	fi
	@echo "analisis clompletado. Revise el directorio out/"

# Empaquetado reproducible
pack: build test
	@echo "Creando paquete reproducible..."
	@mkdir -p $(DIST_DIR)
	@echo "Empaquetando $(PROJECT_NAME)-$(RELEASE)..."
	@tar --transform 's|^|$(PROJECT_NAME)-$(RELEASE)/|' \
		-czf $(DIST_DIR)/$(PROJECT_NAME)-$(RELEASE).tar.gz \
		src/ tests/ systemd/ makefile README.md docs/ $(OUT_DIR)/
	@echo "Generando checksums..."
	@cd $(DIST_DIR) && sha256sum $(PROJECT_NAME)-$(RELEASE).tar.gz > $(PROJECT_NAME)-$(RELEASE).sha256
	@echo "Paquete creado: $(DIST_DIR)/$(PROJECT_NAME)-$(RELEASE).tar.gz"
	@ls -lh $(DIST_DIR)/

# Limpieza segura
clean:
	@echo "Limpiando artefactos..."
	@if [ -d "$(OUT_DIR)" ]; then \
		echo "Eliminando $(OUT_DIR)/..."; \
		rm -rf $(OUT_DIR)/; \
	fi
	@if [ -d "$(DIST_DIR)" ]; then \
		echo "Eliminando $(DIST_DIR)/..."; \
		rm -rf $(DIST_DIR)/; \
	fi
	@echo "Limpieza completada"

# Instala el servicio systemd
install-service: build
	@echo "Instalando servicio systemd..."
	@sed 's|{{PROJECT_DIR}}|$(PWD)|g' systemd/hello.service > out/hello.service
	@sed -i 's|Environment=PORT=8080 MESSAGE=Hola_desde_systemd|Environment=PORT=$(PORT) MESSAGE=$(MESSAGE)|g' out/hello.service
	@sudo cp out/hello.service /etc/systemd/system/
	@sudo systemctl daemon-reload
	@echo "Servicio instalado."

# Desinstala el servicio systemd
uninstall-service:
	@echo "Desinstalando servicio systemd..."
	@sudo systemctl stop hello 2>/dev/null || true
	@sudo systemctl disable hello 2>/dev/null || true
	@sudo rm -f /etc/systemd/system/hello.service
	@sudo systemctl daemon-reload
	@echo "Servicio desinstalado"

# Inicia el servicio systemd
start-service:
	@echo "Iniciando servicio"
	@sudo systemctl enable hello
	@sudo systemctl start hello
	@echo "Servicio iniciado. Use 'make status-service' para verificar"

# Detiene el servicio systemd
stop-service:
	@echo "Deteniendo servicio"
	@sudo systemctl stop hello || true
	@echo "Servicio detenido."

# Muestra el estado del servicio systemd
status-service:
	@echo "Estado del servicio:"
	@sudo systemctl status hello --no-pager || true
	@echo ""
	@echo "Logs recientes:"
	@sudo journalctl -u hello --no-pager -n 10 || true
	
# Documentación de uso
help:
	@echo "Makefile para $(PROJECT_NAME)"
	@echo ""
	@echo "Targets disponibles:"
	@echo "  tools          : Verifica herramientas requeridas (nc, curl, dig, bats, ss, journalctl)"
	@echo "  build          : Genera artefactos intermedios en $(OUT_DIR)/"
	@echo "  test           : Ejecuta suite de tests Bats"  
	@echo "  run            : Ejecuta el servicio Hello (PORT=$(PORT), APP_ENV=$(APP_ENV))"
	@echo "  analyze-logs   : Ejecuta analisis de log (analyze_logs.sh) con herramientas Unix"
	@echo "  pack           : Crea paquete reproducible en $(DIST_DIR)/"
	@echo "  clean          : Elimina $(OUT_DIR)/ y $(DIST_DIR)/"
	@echo ""
	@echo "Targets de systemd:"
	@echo "  install-service : Instala servicio systemd"
	@echo "  start-service   : Inicia servicio systemd" 
	@echo "  stop-service    : Detiene servicio systemd"
	@echo "  status-service  : Muestra estado del servicio"
	@echo "  uninstall-service : Desinstala servicio systemd"
	@echo ""
	@echo "Variables de entorno:"
	@echo "  PORT=$(PORT)			: Puerto HTTP del servicio"
	@echo "  APP_ENV=$(APP_ENV)		: Entorno de ejecución (dev/prod)"
	@echo "  RELEASE=$(RELEASE)		: Versión del release"
