defmodule WeatherFlow.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias WeatherFlow.Adapters.{
    MongoAlertRepository,
    MongoStationRepository,
    MongoTelemetryRepository,
    MongoUserRepository
  }

  @impl true
  def start(_type, _args) do
    mongo_config =
      Application.get_env(:weather_flow, :mongo) ||
        [database: "weather_flow", url: "mongodb://localhost:27017", pool_size: 1]

    children = [
      WeatherFlowWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:weather_flow, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: WeatherFlow.PubSub},
      {Mongo,
       [
         name: :mongo,
         database: mongo_config[:database],
         url: mongo_config[:url],
         pool_size: mongo_config[:pool_size] || 2
       ]},
      WeatherFlow.Application.Workers.AlertEngine,
      WeatherFlowWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WeatherFlow.Supervisor]
    result = Supervisor.start_link(children, opts)

    if match?({:ok, _}, result) do
      Task.start(fn ->
        MongoUserRepository.setup_indexes()
        MongoStationRepository.setup_indexes()
        MongoTelemetryRepository.setup_indexes()
        MongoAlertRepository.setup_indexes()
      end)
    end

    result
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WeatherFlowWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
