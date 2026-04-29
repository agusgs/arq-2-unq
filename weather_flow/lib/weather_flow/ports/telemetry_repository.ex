defmodule WeatherFlow.Ports.TelemetryRepository do
  @moduledoc """
  Puerto (contrato) que define las operaciones del repositorio de telemetría.
  Los adaptadores concretos deben implementar este behaviour.
  """
  alias WeatherFlow.Domain.Telemetry

  @callback insert(Telemetry.t()) :: {:ok, Telemetry.t()} | {:error, any()}
  @callback filter(map()) :: {:ok, [Telemetry.t()]} | {:error, any()}
end
