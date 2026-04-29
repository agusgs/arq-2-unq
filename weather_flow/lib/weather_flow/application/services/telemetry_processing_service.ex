defmodule WeatherFlow.Application.Services.TelemetryProcessingService do
  @moduledoc """
  Servicio responsable de la ingesta de telemetría proveniente de
  las estaciones meteorológicas.
  """
  alias WeatherFlow.Application.Services.StationManagementService
  alias WeatherFlow.Domain.Telemetry

  defp repo do
    Application.get_env(
      :weather_flow,
      :telemetry_repository,
      WeatherFlow.Adapters.MongoTelemetryRepository
    )
  end

  @doc """
  Recibe un paquete de métricas. Construye la entidad pura validando tipos,
  inyecta la fecha UTC actual si falta, y persiste directamente en la Time-Series.
  """
  @spec ingest(map() | keyword()) :: {:ok, Telemetry.t()} | {:error, String.t()}
  def ingest(attrs) do
    timestamp_input = attrs["timestamp"] || attrs[:timestamp]

    timestamp =
      case timestamp_input do
        nil ->
          DateTime.utc_now()

        %DateTime{} = dt ->
          dt

        binary_dt when is_binary(binary_dt) ->
          case DateTime.from_iso8601(binary_dt) do
            {:ok, datetime, _offset} -> datetime
            _ -> binary_dt
          end

        other ->
          other
      end

    parsed_attrs =
      attrs
      |> Map.drop(["timestamp", :timestamp])
      |> Map.put(:timestamp, timestamp)

    with {:ok, telemetry} <- Telemetry.new(parsed_attrs),
         {:ok, saved} <- repo().insert(telemetry) do
      Phoenix.PubSub.broadcast(
        WeatherFlow.PubSub,
        "telemetry_stream",
        {:telemetry_inserted, saved}
      )

      {:ok, saved}
    else
      {:error, reason} when is_binary(reason) ->
        {:error, reason}

      {:error, reason} ->
        {:error, "Falla en la BBDD TimeSeries durante ingesta: #{inspect(reason)}"}
    end
  end

  @doc """
  Busca telemetrías aplicando filtros avanzados.
  Soporta resolución del `station_id` a través del `station_name`.
  Permite filtrar dinámicamente por cualquier métrica enviando `min_METRICA` o `max_METRICA`.
  """
  @spec search_telemetry(map()) :: {:ok, [Telemetry.t()]} | {:error, any()}
  def search_telemetry(params) do
    filters =
      %{}
      |> parse_boolean_filter(params, "is_alert", :is_alert)
      |> parse_metric_filters(params)

    case resolve_and_put_station_id(filters, params["station_name"]) do
      {:ok, final_filters} -> repo().filter(final_filters)
      {:error, :not_found} -> {:ok, []}
      {:error, reason} -> {:error, reason}
    end
  end

  defp parse_boolean_filter(filters, params, key, dest_key) do
    if params[key] in ["true", true] do
      Map.put(filters, dest_key, true)
    else
      filters
    end
  end

  defp parse_metric_filters(filters, params) do
    Enum.reduce(params, filters, fn
      {"min_" <> metric, val}, acc -> put_in_metric_filter(acc, metric, :min, val)
      {"max_" <> metric, val}, acc -> put_in_metric_filter(acc, metric, :max, val)
      _, acc -> acc
    end)
  end

  defp put_in_metric_filter(filters, metric, bound, val) do
    metric_filters = Map.get(filters, :metrics, %{})
    specific_metric = Map.get(metric_filters, metric, %{})

    updated_specific = Map.put(specific_metric, bound, val)
    updated_metrics = Map.put(metric_filters, metric, updated_specific)

    Map.put(filters, :metrics, updated_metrics)
  end

  defp resolve_and_put_station_id(filters, nil), do: {:ok, filters}

  defp resolve_and_put_station_id(filters, name) do
    case StationManagementService.get_station_by_name(name) do
      {:ok, station} -> {:ok, Map.put(filters, :station_id, station.id)}
      {:error, :not_found} -> {:error, :not_found}
      error -> error
    end
  end
end
