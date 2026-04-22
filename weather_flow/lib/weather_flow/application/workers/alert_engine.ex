defmodule WeatherFlow.Application.Workers.AlertEngine do
  @moduledoc """
  Proceso en background (GenServer) encarcado de analizar en tiempo real
  todo el flujo de telemetría que ingresa al sistema y generar disparos de Alertas
  evaluando reglas de negocio, notificando luego a los usuarios.
  """
  use GenServer
  require Logger

  @topic "telemetry_stream"

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    Phoenix.PubSub.subscribe(WeatherFlow.PubSub, @topic)

    Logger.info(
      "AlertEngine ha iniciado y suscripto a #{@topic} exitosamente. Esperando métricas..."
    )

    {:ok, state}
  end

  @impl true
  def handle_info({:telemetry_inserted, telemetry}, state) do
    WeatherFlow.Application.Services.AlertProcessingService.process_telemetry(telemetry)
    {:noreply, state}
  end
end
