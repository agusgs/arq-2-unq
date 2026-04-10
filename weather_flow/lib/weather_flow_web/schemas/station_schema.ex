defmodule WeatherFlowWeb.Schemas.Station do
  @moduledoc "Esquema OpenAPI para las respuestas de Estación"
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "Station",
    description: "Una estación meteorológica registrada en el sistema.",
    type: :object,
    properties: %{
      id: %Schema{type: :string, description: "ID de la estación (BSON ObjectID hex)"},
      name: %Schema{type: :string, description: "Nombre asignado a la estación"},
      latitude: %Schema{type: :number, format: :float, description: "Latitud geográfica"},
      longitude: %Schema{type: :number, format: :float, description: "Longitud geográfica"}
    },
    required: [:id, :name, :latitude, :longitude]
  })
end

defmodule WeatherFlowWeb.Schemas.StationRequest do
  @moduledoc "Esquema OpenAPI para crear una nueva Estación"
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "StationRequest",
    description: "Payload necesario para registrar una estación",
    type: :object,
    properties: %{
      station: %Schema{
        type: :object,
        properties: %{
          name: %Schema{type: :string, example: "Estación Buenos Aires"},
          latitude: %Schema{type: :number, format: :float, example: -34.6037},
          longitude: %Schema{type: :number, format: :float, example: -58.3816}
        },
        required: [:name, :latitude, :longitude]
      }
    },
    required: [:station]
  })
end
