PORT ?= 8080
MESSAGE ?= Hola_desde_systemd

.PHONY: tools build test run

tools:
	@command -v nc >/dev/null || (echo "nc no instalado" && exit 1)
	@command -v dig >/dev/null || (echo "dig no instalado" && exit 1)
	@command -v bats >/dev/null || (echo "bats no instalado" && exit 1)
	@echo "Todas las herramientas disponibles"

build:
	@echo "No hay compilacion en bash, solo verificacion"
	@mkdir -p out

test:
	bats tests/

run:
	PORT=$(PORT) APP_ENV=$(APP_ENV) bash src/hello_service.sh

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
	