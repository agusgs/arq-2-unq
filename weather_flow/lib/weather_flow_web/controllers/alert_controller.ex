defmodule WeatherFlowWeb.AlertController do
  use WeatherFlowWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias WeatherFlow.Adapters.MongoAlertRepository
  alias WeatherFlow.Domain.Alert

  tags(["Alerts"])

  operation(:index,
    summary: "Listar Historial de Alertas",
    description:
      "Devuelve el historial de alertas disparadas por el motor analítico correspondientes a una estación climática en particular de más recientes a más antiguas.",
    parameters: [
      station_id: [
        in: :path,
        description: "ID Hexadecimal de la estación",
        type: :string,
        required: true
      ]
    ],
    responses: [
      ok:
        {"Lista de alertas ordenadas cronológicamente", "application/json",
         %OpenApiSpex.Schema{type: :array, items: WeatherFlowWeb.Schemas.Alert}}
    ]
  )

  def index(conn, %{"station_id" => station_id}) do
    {:ok, alerts} = MongoAlertRepository.get_by_station_id(station_id)

    conn
    |> put_status(:ok)
    |> json(Enum.map(alerts, fn %Alert{} = alert ->
      %{
        id: alert.id,
        station_id: alert.station_id,
        metric: alert.metric,
        value: alert.value,
        message: alert.message,
        timestamp: DateTime.to_iso8601(alert.timestamp)
      }
    end))
  end
end
