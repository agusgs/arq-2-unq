defmodule WeatherFlow.Ports.UserRepository do
  alias WeatherFlow.Domain.User

  @callback insert(User.t()) :: {:ok, User.t()} | {:error, any()}
  @callback get_by_id(String.t()) :: {:ok, User.t()} | {:error, :not_found}
  @callback get_by_email(String.t()) :: {:ok, User.t()} | {:error, :not_found}
  @callback get_all() :: [User.t()]
  @callback update(User.t()) :: {:ok, User.t()} | {:error, any()}
  @callback get_users_subscribed_to(String.t()) :: [User.t()]
end
