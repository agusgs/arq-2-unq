defmodule WeatherFlowWeb.Schemas.SubscriptionRequest do
  @moduledoc "Esquema OpenAPI para crear/borrar una suscripción"
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "SubscriptionRequest",
    description: "Payload necesario para vincular una Estación al usuario",
    type: :object,
    properties: %{
      station_id: %Schema{type: :string, description: "ID de la estación"}
    },
    required: [:station_id]
  })
end
