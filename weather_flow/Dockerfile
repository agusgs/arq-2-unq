# ==============================================================================
# STAGE 1: Builder
# Compila las dependencias y el release de producción de Elixir.
# Usa imagen Debian para garantizar compatibilidad de OpenSSL con el runtime.
# ==============================================================================
FROM elixir:1.19-slim AS builder

# Instalar dependencias del sistema operativo necesarias para compilar NIFs y HTTPS
RUN apt-get update -y && apt-get install -y build-essential git ca-certificates --no-install-recommends \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Instalar Hex y Rebar (gestores de dependencias de Elixir/Erlang)
RUN mix local.hex --force && mix local.rebar --force

# Setear el ambiente en producción para el build
ENV MIX_ENV=prod

# Copiar archivos de dependencias y resolverlas primero (cache layer)
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod
RUN mix deps.compile

# Copiar el resto del código fuente
COPY config config
COPY lib lib
COPY priv priv

# Compilar la aplicación y generar el release OTP
RUN mix compile
RUN mix release

# ==============================================================================
# STAGE 2: Runtime
# Imagen final mínima. Solo copia el artefacto compilado del stage anterior.
# Usa la misma base Debian que el builder para garantizar compatibilidad de OpenSSL.
# ==============================================================================
FROM debian:trixie-slim AS runtime

# Dependencias mínimas de runtime para la VM de Erlang/OTP
RUN apt-get update -y && apt-get install -y libstdc++6 openssl libncurses6 locales --no-install-recommends \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar únicamente el release compilado desde el stage de build
COPY --from=builder /app/_build/prod/rel/weather_flow ./

# Exponer el puerto de la aplicación Phoenix
EXPOSE 4000

# Variables de entorno por defecto (sobreescribibles al lanzar el contenedor)
ENV PHX_HOST=localhost
ENV PORT=4000

# Comando para iniciar la aplicación
CMD ["bin/weather_flow", "start"]
