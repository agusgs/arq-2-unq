#!/usr/bin/env bash
# ==============================================================================
# scripts/setup.sh — Configuración inicial del entorno de desarrollo
#
# PLATAFORMA: Linux (probado en Ubuntu/Debian y derivados)
#
# Este script prepara el entorno desde cero para un desarrollador nuevo.
# Solo es necesario ejecutarlo una vez al clonar el repositorio.
#
# Uso:
#   bash scripts/setup.sh
# ==============================================================================
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo ""
echo -e "${GREEN}=== WeatherFlow — Setup inicial ===${NC}"
echo ""

# --- Verificar prerequisitos ---
echo "▶ Verificando prerequisitos..."

if ! command -v docker &> /dev/null; then
  echo -e "${RED}✗ Docker no encontrado. Instalalo desde https://docs.docker.com/engine/install/${NC}"
  exit 1
fi
echo -e "  ${GREEN}✓ Docker: $(docker --version)${NC}"

if ! command -v docker compose &> /dev/null && ! docker-compose version &> /dev/null 2>&1; then
  echo -e "${RED}✗ Docker Compose no encontrado.${NC}"
  exit 1
fi
echo -e "  ${GREEN}✓ Docker Compose: OK${NC}"

if ! command -v mix &> /dev/null; then
  echo -e "${RED}✗ Elixir/Mix no encontrado.${NC}"
  echo -e "  Recomendamos instalarlo via asdf usando el archivo .tool-versions del proyecto."
  echo -e "  Ver: https://asdf-vm.com/"
  exit 1
fi
echo -e "  ${GREEN}✓ Elixir: $(elixir --version | head -1)${NC}"

# --- Configurar variables de entorno ---
echo ""
echo "▶ Configurando variables de entorno..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

if [ -f "$PROJECT_DIR/.env" ]; then
  echo -e "  ${YELLOW}⚠ Archivo .env ya existe, se omite la creación.${NC}"
else
  cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
  echo -e "  ${GREEN}✓ Archivo .env creado desde .env.example${NC}"
  echo -e "  ${YELLOW}⚠ Completá SECRET_KEY_BASE en .env antes de usar el modo producción.${NC}"
  echo -e "    Podés generarla con: mix phx.gen.secret"
fi

# --- Instalar dependencias de Elixir ---
echo ""
echo "▶ Instalando dependencias de Elixir..."
cd "$PROJECT_DIR"
mix deps.get
echo -e "  ${GREEN}✓ Dependencias instaladas${NC}"

# --- Resumen final ---
echo ""
echo -e "${GREEN}=== Setup completado ===${NC}"
echo ""
echo "Próximos pasos:"
echo "  Desarrollo:  bash scripts/dev/start.sh"
echo "  Producción:  bash scripts/prod/start.sh"
echo ""
