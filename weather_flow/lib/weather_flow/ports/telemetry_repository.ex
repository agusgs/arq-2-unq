defmodule WeatherFlow.Ports.TelemetryRepository do
  alias WeatherFlow.Domain.Telemetry

  @callback insert(Telemetry.t()) :: {:ok, Telemetry.t()} | {:error, any()}
end
