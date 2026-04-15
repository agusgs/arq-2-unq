defmodule WeatherFlowWeb.TelemetryController do
  use WeatherFlowWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias WeatherFlow.Application.Services.TelemetryProcessingService

  tags(["Telemetry"])

  operation(:create,
    summary: "Ingesta altísima de Telemetría IoT",
    description:
      "Guarda mediciones físicas en formato MongoDB Time-Series ultra rápido. No verifica bloqueantemente que el ID de la estación exista y asume persistencia ciega optimizando rendimiento.",
    parameters: [
      station_id: [
        in: :path,
        description: "ID Hexadecimal de la estación emisora",
        type: :string,
        required: true
      ]
    ],
    request_body:
      {"Payload IoT con métricas numéricas", "application/json",
       WeatherFlowWeb.Schemas.TelemetryRequest, required: true},
    responses: [
      created:
        {"Telemetría Time-Series persistida", "application/json",
         WeatherFlowWeb.Schemas.TelemetryResponse},
      bad_request:
        {"Error de Dominio o infraestructura", "application/json",
         %OpenApiSpex.Schema{
           type: :object,
           properties: %{error: %OpenApiSpex.Schema{type: :string}}
         }}
    ]
  )

  def create(conn, params = %{"station_id" => station_id}) do
    attrs = %{
      "station_id" => station_id,
      "metrics" => Map.get(params, "metrics", %{}),
      "timestamp" => Map.get(params, "timestamp")
    }

    case TelemetryProcessingService.ingest(attrs) do
      {:ok, telemetry} ->
        conn
        |> put_status(:created)
        |> json(%{
          id: telemetry.id,
          station_id: telemetry.station_id,
          metrics: telemetry.metrics,
          timestamp: DateTime.to_iso8601(telemetry.timestamp)
        })

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end
end
