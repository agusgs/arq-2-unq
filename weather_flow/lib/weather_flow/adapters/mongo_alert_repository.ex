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
    doc = %{
      "station_id" => alert.station_id,
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
    cursor =
      Mongo.find(:mongo, @collection, %{"station_id" => station_id}, sort: %{"timestamp" => -1})

    alerts =
      Enum.map(cursor, fn doc ->
        id = BSON.ObjectId.encode!(doc["_id"])

        {:ok, alert} =
          Alert.new(%{
            "id" => id,
            "station_id" => doc["station_id"],
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
