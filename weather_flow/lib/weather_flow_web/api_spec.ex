defmodule WeatherFlowWeb.ApiSpec do
  @moduledoc false
  alias OpenApiSpex.{Info, Server, Components, OpenApi}

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
          "User" => WeatherFlowWeb.Schemas.User.schema(),
          "UserRequest" => WeatherFlowWeb.Schemas.UserRequest.schema(),
          "Station" => WeatherFlowWeb.Schemas.Station.schema(),
          "StationRequest" => WeatherFlowWeb.Schemas.StationRequest.schema(),
          "SubscriptionRequest" => WeatherFlowWeb.Schemas.SubscriptionRequest.schema(),
          "TelemetryRequest" => WeatherFlowWeb.Schemas.TelemetryRequest.schema(),
          "TelemetryResponse" => WeatherFlowWeb.Schemas.TelemetryResponse.schema(),
          "Alert" => WeatherFlowWeb.Schemas.Alert.schema()
        }
      },
      paths: OpenApiSpex.Paths.from_router(WeatherFlowWeb.Router)
    }
    |> OpenApiSpex.resolve_schema_modules()
  end
end
