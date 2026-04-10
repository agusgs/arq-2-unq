defmodule WeatherFlow.Adapters.MongoStationRepository do
  @moduledoc """
  Implementación en MongoDB para el repositorio de estaciones.
  """
  @behaviour WeatherFlow.Ports.StationRepository

  alias WeatherFlow.Domain.Station

  @collection "stations"

  def setup_indexes() do
    command = [
      createIndexes: @collection,
      indexes: [
        [key: [name: 1], name: "name_unique_index", unique: true]
      ]
    ]

    Mongo.command(:mongo, command)
  end

  @impl true
  def insert(%Station{} = station) do
    # Generamos explicitamente un ID de MongoDB (ObjectId) nuevo
    bson_id = Mongo.object_id()

    doc = %{
      "_id" => bson_id,
      "name" => station.name,
      "latitude" => station.latitude,
      "longitude" => station.longitude
    }

    case Mongo.insert_one(:mongo, @collection, doc) do
      {:ok, _result} ->
        string_id = BSON.ObjectId.encode!(bson_id)
        {:ok, %{station | id: string_id}}

      {:error, %Mongo.WriteError{write_errors: [%{"code" => 11000} | _]}} ->
        {:error, :name_already_registered}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def get_by_id(id) when is_binary(id) do
    bson_id = BSON.ObjectId.decode!(id)

    case Mongo.find_one(:mongo, @collection, %{"_id" => bson_id}) do
      nil -> {:error, :not_found}
      doc -> {:ok, document_to_station(doc)}
    end
  rescue
    MatchError -> {:error, :not_found}
    ArgumentError -> {:error, :not_found}
    FunctionClauseError -> {:error, :not_found}
  end

  @impl true
  def list_all() do
    cursor = Mongo.find(:mongo, @collection, %{})

    stations =
      cursor
      |> Enum.to_list()
      |> Enum.map(&document_to_station/1)

    {:ok, stations}
  end

  defp document_to_station(doc) do
    bson_id = Map.get(doc, "_id")
    string_id = BSON.ObjectId.encode!(bson_id)

    %Station{
      id: string_id,
      name: Map.get(doc, "name"),
      latitude: Map.get(doc, "latitude"),
      longitude: Map.get(doc, "longitude")
    }
  end
end
