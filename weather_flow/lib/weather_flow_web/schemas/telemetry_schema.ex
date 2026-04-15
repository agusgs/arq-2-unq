defmodule WeatherFlowWeb.Schemas.TelemetryRequest do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "TelemetryRequest",
    description:
      "Payload de métricas recibidas de estaciones IoT (Diccionario dinámico de floats)",
    type: :object,
    properties: %{
      metrics: %Schema{
        type: :object,
        additionalProperties: %Schema{type: :number},
        example: %{"temperature" => 25.5, "humidity" => 60.1}
      },
      timestamp: %Schema{
        type: :string,
        format: :"date-time",
        description:
          "ISO8601 Timestamp opcional. Si se omite se usará la hora de recesión en el servidor."
      }
    },
    required: [:metrics]
  })
end

defmodule WeatherFlowWeb.Schemas.TelemetryResponse do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "TelemetryResponse",
    description: "Confirmación de ingesta de telemetría IoT",
    type: :object,
    properties: %{
      id: %Schema{type: :string, description: "BSON ID generado (interno)"},
      station_id: %Schema{type: :string},
      metrics: %Schema{type: :object, additionalProperties: %Schema{type: :number}},
      timestamp: %Schema{type: :string, format: :"date-time"}
    }
  })
end
