defmodule WeatherFlowWeb.TelemetryControllerTest do
  use WeatherFlowWeb.ConnCase, async: false

  alias WeatherFlow.Adapters.MongoTelemetryRepository

  setup do
    Mongo.delete_many!(:mongo, "telemetries", %{})
    MongoTelemetryRepository.setup_indexes()
    :ok
  end

  describe "POST /api/stations/:station_id/telemetry" do
    test "ingresa datos exitosamente validando el mapping dinámico", %{conn: conn} do
      station_id = "66144e5b3dc8a6efb349b1ca"

      payload = %{
        "metrics" => %{
          "temperature" => 33.5,
          "uv_index" => 12,
          "wind_direction" => 250.0
        }
      }

      conn = post(conn, ~p"/api/stations/#{station_id}/telemetry", payload)

      response = json_response(conn, 201)
      assert response["station_id"] == station_id
      assert Map.has_key?(response["metrics"], "uv_index")
      assert response["timestamp"] != nil
    end

    test "falla rotundamente si se mandan Strings en metricas, demostrando portectores de dominio",
         %{conn: conn} do
      station_id = "661"

      payload = %{
        "metrics" => %{
          "temperature" => "high"
        }
      }

      conn = post(conn, ~p"/api/stations/#{station_id}/telemetry", payload)

      assert %{
               "error" =>
                 "Todas las lecturas de los sensores deben ser valores numéricos estrictamente."
             } = json_response(conn, 400)
    end
  end
end
