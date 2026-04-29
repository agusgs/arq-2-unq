defmodule WeatherFlow.Ports.AlertRepository do
  @moduledoc """
  Puerto (contrato) que define las operaciones del repositorio de alertas.
  Los adaptadores concretos deben implementar este behaviour.
  """
  alias WeatherFlow.Domain.Alert

  @callback insert(Alert.t()) :: {:ok, Alert.t()} | {:error, any()}
  @callback get_by_station_id(String.t()) :: {:ok, [Alert.t()]} | {:error, any()}
end
