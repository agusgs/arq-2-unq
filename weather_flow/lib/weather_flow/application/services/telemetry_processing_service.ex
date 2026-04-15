defmodule WeatherFlow.Application.Services.TelemetryProcessingService do
  @moduledoc """
  Servicio orquestador responsable de la ingesta de telemetría proveniente de
  las estaciones meteorológicas.
  """
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
  inyecta la fecha UTC actual si falta, y persiste directamente en la Time-Series
  orientada a la alta recurrencia de red.
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
      {:ok, saved}
    else
      {:error, reason} when is_binary(reason) ->
        {:error, reason}

      {:error, reason} ->
        {:error, "Falla en la BBDD TimeSeries durante ingesta: #{inspect(reason)}"}
    end
  end
end
