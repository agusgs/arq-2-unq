defmodule WeatherFlowWeb.UserController do
  use WeatherFlowWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias WeatherFlow.Application.Services.UserManagementService
  alias WeatherFlowWeb.Schemas.{User, UserRequest}

  tags ["Users"]

  operation :create,
    summary: "Registrar un usuario",
    request_body: {"Atributos del User", "application/json", UserRequest},
    responses: [
      created: {"Usuario registrado exitosamente", "application/json", User},
      bad_request: "Error de validación (faltan campos) o email duplicado"
    ]

  def create(conn, params) do
    # Dejamos la orquestación en manos del Application Service (Use Case)
    case UserManagementService.register_user(params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(user_to_map(user))

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end

  operation :index,
    summary: "Listar los usuarios registrados",
    responses: [
      ok: {"Lista array de todos los Usuarios", "application/json", %OpenApiSpex.Schema{type: :array, items: User}}
    ]

  def index(conn, _params) do
    users = UserManagementService.list_users() |> Enum.map(&user_to_map/1)
    json(conn, users)
  end

  operation :show,
    summary: "Obtener un usuario por ID",
    parameters: [
      id: [in: :path, description: "ID del usuario", type: :string, required: true]
    ],
    responses: [
      ok: {"Usuario encontrado", "application/json", User},
      not_found: "Usuario no encontrado"
    ]

  def show(conn, %{"id" => id}) do
    case UserManagementService.get_user(id) do
      {:ok, user} ->
        conn
        |> put_status(:ok)
        |> json(user_to_map(user))

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Usuario no encontrado."})
    end
  end

  # Helper para sanear la entidad de Dominio a Mapa JSON-friendly
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
