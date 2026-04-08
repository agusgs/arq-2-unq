defmodule WeatherFlow.Application.Services.UserManagementService do
  alias WeatherFlow.Domain.User

  defp repo, do: Application.get_env(:weather_flow, :user_repository, WeatherFlow.Adapters.MongoUserRepository)

  @spec register_user(map() | keyword()) :: {:ok, User.t()} | {:error, any()}
  def register_user(attrs) do
    with {:ok, user} <- User.new(attrs),
         {:ok, inserted_user} <- repo().insert(user) do
      {:ok, inserted_user}
    else
      {:error, :email_already_registered} -> {:error, "El email ya se encuentra registrado."}
      error -> error
    end
  end

  @spec get_user(String.t()) :: {:ok, User.t()} | {:error, :not_found}
  def get_user(id), do: repo().get_by_id(id)

  @spec list_users() :: [User.t()]
  def list_users(), do: repo().get_all()
end
