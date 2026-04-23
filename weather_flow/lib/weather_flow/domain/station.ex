defmodule WeatherFlow.Domain.Station do
  @moduledoc """
  Entidad que representa una Estación Meteorológica en el dominio.
  """

  @enforce_keys [:name, :latitude, :longitude]
  defstruct [:id, :name, :latitude, :longitude, is_deleted: false]

  @type t :: %__MODULE__{
          id: String.t() | nil,
          name: String.t(),
          latitude: float(),
          longitude: float(),
          is_deleted: boolean()
        }

  @doc """
  Construye una nueva estructura `Station`. Aplica reglas de validación en tiempo de creación.
  Valida la presencia del nombre, que la latitud esté entre -90.0 y 90.0, y la longitud entre -180.0 y 180.0
  """
  @spec new(map()) :: {:ok, t()} | {:error, String.t()}
  def new(%{"name" => name, "latitude" => lat, "longitude" => lon}) do
    cond do
      is_nil(name) or String.trim(name) == "" ->
        {:error, "El nombre de la estación es obligatorio."}

      not is_float(lat) and not is_integer(lat) ->
        {:error, "La latitud debe ser un número."}

      not is_float(lon) and not is_integer(lon) ->
        {:error, "La longitud debe ser un número."}

      lat < -90.0 or lat > 90.0 ->
        {:error, "La latitud debe estar comprendida entre -90.0 y 90.0 grados."}

      lon < -180.0 or lon > 180.0 ->
        {:error, "La longitud debe estar comprendida entre -180.0 y 180.0 grados."}

      true ->
        {:ok,
         %__MODULE__{
           name: String.trim(name),
           latitude: lat * 1.0,
           longitude: lon * 1.0,
           is_deleted: false
         }}
    end
  end

  def new(_), do: {:error, "Los parámetros name, latitude y longitude son obligatorios."}

  @doc """
  Marca la estación como eliminada lógicamente.
  """
  @spec delete(t()) :: t()
  def delete(%__MODULE__{} = station) do
    %{station | is_deleted: true}
  end
end
