# Variables de configuración
PORT ?= 8080
MESSAGE ?= Hola_desde_systemd
RELEASE ?= v1.0.0
PROJECT_NAME = hello-oservabilidad-grupo4
APP_ENV ?= dev

# Directorios	|
OUT_DIR = out
DIST_DIR = dist

.PHONY: tools build test run

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
	