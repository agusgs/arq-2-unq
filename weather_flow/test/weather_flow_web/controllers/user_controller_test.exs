defmodule WeatherFlowWeb.UserControllerTest do
  use WeatherFlowWeb.ConnCase, async: false

  describe "POST /api/users" do
    test "crea exitosamente un usuario devolviendo JSON de creacion", %{conn: conn} do
      payload = %{"first_name" => "Juan", "last_name" => "Pérez", "email" => "juan@test.com"}
      conn = post(conn, "/api/users", payload)

      response = json_response(conn, 201)
      assert response["email"] == "juan@test.com"
      assert is_binary(response["id"])
      assert response["subscriptions"] == []
    end
  end

  describe "GET /api/users" do
    test "lista los usuarios registrados en un arreglo", %{conn: conn} do
      post(conn, "/api/users", %{
        "first_name" => "U1",
        "last_name" => "L1",
        "email" => "u1@test.com"
      })

      conn_get = get(conn, "/api/users")
      assert [%{"email" => "u1@test.com"}] = json_response(conn_get, 200)
    end
  end

  describe "GET /api/users/:id" do
    test "devuelve 404 para ID inexistente", %{conn: conn} do
      conn = get(conn, "/api/users/invalido")
      assert %{"error" => "Usuario no encontrado."} = json_response(conn, 404)
    end

    test "retorna la entidad codificada si el usuario existe", %{conn: conn} do
      conn_created =
        post(conn, "/api/users", %{
          "first_name" => "U",
          "last_name" => "L",
          "email" => "u_show@test.com"
        })

      user_id = json_response(conn_created, 201)["id"]

      conn_show = get(conn, "/api/users/#{user_id}")
      assert json_response(conn_show, 200)["email"] == "u_show@test.com"
    end
  end

  describe "PUT /api/users/:id" do
    test "actualiza correctamente los datos del usuario", %{conn: conn} do
      conn_created =
        post(conn, "/api/users", %{
          "first_name" => "F1",
          "last_name" => "L1",
          "email" => "uput@test.com"
        })

      user_id = json_response(conn_created, 201)["id"]

      conn_update = put(conn, "/api/users/#{user_id}", %{"first_name" => "F2"})
      assert json_response(conn_update, 200)["first_name"] == "F2"
    end
  end

  describe "DELETE /api/users/:id" do
    test "borra correctamente el usuario devolviendo 204", %{conn: conn} do
      conn_created =
        post(conn, "/api/users", %{
          "first_name" => "FD",
          "last_name" => "LD",
          "email" => "udel@test.com"
        })

      user_id = json_response(conn_created, 201)["id"]

      conn_delete = delete(conn, "/api/users/#{user_id}")
      assert response(conn_delete, 204)

      conn_get = get(conn, "/api/users/#{user_id}")
      assert json_response(conn_get, 404)
    end
  end
end
