defmodule WeatherFlow.Ports.AlertRepository do
  alias WeatherFlow.Domain.Alert

  @callback insert(Alert.t()) :: {:ok, Alert.t()} | {:error, any()}
  @callback get_by_station_id(String.t()) :: {:ok, [Alert.t()]} | {:error, any()}
end
