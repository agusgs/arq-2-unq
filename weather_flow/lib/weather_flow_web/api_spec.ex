defmodule WeatherFlowWeb.ApiSpec do
  @moduledoc false
  alias OpenApiSpex.{Components, Info, OpenApi, Server}

  alias WeatherFlowWeb.Schemas

  @behaviour OpenApiSpex.OpenApi

  @impl OpenApiSpex.OpenApi
  def spec do
    %OpenApi{
      info: %Info{
        title: "WeatherFlow API",
        version: "1.0.0",
        description: "API REST para el procesamiento de telemetría meteorológica."
      },
      servers: [
        Server.from_endpoint(WeatherFlowWeb.Endpoint)
      ],
      components: %Components{
        schemas: %{
          "User" => Schemas.User.schema(),
          "UserRequest" => Schemas.UserRequest.schema(),
          "Station" => Schemas.Station.schema(),
          "StationRequest" => Schemas.StationRequest.schema(),
          "SubscriptionRequest" => Schemas.SubscriptionRequest.schema(),
          "TelemetryRequest" => Schemas.TelemetryRequest.schema(),
          "TelemetryResponse" => Schemas.TelemetryResponse.schema(),
          "Alert" => Schemas.Alert.schema()
        }
      },
      paths: OpenApiSpex.Paths.from_router(WeatherFlowWeb.Router)
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
