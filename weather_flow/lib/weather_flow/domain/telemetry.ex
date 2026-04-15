defmodule WeatherFlow.Domain.Telemetry do
  @moduledoc """
  Entidad pura y polimórfica que representa un paquete de mediciones.
  """
  @enforce_keys [:station_id, :metrics, :timestamp]
  defstruct [:id, :station_id, :metrics, :timestamp]

  @type t :: %__MODULE__{
          id: String.t() | nil,
          station_id: String.t(),
          metrics: %{String.t() => float() | integer()},
          timestamp: DateTime.t()
        }

  @doc """
  Construye de forma segura una entidad. Valida específicamente el Map dinámico.
  """
  @spec new(map() | keyword()) :: {:ok, t()} | {:error, String.t()}
  def new(attrs) do
    station_id = attrs["station_id"] || attrs[:station_id]
    metrics = attrs["metrics"] || attrs[:metrics] || %{}
    timestamp = attrs["timestamp"] || attrs[:timestamp]

    with :ok <- validate_metrics(metrics),
         {:ok, timestamp} <- validate_timestamp(timestamp),
         {:ok, station_id} <- validate_id(station_id) do
      telemetry = %__MODULE__{
        id: attrs["id"] || attrs[:id],
        station_id: station_id,
        metrics: metrics,
        timestamp: timestamp
      }

      {:ok, telemetry}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp validate_id(id) when is_binary(id) and byte_size(id) > 0, do: {:ok, id}
  defp validate_id(_), do: {:error, "station_id es requerido y debe ser un ID válido."}

  defp validate_metrics(metrics) when map_size(metrics) == 0,
    do: {:error, "Se requiere al menos una métrica."}

  defp validate_metrics(metrics) when is_map(metrics) do
    all_valid? = Enum.all?(metrics, fn {_key, value} -> is_number(value) end)

    if all_valid? do
      :ok
    else
      {:error, "Todas las lecturas de los sensores deben ser valores numéricos estrictamente."}
    end
  end

  defp validate_metrics(_), do: {:error, "metrics debe ser un diccionario/objeto JSON."}

  defp validate_timestamp(%DateTime{} = dt), do: {:ok, dt}

  defp validate_timestamp(_),
    do: {:error, "El parametro timestamp debe ser obligatoriamente una fecha %DateTime{} válida."}
end
