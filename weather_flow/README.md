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

## Referencia de Modelos y Servicios

A medida que el proyecto crezca, el diccionario de dominio se documentará aquí:

### Modelos de Dominio
- **User (`WeatherFlow.Domain.User`)**: 
  Representa a un miembro o administrador de la plataforma. 
  *Atributos*: `id` (String Hex), `first_name` (String), `last_name` (String), `email` (String), `subscriptions` (Arreglo de Strings/IDs Hex). 
  *Invariantes de negocio*: El modelo debe construirse con todos los atributos obligatorios completos. A nivel infraestructura, no pueden existir dos perfiles con el mismo e-mail.

- **Station (`WeatherFlow.Domain.Station`)**:
  Representa un sensor meteorológico físico y punto geográfico de recolección de métricas.
  *Atributos*: `id` (String Hex), `name` (String), `latitude` (Float), `longitude` (Float).
  *Invariantes de negocio*: Verifica obligatoriamente que las coordenadas geográficas sean números válidos dentro de los límites del plano (-90.0 a 90.0 para latitud, -180.0 a 180.0 para longitud). A nivel BD, el `name` debe ser único globalmente.

- **Telemetry (`WeatherFlow.Domain.Telemetry`)**:
  Representa un paquete polimórfico de mediciones IoT en tiempo real.
  *Atributos*: `id` (String Hex), `station_id` (String Hex), `timestamp` (DateTime), `metrics` (Map dinámico de Strings a valores numéricos).
  *Invariantes de negocio*: Utiliza el Patrón de Atributos; se permite cualquier variable climática siempre y cuando sus valores internos sean estrictamente numéricos.

### Servicios Orquestadores
- **UserManagementService**: 
  * `register_user(attrs)`: Valida requisitos, invoca persistencia y actúa como escudo atrapando proactivamente los errores del motor BSON por e-mails duplicados para retornar mensajes limpios de dominio.
  * `get_user(id)`: Retorna una entidad o `{:error, :not_found}`. Es resiliente ante formatos de ID inválidos.
  * `list_users()`: Recupera la colección completa de usuarios mapeada de base de datos a Entidades de Dominio puras.

- **StationManagementService**:
  * Funciona de análogamente al servicio de usuario, orquestando las duras validaciones paramétricas del modelo `Station` antes de disparar las consultas hacia MongoDB. Actúa como mediador transaccional con el `MongoStationRepository` y resuelve activamente los choques de índices de estación únicos traduciendo WriteErrors.

- **SubscriptionManagementService**:
  * Orquesta transaccionalmente la creación y destrucción de vínculos inmutables (mediante colecciones de IDs) entre los Dominios de `User` y `Station`. Asegura que ambos agregados existan antes del guardado y maneja de manera limpia las tuplas de error de Elixir sin corromper la DB.

- **TelemetryProcessingService**:
  * `ingest(attrs)`: Servicio de altísimo rendimiento encargado de tragar métricas crudas, parsear y preprocesar su formato web, ensamblar la entidad pura inyectando la fecha del servidor en caso de ser necesario, y persistirla ciegamente en una colección estricta Time-Series optimizando el I/O al evitar comprobaciones de llaves foráneas.

## Guía de Uso de la API (Ejemplos Rápidos)

Nuestra REST API puede experimentarse cómodamente y visualizarse interactivamente navegando a **`http://localhost:4000/api/swaggerui`**. Alternativamente, te dejamos las sentencias curl de terminal:

### 1. Registrar un Usuario (POST `/api/users/`)
```bash
curl -X POST http://localhost:4000/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "first_name": "Ada",
      "last_name": "Lovelace",
      "email": "ada@lovelace.com"
    }
  }'
```

### 2. Listar todos los Usuarios (GET `/api/users/`)
```bash
curl -X GET http://localhost:4000/api/users
```

### 3. Obtener Usuario por ID (GET `/api/users/:id`)
```bash
curl -X GET http://localhost:4000/api/users/66144e5b3dc8a6efb349b1a1
```

### 4. Registrar una Estación (POST `/api/stations/`)
```bash
curl -X POST http://localhost:4000/api/stations \
  -H "Content-Type: application/json" \
  -d '{
    "station": {
      "name": "Estación Sur",
      "latitude": -34.6118,
      "longitude": -58.4173
    }
  }'
```

### 5. Listar Estaciones (GET `/api/stations/`)
```bash
curl -X GET http://localhost:4000/api/stations
```

### 6. Suscribir un Usuario a una Estación (POST `/api/users/:user_id/subscriptions`)
```bash
curl -X POST http://localhost:4000/api/users/AQUI_TU_USER_ID/subscriptions \
  -H "Content-Type: application/json" \
  -d '{
    "station_id": "AQUI_TU_STATION_ID"
  }'
```

### 7. Eliminar Suscripción de un Usuario (DELETE `/api/users/:user_id/subscriptions/:station_id`)
```bash
curl -X DELETE http://localhost:4000/api/users/AQUI_TU_USER_ID/subscriptions/AQUI_TU_STATION_ID
```

### 8. Ingestar Telemetría de Alta Velocidad (POST `/api/stations/:station_id/telemetry`)
```bash
curl -X POST http://localhost:4000/api/stations/AQUI_TU_STATION_ID/telemetry \
  -H "Content-Type: application/json" \
  -d '{
    "metrics": {
      "temperature": 35.8,
      "humidity": 42.1,
      "wind_speed": 12.3
    }
  }'
```

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
