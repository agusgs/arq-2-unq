#!/usr/bin/env bash
# ==============================================================================
# scripts/dev/start.sh — Inicia el entorno de desarrollo
#
# PLATAFORMA: Linux (probado en Ubuntu/Debian y derivados)
#
# Levanta MongoDB en Docker e inicia Phoenix en segundo plano.
# Los logs de Phoenix se guardan en .phoenix.log en la raíz del proyecto.
#
# Uso:
#   bash scripts/dev/start.sh
#
# Para ver los logs de Phoenix en tiempo real:
#   tail -f .phoenix.log
# ==============================================================================
set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
PID_FILE="$PROJECT_DIR/.phoenix.pid"
LOG_FILE="$PROJECT_DIR/.phoenix.log"

echo ""
echo -e "${GREEN}=== WeatherFlow — Iniciando entorno de desarrollo ===${NC}"
echo ""

# --- Verificar que Phoenix no esté ya corriendo ---
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
  echo -e "${YELLOW}⚠ Phoenix ya está corriendo (PID: $(cat "$PID_FILE")).${NC}"
  echo "  Para detenerlo: bash scripts/dev/stop.sh"
  exit 0
fi

# --- Levantar MongoDB en Docker ---
echo "▶ Levantando MongoDB en Docker..."
cd "$PROJECT_DIR"
docker-compose -f docker-compose.dev.yml up -d

# --- Esperar a que MongoDB esté listo ---
echo "▶ Esperando a que MongoDB esté disponible..."
for i in {1..15}; do
  if docker exec weather_flow_mongo_dev mongosh --eval "db.adminCommand('ping')" &> /dev/null 2>&1; then
    echo -e "  ${GREEN}✓ MongoDB listo${NC}"
    break
  fi
  if [ "$i" -eq 15 ]; then
    echo -e "  ${YELLOW}⚠ MongoDB tardó más de lo esperado. Verificá con: docker logs weather_flow_mongo_dev${NC}"
  fi
  sleep 1
done

# --- Iniciar Phoenix en segundo plano ---
echo "▶ Iniciando Phoenix en segundo plano..."
cd "$PROJECT_DIR"
mix phx.server > "$LOG_FILE" 2>&1 &
echo $! > "$PID_FILE"

echo ""
echo -e "${GREEN}=== Entorno de desarrollo corriendo ===${NC}"
echo -e "  API disponible en: ${GREEN}http://localhost:4000${NC}"
echo -e "  Swagger UI en:     ${GREEN}http://localhost:4000/api/swaggerui${NC}"
echo ""
echo "  Para ver los logs de Phoenix:  tail -f .phoenix.log"
echo "  Para detener todo:             bash scripts/dev/stop.sh"
echo ""

