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
    with :ok <- validate_name(name),
         :ok <- validate_numeric(lat, "latitud"),
         :ok <- validate_numeric(lon, "longitud"),
         :ok <- validate_latitude(lat),
         :ok <- validate_longitude(lon) do
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

  defp validate_name(name) do
    if is_nil(name) or String.trim(name) == "" do
      {:error, "El nombre de la estación es obligatorio."}
    else
      :ok
    end
  end

  defp validate_numeric(val, field) do
    if is_float(val) or is_integer(val) do
      :ok
    else
      {:error, "La #{field} debe ser un número."}
    end
  end

  defp validate_latitude(lat) do
    if lat >= -90.0 and lat <= 90.0 do
      :ok
    else
      {:error, "La latitud debe estar comprendida entre -90.0 y 90.0 grados."}
    end
  end

  defp validate_longitude(lon) do
    if lon >= -180.0 and lon <= 180.0 do
      :ok
    else
      {:error, "La longitud debe estar comprendida entre -180.0 y 180.0 grados."}
    end
  end

  @doc """
  Marca la estación como eliminada lógicamente.
  """
  @spec delete(t()) :: t()
  def delete(%__MODULE__{} = station) do
    %{station | is_deleted: true}
  end
end
