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
end
