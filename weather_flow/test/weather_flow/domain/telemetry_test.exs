defmodule WeatherFlow.Domain.TelemetryTest do
  use ExUnit.Case, async: true
  alias WeatherFlow.Domain.Telemetry

  describe "new/1" do
    test "crea Data correctamente si todos los datos y métricas son válidas" do
      attrs = %{
        "station_id" => "66144e5b3dc8a6efb349b1aa",
        "metrics" => %{"temperature" => 25.5, "humidity" => 60, "wind_speed" => 12.1},
        "timestamp" => DateTime.utc_now()
      }

      assert {:ok, telemetry} = Telemetry.new(attrs)
      assert telemetry.station_id == "66144e5b3dc8a6efb349b1aa"
      assert map_size(telemetry.metrics) == 3
      assert %DateTime{} = telemetry.timestamp
    end

    test "falla si inyectan basura (Strings, Bools) en los metrics" do
      attrs = %{
        "station_id" => "66144e5b3dc8a6efb349b1aa",
        "metrics" => %{"temperature" => "treinta grados", "bool" => false}
      }

      assert {:error,
              "Todas las lecturas de los sensores deben ser valores numéricos estrictamente."} =
               Telemetry.new(attrs)
    end

    test "falla si el diccionario está vacío" do
      attrs = %{"station_id" => "661", "metrics" => %{}}
      assert {:error, "Se requiere al menos una métrica."} = Telemetry.new(attrs)
    end
  end
end
