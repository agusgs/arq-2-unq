defmodule WeatherFlow.Application.Services.SubscriptionManagementService do
  @moduledoc """
  Servicio orquestador responsable de gestionar las suscripciones de los
  usuarios a las estaciones meteorológicas.
  """

  alias WeatherFlow.Domain.User
  alias WeatherFlow.Application.Services.StationManagementService

  defp user_repo,
    do:
      Application.get_env(
        :weather_flow,
        :user_repository,
        WeatherFlow.Adapters.MongoUserRepository
      )

  @doc """
  Intenta suscribir a un usuario a una estación de manera idempotente.
  """
  @spec subscribe(String.t(), String.t()) ::
          {:ok, User.t()} | {:error, :not_found} | {:error, :internal_error, any()}
  def subscribe(user_id, station_id) do
    with {:ok, user} <- user_repo().get_by_id(user_id),
         {:ok, _station} <- StationManagementService.get_station(station_id),
         updated_user <- User.subscribe(user, station_id),
         {:ok, saved_user} <- user_repo().update(updated_user) do
      {:ok, saved_user}
    else
      {:error, :not_found} -> {:error, :not_found}
      {:error, reason} -> {:error, :internal_error, reason}
    end
  end

  @doc """
  Desuscribe al usuario de la estación.
  """
  @spec unsubscribe(String.t(), String.t()) ::
          {:ok, User.t()} | {:error, :not_found} | {:error, :internal_error, any()}
  def unsubscribe(user_id, station_id) do
    with {:ok, user} <- user_repo().get_by_id(user_id),
         updated_user <- User.unsubscribe(user, station_id),
         {:ok, saved_user} <- user_repo().update(updated_user) do
      {:ok, saved_user}
    else
      {:error, :not_found} -> {:error, :not_found}
      {:error, reason} -> {:error, :internal_error, reason}
    end
  end
end
