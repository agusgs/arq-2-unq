defmodule WeatherFlow.Application.Workers.AlertEngineTest do
  use ExUnit.Case, async: false

  alias WeatherFlow.Application.Workers.AlertEngine
  alias WeatherFlow.Domain.Telemetry

  test "El engine procesa los mensajes de pubsub correctamente sin crashear" do
    {:ok, telemetry} =
      Telemetry.new(%{
        "station_id" => "mock",
        "metrics" => %{"temperature" => 20.0},
        "timestamp" => DateTime.utc_now()
      })

    assert {:noreply, %{}} = AlertEngine.handle_info({:telemetry_inserted, telemetry}, %{})
  end
end
