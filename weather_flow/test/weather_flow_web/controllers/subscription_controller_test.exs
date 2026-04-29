defmodule WeatherFlowWeb.SubscriptionControllerTest do
  use WeatherFlowWeb.ConnCase, async: false

  alias WeatherFlow.Adapters.{MongoStationRepository, MongoUserRepository}
  alias WeatherFlow.Domain.{Station, User}

  setup do
    {:ok, %User{} = valid_user} =
      MongoUserRepository.insert(%User{
        first_name: "John",
        last_name: "Doe",
        email: "sub_test@test.com",
        subscriptions: []
      })

    {:ok, %Station{} = valid_station} =
      MongoStationRepository.insert(%Station{
        name: "BaseAntartica",
        latitude: -90.0,
        longitude: 0.0
      })

    {:ok, user: valid_user, station: valid_station}
  end

  describe "POST /api/users/:user_id/subscriptions" do
    test "Retorna 200 y el usuario modificado cuando la subscripción es exitosa", %{
      conn: conn,
      user: user,
      station: station
    } do
      payload = %{"station_id" => station.id}
      conn = post(conn, ~p"/api/users/#{user.id}/subscriptions", payload)

      response = json_response(conn, 200)
      assert response["email"] == user.email
      assert response["subscriptions"] == [station.id]
    end

    test "Retorna 404 Not Found si el usuario no existe", %{conn: conn, station: station} do
      payload = %{"station_id" => station.id}
      conn = post(conn, ~p"/api/users/invalido/subscriptions", payload)

      assert %{"error" => "El usuario o la estación especificada no existe."} =
               json_response(conn, 404)
    end
  end

  describe "DELETE /api/users/:user_id/subscriptions/:station_id" do
    test "Retorna 200 y desuscribe si existia el vinculo", %{
      conn: conn,
      user: user,
      station: station
    } do
      post(conn, ~p"/api/users/#{user.id}/subscriptions", %{"station_id" => station.id})

      conn_del = delete(conn, ~p"/api/users/#{user.id}/subscriptions/#{station.id}")

      response = json_response(conn_del, 200)
      assert response["subscriptions"] == []
    end

    test "Retorna 404 Not Found si el usuario no existe", %{conn: conn, station: station} do
      conn_del = delete(conn, ~p"/api/users/invalido/subscriptions/#{station.id}")
      assert %{"error" => "Usuario no encontrado."} = json_response(conn_del, 404)
    end
  end
end
