defmodule WeatherFlow.DataCase do
  @moduledoc """
  Este módulo define el caso de prueba para interactuar con la capa de datos (MongoDB).

  Garantiza que la base de datos se limpia completamente antes de cada test para
  garantizar un entorno aislado determinista.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      import WeatherFlow.DataCase
    end
  end

  setup _tags do
    WeatherFlow.DataCase.setup_db()
    :ok
  end

  alias WeatherFlow.Adapters.{
    MongoAlertRepository,
    MongoStationRepository,
    MongoTelemetryRepository,
    MongoUserRepository
  }

  @doc """
  Limpia todas las colecciones y regenera los índices básicos.
  """
  def setup_db do
    Mongo.delete_many!(:mongo, "users", %{})
    Mongo.delete_many!(:mongo, "stations", %{})
    Mongo.delete_many!(:mongo, "telemetries", %{})
    Mongo.delete_many!(:mongo, "alerts", %{})

    MongoUserRepository.setup_indexes()
    MongoStationRepository.setup_indexes()
    MongoTelemetryRepository.setup_indexes()
    MongoAlertRepository.setup_indexes()

    :ok
  end
end
