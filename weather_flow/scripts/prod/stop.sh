#!/usr/bin/env bash
# ==============================================================================
# scripts/prod/stop.sh — Detiene el stack de producción
#
# PLATAFORMA: Linux (probado en Ubuntu/Debian y derivados)
#
# Detiene todos los contenedores del stack de producción.
# Los datos de MongoDB persisten en el volumen Docker (mongo_data).
#
# Uso:
#   bash scripts/prod/stop.sh
#
# Para detener Y eliminar volúmenes (borra todos los datos):
#   docker-compose down -v   ⚠ CUIDADO: esto borra los datos persistidos
# ==============================================================================
set -euo pipefail

GREEN='\033[0;32m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"

echo ""
echo "▶ Deteniendo el stack de producción..."
cd "$PROJECT_DIR"
docker-compose down

echo ""
echo -e "${GREEN}✓ Stack de producción detenido.${NC}"
echo "  Los datos de MongoDB siguen persistidos en el volumen Docker."
echo ""
