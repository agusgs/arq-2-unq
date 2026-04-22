defmodule WeatherFlow.Domain.AlertRules do
  @moduledoc """
  Motor de Reglas para evaluar anomalías climáticas.
  """

  @supported_metrics ["temperature", "pressure", "humidity"]

  @rules [
    %{
      metric: "temperature",
      operator: :gt,
      threshold: 40.0,
      message: "Alerta de calor extremo detectada."
    },
    %{
      metric: "temperature",
      operator: :lt,
      threshold: 0.0,
      message: "Alerta de helada detectada."
    },
    %{
      metric: "pressure",
      operator: :lt,
      threshold: 980.0,
      message: "Alerta de tormenta/baja presión detectada."
    },
    %{
      metric: "humidity",
      operator: :gt,
      threshold: 90.0,
      message: "Alerta de humedad crítica detectada."
    }
  ]

  @doc """
  Evalúa el valor de una métrica individual contra las directivas conocidas.
  - Retorna `{:ok, [mensajes]}` si generó matches.
  - Retorna `{:unsupported, metric}` si ingresa un tipo de sensor que desconocemos por diseño.
  """
  def evaluate(metric_name, value) do
    if metric_name in @supported_metrics do
      alerts =
        @rules
        |> Enum.filter(
          &(&1.metric == metric_name and match_condition?(&1.operator, value, &1.threshold))
        )
        |> Enum.map(& &1.message)

      {:ok, alerts}
    else
      {:unsupported, metric_name}
    end
  end

  defp match_condition?(:gt, value, threshold) when is_number(value), do: value > threshold
  defp match_condition?(:lt, value, threshold) when is_number(value), do: value < threshold
  defp match_condition?(_, _value, _threshold), do: false
end
