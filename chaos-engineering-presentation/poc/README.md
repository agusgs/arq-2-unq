# Demo de Chaos Engineering & Arquitectura Avanzada 💥

Este repositorio contiene un Proof of Concept (POC) de un sistema de E-Commerce simulado diseñado para demostrar principios de **Chaos Engineering**, **Arquitectura de Software** y **Teoría de Colas**.

## Arquitectura del Sistema
*   **Frontend (Nginx + JS):** Dashboard SRE en tiempo real que simula el tráfico de usuarios y visualiza métricas clave (CPS, Latencia, CPU, estado del Circuit Breaker).
*   **Gateway API (FastAPI):** Servicio principal encargado del "Checkout". Contiene patrones de resiliencia integrados (Timeouts, Circuit Breaker, Caché).
*   **Sugerencias (FastAPI):** Microservicio secundario no crítico. Su limitación de CPU (`0.5` cores) lo hace el blanco perfecto para inyectar fallos controlados.
*   **Redis:** Almacenamiento rápido del contador de ventas (Componente Crítico / SPOF).
*   **Caos (Pumba):** Herramienta que inyecta fallos directamente a nivel de red y kernel en los contenedores de Docker.

---

## Patrones de Resiliencia Implementados 🛡️

El API Gateway implementa patrones arquitectónicos avanzados para proteger el throughput de negocio (Compras Por Segundo - CPS) frente a fallos en sus dependencias:

### 1. Circuit Breaker (Cortocircuito) & Fail-Fast
Si el servicio de Sugerencias sufre latencia extrema, el Gateway no espera a que cada petición alcance el límite de Timeout, lo cual degradaría drásticamente el rendimiento general. Tras 3 fallos consecutivos, el circuito transiciona al estado **ABIERTO**. En este estado, el Gateway aplica el principio de *Fail-Fast* (latencia de 0ms), devolviendo una respuesta inmediata y evitando sobrecargar la red con peticiones destinadas a fallar.

### 2. Stale Cache (Caché de Respaldo)
Ante la apertura del Circuit Breaker o un fallo de red, el Gateway no expone el error al usuario final. En su lugar, recupera la **última lista válida de sugerencias** almacenada en caché de memoria, manteniendo la experiencia del usuario intacta de manera transparente (Graceful Degradation).

### 3. Degradación Progresiva y Runqueue Starvation (Teoría de Colas)
La arquitectura demuestra un principio fundamental de la teoría de colas (Fórmula de Kingman): la latencia de un servicio no se degrada linealmente con el uso de CPU. Se mantiene estable hasta que la utilización se acerca al 100%, punto en el cual se forma una cola de procesos masiva. Al limitar el contenedor de Sugerencias a `0.5` CPUs, los scripts de prueba inyectan múltiples hilos para saturar instantáneamente dicha cuota, provocando *Runqueue Starvation* (Inanición por Cola de Ejecución) y demostrando cómo la contención real de recursos asfixia a la latencia del sistema.

---

## Guía de Ejecución de Pruebas 🚀

### 1. Iniciar el Sistema (Estado Estable)
Para inicializar el entorno, ejecutar en la raíz del directorio:
```bash
docker compose up -d --build
```
Posteriormente, acceder a [http://localhost:8080](http://localhost:8080). Se observará tráfico saludable y métricas estables.

### 2. Prueba 1: Inyección de Latencia de Red
Para simular degradación en la red del microservicio secundario:
```bash
./chaos-latency.sh
```
**Observaciones esperadas:** La latencia escalará en intervalos (50ms -> 150ms -> 400ms). Al superar los 200ms, el Gateway alcanzará su límite de Timeout, forzando la apertura del Circuit Breaker (estado 🔴). El sistema comenzará a servir datos oxidados marcados como `[Desde Caché]`, garantizando que el CPS (Compras Por Segundo) se mantenga inalterado.

### 3. Prueba 2: Agotamiento de CPU (Noisy Neighbor)
Para simular el impacto de un proceso compitiendo por recursos del CPU:
```bash
./chaos-cpu.sh
```
**Observaciones esperadas:** El script saturará progresivamente la cuota de CPU del contenedor. Se demostrará que la latencia **no se ve afectada** al 50% ni al 80% de utilización. Sin embargo, al alcanzar el 100%, la latencia experimentará un crecimiento exponencial debido al *Runqueue Starvation*, forzando nuevamente la activación del Circuit Breaker.

### 4. Detener el Entorno
Para finalizar las pruebas y destruir los contenedores:
```bash
docker compose down
```

## Material Complementario
Para visualizar las diapositivas de presentación asociadas al proyecto, se requiere la extensión "Marp for VS Code". Alternativamente, se pueden visualizar desde el navegador mediante:
```bash
npx @marp-team/marp-cli@latest slides.md --server
```
