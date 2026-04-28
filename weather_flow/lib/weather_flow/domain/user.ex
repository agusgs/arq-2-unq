defmodule WeatherFlow.Domain.User do
  @moduledoc """
  Entidad inmutable que representa a un miembro de la plataforma.
  """
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
    case {attrs["first_name"] || attrs[:first_name], attrs["last_name"] || attrs[:last_name],
          attrs["email"] || attrs[:email]} do
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

  @doc """
  Suscribe de manera inmutable al usuario a una estación específica.
  Si ya posee la subscripción, ignora la adición para asegurar unicidad.
  """
  @spec subscribe(t(), String.t()) :: t()
  def subscribe(%__MODULE__{} = user, station_id) do
    new_subs = Enum.uniq([station_id | user.subscriptions])
    %{user | subscriptions: new_subs}
  end

  @doc """
  Desuscribe de manera inmutable al usuario a una estación.
  """
  @spec unsubscribe(t(), String.t()) :: t()
  def unsubscribe(%__MODULE__{} = user, station_id) do
    new_subs = List.delete(user.subscriptions, station_id)
    %{user | subscriptions: new_subs}
  end
end
