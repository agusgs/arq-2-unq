#!/bin/bash
echo "💥 Matando el contenedor de Redis (poc_redis) por 20 segundos..."
echo "Observa cómo el Gateway falla el checkout porque Redis es un componente crítico..."
# Usamos Pumba para pausar/matar el contenedor. En este caso hacemos un 'pause' por 20s 
# para simular una caída de base de datos sin perder estado.
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock ghcr.io/alexei-led/pumba \
    pause --duration 20s poc_redis
echo "✅ Redis ha vuelto a la vida."
