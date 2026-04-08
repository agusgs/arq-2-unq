import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :weather_flow, WeatherFlowWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "A6RLrnoTycpHEL1LLjah6MUFrMYJGwx4t2mVNkXtZcP/R+pRrqp5F1JXvmE3NzO8",
  server: false

config :weather_flow, :mongo,
  database: "weather_flow_test",
  url: "mongodb://localhost:27017",
  pool_size: 1

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Sort query params output of verified routes for robust url comparisons
config :phoenix,
  sort_verified_routes_query_params: true
