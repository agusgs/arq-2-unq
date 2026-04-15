defmodule WeatherFlow.Application.Services.TelemetryProcessingServiceTest do
  use ExUnit.Case, async: false

  alias WeatherFlow.Application.Services.TelemetryProcessingService
  alias WeatherFlow.Adapters.MongoTelemetryRepository

  setup do
    Mongo.delete_many!(:mongo, "telemetries", %{})
    MongoTelemetryRepository.setup_indexes()
    :ok
  end

  describe "ingest/1" do
    test "ingesta y guarda datos de telemetria correctamente en la coleccion timeseries" do
      attrs = %{
        "station_id" => "66144e5b3dc8a6efb349b1cc",
        "metrics" => %{"temp" => 20.0, "hum" => 40.0}
      }

      assert {:ok, telemetry} = TelemetryProcessingService.ingest(attrs)
      assert telemetry.station_id == "66144e5b3dc8a6efb349b1cc"
      assert Map.has_key?(telemetry.metrics, "temp")
      assert telemetry.id != nil
    end

    test "falla si las metricas no son numericas desde el servicio" do
      attrs = %{
        "station_id" => "661",
        "metrics" => %{"hum" => "high"}
      }

      assert {:error,
              "Todas las lecturas de los sensores deben ser valores numéricos estrictamente."} =
               TelemetryProcessingService.ingest(attrs)
    end

    test "parsea correctamente y guarda si inyectan timestamps externos que vienen en ISO8601 string genéricos desde la request" do
      iso_time = "2023-11-01T15:00:00Z"

      attrs = %{
        "station_id" => "66144e",
        "metrics" => %{"temp" => 1},
        "timestamp" => iso_time
      }

      assert {:ok, telemetry} = TelemetryProcessingService.ingest(attrs)
      assert DateTime.to_iso8601(telemetry.timestamp) == iso_time
    end
  end
end
