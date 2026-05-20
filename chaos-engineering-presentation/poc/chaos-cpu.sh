#!/bin/bash
echo "🔥 Iniciando DEGRADACIÓN PROGRESIVA de CPU en Sugerencias..."
echo "Observa cómo el medidor de CPU sube escalonadamente en el dashboard..."

echo "-------------------------------------"
echo "🟡 Nivel 1: Carga Leve (50% CPU) x 5 seg"
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/alexei-led/pumba \
    stress --duration 5s --stressors "--cpu 1 --cpu-load 25" poc_suggestions

echo "🟠 Nivel 2: Carga Peligrosa (80% CPU) x 5 seg"
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/alexei-led/pumba \
    stress --duration 5s --stressors "--cpu 1 --cpu-load 40" poc_suggestions

echo "🔴 Nivel 3: Asfixia Total (100% CPU) x 15 seg"
echo "¡Múltiples hilos saturarán la CPU, creando colas masivas (Runqueue Starvation)!"
echo "¡La latencia se disparará y el Circuit Breaker saltará!"
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/alexei-led/pumba \
    stress --duration 15s --stressors "--cpu 0 --cpu-load 100" poc_suggestions

echo "-------------------------------------"
echo "✅ Estrés eliminado. El servicio vuelve a la normalidad."
