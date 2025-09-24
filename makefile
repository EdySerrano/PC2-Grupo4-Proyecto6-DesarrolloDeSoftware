# ...

.PHONY: tools build

tools:
	@command -v nc >/dev/null || (echo "nc no instalado" && exit 1)
	@command -v dig >/dev/null || (echo "dig no instalado" && exit 1)
	@command -v bats >/dev/null || (echo "bats no instalado" && exit 1)
	@echo "Todas las herramientas disponibles"

build:
	@echo "No hay compilacion en bash, solo verificacion"
	@mkdir -p out