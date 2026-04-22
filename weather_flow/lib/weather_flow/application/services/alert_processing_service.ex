defmodule WeatherFlow.Application.Services.AlertProcessingService do
  @moduledoc """
  Servicio orquestador encargado de coordinar la evaluación
  de las métricas de telemetría, persistir las alertas resultantes y notificar a los usuarios.
  """
  require Logger

  alias WeatherFlow.Domain.Alert
  alias WeatherFlow.Adapters.MongoAlertRepository
  alias WeatherFlow.Adapters.MongoUserRepository

  def process_telemetry(telemetry) do
    Enum.each(telemetry.metrics, fn {metric_name, value} ->
      eval_metric(telemetry, metric_name, value)
    end)
  end

  defp eval_metric(telemetry, metric_name, value) do
    case WeatherFlow.Domain.AlertRules.evaluate(metric_name, value) do
      {:ok, alerts} ->
        Enum.each(alerts, fn message ->
          trigger_alert(telemetry, metric_name, value, message)
        end)

      {:unsupported, unsupported_metric} ->
        Logger.warning(
          "Ignorando métrica no soportada durante evaluación de alertas: #{unsupported_metric}"
        )
    end
  end

  defp trigger_alert(telemetry, metric, value, message) do
    Logger.warning("ANOMALIA DETECTADA: [Station: #{telemetry.station_id}] #{message} (#{value})")

    {:ok, alert} =
      Alert.new(%{
        "station_id" => telemetry.station_id,
        "metric" => metric,
        "value" => value,
        "message" => message,
        "timestamp" => telemetry.timestamp
      })

    case MongoAlertRepository.insert(alert) do
      {:ok, _saved_alert} ->
        notify_users(telemetry.station_id, message)

      {:error, reason} ->
        Logger.error("Error al persistir la alerta: #{inspect(reason)}")
    end
  end

  defp notify_users(station_id, message) do
    users = MongoUserRepository.get_users_subscribed_to(station_id)

    Enum.each(users, fn user ->
      Logger.info("-> Notificando a #{user.email} (Usuario ID: #{user.id}): #{message}")
    end)
  end
end
