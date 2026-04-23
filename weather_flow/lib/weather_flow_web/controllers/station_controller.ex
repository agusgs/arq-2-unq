defmodule WeatherFlowWeb.StationController do
  use WeatherFlowWeb, :controller
  use OpenApiSpex.ControllerSpecs

  alias WeatherFlow.Application.Services.StationManagementService
  alias WeatherFlow.Domain.Station

  tags(["Stations"])

  operation(:index,
    summary: "Lista todas las estaciones",
    description: "Recupera un arreglo con todas las estaciones registradas.",
    responses: [
      ok:
        {"Lista de estaciones devuelta con éxito", "application/json",
         %OpenApiSpex.Schema{type: :array, items: WeatherFlowWeb.Schemas.Station}}
    ]
  )

  def index(conn, _params) do
    {:ok, stations} = StationManagementService.list_stations()
    stations_map = Enum.map(stations, &station_to_map/1)

    conn
    |> put_status(:ok)
    |> json(stations_map)
  end

  operation(:create,
    summary: "Registra una nueva estación",
    description: "Guarda una nueva estación meteorológica validando las coordenadas y nombre.",
    request_body:
      {"Payload de la estación", "application/json", WeatherFlowWeb.Schemas.StationRequest,
       required: true},
    responses: [
      created:
        {"Estación registrada correctamente", "application/json", WeatherFlowWeb.Schemas.Station},
      bad_request:
        {"Error de validación del dominio o infraestructura", "application/json",
         %OpenApiSpex.Schema{
           type: :object,
           properties: %{error: %OpenApiSpex.Schema{type: :string}}
         }}
    ]
  )

  def create(conn, %{"station" => station_params}) do
    case StationManagementService.register_station(station_params) do
      {:ok, %Station{} = station} ->
        conn
        |> put_status(:created)
        |> json(station_to_map(station))

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end

  operation(:show,
    summary: "Obtiene una estación por ID",
    description: "Recupera los datos de una estación buscando por su ObjectID hexadecimal.",
    parameters: [
      id: [in: :path, description: "ID de la estación", type: :string, required: true]
    ],
    responses: [
      ok: {"Estación encontrada", "application/json", WeatherFlowWeb.Schemas.Station},
      not_found:
        {"Estación no encontrada", "application/json",
         %OpenApiSpex.Schema{
           type: :object,
           properties: %{error: %OpenApiSpex.Schema{type: :string}}
         }}
    ]
  )

  def show(conn, %{"id" => id}) do
    case StationManagementService.get_station(id) do
      {:ok, %Station{} = station} ->
        conn
        |> put_status(:ok)
        |> json(station_to_map(station))

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Estación no encontrada."})
    end
  end

  operation(:update,
    summary: "Actualiza una estación",
    description: "Modifica nombre o coordenadas de una estación existente.",
    parameters: [
      id: [in: :path, description: "ID de la estación", type: :string, required: true]
    ],
    request_body: {"Nuevos datos", "application/json", WeatherFlowWeb.Schemas.StationRequest},
    responses: [
      ok: {"Estación actualizada", "application/json", WeatherFlowWeb.Schemas.Station},
      not_found: "Estación no encontrada",
      bad_request: "Error de validación"
    ]
  )

  def update(conn, %{"id" => id, "station" => station_params}) do
    case StationManagementService.update_station(id, station_params) do
      {:ok, %Station{} = station} ->
        conn
        |> put_status(:ok)
        |> json(station_to_map(station))

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Estación no encontrada."})

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: reason})
    end
  end

  operation(:delete,
    summary: "Elimina una estación lógicamente",
    description: "Realiza un soft-delete de la estación.",
    parameters: [
      id: [in: :path, description: "ID de la estación", type: :string, required: true]
    ],
    responses: [
      no_content: "Estación borrada",
      not_found: "Estación no encontrada"
    ]
  )

  def delete(conn, %{"id" => id}) do
    case StationManagementService.delete_station(id) do
      :ok ->
        send_resp(conn, :no_content, "")

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "Estación no encontrada."})
    end
  end

  # Helper para sanear la entidad de Dominio a un Mapa serializable por Jason
  defp station_to_map(station) do
    %{
      id: station.id,
      name: station.name,
      latitude: station.latitude,
      longitude: station.longitude
    }
  end
end
