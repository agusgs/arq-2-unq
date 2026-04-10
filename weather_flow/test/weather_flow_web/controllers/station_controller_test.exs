defmodule WeatherFlowWeb.StationControllerTest do
  use WeatherFlowWeb.ConnCase, async: false

  alias WeatherFlow.Adapters.MongoStationRepository

  setup do
    Mongo.delete_many!(:mongo, "stations", %{})
    MongoStationRepository.setup_indexes()
    :ok
  end

  describe "POST /api/stations" do
    test "crea exitosamente una estación y la retorna codificada en JSON", %{conn: conn} do
      payload = %{"station" => %{"name" => "Estación Test API", "latitude" => -34.0, "longitude" => -58.0}}
      conn = post(conn, "/api/stations", payload)
      
      response = json_response(conn, 201)
      assert response["name"] == "Estación Test API"
      assert response["latitude"] == -34.0
      assert response["longitude"] == -58.0
      assert is_binary(response["id"])
    end

    test "retorna 400 Bad Request si faltan parámetros del dominio", %{conn: conn} do
      payload = %{"station" => %{"latitude" => -34.0, "longitude" => -58.0}} # Sin name
      conn = post(conn, "/api/stations", payload)

      assert %{"error" => "Los parámetros name, latitude y longitude son obligatorios."} = json_response(conn, 400)
    end
  end

  describe "GET /api/stations" do
    test "retorna todas las estaciones en un arreglo", %{conn: conn} do
      post(conn, "/api/stations", %{"station" => %{"name" => "S1", "latitude" => 1.0, "longitude" => 1.0}})
      post(conn, "/api/stations", %{"station" => %{"name" => "S2", "latitude" => 2.0, "longitude" => 2.0}})

      conn = get(conn, "/api/stations")
      stations_list = json_response(conn, 200)
      assert length(stations_list) == 2
    end
  end

  describe "GET /api/stations/:id" do
    test "retorna 200 y el objeto si la estación es encontrada", %{conn: conn} do
      conn_created = post(conn, "/api/stations", %{"station" => %{"name" => "Buscada", "latitude" => 1.0, "longitude" => 1.0}})
      id = json_response(conn_created, 201)["id"]

      conn_show = get(conn, "/api/stations/#{id}")
      assert json_response(conn_show, 200)["name"] == "Buscada"
    end

    test "retorna 404 No Encontrado si le pasamos un ID invalido", %{conn: conn} do
      conn = get(conn, "/api/stations/inexistente")
      assert %{"error" => "Estación no encontrada."} = json_response(conn, 404)
    end
  end
end
