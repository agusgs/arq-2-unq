defmodule WeatherFlow.Adapters.MongoTelemetryRepository do
  @moduledoc """
  Adaptador concreto de MongoDB inicializando `telemetries` como
  una Time-Series Collection nativa de alta performance.
  """
  @behaviour WeatherFlow.Ports.TelemetryRepository

  alias WeatherFlow.Domain.Telemetry

  @collection "telemetries"

  @doc "Construye la tabla TimeSeries la primera vez."
  def setup_indexes() do
    command = [
      create: @collection,
      timeseries: [
        timeField: "timestamp",
        metaField: "station_id",
        granularity: "seconds"
      ]
    ]

    # Ignora errores lógicos si la colección ya existe.
    case Mongo.command(:mongo, command) do
      {:ok, %{"ok" => 1.0}} -> :ok
      # NamespaceExists
      {:error, %Mongo.Error{code: 48}} -> :ok
      _ -> :ok
    end
  end

  @impl true
  def insert(%Telemetry{} = telemetry) do
    # Codificamos a ObjectId Nativo si el string es valido, sino lo pasamos crudo (Tolerancia IoT)
    bson_station_id =
      case BSON.ObjectId.decode(telemetry.station_id) do
        {:ok, object_id} -> object_id
        _ -> telemetry.station_id
      end

    doc = %{
      "station_id" => bson_station_id,
      "timestamp" => telemetry.timestamp,
      "metrics" => telemetry.metrics
    }

    case Mongo.insert_one(:mongo, @collection, doc) do
      {:ok, %Mongo.InsertOneResult{inserted_id: bson_id}} ->
        string_id = BSON.ObjectId.encode!(bson_id)
        {:ok, %{telemetry | id: string_id}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
