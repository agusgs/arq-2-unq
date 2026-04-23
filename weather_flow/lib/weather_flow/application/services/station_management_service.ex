defmodule WeatherFlow.Application.Services.StationManagementService do
  @moduledoc """
  Servicio orquestador responsable de la gestión y registro de estaciones meteorológicas.
  """

  alias WeatherFlow.Domain.Station

  @spec register_station(map()) :: {:ok, Station.t()} | {:error, String.t()}
  def register_station(attrs) do
    with {:ok, station} <- Station.new(attrs),
         {:ok, saved_station} <- repository().insert(station) do
      {:ok, saved_station}
    else
      {:error, :name_already_registered} ->
        {:error, "El nombre de la estación ya se encuentra registrado."}

      {:error, reason} ->
        # Captura errores del dominio o de base de datos generales
        {:error, reason}
    end
  end

  @spec get_station(String.t()) :: {:ok, Station.t()} | {:error, :not_found} | {:error, any()}
  def get_station(id) do
    case repository().get_by_id(id) do
      {:ok, %Station{is_deleted: true}} -> {:error, :not_found}
      {:ok, station} -> {:ok, station}
      error -> error
    end
  end

  @spec list_stations() :: {:ok, [Station.t()]} | {:error, any()}
  def list_stations() do
    repository().list_all(%{is_deleted: false})
  end

  @spec update_station(String.t(), map()) :: {:ok, Station.t()} | {:error, any()}
  def update_station(id, params) do
    with {:ok, station} <- get_station(id),
         merged_attrs <- %{
           "name" => params["name"] || station.name,
           "latitude" => params["latitude"] || station.latitude,
           "longitude" => params["longitude"] || station.longitude
         },
         {:ok, updated_station} <- Station.new(merged_attrs),
         updated_with_id = %{updated_station | id: id, is_deleted: station.is_deleted},
         {:ok, saved_station} <- repository().update(updated_with_id) do
      {:ok, saved_station}
    else
      {:error, :name_already_registered} ->
        {:error, "El nombre de la estación ya se encuentra registrado."}

      error ->
        error
    end
  end

  @spec delete_station(String.t()) :: :ok | {:error, any()}
  def delete_station(id) do
    with {:ok, station} <- get_station(id),
         deleted_station = Station.delete(station),
         {:ok, _} <- repository().update(deleted_station) do
      :ok
    end
  end

  defp repository do
    Application.get_env(
      :weather_flow,
      :station_repository,
      WeatherFlow.Adapters.MongoStationRepository
    )
  end
end
