defmodule WeatherFlow.Application.Services.AlertProcessingServiceTest do
  use WeatherFlow.DataCase, async: false

  alias WeatherFlow.Adapters.MongoAlertRepository
  alias WeatherFlow.Adapters.MongoUserRepository
  alias WeatherFlow.Domain.Telemetry
  alias WeatherFlow.Application.Services.AlertProcessingService

  test "Genera y persiste alerta si temp es > 35, y notifica a los suscritos" do
    {:ok, _user} =
      MongoUserRepository.insert(%WeatherFlow.Domain.User{
        id: nil,
        first_name: "Juan",
        last_name: "Perez",
        email: "juan@test.com",
        subscriptions: ["111111111111111111111111"]
      })

    {:ok, telemetry} =
      Telemetry.new(%{
        "station_id" => "111111111111111111111111",
        "metrics" => %{"temperature" => 41.0},
        "timestamp" => DateTime.utc_now()
      })

    AlertProcessingService.process_telemetry(telemetry)

    {:ok, alerts} = MongoAlertRepository.get_by_station_id("111111111111111111111111")
    assert length(alerts) == 1

    alert = hd(alerts)
    assert alert.metric == "temperature"
    assert alert.value == 41.0
    assert alert.message =~ "calor extremo"
  end

  test "Genera alertas correctas para otras metricas validas como Presion" do
    {:ok, telemetry} =
      Telemetry.new(%{
        "station_id" => "222222222222222222222222",
        "metrics" => %{"pressure" => 970.0},
        "timestamp" => DateTime.utc_now()
      })

    AlertProcessingService.process_telemetry(telemetry)

    {:ok, alerts} = MongoAlertRepository.get_by_station_id("222222222222222222222222")
    assert length(alerts) == 1
    assert hd(alerts).message =~ "baja presión"
  end

  test "Ignora silenciosamente telemetrías que están dentro de los rangos normales" do
    {:ok, telemetry} =
      Telemetry.new(%{
        "station_id" => "333333333333333333333333",
        "metrics" => %{"temperature" => 25.0},
        "timestamp" => DateTime.utc_now()
      })

    AlertProcessingService.process_telemetry(telemetry)

    {:ok, alerts} = MongoAlertRepository.get_by_station_id("333333333333333333333333")
    assert Enum.empty?(alerts)
  end

  test "Ignora métricas no soportadas emitiendo warning y sin insertar alertas fantasma" do
    {:ok, telemetry} =
      Telemetry.new(%{
        "station_id" => "333333333333333333333333",
        "metrics" => %{"wind_speed" => 120.0},
        "timestamp" => DateTime.utc_now()
      })

    AlertProcessingService.process_telemetry(telemetry)

    {:ok, alerts} = MongoAlertRepository.get_by_station_id("333333333333333333333333")
    assert Enum.empty?(alerts)
  end
end
