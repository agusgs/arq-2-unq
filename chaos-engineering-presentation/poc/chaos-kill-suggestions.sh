#!/bin/bash
echo "💥 Matando el contenedor de Sugerencias (poc_suggestions) por 20 segundos..."
echo "Observa cómo el Gateway detecta la caída y pasa al modo de Fallback para las Sugerencias..."
# Usamos Pumba para pausar/matar el contenedor.
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/alexei-led/pumba \
    pause --duration 20s poc_suggestions
echo "✅ El servicio de Sugerencias ha vuelto a la vida."
