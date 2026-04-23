defmodule WeatherFlowWeb.Integration.WeatherFlowE2ETest do
  use WeatherFlowWeb.ConnCase, async: false

  test "simula el flujo completo (E2E) de la plataforma meteorológica", %{conn: conn} do
    # 1. Crear un usuario
    conn_user =
      post(conn, "/api/users", %{
        "first_name" => "Alan",
        "last_name" => "Turing",
        "email" => "alan@turing.com"
      })

    user_response = json_response(conn_user, 201)
    user_id = user_response["id"]
    assert user_id != nil

    # 2. Crear una estación
    conn_station =
      post(conn, "/api/stations", %{
        "station" => %{
          "name" => "Estación E2E",
          "latitude" => -34.6,
          "longitude" => -58.4
        }
      })

    station_response = json_response(conn_station, 201)
    station_id = station_response["id"]
    assert station_id != nil

    # 3. Suscribir al usuario a la estación
    conn_sub = post(conn, "/api/users/#{user_id}/subscriptions", %{"station_id" => station_id})
    sub_response = json_response(conn_sub, 200)
    assert station_id in sub_response["subscriptions"]

    # 4. Ingestar Telemetría Normal
    conn_telemetry1 =
      post(conn, "/api/stations/#{station_id}/telemetry", %{
        "metrics" => %{
          "temperature" => 25.0,
          "humidity" => 40.0
        }
      })

    assert json_response(conn_telemetry1, 201)["station_id"] == station_id

    # Esperamos un instante para que el reloj avance y la segunda telemetría tenga otro timestamp
    Process.sleep(10)

    # 5. Ingestar Telemetría Extrema (Debería gatillar alerta)
    conn_telemetry2 =
      post(conn, "/api/stations/#{station_id}/telemetry", %{
        "metrics" => %{
          # Mayor a 40 dispara alerta
          "temperature" => 45.0,
          # Mayor a 90 dispara alerta
          "humidity" => 95.0
        }
      })

    assert json_response(conn_telemetry2, 201)["station_id"] == station_id

    # 6. Esperar sincronización del PubSub (Worker Asíncrono)
    Process.sleep(200)

    # 7. Verificar que se hayan generado alertas
    conn_alerts = get(conn, "/api/stations/#{station_id}/alerts")
    alerts_response = json_response(conn_alerts, 200)

    assert length(alerts_response) > 0
    # Deberían ser 2 alertas, una por temperatura y otra por humedad
    assert Enum.any?(alerts_response, fn a -> a["metric"] == "temperature" end)
    assert Enum.any?(alerts_response, fn a -> a["metric"] == "humidity" end)

    # 8. Verificación del Buscador Avanzado (Solo mediciones anómalas)
    conn_search =
      get(conn, "/api/telemetry", %{"station_name" => "Estación E2E", "is_alert" => "true"})

    search_response = json_response(conn_search, 200)

    # Solo la telemetría extrema debería volver
    assert length(search_response) == 1
    assert hd(search_response)["metrics"]["temperature"] == 45.0

    # 9. Soft Delete de la Estación
    conn_delete = delete(conn, "/api/stations/#{station_id}")
    assert response(conn_delete, 204)

    # Verificar que el usuario ya no la vea al consultar por ID
    conn_get_deleted = get(conn, "/api/stations/#{station_id}")
    assert json_response(conn_get_deleted, 404)
  end
end
