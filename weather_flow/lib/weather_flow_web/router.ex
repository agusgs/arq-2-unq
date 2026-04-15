defmodule WeatherFlowWeb.Router do
  use WeatherFlowWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
    plug OpenApiSpex.Plug.PutApiSpec, module: WeatherFlowWeb.ApiSpec
  end

  scope "/api", WeatherFlowWeb do
    pipe_through :api

    get "/users", UserController, :index
    post "/users", UserController, :create
    get "/users/:id", UserController, :show

    get "/stations", StationController, :index
    post "/stations", StationController, :create
    get "/stations/:id", StationController, :show

    post "/users/:user_id/subscriptions", SubscriptionController, :create
    delete "/users/:user_id/subscriptions/:station_id", SubscriptionController, :delete
  end

  # Swagger UI y Spec Routes
  scope "/api" do
    pipe_through :api

    get "/openapi", OpenApiSpex.Plug.RenderSpec, default: WeatherFlowWeb.ApiSpec
    get "/swaggerui", OpenApiSpex.Plug.SwaggerUI, path: "/api/openapi"
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:weather_flow, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: WeatherFlowWeb.Telemetry
    end
  end
end
