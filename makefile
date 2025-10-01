# Variables de configuración
PORT ?= 8080
MESSAGE ?= Hola_desde_systemd
RELEASE ?= v1.0.0
PROJECT_NAME = hello-oservabilidad-grupo4
APP_ENV ?= dev
.DEFAULT_GOAL := help
.DELETE_ON_ERROR:

# Directorios
OUT_DIR = out
DIST_DIR = dist

.PHONY: tools build test run pack clean help install-service uninstall-service start-service stop-service status-service

all: tools build test analyze-logs pack ## Construir, testear, analizar logs y empaquetar todo

tools: ## Verifica que las herramientas necesarias estén instaladas
	@echo "Verificando herramientas requeridas..."
	@command -v nc >/dev/null || (echo "ERROR: nc no instalado" && exit 1)
	@command -v curl >/dev/null || (echo "ERROR: curl no instalado" && exit 1)  
	@command -v dig >/dev/null || (echo "ERROR: dig no instalado" && exit 1)
	@command -v bats >/dev/null || (echo "ERROR: bats no instalado" && exit 1)
	@command -v ss >/dev/null || (echo "ERROR: ss no instalado" && exit 1)
	@command -v journalctl >/dev/null || (echo "ERROR: journalctl no instalado" && exit 1)
	@echo "Todas las herramientas están disponibles"

build: tools $(OUT_DIR) $(OUT_DIR)/build.timestamp ## Cache inteligente: solo rebuild si hay cambios
	@echo "Build completado exitosamente (usando caché incremental)"

$(OUT_DIR)/build.timestamp: src/*.sh makefile | $(OUT_DIR)
	@bash src/build.sh
	@touch $@

$(OUT_DIR):
	@mkdir -p $(OUT_DIR)

$(DIST_DIR):
	@mkdir -p $(DIST_DIR)

test: build ## Ejecuta tests
	@echo "Ejecutando suite de tests Bats..."
	@bats tests/ || (echo "ERROR: Tests fallaron" && exit 1)
	@echo "Todos los tests pasaron"

release: pack ## Crea un release con metadatos
	@echo "Creando release $(RELEASE) para entorno $(APP_ENV)..."
	@mkdir -p $(OUT_DIR)/releases/$(RELEASE)
	@echo "RELEASE_DATE=$$(date --iso-8601=seconds)" > $(OUT_DIR)/releases/$(RELEASE)/release.env
	@echo "RELEASE_VERSION=$(RELEASE)" >> $(OUT_DIR)/releases/$(RELEASE)/release.env
	@echo "TARGET_ENV=$(APP_ENV)" >> $(OUT_DIR)/releases/$(RELEASE)/release.env
	@echo "ARTIFACT_HASH=$$(sha256sum $(DIST_DIR)/$(PROJECT_NAME)-$(RELEASE).tar.gz | cut -d' ' -f1)" >> $(OUT_DIR)/releases/$(RELEASE)/release.env
	@cp $(DIST_DIR)/$(PROJECT_NAME)-$(RELEASE)* $(OUT_DIR)/releases/$(RELEASE)/
	@echo "Release $(RELEASE) creado en $(OUT_DIR)/releases/$(RELEASE)/"

run: build ## Ejecuta el servicio localmente
	@echo "Iniciando servicio Hello en puerto $(PORT)..."
	@echo "Variables runtime: PORT=$(PORT) APP_ENV=$(APP_ENV)"
	@echo "Build info: $$(cat $(OUT_DIR)/build.env 2>/dev/null | grep BUILD_DATE || echo 'Build date: unknown')"
	PORT=$(PORT) APP_ENV=$(APP_ENV) LATENCY_THRESHOLD=1000 bash src/hello_service.sh

analyze-logs: build ## Analiza logs y genera reportes
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

$(DIST_DIR)/$(PROJECT_NAME)-$(RELEASE)-manifest.json: $(OUT_DIR)/build.timestamp | $(DIST_DIR)
	@bash src/package.sh

pack: build test $(DIST_DIR)/$(PROJECT_NAME)-$(RELEASE)-manifest.json ## Empaquetar artefactos con metadatos
	@echo "Paquete reproducible creado exitosamente"

clean: ## Limpieza segura
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

install-service: build ## Instala el servicio systemd
	@echo "Instalando servicio systemd..."
	@sed 's|{{PROJECT_DIR}}|$(PWD)|g' systemd/hello.service > out/hello.service
	@sed -i 's|Environment=PORT=8080 MESSAGE=Hola_desde_systemd|Environment=PORT=$(PORT) MESSAGE=$(MESSAGE)|g' out/hello.service
	@sudo cp out/hello.service /etc/systemd/system/
	@sudo systemctl daemon-reload
	@echo "Servicio instalado."

uninstall-service: ## Desinstala el servicio systemd
	@echo "Desinstalando servicio systemd..."
	@sudo systemctl stop hello 2>/dev/null || true
	@sudo systemctl disable hello 2>/dev/null || true
	@sudo rm -f /etc/systemd/system/hello.service
	@sudo systemctl daemon-reload
	@echo "Servicio desinstalado"

start-service: ## Inicia el servicio systemd
	@echo "Iniciando servicio"
	@sudo systemctl enable hello
	@sudo systemctl start hello
	@echo "Servicio iniciado. Use 'make status-service' para verificar"

stop-service: ## Detiene el servicio systemd
	@echo "Deteniendo servicio"
	@sudo systemctl stop hello || true
	@echo "Servicio detenido."

status-service: ## Muestra el estado del servicio systemd
	@echo "Estado del servicio:"
	@sudo systemctl status hello --no-pager || true
	@echo ""
	@echo "Logs recientes:"
	@sudo journalctl -u hello --no-pager -n 10 || true
	
help: ## Mostrar ayuda
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) | awk -F':|##' '{printf "  %-20s %s\n", $$1, $$3}'