defmodule WeatherFlow.Adapters.MongoAlertRepository do
  @behaviour WeatherFlow.Ports.AlertRepository

  alias WeatherFlow.Domain.Alert

  @collection "alerts"

  def setup_indexes() do
    Mongo.command(:mongo,
      createIndexes: @collection,
      indexes: [
        %{
          key: %{"station_id" => 1, "timestamp" => -1},
          name: "station_id_timestamp_idx"
        }
      ]
    )
  end

  @impl true
  def insert(%Alert{} = alert) do
    bson_station_id = BSON.ObjectId.decode!(alert.station_id)

    doc = %{
      "station_id" => bson_station_id,
      "metric" => alert.metric,
      "value" => alert.value,
      "message" => alert.message,
      "timestamp" => alert.timestamp
    }

    case Mongo.insert_one(:mongo, @collection, doc) do
      {:ok, %Mongo.InsertOneResult{inserted_id: bson_id}} ->
        {:ok, %{alert | id: BSON.ObjectId.encode!(bson_id)}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def get_by_station_id(station_id) do
    bson_station_id = BSON.ObjectId.decode!(station_id)

    cursor =
      Mongo.find(:mongo, @collection, %{"station_id" => bson_station_id}, sort: %{"timestamp" => -1})

    alerts =
      Enum.map(cursor, fn doc ->
        id = BSON.ObjectId.encode!(doc["_id"])

        station_str = BSON.ObjectId.encode!(doc["station_id"])

        {:ok, alert} =
          Alert.new(%{
            "id" => id,
            "station_id" => station_str,
            "metric" => doc["metric"],
            "value" => doc["value"],
            "message" => doc["message"],
            "timestamp" => doc["timestamp"]
          })

        alert
      end)

    {:ok, alerts}
  end
end
