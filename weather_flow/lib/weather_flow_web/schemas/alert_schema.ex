defmodule WeatherFlowWeb.Schemas.Alert do
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Alert",
    description: "Anomalía detectada a partir de los streams de telemetría.",
    type: :object,
    properties: %{
      id: %Schema{type: :string, description: "ID de la alerta en MongoDB"},
      station_id: %Schema{type: :string, description: "Estación que causó el disparo"},
      metric: %Schema{type: :string, example: "temperature"},
      value: %Schema{type: :number, example: 38.5},
      message: %Schema{type: :string, example: "Alerta de Calor Extremo detectada."},
      timestamp: %Schema{type: :string, format: :"date-time"}
    }
  })
end
