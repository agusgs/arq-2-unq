defmodule WeatherFlow.Domain.UserTest do
  use ExUnit.Case, async: true
  alias WeatherFlow.Domain.User

  describe "new/1" do
    test "crea una estructura de usuario válida a partir de un mapa completo" do
      attrs = %{"first_name" => "Agustin", "last_name" => "Garcia", "email" => "agus@example.com"}
      assert {:ok, user} = User.new(attrs)
      assert user.first_name == "Agustin"
      assert user.email == "agus@example.com"
      assert user.subscriptions == []
    end

    test "falla si falta el first_name" do
      assert {:error, "first_name, last_name y email son requeridos y deben ser un string"} =
               User.new(%{"last_name" => "Garcia", "email" => "agus@example.com"})
    end

    test "falla si falta el last_name" do
      assert {:error, "first_name, last_name y email son requeridos y deben ser un string"} =
               User.new(%{"first_name" => "Agustin", "email" => "agus@example.com"})
    end

    test "falla si falta el email" do
      assert {:error, "first_name, last_name y email son requeridos y deben ser un string"} =
               User.new(%{"first_name" => "Agustin", "last_name" => "Garcia"})
    end
  end

  describe "subscribe/2 y unsubscribe/2" do
    setup do
      {:ok, user} =
        User.new(%{"first_name" => "Test", "last_name" => "User", "email" => "test@example.com"})

      {:ok, user: user}
    end

    test "subscribe/2 añade el station_id al array inmutablemente", %{user: user} do
      updated_user = User.subscribe(user, "station_123")
      assert updated_user.subscriptions == ["station_123"]
      # El original no muta
      assert user.subscriptions == []
    end

    test "subscribe/2 ignora la adición si el station_id ya existe (idempotencia)", %{user: user} do
      u1 = User.subscribe(user, "st_1")
      u2 = User.subscribe(u1, "st_1")
      assert length(u2.subscriptions) == 1
    end

    test "unsubscribe/2 elimina correctamente la estación", %{user: user} do
      u1 = User.subscribe(user, "st_test")
      u2 = User.unsubscribe(u1, "st_test")
      assert u2.subscriptions == []
    end
  end
end
