defmodule WeatherFlowWeb.Schemas.User do
  @moduledoc false
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "User",
    description: "Un usuario registrado en el sistema que puede suscribirse a estaciones",
    type: :object,
    properties: %{
      id: %Schema{type: :string, description: "Mongo Object ID generado"},
      first_name: %Schema{type: :string},
      last_name: %Schema{type: :string},
      email: %Schema{type: :string},
      subscriptions: %Schema{type: :array, items: %Schema{type: :string}}
    },
    example: %{
      "id" => "66141a02798fbb0d5db6eebd",
      "first_name" => "Juan",
      "last_name" => "Perez",
      "email" => "juan@example.com",
      "subscriptions" => ["station_1", "station_2"]
    }
  })
end

defmodule WeatherFlowWeb.Schemas.UserRequest do
  @moduledoc false
  require OpenApiSpex
  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "UserRequest",
    description: "Payload necesario para crear un usuario",
    type: :object,
    properties: %{
      first_name: %Schema{type: :string},
      last_name: %Schema{type: :string},
      email: %Schema{type: :string}
    },
    required: [:first_name, :last_name, :email],
    example: %{
      "first_name" => "Juan",
      "last_name" => "Perez",
      "email" => "juan@example.com"
    }
  })
end
