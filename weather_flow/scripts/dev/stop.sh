#!/usr/bin/env bash
# ==============================================================================
# scripts/dev/stop.sh — Detiene el entorno de desarrollo
#
# PLATAFORMA: Linux (probado en Ubuntu/Debian y derivados)
#
# Mata el proceso de Phoenix (usando el PID guardado en .phoenix.pid)
# y detiene el contenedor de MongoDB.
# Los datos persisten en el volumen Docker (mongo_dev_data).
#
# Uso:
#   bash scripts/dev/stop.sh
# ==============================================================================
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
PID_FILE="$PROJECT_DIR/.phoenix.pid"

echo ""

# --- Detener Phoenix ---
if [ -f "$PID_FILE" ]; then
  PHOENIX_PID=$(cat "$PID_FILE")
  if kill -0 "$PHOENIX_PID" 2>/dev/null; then
    echo "▶ Deteniendo Phoenix (PID: $PHOENIX_PID)..."
    kill "$PHOENIX_PID"
    wait "$PHOENIX_PID" 2>/dev/null || true
    echo -e "  ${GREEN}✓ Phoenix detenido${NC}"
  else
    echo -e "  ${YELLOW}⚠ Phoenix no estaba corriendo (PID $PHOENIX_PID inactivo)${NC}"
  fi
  rm -f "$PID_FILE"
else
  echo -e "  ${YELLOW}⚠ No se encontró .phoenix.pid — Phoenix puede no estar corriendo.${NC}"
fi

# --- Detener MongoDB ---
echo "▶ Deteniendo MongoDB de desarrollo..."
cd "$PROJECT_DIR"
docker-compose -f docker-compose.dev.yml down

echo ""
echo -e "${GREEN}✓ Entorno de desarrollo detenido.${NC}"
echo "  Los datos de la base siguen persistidos en el volumen Docker."
echo ""

