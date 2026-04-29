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

  def create(conn, %{"station_id" => station_id} = params) do
    attrs = %{
      "station_id" => station_id,
      "metrics" => Map.get(params, "metrics", %{}),
      "timestamp" => Map.get(params, "timestamp")
    }

    case TelemetryProcessingService.ingest(attrs) do
      {:ok, telemetry} ->
        conn
        |> put_status(:created)
        |> json(to_json_map(telemetry))

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end

  operation(:index,
    summary: "Buscador Avanzado de Telemetría",
    description:
      "Permite filtrar las métricas usando parámetros como station_name, min_temp, max_temp y is_alert.",
    parameters: [
      station_name: [
        in: :query,
        description: "Nombre de la estación",
        type: :string,
        required: false
      ],
      min_temp: [in: :query, description: "Ej: Filtro dinámico de mínimo. Usa prefijo min_ para cualquier métrica (min_hum, min_wind_speed, etc)", type: :number, required: false],
      max_temp: [in: :query, description: "Ej: Filtro dinámico de máximo. Usa prefijo max_ para cualquier métrica (max_hum, max_wind_speed, etc)", type: :number, required: false],
      is_alert: [
        in: :query,
        description: "Filtrar solo mediciones que dispararon alertas",
        type: :boolean,
        required: false
      ]
    ],
    responses: [
      ok:
        {"Lista de telemetría filtrada", "application/json",
         %OpenApiSpex.Schema{type: :array, items: WeatherFlowWeb.Schemas.TelemetryResponse}},
      bad_request:
        {"Error", "application/json",
         %OpenApiSpex.Schema{
           type: :object,
           properties: %{error: %OpenApiSpex.Schema{type: :string}}
         }}
    ]
  )

  def index(conn, params) do
    case TelemetryProcessingService.search_telemetry(params) do
      {:ok, telemetries} ->
        json_data = Enum.map(telemetries, &to_json_map/1)

        conn
        |> put_status(:ok)
        |> json(json_data)

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: inspect(reason)})
    end
  end

  defp to_json_map(t) do
    %{
      id: t.id,
      station_id: t.station_id,
      metrics: t.metrics,
      timestamp: DateTime.to_iso8601(t.timestamp)
    }
  end
end
