# WeatherFlow - Sistema de Alertas Climatológicas

Plataforma de servicios meteorológicos desarrollada para procesar y alertar sobre métricas climáticas extremas. El proyecto está construido bajo el paradigma de **Arquitectura Hexagonal (Ports and Adapters)** y **Domain-Driven Design (DDD)** como parte del Trabajo Práctico 1.

## ¿Por qué Elixir y Phoenix?

La elección de **Elixir** (y la máquina virtual de Erlang, BEAM) junto a **Phoenix** se fundamenta en las características arquitectónicas necesarias para un sistema meteorológico:

1. **Alta Concurrencia:** Los sensores meteorológicos envían mediciones constantemente (telemetría). Elixir maneja cientos de miles de procesos ligeros concurrentes, permitiendo procesar y validar las métricas de cada estación simultáneamente sin encolar o bloquear el sistema.
2. **Tolerancia a Fallos:** Su modelo de Actores y Árboles de Supervisión garantiza que si ocurre un pánico procesando la medición corrupta de una estación, ese proceso fallará aisladamente y se reiniciará sin tirar abajo toda la aplicación web.
3. **Alto Rendimiento (Phoenix):** Phoenix es excepcionalmente rápido y liviano, ideal para construir una API REST pulcra y además deja la puerta abierta para procesar eventos en tiempo real (WebSockets/PubSub) si se requieren enviar las alertas a pantallas de clientes en vivo.
4. **Sinergia con Arquitectura Hexagonal y DDD:** El paradigma Funcional Puro encaja perfectamente con el DDD; el "Dominio" está conformado enteramente por estructuras inmutables (`Structs`) y funciones puras libres de efectos colaterales. A su vez, los "Puertos" de la Arquitectura Hexagonal se mapean nativamente utilizando el sistema de **Behaviours** (`@callback`) de Elixir, delimitando las fronteras entre nuestra lógica de negocio y los adaptadores de infraestructura (como MongoDB) de una manera limpia, explícita y fácilmente testeable.

## Tecnologías Utilizadas

- **Lenguaje:** Elixir (~> 1.19)
- **Framework Web:** Phoenix (~> 1.8.5) _(Modo API pura: --no-html --no-assets --no-mailer --no-ecto)_
- **Base de Datos:** MongoDB 6.0
- **Driver de BD:** `mongodb_driver`
- **Documentación de API:** `open_api_spex` (Swagger/OpenAPI 3)
- **Análisis de Código Estático:** `credo` y `dialyxir`

## Requisitos Previos

Para ejecutar y contribuir a este proyecto en un entorno local, necesitas tener instalados:

- **Elixir & Erlang:** (Recomendado vía gestores de versiones como `asdf` utilizando las versiones declaradas en `.tool-versions`).
- **Docker y Docker Compose:** Para ejecutar la base de datos de manera aislada sin necesidad de instalar un binario de MongoDB local.

## Arquitectura y Documentación Técnica

Detalles técnicos y diagramas arquitectónicos en la carpeta `/docs`:

1. [Arquitectura General y Componentes](docs/architecture.md)
2. [Modelo de Dominio y Validaciones](docs/domain_model.md)
3. [Esquema de Base de Datos MongoDB](docs/database.md)



## Configuración y Ejecución Local

1. **Levantar la base de datos (MongoDB local):**
   ```bash
   docker-compose up -d
   ```
2. **Instalar las dependencias de Elixir:**
   ```bash
   mix deps.get
   ```
3. **Iniciar el servidor local de Phoenix:**
   ```bash
   mix phx.server
   ```
   *(También puedes arrancar el servidor dentro de una sesión interactiva de consola usando `iex -S mix phx.server` para debugear)*

El servidor quedará a la escucha en [`http://localhost:4000`](http://localhost:4000).

## Tests y Análisis de Calidad

Para correr la suite de pruebas unitarias y de integración (ExUnit):
```bash
mix test
```

Para lanzar las herramientas de linter y validación de tipos:
```bash
mix credo --strict
mix dialyzer
```

## Referencias y Enlaces Útiles

- [Guía de Uso de la API y Ejemplos de cURL](docs/api_guide.md)
