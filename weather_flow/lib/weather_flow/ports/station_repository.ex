defmodule WeatherFlow.Ports.StationRepository do
  @moduledoc """
  Contrato agnóstico de infraestructura para la persistencia de estaciones.
  """
  alias WeatherFlow.Domain.Station

  @callback insert(Station.t()) :: {:ok, Station.t()} | {:error, any()}
  @callback get_by_id(String.t()) :: {:ok, Station.t()} | {:error, :not_found} | {:error, any()}
  @callback list_all(map()) :: {:ok, [Station.t()]} | {:error, any()}
  @callback update(Station.t()) :: {:ok, Station.t()} | {:error, any()}
end
