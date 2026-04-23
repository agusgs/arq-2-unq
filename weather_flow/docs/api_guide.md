# Guía de Uso de la API (Ejemplos Rápidos)

Nuestra REST API puede experimentarse cómodamente y visualizarse interactivamente navegando a **`http://localhost:4000/api/swaggerui`**. Alternativamente, te dejamos las sentencias curl de terminal agrupadas por dominios:

## 1. Gestión de Usuarios

### Registrar un Usuario (POST `/api/users/`)
```bash
curl -X POST http://localhost:4000/api/users \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Ada",
    "last_name": "Lovelace",
    "email": "ada@lovelace.com"
  }'
```

### Listar todos los Usuarios (GET `/api/users/`)
```bash
curl -X GET http://localhost:4000/api/users
```

### Obtener Usuario por ID (GET `/api/users/:id`)
```bash
curl -X GET http://localhost:4000/api/users/AQUI_TU_USER_ID
```

### Actualizar Usuario (PUT `/api/users/:id`)
```bash
curl -X PUT http://localhost:4000/api/users/AQUI_TU_USER_ID \
  -H "Content-Type: application/json" \
  -d '{
    "first_name": "Alan",
    "last_name": "Turing"
  }'
```

### Eliminar Usuario (DELETE `/api/users/:id`)
```bash
curl -X DELETE http://localhost:4000/api/users/AQUI_TU_USER_ID
```

## 2. Gestión de Estaciones Meteorológicas

### Registrar una Estación (POST `/api/stations/`)
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

### Listar Estaciones (GET `/api/stations/`)
```bash
curl -X GET http://localhost:4000/api/stations
```

### Obtener Estación por ID (GET `/api/stations/:id`)
```bash
curl -X GET http://localhost:4000/api/stations/AQUI_TU_STATION_ID
```

### Actualizar Estación (PUT `/api/stations/:id`)
```bash
curl -X PUT http://localhost:4000/api/stations/AQUI_TU_STATION_ID \
  -H "Content-Type: application/json" \
  -d '{
    "station": {
      "name": "Estación Sur Actualizada",
      "latitude": -34.6,
      "longitude": -58.4
    }
  }'
```

### Eliminar Estación - Soft Delete (DELETE `/api/stations/:id`)
```bash
curl -X DELETE http://localhost:4000/api/stations/AQUI_TU_STATION_ID
```

## 3. Suscripciones

### Suscribir un Usuario a una Estación (POST `/api/users/:user_id/subscriptions`)
```bash
curl -X POST http://localhost:4000/api/users/AQUI_TU_USER_ID/subscriptions \
  -H "Content-Type: application/json" \
  -d '{
    "station_id": "AQUI_TU_STATION_ID"
  }'
```

### Eliminar Suscripción de un Usuario (DELETE `/api/users/:user_id/subscriptions/:station_id`)
```bash
curl -X DELETE http://localhost:4000/api/users/AQUI_TU_USER_ID/subscriptions/AQUI_TU_STATION_ID
```

## 4. Telemetría y Alertas

### Ingestar Telemetría de Alta Velocidad (POST `/api/stations/:station_id/telemetry`)
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

### Buscador Avanzado de Telemetría (GET `/api/telemetry`)
*Permite filtrar las métricas usando parámetros como station_name, o combinaciones dinámicas de métricas como min_temp, max_temp, min_hum, e is_alert.*
```bash
curl -X GET "http://localhost:4000/api/telemetry?station_name=Estaci%C3%B3n%20Sur&is_alert=true&min_temp=30&max_hum=50"
```

### Listar Alertas de una Estación (GET `/api/stations/:station_id/alerts`)
```bash
curl -X GET http://localhost:4000/api/stations/AQUI_TU_STATION_ID/alerts
```
