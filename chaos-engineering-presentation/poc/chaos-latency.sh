#!/bin/bash
echo "🐌 Iniciando DEGRADACIÓN PROGRESIVA de Latencia en Sugerencias..."
echo "Observa cómo la latencia sube en el panel antes de hacer Timeout..."

echo "-------------------------------------"
echo "🟡 Nivel 1: Latencia Leve (50ms) x 4 seg"
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/alexei-led/pumba \
    netem --duration 4s delay --time 50 poc_suggestions

echo "🟠 Nivel 2: Latencia Peligrosa (150ms) x 4 seg"
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/alexei-led/pumba \
    netem --duration 4s delay --time 150 poc_suggestions

echo "🔴 Nivel 3: Caos Total (>250ms) x 15 seg"
echo "¡El Timeout del Gateway (200ms) se romperá y saltará el Circuit Breaker!"
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/alexei-led/pumba \
    netem --duration 15s delay --time 400 poc_suggestions

echo "-------------------------------------"
echo "✅ Latencia eliminada. El servicio vuelve a la normalidad."
