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

  @impl true
  def filter(filters) do
    []
    |> build_match_stage(filters)
    |> build_lookup_stage(filters)
    |> build_sort_stage()
    |> run_aggregation()
  end

  defp build_match_stage(pipeline, filters) do
    match =
      %{}
      |> put_station_match(filters[:station_id])
      |> put_metrics_match(filters[:metrics])

    if map_size(match) > 0, do: pipeline ++ [%{"$match" => match}], else: pipeline
  end

  defp put_station_match(match, nil), do: match

  defp put_station_match(match, station_id) do
    bson_id =
      case BSON.ObjectId.decode(station_id) do
        {:ok, id} -> id
        _ -> station_id
      end

    Map.put(match, "station_id", bson_id)
  end

  defp put_metrics_match(match, nil), do: match

  defp put_metrics_match(match, metrics) do
    Enum.reduce(metrics, match, fn {metric_name, bounds}, acc ->
      mongo_bounds =
        %{}
        |> put_bound("$gte", bounds[:min])
        |> put_bound("$lte", bounds[:max])

      if map_size(mongo_bounds) > 0 do
        Map.put(acc, "metrics.#{metric_name}", mongo_bounds)
      else
        acc
      end
    end)
  end

  defp put_bound(mongo_bounds, _operator, nil), do: mongo_bounds
  defp put_bound(mongo_bounds, operator, val), do: Map.put(mongo_bounds, operator, to_float(val))

  defp build_lookup_stage(pipeline, %{is_alert: true}) do
    pipeline ++
      [
        %{
          "$lookup" => %{
            "from" => "alerts",
            "let" => %{"ts" => "$timestamp", "sid" => "$station_id"},
            "pipeline" => [
              %{
                "$match" => %{
                  "$expr" => %{
                    "$and" => [
                      %{"$eq" => ["$station_id", "$$sid"]},
                      %{"$eq" => ["$timestamp", "$$ts"]}
                    ]
                  }
                }
              }
            ],
            "as" => "alert_data"
          }
        },
        %{"$match" => %{"alert_data" => %{"$ne" => []}}}
      ]
  end

  defp build_lookup_stage(pipeline, _filters), do: pipeline

  defp build_sort_stage(pipeline) do
    pipeline ++ [%{"$sort" => %{"timestamp" => -1}}]
  end

  defp run_aggregation(pipeline) do
    telemetries =
      Mongo.aggregate(:mongo, @collection, pipeline)
      |> Enum.map(&document_to_telemetry/1)

    {:ok, telemetries}
  end

  defp to_float(val) when is_binary(val) do
    case Float.parse(val) do
      {f, _} -> f
      :error -> val
    end
  end

  defp to_float(val) when is_number(val), do: val * 1.0
  defp to_float(val), do: val

  defp document_to_telemetry(doc) do
    bson_id = Map.get(doc, "_id")
    string_id = if bson_id, do: BSON.ObjectId.encode!(bson_id), else: nil

    station_bson = Map.get(doc, "station_id")

    station_id =
      case station_bson do
        %BSON.ObjectId{} = object_id -> BSON.ObjectId.encode!(object_id)
        other -> other
      end

    {:ok, telemetry} =
      WeatherFlow.Domain.Telemetry.new(%{
        "id" => string_id,
        "station_id" => station_id,
        "metrics" => Map.get(doc, "metrics"),
        "timestamp" => Map.get(doc, "timestamp")
      })

    telemetry
  end
end
