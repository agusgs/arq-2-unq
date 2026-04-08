defmodule WeatherFlow.MockUserRepository do
  @moduledoc """
  Implementación simulada del Puerto UserRepository.
  Utilizada exclusivamente para pruebas de unidad de ExUnit de las capas superiores.
  """
  @behaviour WeatherFlow.Ports.UserRepository

  alias WeatherFlow.Domain.User

  @impl true
  def insert(%User{email: "duplicate@example.com"}), do: {:error, :email_already_registered}
  def insert(%User{} = user), do: {:ok, %{user | id: "mock_id_123"}}

  @impl true
  def get_by_id("mock_id_123"),
    do:
      {:ok,
       %User{
         id: "mock_id_123",
         first_name: "Mock",
         last_name: "User",
         email: "mock@example.com",
         subscriptions: []
       }}

  def get_by_id(_), do: {:error, :not_found}

  @impl true
  def get_by_email("mock@example.com"),
    do:
      {:ok,
       %User{
         id: "mock_id_123",
         first_name: "Mock",
         last_name: "User",
         email: "mock@example.com",
         subscriptions: []
       }}

  def get_by_email(_), do: {:error, :not_found}

  @impl true
  def get_all(),
    do: [
      %User{
        id: "mock_id_123",
        first_name: "Mock",
        last_name: "User",
        email: "mock@example.com",
        subscriptions: []
      }
    ]

  @impl true
  def update(%User{id: "mock_id_123"} = user), do: {:ok, user}
  def update(%User{}), do: {:error, :missing_id}
end
