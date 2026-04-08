defmodule WeatherFlow.Domain.User do
  @enforce_keys [:first_name, :last_name, :email]
  defstruct [:id, :first_name, :last_name, :email, subscriptions: []]

  @type t :: %__MODULE__{
          id: String.t() | nil,
          first_name: String.t(),
          last_name: String.t(),
          email: String.t(),
          subscriptions: [String.t()]
        }

  @spec new(map() | keyword()) :: {:ok, t()} | {:error, String.t()}
  def new(attrs) do
    case {attrs["first_name"] || attrs[:first_name], attrs["last_name"] || attrs[:last_name], attrs["email"] || attrs[:email]} do
      {first, last, email} when is_binary(first) and is_binary(last) and is_binary(email) ->
        user = %__MODULE__{
          id: attrs["id"] || attrs[:id],
          first_name: first,
          last_name: last,
          email: email,
          subscriptions: attrs["subscriptions"] || attrs[:subscriptions] || []
        }

        {:ok, user}

      _ ->
        {:error, "first_name, last_name y email son requeridos y deben ser un string"}
    end
  end
end
