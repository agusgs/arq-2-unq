defmodule WeatherFlow.Application.Services.StationManagementService do
  @moduledoc """
  Servicio orquestador responsable de la gestión y registro de estaciones meteorológicas.
  Actúa como el caso de uso (Use Case) principal.
  """

  alias WeatherFlow.Domain.Station

  @doc """
  Registra una nueva estación. Aplica reglas de dominio y luego interactúa con el puerto abstracto.
  """
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

  @doc """
  Recupera una estación por ID.
  """
  @spec get_station(String.t()) :: {:ok, Station.t()} | {:error, :not_found} | {:error, any()}
  def get_station(id) do
    repository().get_by_id(id)
  end

  @doc """
  Lista todas las estaciones disponibles.
  """
  @spec list_stations() :: {:ok, [Station.t()]} | {:error, any()}
  def list_stations() do
    repository().list_all()
  end

  # Resuelve el adaptador en tiempo de ejecución para facilitar inyecciones de test o alternativas.
  defp repository do
    Application.get_env(
      :weather_flow,
      :station_repository,
      WeatherFlow.Adapters.MongoStationRepository
    )
  end
end
