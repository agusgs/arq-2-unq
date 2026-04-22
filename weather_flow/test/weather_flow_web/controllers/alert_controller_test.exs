defmodule WeatherFlowWeb.AlertControllerTest do
  use WeatherFlowWeb.ConnCase, async: false

  alias WeatherFlow.Adapters.MongoAlertRepository
  alias WeatherFlow.Domain.Alert

  setup do
    Mongo.delete_many!(:mongo, "alerts", %{})
    MongoAlertRepository.setup_indexes()
    :ok
  end

  describe "GET /api/stations/:station_id/alerts" do
    test "Lista todas las alertas generadas de una estacion particular cronológicamente", %{
      conn: conn
    } do
      station_id = "66144e5b3dc8a6efb349b1cc"

      # Generamos historial de alertas manual 
      {:ok, _} = MongoAlertRepository.insert(%Alert{
        id: nil, station_id: station_id, metric: "temperature", value: 37.0, message: "A", timestamp: DateTime.add(DateTime.utc_now(), -10, :second)
      })

      {:ok, _} =
        MongoAlertRepository.insert(%Alert{
          id: nil,
          station_id: station_id,
          metric: "temperature",
          value: 41.0,
          message: "B",
          timestamp: DateTime.utc_now()
        })

      conn = get(conn, ~p"/api/stations/#{station_id}/alerts")

      response = json_response(conn, 200)
      assert length(response) == 2
      # La ultima insertada debe venir primero por orden cronológico reverso
      assert hd(response)["message"] == "B"
    end

    test "Devuelve lista vacia si la estacion no tiene alertas", %{conn: conn} do
      conn = get(conn, ~p"/api/stations/ghost_station/alerts")
      assert json_response(conn, 200) == []
    end
  end
end
