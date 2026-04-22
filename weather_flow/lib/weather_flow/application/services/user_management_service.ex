defmodule WeatherFlow.Application.Services.UserManagementService do
  alias WeatherFlow.Domain.User

  defp repo,
    do:
      Application.get_env(
        :weather_flow,
        :user_repository,
        WeatherFlow.Adapters.MongoUserRepository
      )

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

  @spec update_user(String.t(), map()) :: {:ok, User.t()} | {:error, any()}
  def update_user(id, params) do
    with {:ok, user} <- get_user(id),
         merged_attrs <- %{
           "id" => user.id,
           "first_name" => params["first_name"] || user.first_name,
           "last_name" => params["last_name"] || user.last_name,
           "email" => params["email"] || user.email,
           "subscriptions" => user.subscriptions
         },
         {:ok, updated_user} <- User.new(merged_attrs),
         {:ok, saved_user} <- repo().update(updated_user) do
      {:ok, saved_user}
    else
      {:error, :email_already_registered} -> {:error, "El email ya se encuentra registrado."}
      error -> error
    end
  end

  @spec delete_user(String.t()) :: :ok | {:error, any()}
  def delete_user(id), do: repo().delete(id)
end
