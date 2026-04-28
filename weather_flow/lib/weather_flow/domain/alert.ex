defmodule WeatherFlow.Domain.Alert do
  @moduledoc """
  Entidad que representa alertas meteorológicas disparadas por anomalías en sensores.
  """
  @enforce_keys [:station_id, :metric, :value, :message, :timestamp]
  defstruct [:id, :station_id, :metric, :value, :message, :timestamp]

  @type t :: %__MODULE__{
          id: String.t() | nil,
          station_id: String.t(),
          metric: String.t(),
          value: float() | integer(),
          message: String.t(),
          timestamp: DateTime.t()
        }

  @doc """
  Construye una entidad Alert pura.
  """
  def new(attrs) do
    station_id = attrs["station_id"] || attrs[:station_id]
    metric = attrs["metric"] || attrs[:metric]
    value = attrs["value"] || attrs[:value]
    message = attrs["message"] || attrs[:message]
    timestamp = attrs["timestamp"] || attrs[:timestamp] || DateTime.utc_now()

    with {:ok, station_id} <- validate_string(station_id, "station_id"),
         {:ok, metric} <- validate_string(metric, "metric"),
         {:ok, message} <- validate_string(message, "message"),
         {:ok, _val} <- validate_number(value, "value"),
         {:ok, _dt} <- validate_timestamp(timestamp) do
      alert = %__MODULE__{
        id: attrs["id"] || attrs[:id],
        station_id: station_id,
        metric: metric,
        value: value,
        message: message,
        timestamp: timestamp
      }

      {:ok, alert}
    else
      err -> err
    end
  end

  defp validate_string(val, _field) when is_binary(val) and byte_size(val) > 0, do: {:ok, val}
  defp validate_string(_, field), do: {:error, "#{field} debe ser un string válido."}

  defp validate_number(val, _field) when is_number(val), do: {:ok, val}
  defp validate_number(_, field), do: {:error, "#{field} debe ser numérico."}

  defp validate_timestamp(%DateTime{} = dt), do: {:ok, dt}

  defp validate_timestamp(_),
    do: {:error, "timestamp debe ser una esctructura %DateTime{} válida."}
end
