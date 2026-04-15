defmodule WeatherFlow.Adapters.MongoUserRepository do
  @behaviour WeatherFlow.Ports.UserRepository

  alias WeatherFlow.Domain.User

  @collection "users"

  def setup_indexes() do
    command = [
      createIndexes: @collection,
      indexes: [
        [key: [email: 1], name: "email_unique_index", unique: true]
      ]
    ]

    Mongo.command(:mongo, command)
  end

  @impl true
  def insert(%User{} = user) do
    doc = user_to_document(user)

    case Mongo.insert_one(:mongo, @collection, doc) do
      {:ok, %Mongo.InsertOneResult{inserted_id: bson_id}} ->
        string_id = BSON.ObjectId.encode!(bson_id)
        {:ok, %{user | id: string_id}}

      {:error, %Mongo.WriteError{write_errors: [%{"code" => 11000} | _]}} ->
        {:error, :email_already_registered}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def get_by_id(id) when is_binary(id) do
    bson_id = BSON.ObjectId.decode!(id)

    case Mongo.find_one(:mongo, @collection, %{"_id" => bson_id}) do
      nil -> {:error, :not_found}
      doc -> {:ok, document_to_user(doc)}
    end
  rescue
    MatchError -> {:error, :not_found}
    ArgumentError -> {:error, :not_found}
    FunctionClauseError -> {:error, :not_found}
  end

  @impl true
  def get_by_email(email) do
    case Mongo.find_one(:mongo, @collection, %{"email" => email}) do
      nil -> {:error, :not_found}
      doc -> {:ok, document_to_user(doc)}
    end
  end

  @impl true
  def get_all() do
    Mongo.find(:mongo, @collection, %{})
    |> Enum.to_list()
    |> Enum.map(&document_to_user/1)
  end

  @impl true
  def update(%User{id: id} = user) when is_binary(id) do
    bson_id = BSON.ObjectId.decode!(id)
    doc = user_to_document(user)

    case Mongo.update_one(:mongo, @collection, %{"_id" => bson_id}, %{"$set" => doc}) do
      {:ok, _result} ->
        {:ok, user}

      {:error, %Mongo.WriteError{write_errors: [%{"code" => 11000} | _]}} ->
        {:error, :email_already_registered}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def update(%User{id: nil}), do: {:error, :missing_id}

  defp user_to_document(%User{} = user) do
    %{
      "first_name" => user.first_name,
      "last_name" => user.last_name,
      "email" => user.email,
      "subscriptions" => user.subscriptions
    }
  end

  defp document_to_user(
         %{"_id" => bson_id, "first_name" => first, "last_name" => last, "email" => email} = doc
       ) do
    string_id = BSON.ObjectId.encode!(bson_id)

    %User{
      id: string_id,
      first_name: first,
      last_name: last,
      email: email,
      subscriptions: Map.get(doc, "subscriptions", [])
    }
  end
end
