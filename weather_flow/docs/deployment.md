# Despliegue y Ambientes

WeatherFlow soporta tres ambientes diferenciados, cada uno con su propia base de datos y estrategia de ejecución.

## Tabla de Ambientes

| Ambiente   | Comando de inicio         | Base de datos          | Config leída          |
|------------|---------------------------|------------------------|-----------------------|
| Dev        | `mix phx.server`          | `weather_flow_dev`     | `config/dev.exs`      |
| Test       | `mix test`                | `weather_flow_test`    | `config/test.exs`     |
| Producción | `bin/weather_flow start`  | Vía variable de entorno | `config/runtime.exs` |

---

## Modo 1: Desarrollo Local (Recomendado)

Este es el modo habitual para el trabajo diario. La base de datos corre en Docker para aislarla del sistema, pero la aplicación corre **nativa** para aprovechar la recarga en caliente de código (hot-reload).

**1. Primera vez (setup inicial):**
```bash
bash scripts/setup.sh
```

**2. Iniciar el entorno de desarrollo:**
```bash
bash scripts/dev/start.sh
```

Esto levanta MongoDB en Docker y luego inicia Phoenix nativamente con hot-reload.
La API quedará disponible en `http://localhost:4000`.
La base de datos utilizada será `weather_flow_dev` y **persiste entre reinicios** gracias al volumen Docker `mongo_dev_data`.

**3. Detener el entorno:**
```bash
bash scripts/dev/stop.sh
```

---

## Modo 2: Full-Stack con Docker Compose (Simulación de Producción)

Levanta **todo** containerizado: base de datos + aplicación Phoenix. Ideal para:
- Probar el comportamiento completo antes de un deploy real.
- Compartir el ambiente con otros desarrolladores sin instalar Elixir.

**1. Setup inicial (solo la primera vez):**
```bash
bash scripts/setup.sh
```

**2. Completar `SECRET_KEY_BASE` en el archivo `.env`:**
```bash
echo "SECRET_KEY_BASE=$(mix phx.gen.secret)" >> .env
```

**3. Iniciar el stack:**
```bash
bash scripts/prod/start.sh
```

**4. Detener el stack:**
```bash
bash scripts/prod/stop.sh
```

La API quedará disponible en `http://localhost:4000`.

> **Nota:** La primera vez que se ejecuta, Docker construirá la imagen de la aplicación, lo que puede tardar algunos minutos.

---

## Modo 3: Deploy a Producción Real

Para un deploy en la nube, se utilizan **variables de entorno** para configurar la aplicación en tiempo de ejecución (ver `config/runtime.exs`).

Las variables requeridas son:

| Variable         | Descripción                                  | Ejemplo                                    |
|------------------|----------------------------------------------|--------------------------------------------|
| `SECRET_KEY_BASE`| Clave secreta de Phoenix (64+ chars)         | `mix phx.gen.secret`                       |
| `PHX_HOST`       | Dominio público de la aplicación             | `weather-flow.fly.dev`                     |
| `PORT`           | Puerto HTTP de escucha (defecto: `4000`)     | `4000`                                     |
| `MONGO_URL`      | URL de conexión a MongoDB                    | `mongodb+srv://user:pass@cluster.mongodb.net` |
| `MONGO_DATABASE` | Nombre de la base de datos de producción     | `weather_flow_prod`                        |
| `MONGO_POOL_SIZE`| Tamaño del pool de conexiones (defecto: `10`)| `20`                                       |

### Estructura del Dockerfile

El `Dockerfile` utiliza un **build multi-stage** para generar una imagen de producción mínima:

```
Stage 1 (builder): elixir:1.19-alpine
  └── Compila dependencias + código fuente
  └── Genera el release OTP con `mix release`

Stage 2 (runtime): alpine:3.19
  └── Solo copia el binario compilado
  └── Imagen final ~50MB (sin código fuente ni herramientas de build)
```

Esta estrategia es la práctica estándar de la comunidad Elixir para deployar aplicaciones Phoenix en producción.
