defmodule WeatherFlowWeb.SubscriptionController do
  use WeatherFlowWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias WeatherFlow.Application.Services.SubscriptionManagementService
  alias WeatherFlowWeb.Schemas.User

  tags(["Subscriptions"])

  operation(:create,
    summary: "Suscribir usuario a una estación",
    description:
      "Vincula permanentemente una estación climática al seguimiento personal de un usuario.",
    parameters: [
      user_id: [in: :path, description: "ID del usuario", type: :string, required: true]
    ],
    request_body:
      {"ID de la estación", "application/json", WeatherFlowWeb.Schemas.SubscriptionRequest,
       required: true},
    responses: [
      ok: {"Suscripción agregada retornando usuario actualizado", "application/json", User},
      bad_request:
        {"Error", "application/json",
         %OpenApiSpex.Schema{
           type: :object,
           properties: %{error: %OpenApiSpex.Schema{type: :string}}
         }},
      not_found:
        {"Usuario o Estación no encontrados", "application/json",
         %OpenApiSpex.Schema{
           type: :object,
           properties: %{error: %OpenApiSpex.Schema{type: :string}}
         }}
    ]
  )

  def create(conn, %{"user_id" => user_id, "station_id" => station_id}) do
    case SubscriptionManagementService.subscribe(user_id, station_id) do
      {:ok, user} ->
        conn
        |> put_status(:ok)
        |> json(user_to_map(user))

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "El usuario o la estación especificada no existe."})

      {:error, :internal_error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Error interno: #{inspect(reason)}"})
    end
  end

  operation(:delete,
    summary: "Desuscribir de una estación",
    description: "Rompe el vínculo entre un usuario y cierta estación.",
    parameters: [
      user_id: [in: :path, description: "ID del usuario", type: :string, required: true],
      station_id: [in: :path, description: "ID de la estación", type: :string, required: true]
    ],
    responses: [
      ok: {"Suscripción removida exitosamente", "application/json", User},
      bad_request:
        {"Error", "application/json",
         %OpenApiSpex.Schema{
           type: :object,
           properties: %{error: %OpenApiSpex.Schema{type: :string}}
         }},
      not_found:
        {"Usuario no encontrado", "application/json",
         %OpenApiSpex.Schema{
           type: :object,
           properties: %{error: %OpenApiSpex.Schema{type: :string}}
         }}
    ]
  )

  def delete(conn, %{"user_id" => user_id, "station_id" => station_id}) do
    case SubscriptionManagementService.unsubscribe(user_id, station_id) do
      {:ok, user} ->
        conn
        |> put_status(:ok)
        |> json(user_to_map(user))

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Usuario no encontrado."})

      {:error, :internal_error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Error interno: #{inspect(reason)}"})
    end
  end

  defp user_to_map(user) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      subscriptions: user.subscriptions
    }
  end
end
