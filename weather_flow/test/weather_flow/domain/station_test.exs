defmodule WeatherFlow.Domain.StationTest do
  use ExUnit.Case, async: true

  alias WeatherFlow.Domain.Station

  describe "new/1" do
    test "crea una estructura de estación válida cuando los parámetros son correctos" do
      attrs = %{"name" => "Estación Central", "latitude" => -34.6037, "longitude" => -58.3816}

      assert {:ok, %Station{} = station} = Station.new(attrs)
      assert station.name == "Estación Central"
      assert station.latitude == -34.6037
      assert station.longitude == -58.3816
      assert station.id == nil
    end

    test "acepta valores enteros en lat y lon y los convierte a float" do
       attrs = %{"name" => "Estación Numérica", "latitude" => 10, "longitude" => -20}

       assert {:ok, %Station{} = station} = Station.new(attrs)
       assert station.latitude === 10.0
       assert station.longitude === -20.0
    end

    test "retorna error si falta algún parámetro obligatorio" do
      assert {:error, "Los parámetros name, latitude y longitude son obligatorios."} = Station.new(%{"name" => "Algo"})
      assert {:error, "Los parámetros name, latitude y longitude son obligatorios."} = Station.new(%{"latitude" => 10.0, "longitude" => 20.0})
    end

    test "retorna error si el nombre está vacío o nulo" do
      attrs_vacio = %{"name" => "   ", "latitude" => 10.0, "longitude" => 10.0}
      assert {:error, "El nombre de la estación es obligatorio."} = Station.new(attrs_vacio)
    end

    test "retorna error si la latitud no es un número" do
      attrs = %{"name" => "Estación", "latitude" => "10.0", "longitude" => 10.0}
      assert {:error, "La latitud debe ser un número."} = Station.new(attrs)
    end

    test "retorna error si la longitud no es un número" do
      attrs = %{"name" => "Estación", "latitude" => 10.0, "longitude" => "10.0"}
      assert {:error, "La longitud debe ser un número."} = Station.new(attrs)
    end

    test "retorna error si la latitud está fuera de los límites" do
      assert {:error, "La latitud debe estar comprendida entre -90.0 y 90.0 grados."} =
               Station.new(%{"name" => "Estación", "latitude" => 90.1, "longitude" => 0.0})

      assert {:error, "La latitud debe estar comprendida entre -90.0 y 90.0 grados."} =
               Station.new(%{"name" => "Estación", "latitude" => -90.1, "longitude" => 0.0})
    end

    test "retorna error si la longitud está fuera de los límites" do
      assert {:error, "La longitud debe estar comprendida entre -180.0 y 180.0 grados."} =
               Station.new(%{"name" => "Estación", "latitude" => 0.0, "longitude" => 180.1})

      assert {:error, "La longitud debe estar comprendida entre -180.0 y 180.0 grados."} =
               Station.new(%{"name" => "Estación", "latitude" => 0.0, "longitude" => -180.1})
    end
  end
end
