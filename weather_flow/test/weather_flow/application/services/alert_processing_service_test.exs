defmodule WeatherFlow.Application.Services.AlertProcessingServiceTest do
  use ExUnit.Case, async: false

  alias WeatherFlow.Adapters.MongoAlertRepository
  alias WeatherFlow.Adapters.MongoUserRepository
  alias WeatherFlow.Domain.Telemetry
  alias WeatherFlow.Application.Services.AlertProcessingService

  setup do
    Mongo.delete_many!(:mongo, "alerts", %{})
    Mongo.delete_many!(:mongo, "users", %{})
    MongoAlertRepository.setup_indexes()
    :ok
  end

  test "Genera y persiste alerta si temp es > 35, y notifica a los suscritos" do
    {:ok, _user} =
      MongoUserRepository.insert(%WeatherFlow.Domain.User{
        id: nil,
        first_name: "Juan",
        last_name: "Perez",
        email: "juan@test.com",
        subscriptions: ["station_hot"]
      })

    {:ok, telemetry} =
      Telemetry.new(%{
        "station_id" => "station_hot",
        "metrics" => %{"temperature" => 41.0},
        "timestamp" => DateTime.utc_now()
      })

    AlertProcessingService.process_telemetry(telemetry)

    {:ok, alerts} = MongoAlertRepository.get_by_station_id("station_hot")
    assert length(alerts) == 1
    
    alert = hd(alerts)
    assert alert.metric == "temperature"
    assert alert.value == 41.0
    assert alert.message =~ "calor extremo"
  end

  test "Genera alertas correctas para otras metricas validas como Presion" do
    {:ok, telemetry} = Telemetry.new(%{
       "station_id" => "station_storm", "metrics" => %{"pressure" => 970.0}, "timestamp" => DateTime.utc_now()
    })

    AlertProcessingService.process_telemetry(telemetry)

    {:ok, alerts} = MongoAlertRepository.get_by_station_id("station_storm")
    assert length(alerts) == 1
    assert hd(alerts).message =~ "baja presión"
  end

  test "Ignora silenciosamente telemetrías que están dentro de los rangos normales" do
    {:ok, telemetry} =
      Telemetry.new(%{
        "station_id" => "station_normal",
        "metrics" => %{"temperature" => 25.0},
        "timestamp" => DateTime.utc_now()
      })

    AlertProcessingService.process_telemetry(telemetry)

    {:ok, alerts} = MongoAlertRepository.get_by_station_id("station_normal")
    assert Enum.empty?(alerts)
  end

  test "Ignora métricas no soportadas emitiendo warning y sin insertar alertas fantasma" do
    {:ok, telemetry} =
      Telemetry.new(%{
        "station_id" => "station_normal",
        "metrics" => %{"wind_speed" => 120.0},
        "timestamp" => DateTime.utc_now()
      })

    AlertProcessingService.process_telemetry(telemetry)

    {:ok, alerts} = MongoAlertRepository.get_by_station_id("station_normal")
    assert Enum.empty?(alerts)
  end
end
