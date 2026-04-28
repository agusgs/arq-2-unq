#!/usr/bin/env bash
# ==============================================================================
# scripts/prod/start.sh — Inicia el stack completo de producción
#
# PLATAFORMA: Linux (probado en Ubuntu/Debian y derivados)
#
# Buildea la imagen Docker de la aplicación y levanta el stack completo
# (MongoDB + Phoenix) de forma containerizada.
#
# Requisitos previos:
#   - Archivo .env con SECRET_KEY_BASE completado (ver .env.example)
#   - Docker y Docker Compose instalados
#
# Uso:
#   bash scripts/prod/start.sh
# ==============================================================================
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo ""
echo -e "${GREEN}=== WeatherFlow — Iniciando stack de producción ===${NC}"
echo ""

# --- Verificar que existe .env ---
if [ ! -f "$PROJECT_DIR/.env" ]; then
  echo -e "${RED}✗ Archivo .env no encontrado.${NC}"
  echo "  Copialo y completá SECRET_KEY_BASE:"
  echo "    cp .env.example .env"
  echo "    # Editá .env y completá SECRET_KEY_BASE con: mix phx.gen.secret"
  exit 1
fi

# --- Verificar que SECRET_KEY_BASE está definida ---
if ! grep -qE "^SECRET_KEY_BASE=.+" "$PROJECT_DIR/.env"; then
  echo -e "${RED}✗ SECRET_KEY_BASE no está definida en .env.${NC}"
  echo "  Generala con: mix phx.gen.secret"
  exit 1
fi

echo -e "  ${GREEN}✓ Archivo .env encontrado${NC}"

# --- Buildear e iniciar el stack ---
echo ""
echo "▶ Buildeando imagen y levantando el stack (esto puede tardar la primera vez)..."
cd "$PROJECT_DIR"
docker-compose up --build -d

# --- Esperar a que la app esté lista ---
echo ""
echo "▶ Esperando a que la aplicación esté disponible..."
for i in {1..30}; do
  if curl -s -o /dev/null -w "%{http_code}" http://localhost:4000/api/openapi | grep -q "200"; then
    echo -e "  ${GREEN}✓ Aplicación lista${NC}"
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo -e "  ${YELLOW}⚠ La aplicación tardó más de lo esperado.${NC}"
    echo "  Verificá los logs con: docker logs weather_flow_app"
  fi
  sleep 2
done

echo ""
echo -e "${GREEN}=== Stack de producción corriendo ===${NC}"
echo -e "  API disponible en: ${GREEN}http://localhost:4000${NC}"
echo -e "  Swagger UI en:     ${GREEN}http://localhost:4000/api/swaggerui${NC}"
echo ""
echo "  Para ver los logs en tiempo real: docker-compose logs -f"
echo "  Para detener:                     bash scripts/prod/stop.sh"
echo ""
